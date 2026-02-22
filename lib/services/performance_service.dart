// ============================================================================
// MUSCLE POWER - Performance Monitoring Service
// ============================================================================
//
// File: performance_service.dart
// Description: Tracks app performance indicators including cold/warm start
//              times, frame rendering/jank detection, and network latency.
//
// Key Metrics Tracked:
// - Cold Start Time: Time from process creation to first frame rendered
// - Warm Start Time: Time from app resume to UI ready
// - Frame Rendering: FPS, jank frames, frame build/raster times
// - Network Latency: Request/response times, error rates, throughput
//
// Service Level Objectives (SLOs):
// - Cold start < 3000ms (target: < 2000ms)
// - Warm start < 1500ms (target: < 800ms)
// - Frame rate >= 55 FPS (target: 60 FPS)
// - Jank rate < 5% of frames
// - Network p95 latency < 2000ms
// - Network error rate < 2%
//
// ============================================================================

import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// =============================================================================
// PERFORMANCE DATA MODELS
// =============================================================================

/// Represents a single frame timing measurement
class FrameTimingData {
  final DateTime timestamp;
  final Duration buildDuration;
  final Duration rasterDuration;
  final Duration totalDuration;
  final bool isJank;

  FrameTimingData({
    required this.timestamp,
    required this.buildDuration,
    required this.rasterDuration,
    required this.totalDuration,
    required this.isJank,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'buildMs': buildDuration.inMicroseconds / 1000.0,
        'rasterMs': rasterDuration.inMicroseconds / 1000.0,
        'totalMs': totalDuration.inMicroseconds / 1000.0,
        'isJank': isJank,
      };

  factory FrameTimingData.fromJson(Map<String, dynamic> json) {
    return FrameTimingData(
      timestamp: DateTime.parse(json['timestamp']),
      buildDuration: Duration(microseconds: ((json['buildMs'] as num) * 1000).round()),
      rasterDuration: Duration(microseconds: ((json['rasterMs'] as num) * 1000).round()),
      totalDuration: Duration(microseconds: ((json['totalMs'] as num) * 1000).round()),
      isJank: json['isJank'] as bool,
    );
  }
}

/// Represents a network request measurement
class NetworkRequestMetric {
  final String url;
  final String method;
  final int statusCode;
  final Duration latency;
  final int requestSizeBytes;
  final int responseSizeBytes;
  final bool isError;
  final DateTime timestamp;
  final String? errorMessage;

  NetworkRequestMetric({
    required this.url,
    required this.method,
    required this.statusCode,
    required this.latency,
    required this.requestSizeBytes,
    required this.responseSizeBytes,
    required this.isError,
    required this.timestamp,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'method': method,
        'statusCode': statusCode,
        'latencyMs': latency.inMilliseconds,
        'requestSizeBytes': requestSizeBytes,
        'responseSizeBytes': responseSizeBytes,
        'isError': isError,
        'timestamp': timestamp.toIso8601String(),
        'errorMessage': errorMessage,
      };

  factory NetworkRequestMetric.fromJson(Map<String, dynamic> json) {
    return NetworkRequestMetric(
      url: json['url'] as String,
      method: json['method'] as String,
      statusCode: json['statusCode'] as int,
      latency: Duration(milliseconds: json['latencyMs'] as int),
      requestSizeBytes: json['requestSizeBytes'] as int,
      responseSizeBytes: json['responseSizeBytes'] as int,
      isError: json['isError'] as bool,
      timestamp: DateTime.parse(json['timestamp']),
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

/// Startup timing record
class StartupMetric {
  final DateTime timestamp;
  final Duration duration;
  final bool isColdStart;

  StartupMetric({
    required this.timestamp,
    required this.duration,
    required this.isColdStart,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'durationMs': duration.inMilliseconds,
        'isColdStart': isColdStart,
      };

  factory StartupMetric.fromJson(Map<String, dynamic> json) {
    return StartupMetric(
      timestamp: DateTime.parse(json['timestamp']),
      duration: Duration(milliseconds: json['durationMs'] as int),
      isColdStart: json['isColdStart'] as bool,
    );
  }
}

/// Aggregated performance summary
class PerformanceSummary {
  // Startup metrics
  final double avgColdStartMs;
  final double avgWarmStartMs;
  final double p95ColdStartMs;
  final double p95WarmStartMs;
  final int totalColdStarts;
  final int totalWarmStarts;

  // Frame metrics
  final double avgFps;
  final double jankRate;
  final int totalFrames;
  final int jankFrames;
  final double avgFrameBuildMs;
  final double avgFrameRasterMs;
  final double p95FrameDurationMs;

  // Network metrics
  final double avgNetworkLatencyMs;
  final double p50NetworkLatencyMs;
  final double p95NetworkLatencyMs;
  final double networkErrorRate;
  final int totalRequests;
  final int failedRequests;
  final double avgThroughputBytesPerSec;

  // SLO compliance
  final bool coldStartSloMet;
  final bool warmStartSloMet;
  final bool fpsSloMet;
  final bool jankSloMet;
  final bool networkLatencySloMet;
  final bool networkErrorSloMet;
  final double overallSloCompliance;

  PerformanceSummary({
    required this.avgColdStartMs,
    required this.avgWarmStartMs,
    required this.p95ColdStartMs,
    required this.p95WarmStartMs,
    required this.totalColdStarts,
    required this.totalWarmStarts,
    required this.avgFps,
    required this.jankRate,
    required this.totalFrames,
    required this.jankFrames,
    required this.avgFrameBuildMs,
    required this.avgFrameRasterMs,
    required this.p95FrameDurationMs,
    required this.avgNetworkLatencyMs,
    required this.p50NetworkLatencyMs,
    required this.p95NetworkLatencyMs,
    required this.networkErrorRate,
    required this.totalRequests,
    required this.failedRequests,
    required this.avgThroughputBytesPerSec,
    required this.coldStartSloMet,
    required this.warmStartSloMet,
    required this.fpsSloMet,
    required this.jankSloMet,
    required this.networkLatencySloMet,
    required this.networkErrorSloMet,
    required this.overallSloCompliance,
  });
}

// =============================================================================
// PERFORMANCE SERVICE (SINGLETON)
// =============================================================================

/// Core service for tracking and analyzing app performance metrics.
///
/// Implements the singleton pattern for consistent global access.
/// Monitors cold/warm starts, frame rendering, jank, and network performance.
///
/// Usage:
/// ```dart
/// final perf = PerformanceService();
/// await perf.init();
/// perf.startFrameMonitoring();
/// perf.recordNetworkRequest(...);
/// final summary = perf.getSummary();
/// ```
class PerformanceService {
  // ========================================
  // SINGLETON PATTERN
  // ========================================
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // ========================================
  // SLO THRESHOLDS
  // ========================================
  static const double coldStartSloMs = 3000.0;
  static const double coldStartTargetMs = 2000.0;
  static const double warmStartSloMs = 1500.0;
  static const double warmStartTargetMs = 800.0;
  static const double fpsSlO = 55.0;
  static const double fpsTarget = 60.0;
  static const double jankRateSlo = 0.05; // 5%
  static const double jankRateTarget = 0.02; // 2%
  static const double networkLatencyP95SloMs = 2000.0;
  static const double networkLatencyP95TargetMs = 1000.0;
  static const double networkErrorRateSlo = 0.02; // 2%
  static const double networkErrorRateTarget = 0.005; // 0.5%

  // Jank threshold: > 16.67ms per frame (target 60fps)
  static const double _jankThresholdMs = 16.67;

  // ========================================
  // DATA STORAGE
  // ========================================
  final List<StartupMetric> _startupMetrics = [];
  final Queue<FrameTimingData> _frameTimings = Queue<FrameTimingData>();
  final List<NetworkRequestMetric> _networkMetrics = [];

  // Keep last 1000 frame timings in memory
  static const int _maxFrameTimings = 1000;
  // Keep last 500 network requests in memory
  static const int _maxNetworkMetrics = 500;

  bool _initialized = false;
  bool _frameMonitoringActive = false;
  DateTime? _lastResumeTime;

  // Stream controller for real-time performance updates
  final StreamController<PerformanceSummary> _summaryController =
      StreamController<PerformanceSummary>.broadcast();

  /// Stream of performance summaries for real-time dashboard updates
  Stream<PerformanceSummary> get summaryStream => _summaryController.stream;

  // Periodic summary timer
  Timer? _summaryTimer;

  // ========================================
  // INITIALIZATION
  // ========================================

  /// Initialize the performance service.
  ///
  /// Loads persisted metrics, records cold start time, and begins
  /// periodic summary emission.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _loadPersistedMetrics();

    // Emit summaries every 10 seconds
    _summaryTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _emitSummary();
    });
  }

  /// Record the cold start completion time.
  ///
  /// Call this once the first frame has been rendered after a fresh app launch.
  void recordColdStart(Duration duration) {
    final metric = StartupMetric(
      timestamp: DateTime.now(),
      duration: duration,
      isColdStart: true,
    );
    _startupMetrics.add(metric);
    _persistMetrics();
    _emitSummary();
  }

  /// Record a warm start (app resume) completion time.
  ///
  /// Call this when the app resumes from background and the UI is ready.
  void recordWarmStart(Duration duration) {
    final metric = StartupMetric(
      timestamp: DateTime.now(),
      duration: duration,
      isColdStart: false,
    );
    _startupMetrics.add(metric);
    _persistMetrics();
    _emitSummary();
  }

  /// Mark the beginning of an app resume (warm start).
  void markResumeStart() {
    _lastResumeTime = DateTime.now();
  }

  /// Mark the end of an app resume and record the warm start metric.
  void markResumeEnd() {
    if (_lastResumeTime != null) {
      final duration = DateTime.now().difference(_lastResumeTime!);
      recordWarmStart(duration);
      _lastResumeTime = null;
    }
  }

  // ========================================
  // FRAME MONITORING
  // ========================================

  /// Start monitoring frame rendering performance.
  ///
  /// Uses [SchedulerBinding.addTimingsCallback] to receive frame timing data.
  /// Detects jank by comparing frame duration against the 16.67ms threshold.
  void startFrameMonitoring() {
    if (_frameMonitoringActive) return;
    _frameMonitoringActive = true;

    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  /// Stop frame monitoring.
  void stopFrameMonitoring() {
    if (!_frameMonitoringActive) return;
    _frameMonitoringActive = false;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildDuration = Duration(
        microseconds: timing.buildDuration.inMicroseconds,
      );
      final rasterDuration = Duration(
        microseconds: timing.rasterDuration.inMicroseconds,
      );
      final totalDuration = Duration(
        microseconds: timing.totalSpan.inMicroseconds,
      );
      final isJank =
          totalDuration.inMicroseconds > (_jankThresholdMs * 1000);

      final data = FrameTimingData(
        timestamp: DateTime.now(),
        buildDuration: buildDuration,
        rasterDuration: rasterDuration,
        totalDuration: totalDuration,
        isJank: isJank,
      );

      _frameTimings.addLast(data);
      while (_frameTimings.length > _maxFrameTimings) {
        _frameTimings.removeFirst();
      }
    }
  }

  // ========================================
  // NETWORK MONITORING
  // ========================================

  /// Record a network request metric.
  ///
  /// Call this after each API request completes (success or failure).
  void recordNetworkRequest({
    required String url,
    required String method,
    required int statusCode,
    required Duration latency,
    int requestSizeBytes = 0,
    int responseSizeBytes = 0,
    String? errorMessage,
  }) {
    final isError = statusCode >= 400 || errorMessage != null;

    final metric = NetworkRequestMetric(
      url: url,
      method: method,
      statusCode: statusCode,
      latency: latency,
      requestSizeBytes: requestSizeBytes,
      responseSizeBytes: responseSizeBytes,
      isError: isError,
      timestamp: DateTime.now(),
      errorMessage: errorMessage,
    );

    _networkMetrics.add(metric);
    if (_networkMetrics.length > _maxNetworkMetrics) {
      _networkMetrics.removeAt(0);
    }
    _persistMetrics();
  }

  /// Convenience wrapper that times a network call and records the metric.
  ///
  /// Usage:
  /// ```dart
  /// final response = await perf.trackNetworkCall(
  ///   url: 'https://api.example.com/workouts',
  ///   method: 'GET',
  ///   call: () => http.get(Uri.parse('https://api.example.com/workouts')),
  /// );
  /// ```
  Future<T> trackNetworkCall<T>({
    required String url,
    required String method,
    required Future<T> Function() call,
    int Function(T)? getStatusCode,
    int Function(T)? getResponseSize,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await call();
      stopwatch.stop();
      recordNetworkRequest(
        url: url,
        method: method,
        statusCode: getStatusCode?.call(result) ?? 200,
        latency: stopwatch.elapsed,
        responseSizeBytes: getResponseSize?.call(result) ?? 0,
      );
      return result;
    } catch (e) {
      stopwatch.stop();
      recordNetworkRequest(
        url: url,
        method: method,
        statusCode: 0,
        latency: stopwatch.elapsed,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  // ========================================
  // SUMMARY & ANALYTICS
  // ========================================

  /// Get the current performance summary with SLO compliance checks.
  PerformanceSummary getSummary() {
    // Startup metrics
    final coldStarts =
        _startupMetrics.where((m) => m.isColdStart).toList();
    final warmStarts =
        _startupMetrics.where((m) => !m.isColdStart).toList();

    final avgColdMs = coldStarts.isEmpty
        ? 0.0
        : coldStarts.map((m) => m.duration.inMilliseconds).reduce((a, b) => a + b) /
            coldStarts.length;
    final avgWarmMs = warmStarts.isEmpty
        ? 0.0
        : warmStarts.map((m) => m.duration.inMilliseconds).reduce((a, b) => a + b) /
            warmStarts.length;
    final p95ColdMs = _percentile(
        coldStarts.map((m) => m.duration.inMilliseconds.toDouble()).toList(), 95);
    final p95WarmMs = _percentile(
        warmStarts.map((m) => m.duration.inMilliseconds.toDouble()).toList(), 95);

    // Frame metrics
    final frameList = _frameTimings.toList();
    final jankFrameCount = frameList.where((f) => f.isJank).length;
    final totalFrameCount = frameList.length;
    final jankRate = totalFrameCount == 0 ? 0.0 : jankFrameCount / totalFrameCount;

    final avgBuildMs = frameList.isEmpty
        ? 0.0
        : frameList
                .map((f) => f.buildDuration.inMicroseconds / 1000.0)
                .reduce((a, b) => a + b) /
            frameList.length;
    final avgRasterMs = frameList.isEmpty
        ? 0.0
        : frameList
                .map((f) => f.rasterDuration.inMicroseconds / 1000.0)
                .reduce((a, b) => a + b) /
            frameList.length;
    final p95FrameMs = _percentile(
        frameList
            .map((f) => f.totalDuration.inMicroseconds / 1000.0)
            .toList(),
        95);

    final avgFps = frameList.isEmpty
        ? 60.0
        : 1000.0 /
            max(
                1.0,
                frameList
                        .map((f) => f.totalDuration.inMicroseconds / 1000.0)
                        .reduce((a, b) => a + b) /
                    frameList.length);

    // Network metrics
    final totalRequests = _networkMetrics.length;
    final failedRequests = _networkMetrics.where((n) => n.isError).length;
    final networkErrorRate =
        totalRequests == 0 ? 0.0 : failedRequests / totalRequests;

    final latencies =
        _networkMetrics.map((n) => n.latency.inMilliseconds.toDouble()).toList();
    final avgLatencyMs = latencies.isEmpty
        ? 0.0
        : latencies.reduce((a, b) => a + b) / latencies.length;
    final p50LatencyMs = _percentile(latencies, 50);
    final p95LatencyMs = _percentile(latencies, 95);

    final totalBytes = _networkMetrics.fold<int>(
        0, (sum, n) => sum + n.responseSizeBytes);
    final timeSpanSec = _networkMetrics.length >= 2
        ? _networkMetrics.last.timestamp
                .difference(_networkMetrics.first.timestamp)
                .inSeconds
                .toDouble()
                .clamp(1.0, double.infinity)
        : 1.0;
    final avgThroughput = totalBytes / timeSpanSec;

    // SLO checks
    final coldSloMet = coldStarts.isEmpty || p95ColdMs <= coldStartSloMs;
    final warmSloMet = warmStarts.isEmpty || p95WarmMs <= warmStartSloMs;
    final fpsMet = avgFps >= fpsSlO;
    final jankMet = jankRate <= jankRateSlo;
    final netLatMet = totalRequests == 0 || p95LatencyMs <= networkLatencyP95SloMs;
    final netErrMet = networkErrorRate <= networkErrorRateSlo;

    final sloChecks = [coldSloMet, warmSloMet, fpsMet, jankMet, netLatMet, netErrMet];
    final sloCompliance =
        sloChecks.where((s) => s).length / sloChecks.length;

    return PerformanceSummary(
      avgColdStartMs: avgColdMs,
      avgWarmStartMs: avgWarmMs,
      p95ColdStartMs: p95ColdMs,
      p95WarmStartMs: p95WarmMs,
      totalColdStarts: coldStarts.length,
      totalWarmStarts: warmStarts.length,
      avgFps: avgFps.clamp(0.0, 120.0),
      jankRate: jankRate,
      totalFrames: totalFrameCount,
      jankFrames: jankFrameCount,
      avgFrameBuildMs: avgBuildMs,
      avgFrameRasterMs: avgRasterMs,
      p95FrameDurationMs: p95FrameMs,
      avgNetworkLatencyMs: avgLatencyMs,
      p50NetworkLatencyMs: p50LatencyMs,
      p95NetworkLatencyMs: p95LatencyMs,
      networkErrorRate: networkErrorRate,
      totalRequests: totalRequests,
      failedRequests: failedRequests,
      avgThroughputBytesPerSec: avgThroughput,
      coldStartSloMet: coldSloMet,
      warmStartSloMet: warmSloMet,
      fpsSloMet: fpsMet,
      jankSloMet: jankMet,
      networkLatencySloMet: netLatMet,
      networkErrorSloMet: netErrMet,
      overallSloCompliance: sloCompliance,
    );
  }

  /// Get recent frame timings for chart rendering
  List<FrameTimingData> getRecentFrameTimings({int count = 100}) {
    final list = _frameTimings.toList();
    return list.length <= count ? list : list.sublist(list.length - count);
  }

  /// Get recent network metrics for chart rendering
  List<NetworkRequestMetric> getRecentNetworkMetrics({int count = 50}) {
    return _networkMetrics.length <= count
        ? List.from(_networkMetrics)
        : _networkMetrics.sublist(_networkMetrics.length - count);
  }

  /// Get startup metrics history
  List<StartupMetric> getStartupMetrics() => List.from(_startupMetrics);

  // ========================================
  // HELPER METHODS
  // ========================================

  double _percentile(List<double> values, int percentile) {
    if (values.isEmpty) return 0.0;
    final sorted = List<double>.from(values)..sort();
    final index = ((percentile / 100.0) * (sorted.length - 1)).round();
    return sorted[index.clamp(0, sorted.length - 1)];
  }

  void _emitSummary() {
    if (!_summaryController.isClosed) {
      _summaryController.add(getSummary());
    }
  }

  // ========================================
  // PERSISTENCE
  // ========================================

  Future<void> _persistMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Persist last 50 startup metrics
      final startupJson = _startupMetrics
          .reversed
          .take(50)
          .map((m) => m.toJson())
          .toList()
          .reversed
          .toList();
      await prefs.setString('perf_startup_metrics', jsonEncode(startupJson));

      // Persist last 100 network metrics
      final networkJson = _networkMetrics
          .reversed
          .take(100)
          .map((m) => m.toJson())
          .toList()
          .reversed
          .toList();
      await prefs.setString('perf_network_metrics', jsonEncode(networkJson));
    } catch (_) {
      // Silently fail - performance data is non-critical
    }
  }

  Future<void> _loadPersistedMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final startupStr = prefs.getString('perf_startup_metrics');
      if (startupStr != null) {
        final list = jsonDecode(startupStr) as List;
        _startupMetrics.addAll(
            list.map((j) => StartupMetric.fromJson(j as Map<String, dynamic>)));
      }

      final networkStr = prefs.getString('perf_network_metrics');
      if (networkStr != null) {
        final list = jsonDecode(networkStr) as List;
        _networkMetrics.addAll(list
            .map((j) => NetworkRequestMetric.fromJson(j as Map<String, dynamic>)));
      }
    } catch (_) {
      // Silently fail on load errors
    }
  }

  /// Clear all performance data
  Future<void> clearAll() async {
    _startupMetrics.clear();
    _frameTimings.clear();
    _networkMetrics.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('perf_startup_metrics');
    await prefs.remove('perf_network_metrics');
    _emitSummary();
  }

  /// Dispose resources
  void dispose() {
    _summaryTimer?.cancel();
    stopFrameMonitoring();
    _summaryController.close();
  }
}
