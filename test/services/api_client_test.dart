// ============================================================================
// MUSCLE POWER - API Client Tests
// ============================================================================
//
// Coverage targets: api_client.dart
// Tests: rate limiting, offline queueing, error handling, request/response
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiClient singleton', () {
    test('returns same instance', () {
      final a = ApiClient();
      final b = ApiClient();
      expect(identical(a, b), isTrue);
    });
  });

  group('ApiRequest / ApiResponse shapes', () {
    test('ApiRequest serialises to JSON envelope', () {
      const req = ApiRequest(
        data: {'email': 'test@test.com'},
        meta: {'clientVersion': '1.0.0'},
      );
      final json = req.toJson();
      expect(json['data'], isA<Map>());
      expect(json['meta'], isA<Map>());
      expect(json['data']['email'], 'test@test.com');
    });

    test('ApiResponse parses from JSON', () {
      final resp = ApiResponse.fromJson({
        'status': 'ok',
        'data': {'id': 1},
        'meta': {'requestId': '123'},
      });
      expect(resp.status, 'ok');
      expect(resp.data['id'], 1);
      expect(resp.meta?['requestId'], '123');
    });

    test('ApiResponse handles missing fields gracefully', () {
      final resp = ApiResponse.fromJson({});
      expect(resp.status, 'ok');
      expect(resp.data, isEmpty);
    });
  });

  group('ApiException', () {
    test('parses from error JSON', () {
      final ex = ApiException.fromJson(422, {
        'error': {
          'code': 'VALIDATION_FAILED',
          'message': 'Email is required',
          'details': ['email'],
        },
      });
      expect(ex.statusCode, 422);
      expect(ex.code, 'VALIDATION_FAILED');
      expect(ex.message, 'Email is required');
      expect(ex.details, contains('email'));
    });

    test('toString includes status and code', () {
      const ex = ApiException(
        statusCode: 500,
        code: 'INTERNAL',
        message: 'Server error',
      );
      expect(ex.toString(), contains('500'));
      expect(ex.toString(), contains('INTERNAL'));
    });
  });

  group('Rate limiting', () {
    test('allows requests under the limit', () async {
      final client = ApiClient();
      // Should not throw for first request
      final resp = await client.request('GET', '/test-rate-limit-${DateTime.now().millisecondsSinceEpoch}');
      expect(resp.status, isNotEmpty);
    });

    test('throws ApiException(429) when rate limit exceeded', () async {
      final client = ApiClient();
      final path = '/rate-test-${DateTime.now().millisecondsSinceEpoch}';

      // Exhaust the rate limit
      for (int i = 0; i < 60; i++) {
        await client.request('GET', path);
      }

      // 61st request should throw
      expect(
        () => client.request('GET', path),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 429)),
      );
    });
  });

  group('Offline queueing', () {
    test('POST requests are queued when no baseUrl is set', () async {
      final client = ApiClient();
      client.baseUrl = null; // ensure local-only mode
      final initialQueueLen = client.offlineQueueLength;

      await client.request('POST', '/workouts/log', body: {'name': 'Push Day'});

      expect(client.offlineQueueLength, greaterThan(initialQueueLen));
    });

    test('GET requests are not queued offline', () async {
      final client = ApiClient();
      client.baseUrl = null;
      final before = client.offlineQueueLength;

      await client.request('GET', '/exercises');

      expect(client.offlineQueueLength, before);
    });

    test('queued response has status "queued" with offline meta', () async {
      final client = ApiClient();
      client.baseUrl = null;

      final resp = await client.post('/test', {'x': 1});
      expect(resp.status, 'queued');
      expect(resp.meta?['offline'], true);
    });
  });

  group('Auth token management', () {
    test('setAccessToken and clearAccessToken work', () {
      final client = ApiClient();
      client.setAccessToken('abc123');
      client.clearAccessToken();
      // No exception means pass — token is private
    });
  });

  group('Convenience methods', () {
    test('get, post, put, delete return ApiResponse', () async {
      final client = ApiClient();
      client.baseUrl = null;

      final getResp = await client.get('/test');
      expect(getResp.status, isNotEmpty);

      final postResp = await client.post('/test', {'a': 1});
      expect(postResp.status, isNotEmpty);

      final putResp = await client.put('/test', {'a': 2});
      expect(putResp.status, isNotEmpty);

      final delResp = await client.delete('/test');
      expect(delResp.status, isNotEmpty);
    });
  });
}
