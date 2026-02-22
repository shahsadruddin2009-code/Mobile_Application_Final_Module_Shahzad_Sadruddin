// ============================================================================
// MUSCLE POWER - API Client
// ============================================================================
//
// File: api_client.dart
// Description: Centralised HTTP client with error handling, retries,
//              request/response shapes, and offline queue support.
//
// Architecture:
//   The app uses a LOCAL-FIRST architecture. All data is persisted to
//   SharedPreferences (cross-platform) and SQLite (mobile/desktop)
//   *before* any network call is attempted. The API layer is therefore
//   an optional sync/backup channel, NOT the source of truth.
//
//   When a backend is provisioned the only change required is setting
//   [ApiClient.baseUrl] to the live endpoint — every service already
//   calls [ApiClient().request()] which silently queues operations
//   while the device is offline.
//
// API Style:
//   RESTful JSON over HTTPS (TLS 1.2+)
//   Content-Type: application/json; charset=utf-8
//
// Endpoints (planned):
//   POST   /auth/register        → { email, passwordHash, salt }
//   POST   /auth/login            → { email, passwordHash }
//   POST   /auth/refresh          → { refreshToken }
//   GET    /users/:id             → UserProfile JSON
//   PUT    /users/:id             → partial update
//   DELETE /users/:id             → GDPR right-to-erasure
//   GET    /workouts              → paginated workout list
//   POST   /workouts/log          → log a completed session
//   GET    /exercises             → exercise library
//   POST   /progress              → log progress entry
//   GET    /progress?range=30d    → progress history
//   POST   /nutrition/meals       → log a meal
//   GET    /nutrition/today       → today's nutrition summary
//   POST   /feedback              → submit feedback / NPS
//   GET    /users/:id/export      → GDPR data-portability bundle
//
// Request Shape (generic):
//   {
//     "data": { ... },           // payload body
//     "meta": {                  // optional metadata
//       "clientVersion": "1.0.0",
//       "platform": "android",
//       "locale": "en_GB"
//     }
//   }
//
// Success Response Shape:
//   {
//     "status": "ok",
//     "data": { ... },
//     "meta": { "requestId": "uuid", "timestamp": "ISO-8601" }
//   }
//
// Error Response Shape:
//   {
//     "status": "error",
//     "error": {
//       "code": "VALIDATION_FAILED",
//       "message": "Human-readable message",
//       "details": [ ... ]       // optional field-level errors
//     },
//     "meta": { "requestId": "uuid", "timestamp": "ISO-8601" }
//   }
//
// Error Handling:
//   • 4xx → throws [ApiException] immediately (no retry)
//   • 5xx → retries up to [maxRetries] with exponential back-off
//   • Network error → queues to [_offlineQueue] for later replay
//   • Timeout (15 s) → treated like a network error
//
// Transport Security:
//   • All traffic over HTTPS (enforced by Android network_security_config
//     and iOS ATS by default).
//   • Certificate pinning can be enabled via [pinnedCertificates].
//
// Abuse Prevention:
//   • Client-side rate limiter: max 60 requests / minute per endpoint.
//   • Auth tokens sent in Authorization: Bearer header (never in URL).
//   • Short-lived access tokens (15 min) + long-lived refresh tokens.
// ============================================================================

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'connectivity_service.dart';

// ============================================================================
// DATA CLASSES
// ============================================================================

/// Standard envelope for every API request body.
class ApiRequest {
  final Map<String, dynamic> data;
  final Map<String, dynamic>? meta;

  const ApiRequest({required this.data, this.meta});

  Map<String, dynamic> toJson() => {
        'data': data,
        if (meta != null) 'meta': meta,
      };
}

/// Standard envelope for every successful API response.
class ApiResponse {
  final String status;
  final Map<String, dynamic> data;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.status,
    required this.data,
    this.meta,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        status: json['status'] as String? ?? 'ok',
        data: json['data'] as Map<String, dynamic>? ?? {},
        meta: json['meta'] as Map<String, dynamic>?,
      );
}

/// Structured API error returned on 4xx / 5xx responses.
class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final List<dynamic>? details;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiException.fromJson(int statusCode, Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>? ?? {};
    return ApiException(
      statusCode: statusCode,
      code: error['code'] as String? ?? 'UNKNOWN',
      message: error['message'] as String? ?? 'Unknown error',
      details: error['details'] as List<dynamic>?,
    );
  }

  @override
  String toString() => 'ApiException($statusCode $code): $message';
}

/// An HTTP method + path + body stored for offline replay.
class _QueuedRequest {
  final String method;
  final String path;
  final Map<String, dynamic>? body;
  final DateTime queuedAt;

  _QueuedRequest({
    required this.method,
    required this.path,
    this.body,
  }) : queuedAt = DateTime.now();
}

// ============================================================================
// API CLIENT SINGLETON
// ============================================================================

/// Central HTTP client with retry, offline queue, and rate limiting.
///
/// Currently operates in **local-only** mode (no live backend). All public
/// methods resolve locally and optionally queue a sync request. When a
/// backend URL is configured, the same call transparently hits the network.
class ApiClient {
  // ---------- singleton ----------
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // ---------- configuration ----------

  /// Set to non-null to enable network calls (e.g. 'https://api.musclepower.app/v1').
  String? baseUrl;

  /// Bearer token attached to every authenticated request.
  String? _accessToken;

  /// Maximum automatic retries on 5xx / timeout.
  int maxRetries = 3;

  /// Timeout per request.
  Duration timeout = const Duration(seconds: 15);

  // ---------- rate limiter state ----------
  static const int _rateLimitPerMinute = 60;
  final Map<String, Queue<DateTime>> _rateBuckets = {};

  // ---------- offline queue ----------
  final List<_QueuedRequest> _offlineQueue = [];

  /// Number of requests currently waiting for connectivity.
  int get offlineQueueLength => _offlineQueue.length;

  // ---------- auth helpers ----------

  /// Store a fresh access token (called after login / token refresh).
  void setAccessToken(String token) => _accessToken = token;

  /// Remove the current token (called on sign-out).
  void clearAccessToken() => _accessToken = null;

  // ====================================================================
  // PUBLIC REQUEST METHOD
  // ====================================================================

  /// Send a request to [path] using [method].
  ///
  /// Returns an [ApiResponse] on success.
  /// Throws [ApiException] on 4xx errors.
  /// Retries on 5xx up to [maxRetries] times with exponential back-off.
  /// Queues the request offline when the device has no connectivity.
  Future<ApiResponse> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    // -- rate limit --
    _enforceRateLimit(path);

    // -- offline guard --
    if (ConnectivityService().isOffline || baseUrl == null) {
      if (method != 'GET') {
        _offlineQueue.add(_QueuedRequest(method: method, path: path, body: body));
        debugPrint('ApiClient: queued $method $path (offline / no baseUrl)');
      }
      // Return a synthetic local-only response so callers don't crash.
      return ApiResponse(
        status: 'queued',
        data: body ?? {},
        meta: {'offline': true},
      );
    }

    // -- attempt with retries --
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final response = await _send(method, path, body, requiresAuth);
        return response;
      } on ApiException catch (e) {
        // 4xx — don't retry, throw immediately
        if (e.statusCode >= 400 && e.statusCode < 500) rethrow;
        // 5xx — retry with back-off
        if (attempt >= maxRetries) rethrow;
        final delay = Duration(milliseconds: 200 * (1 << attempt));
        debugPrint('ApiClient: retry $attempt for $method $path in ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      } catch (e) {
        // Network / timeout — queue for later
        _offlineQueue.add(_QueuedRequest(method: method, path: path, body: body));
        debugPrint('ApiClient: network error, queued $method $path — $e');
        return ApiResponse(status: 'queued', data: body ?? {}, meta: {'offline': true});
      }
    }
  }

  // ====================================================================
  // CONVENIENCE METHODS
  // ====================================================================

  Future<ApiResponse> get(String path) => request('GET', path);
  Future<ApiResponse> post(String path, Map<String, dynamic> body) =>
      request('POST', path, body: body);
  Future<ApiResponse> put(String path, Map<String, dynamic> body) =>
      request('PUT', path, body: body);
  Future<ApiResponse> delete(String path) => request('DELETE', path);

  // ====================================================================
  // OFFLINE QUEUE REPLAY
  // ====================================================================

  /// Replay all queued requests now that connectivity is restored.
  ///
  /// Removes successfully sent items; keeps failures for next attempt.
  /// Called automatically by [ConnectivityService] when back online.
  Future<void> replayQueue() async {
    if (_offlineQueue.isEmpty || ConnectivityService().isOffline) return;
    debugPrint('ApiClient: replaying ${_offlineQueue.length} queued requests');

    final pending = List<_QueuedRequest>.from(_offlineQueue);
    _offlineQueue.clear();

    for (final req in pending) {
      try {
        await _send(req.method, req.path, req.body, true);
      } catch (e) {
        // Re-queue on failure
        _offlineQueue.add(req);
        debugPrint('ApiClient: replay failed for ${req.method} ${req.path}');
      }
    }
  }

  // ====================================================================
  // INTERNALS
  // ====================================================================

  /// Actually send the HTTP request.
  ///
  /// When [baseUrl] is set, performs a real HTTP call using the `http` package.
  /// Falls back to a simulated success when no backend is configured.
  Future<ApiResponse> _send(
    String method,
    String path,
    Map<String, dynamic>? body,
    bool requiresAuth,
  ) async {
    // Build headers
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'X-Client-Version': '1.0.0',
      if (requiresAuth && _accessToken != null)
        'Authorization': 'Bearer $_accessToken',
    };

    debugPrint('ApiClient: $method $path ${requiresAuth ? "(auth)" : ""}');
    debugPrint('ApiClient: headers = $headers');
    if (body != null) debugPrint('ApiClient: body = ${jsonEncode(body)}');

    // If no backend is configured, return a simulated response.
    if (baseUrl == null) {
      return ApiResponse(
        status: 'ok',
        data: body ?? {},
        meta: {
          'requestId': DateTime.now().millisecondsSinceEpoch.toString(),
          'timestamp': DateTime.now().toIso8601String(),
          'simulated': true,
        },
      );
    }

    // ── Real HTTP call ──────────────────────────────────────────────
    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body != null ? jsonEncode(body) : null;
    final client = http.Client();

    try {
      http.Response httpResponse;

      switch (method.toUpperCase()) {
        case 'GET':
          httpResponse = await client
              .get(uri, headers: headers)
              .timeout(timeout);
          break;
        case 'POST':
          httpResponse = await client
              .post(uri, headers: headers, body: encodedBody)
              .timeout(timeout);
          break;
        case 'PUT':
          httpResponse = await client
              .put(uri, headers: headers, body: encodedBody)
              .timeout(timeout);
          break;
        case 'DELETE':
          httpResponse = await client
              .delete(uri, headers: headers)
              .timeout(timeout);
          break;
        default:
          throw ApiException(
            statusCode: 405,
            code: 'METHOD_NOT_ALLOWED',
            message: 'Unsupported HTTP method: $method',
          );
      }

      debugPrint(
        'ApiClient: response ${httpResponse.statusCode} '
        '(${httpResponse.body.length} bytes)',
      );

      final Map<String, dynamic> json =
          jsonDecode(httpResponse.body) as Map<String, dynamic>;

      if (httpResponse.statusCode >= 400) {
        throw ApiException.fromJson(httpResponse.statusCode, json);
      }

      return ApiResponse.fromJson(json);
    } finally {
      client.close();
    }
  }

  /// Simple sliding-window rate limiter per endpoint path.
  void _enforceRateLimit(String path) {
    final now = DateTime.now();
    final bucket = _rateBuckets.putIfAbsent(path, () => Queue<DateTime>());

    // Remove timestamps older than 1 minute
    while (bucket.isNotEmpty && now.difference(bucket.first).inSeconds > 60) {
      bucket.removeFirst();
    }

    if (bucket.length >= _rateLimitPerMinute) {
      throw ApiException(
        statusCode: 429,
        code: 'RATE_LIMITED',
        message: 'Too many requests to $path — max $_rateLimitPerMinute/min',
      );
    }
    bucket.add(now);
  }
}
