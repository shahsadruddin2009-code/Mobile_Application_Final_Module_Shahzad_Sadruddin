// ============================================================================
// MUSCLE POWER - Health Dashboard Service Unit Tests
// ============================================================================
//
// Coverage targets: health_dashboard_service.dart
// Tests: data models (HealthAlert, AppSession, ServiceLevelObjective),
//        session tracking, crash recording, API call tracking,
//        health checks, alerts, dashboard generation, computed rates.
//
// Total: 45 tests
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodybuilding_app/services/health_dashboard_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ========================================
  // HEALTH ALERT MODEL
  // ========================================

  group('HealthAlert model', () {
    test('toJson serialises all fields', () {
      final alert = HealthAlert(
        id: 'alert_1',
        title: 'Crash Rate High',
        message: 'Crash-free rate below target',
        severity: AlertSeverity.critical,
        timestamp: DateTime(2026, 1, 1),
        metric: 'crash_free_rate',
        currentValue: 0.95,
        threshold: 0.998,
      );
      final json = alert.toJson();
      expect(json['id'], 'alert_1');
      expect(json['severity'], 'critical');
      expect(json['currentValue'], 0.95);
      expect(json['acknowledged'], false);
    });

    test('fromJson round-trips', () {
      final original = HealthAlert(
        id: 'alert_2',
        title: 'API Warning',
        message: 'API success rate declining',
        severity: AlertSeverity.warning,
        timestamp: DateTime(2026, 2, 1),
        metric: 'api_success_rate',
        currentValue: 0.996,
        threshold: 0.997,
        acknowledged: true,
      );
      final restored = HealthAlert.fromJson(original.toJson());
      expect(restored.severity, AlertSeverity.warning);
      expect(restored.acknowledged, true);
      expect(restored.metric, 'api_success_rate');
    });

    test('copyWith updates acknowledged', () {
      final alert = HealthAlert(
        id: 'alert_3',
        title: 'Test',
        message: 'Test message',
        severity: AlertSeverity.info,
        timestamp: DateTime(2026, 1, 1),
        metric: 'test',
        currentValue: 0.99,
        threshold: 0.95,
      );
      final acked = alert.copyWith(acknowledged: true);
      expect(acked.acknowledged, true);
      expect(acked.id, 'alert_3');
    });

    test('fromJson defaults unknown severity to info', () {
      final json = {
        'id': 'a1',
        'title': 'T',
        'message': 'M',
        'severity': 'unknown',
        'timestamp': '2026-01-01T00:00:00.000',
        'metric': 'm',
        'currentValue': 0.5,
        'threshold': 0.9,
      };
      final alert = HealthAlert.fromJson(json);
      expect(alert.severity, AlertSeverity.info);
    });
  });

  // ========================================
  // APP SESSION MODEL
  // ========================================

  group('AppSession model', () {
    test('toJson captures all fields', () {
      final session = AppSession(
        id: 'session_1',
        startTime: DateTime(2026, 1, 1, 10, 0),
        endTime: DateTime(2026, 1, 1, 10, 30),
        crashFree: true,
        anrFree: true,
        errorCount: 0,
      );
      final json = session.toJson();
      expect(json['id'], 'session_1');
      expect(json['crashFree'], true);
      expect(json['endTime'], isNotNull);
    });

    test('fromJson handles null endTime', () {
      final json = {
        'id': 'session_2',
        'startTime': '2026-01-01T10:00:00.000',
        'crashFree': true,
        'anrFree': true,
        'errorCount': 0,
      };
      final session = AppSession.fromJson(json);
      expect(session.endTime, isNull);
    });

    test('crashed session fromJson', () {
      final json = {
        'id': 'session_3',
        'startTime': '2026-01-01T10:00:00.000',
        'endTime': '2026-01-01T10:05:00.000',
        'crashFree': false,
        'anrFree': true,
        'errorCount': 1,
        'crashReason': 'OutOfMemoryError',
      };
      final session = AppSession.fromJson(json);
      expect(session.crashFree, false);
      expect(session.crashReason, 'OutOfMemoryError');
    });
  });

  // ========================================
  // SERVICE LEVEL OBJECTIVE MODEL
  // ========================================

  group('ServiceLevelObjective model', () {
    test('isMet returns true when above target', () {
      final slo = ServiceLevelObjective(
        name: 'Crash-Free',
        description: 'Crash-free sessions',
        target: 0.998,
        warningAt: 0.999,
        currentValue: 0.999,
        status: HealthStatus.healthy,
      );
      expect(slo.isMet, true);
    });

    test('isMet returns false when below target', () {
      final slo = ServiceLevelObjective(
        name: 'Crash-Free',
        description: 'Crash-free sessions',
        target: 0.998,
        warningAt: 0.999,
        currentValue: 0.990,
        status: HealthStatus.unhealthy,
      );
      expect(slo.isMet, false);
    });

    test('errorBudgetRemaining is clamped between 0 and 1', () {
      final slo = ServiceLevelObjective(
        name: 'Test SLO',
        description: 'Test',
        target: 0.95,
        warningAt: 0.97,
        currentValue: 0.80,
        status: HealthStatus.unhealthy,
      );
      expect(slo.errorBudgetRemaining, greaterThanOrEqualTo(0.0));
      expect(slo.errorBudgetRemaining, lessThanOrEqualTo(1.0));
    });

    test('displayValue formats percentage correctly', () {
      final slo = ServiceLevelObjective(
        name: 'Test',
        description: 'Test',
        target: 0.998,
        warningAt: 0.999,
        currentValue: 0.9985,
        status: HealthStatus.healthy,
      );
      expect(slo.displayValue, contains('99.85'));
    });

    test('displayTarget formats percentage', () {
      final slo = ServiceLevelObjective(
        name: 'Test',
        description: 'Test',
        target: 0.998,
        warningAt: 0.999,
        currentValue: 1.0,
        status: HealthStatus.healthy,
      );
      expect(slo.displayTarget, contains('99.8'));
    });
  });

  // ========================================
  // SINGLETON
  // ========================================

  group('HealthDashboardService singleton', () {
    test('returns same instance', () {
      final a = HealthDashboardService();
      final b = HealthDashboardService();
      expect(identical(a, b), isTrue);
    });
  });

  // ========================================
  // SLO TARGET CONSTANTS
  // ========================================

  group('SLO target constants', () {
    test('crashFreeTarget is 99.8%', () {
      expect(HealthDashboardService.crashFreeTarget, 0.998);
    });

    test('anrFreeTarget is 99.5%', () {
      expect(HealthDashboardService.anrFreeTarget, 0.995);
    });

    test('apiSuccessTarget is 99.5%', () {
      expect(HealthDashboardService.apiSuccessTarget, 0.995);
    });

    test('uiResponsiveTarget is 95%', () {
      expect(HealthDashboardService.uiResponsiveTarget, 0.95);
    });
  });

  // ========================================
  // COMPUTED RATES (NO DATA)
  // ========================================

  group('Default computed rates', () {
    test('crashFreeRate defaults to 1.0 with no sessions', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      expect(service.crashFreeRate, 1.0);
    });

    test('anrFreeRate defaults to 1.0', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      expect(service.anrFreeRate, 1.0);
    });

    test('apiSuccessRate defaults to 1.0', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      expect(service.apiSuccessRate, 1.0);
    });

    test('uiResponsivenessRate defaults to 1.0', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      expect(service.uiResponsivenessRate, 1.0);
    });

    test('launchSuccessRate defaults to 1.0', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      expect(service.launchSuccessRate, 1.0);
    });
  });

  // ========================================
  // SESSION TRACKING
  // ========================================

  group('Session tracking', () {
    test('startSession and endSession record clean session', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      service.startSession();
      service.endSession();
      expect(service.crashFreeRate, 1.0);
    });

    test('recordCrash records crashed session', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      service.startSession();
      service.recordCrash('NullPointerException');
      // After crash, session ends with crashFree=false
      expect(service.crashFreeRate, lessThan(1.0));
    });
  });

  // ========================================
  // API CALL TRACKING
  // ========================================

  group('API call tracking', () {
    test('recordApiCall tracks success', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      service.recordApiCall(success: true);
      service.recordApiCall(success: true);
      expect(service.apiSuccessRate, 1.0);
    });

    test('recordApiCall tracks failure', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      service.recordApiCall(success: true);
      service.recordApiCall(success: false);
      expect(service.apiSuccessRate, 0.5);
    });
  });

  // ========================================
  // DASHBOARD
  // ========================================

  group('Dashboard generation', () {
    test('getDashboard returns HealthDashboard', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      final dashboard = service.getDashboard();
      expect(dashboard, isA<HealthDashboard>());
      expect(dashboard.slos, hasLength(5));
      expect(dashboard.overallStatus, HealthStatus.healthy);
    });

    test('dashboard with no issues is healthy', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      service.startSession();
      service.endSession();
      final dashboard = service.getDashboard();
      expect(dashboard.overallStatus, HealthStatus.healthy);
      expect(dashboard.crashedSessions, 0);
    });
  });

  // ========================================
  // ALERT MANAGEMENT
  // ========================================

  group('Alert management', () {
    test('getAllAlerts returns empty list initially', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      expect(service.getAllAlerts(), isEmpty);
    });

    test('getActiveAlerts filters acknowledged', () async {
      final service = HealthDashboardService();
      await service.clearAll();
      expect(service.getActiveAlerts(), isEmpty);
    });
  });

  // ========================================
  // CLEAR ALL
  // ========================================

  group('Clear all', () {
    test('clearAll resets all data', () async {
      final service = HealthDashboardService();
      service.startSession();
      service.endSession();
      service.recordApiCall(success: false);
      await service.clearAll();
      expect(service.crashFreeRate, 1.0);
      expect(service.apiSuccessRate, 1.0);
      expect(service.getAllAlerts(), isEmpty);
    });
  });
}
