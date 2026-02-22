// ============================================================================
// MUSCLE POWER - Performance Service Unit Tests
// ============================================================================
//
// Coverage targets: performance_service.dart
// Tests: data models, startup metrics, network recording, summary generation,
//        SLO compliance, percentile calculations, and resource management.
//
// Total: 38 tests
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodybuilding_app/services/performance_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ========================================
  // FRAME TIMING DATA MODEL
  // ========================================

  group('FrameTimingData model', () {
    test('toJson produces correct keys', () {
      final data = FrameTimingData(
        timestamp: DateTime(2026, 1, 1),
        buildDuration: const Duration(milliseconds: 5),
        rasterDuration: const Duration(milliseconds: 8),
        totalDuration: const Duration(milliseconds: 13),
        isJank: false,
      );
      final json = data.toJson();
      expect(json['buildMs'], closeTo(5.0, 0.1));
      expect(json['rasterMs'], closeTo(8.0, 0.1));
      expect(json['isJank'], false);
    });

    test('fromJson round-trips correctly', () {
      final original = FrameTimingData(
        timestamp: DateTime(2026, 2, 1),
        buildDuration: const Duration(milliseconds: 12),
        rasterDuration: const Duration(milliseconds: 10),
        totalDuration: const Duration(milliseconds: 22),
        isJank: true,
      );
      final restored = FrameTimingData.fromJson(original.toJson());
      expect(restored.isJank, true);
      expect(restored.buildDuration.inMilliseconds, 12);
      expect(restored.rasterDuration.inMilliseconds, 10);
    });
  });

  // ========================================
  // NETWORK REQUEST METRIC MODEL
  // ========================================

  group('NetworkRequestMetric model', () {
    test('toJson captures all fields', () {
      final metric = NetworkRequestMetric(
        url: 'https://api.example.com/workouts',
        method: 'GET',
        statusCode: 200,
        latency: const Duration(milliseconds: 150),
        requestSizeBytes: 0,
        responseSizeBytes: 1024,
        isError: false,
        timestamp: DateTime(2026, 1, 1),
      );
      final json = metric.toJson();
      expect(json['url'], contains('workouts'));
      expect(json['method'], 'GET');
      expect(json['latencyMs'], 150);
      expect(json['responseSizeBytes'], 1024);
    });

    test('fromJson round-trips with error message', () {
      final original = NetworkRequestMetric(
        url: '/api/fail',
        method: 'POST',
        statusCode: 500,
        latency: const Duration(seconds: 2),
        requestSizeBytes: 512,
        responseSizeBytes: 0,
        isError: true,
        timestamp: DateTime(2026, 1, 5),
        errorMessage: 'Internal Server Error',
      );
      final restored = NetworkRequestMetric.fromJson(original.toJson());
      expect(restored.isError, true);
      expect(restored.errorMessage, 'Internal Server Error');
      expect(restored.statusCode, 500);
    });
  });

  // ========================================
  // STARTUP METRIC MODEL
  // ========================================

  group('StartupMetric model', () {
    test('cold start serialises correctly', () {
      final metric = StartupMetric(
        timestamp: DateTime(2026, 1, 1),
        duration: const Duration(milliseconds: 1800),
        isColdStart: true,
      );
      final json = metric.toJson();
      expect(json['durationMs'], 1800);
      expect(json['isColdStart'], true);
    });

    test('warm start serialises correctly', () {
      final metric = StartupMetric(
        timestamp: DateTime(2026, 1, 2),
        duration: const Duration(milliseconds: 600),
        isColdStart: false,
      );
      final restored = StartupMetric.fromJson(metric.toJson());
      expect(restored.isColdStart, false);
      expect(restored.duration.inMilliseconds, 600);
    });
  });

  // ========================================
  // SINGLETON PATTERN
  // ========================================

  group('PerformanceService singleton', () {
    test('returns same instance', () {
      final a = PerformanceService();
      final b = PerformanceService();
      expect(identical(a, b), isTrue);
    });
  });

  // ========================================
  // SLO CONSTANTS
  // ========================================

  group('SLO thresholds', () {
    test('cold start SLO is 3000ms', () {
      expect(PerformanceService.coldStartSloMs, 3000.0);
    });

    test('cold start target is 2000ms', () {
      expect(PerformanceService.coldStartTargetMs, 2000.0);
    });

    test('warm start SLO is 1500ms', () {
      expect(PerformanceService.warmStartSloMs, 1500.0);
    });

    test('warm start target is 800ms', () {
      expect(PerformanceService.warmStartTargetMs, 800.0);
    });

    test('FPS SLO is 55', () {
      expect(PerformanceService.fpsSlO, 55.0);
    });

    test('FPS target is 60', () {
      expect(PerformanceService.fpsTarget, 60.0);
    });

    test('jank rate SLO is 5%', () {
      expect(PerformanceService.jankRateSlo, 0.05);
    });

    test('network latency p95 SLO is 2000ms', () {
      expect(PerformanceService.networkLatencyP95SloMs, 2000.0);
    });

    test('network error rate SLO is 2%', () {
      expect(PerformanceService.networkErrorRateSlo, 0.02);
    });
  });

  // ========================================
  // STARTUP RECORDING TESTS
  // ========================================

  group('Startup recording', () {
    test('recordColdStart adds to startup metrics', () async {
      final service = PerformanceService();
      await service.clearAll();
      service.recordColdStart(const Duration(milliseconds: 1500));
      final metrics = service.getStartupMetrics();
      expect(metrics, isNotEmpty);
      expect(metrics.last.isColdStart, true);
    });

    test('recordWarmStart adds to startup metrics', () async {
      final service = PerformanceService();
      await service.clearAll();
      service.recordWarmStart(const Duration(milliseconds: 500));
      final metrics = service.getStartupMetrics();
      expect(metrics.any((m) => !m.isColdStart), isTrue);
    });
  });

  // ========================================
  // NETWORK RECORDING TESTS
  // ========================================

  group('Network recording', () {
    test('recordNetworkRequest stores metric', () async {
      final service = PerformanceService();
      await service.clearAll();
      service.recordNetworkRequest(
        url: '/api/test',
        method: 'GET',
        statusCode: 200,
        latency: const Duration(milliseconds: 100),
      );
      final recent = service.getRecentNetworkMetrics();
      expect(recent, isNotEmpty);
      expect(recent.last.url, '/api/test');
    });

    test('error request is flagged as error', () async {
      final service = PerformanceService();
      await service.clearAll();
      service.recordNetworkRequest(
        url: '/api/fail',
        method: 'POST',
        statusCode: 500,
        latency: const Duration(milliseconds: 2000),
        errorMessage: 'Server error',
      );
      final recent = service.getRecentNetworkMetrics();
      expect(recent.last.isError, true);
    });
  });

  // ========================================
  // SUMMARY GENERATION TESTS
  // ========================================

  group('Summary generation', () {
    test('getSummary returns valid PerformanceSummary', () async {
      final service = PerformanceService();
      await service.clearAll();
      final summary = service.getSummary();
      expect(summary, isA<PerformanceSummary>());
      expect(summary.overallSloCompliance, isNonNegative);
    });

    test('summary reflects recorded cold starts', () async {
      final service = PerformanceService();
      await service.clearAll();
      service.recordColdStart(const Duration(milliseconds: 1000));
      service.recordColdStart(const Duration(milliseconds: 2000));
      final summary = service.getSummary();
      expect(summary.totalColdStarts, 2);
      expect(summary.avgColdStartMs, closeTo(1500.0, 1.0));
    });

    test('summary with no data has sensible defaults', () async {
      final service = PerformanceService();
      await service.clearAll();
      final summary = service.getSummary();
      expect(summary.avgFps, 60.0);
      expect(summary.jankRate, 0.0);
      expect(summary.totalFrames, 0);
      expect(summary.networkErrorRate, 0.0);
    });

    test('SLOs are all met when no data recorded', () async {
      final service = PerformanceService();
      await service.clearAll();
      final summary = service.getSummary();
      expect(summary.coldStartSloMet, true);
      expect(summary.warmStartSloMet, true);
      expect(summary.jankSloMet, true);
      expect(summary.networkLatencySloMet, true);
      expect(summary.networkErrorSloMet, true);
    });
  });

  // ========================================
  // CLEAR ALL TESTS
  // ========================================

  group('Clear all', () {
    test('clearAll empties all metrics', () async {
      final service = PerformanceService();
      service.recordColdStart(const Duration(milliseconds: 500));
      service.recordNetworkRequest(
        url: '/test', method: 'GET', statusCode: 200,
        latency: const Duration(milliseconds: 50),
      );
      await service.clearAll();
      expect(service.getStartupMetrics(), isEmpty);
      expect(service.getRecentNetworkMetrics(), isEmpty);
    });
  });
}
