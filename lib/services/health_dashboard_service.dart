// ============================================================================
// MUSCLE POWER - Health Dashboard & Alerts Service
// ============================================================================
//
// File: health_dashboard_service.dart
// Description: Monitors app health with SLOs, crash tracking, alerts,
//              and real-time health status dashboards.
//
// Service Level Objectives (SLOs):
// - Crash-Free Sessions: >= 99.8%
// - ANR-Free Sessions: >= 99.5%
// - API Success Rate: >= 99.5%
// - App Launch Success Rate: >= 99.9%
// - UI Responsiveness (no jank): >= 95%
//
// Alert Thresholds:
// - Critical: SLO violated (below minimum threshold)
// - Warning: Approaching SLO boundary (within 1% of threshold)
// - Info: Performance degradation detected
//
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// HEALTH DATA MODELS
// =============================================================================

/// Severity level for health alerts
enum AlertSeverity { info, warning, critical }

/// Current status of a health indicator
enum HealthStatus { healthy, degraded, unhealthy }

/// Represents a health alert triggered by SLO violation or degradation
class HealthAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final String metric;
  final double currentValue;
  final double threshold;
  final bool acknowledged;

  HealthAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    required this.metric,
    required this.currentValue,
    required this.threshold,
    this.acknowledged = false,
  });

  HealthAlert copyWith({bool? acknowledged}) {
    return HealthAlert(
      id: id,
      title: title,
      message: message,
      severity: severity,
      timestamp: timestamp,
      metric: metric,
      currentValue: currentValue,
      threshold: threshold,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'severity': severity.name,
        'timestamp': timestamp.toIso8601String(),
        'metric': metric,
        'currentValue': currentValue,
        'threshold': threshold,
        'acknowledged': acknowledged,
      };

  factory HealthAlert.fromJson(Map<String, dynamic> json) {
    return HealthAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.info,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      metric: json['metric'] as String,
      currentValue: (json['currentValue'] as num).toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
      acknowledged: json['acknowledged'] as bool? ?? false,
    );
  }
}

/// A single SLO definition with target and current status
class ServiceLevelObjective {
  final String name;
  final String description;
  final double target;       // e.g., 0.998 for 99.8%
  final double warningAt;    // e.g., 0.999 - warn when below this
  final double currentValue; // e.g., 0.9985
  final HealthStatus status;
  final String unit;

  ServiceLevelObjective({
    required this.name,
    required this.description,
    required this.target,
    required this.warningAt,
    required this.currentValue,
    required this.status,
    this.unit = '%',
  });

  /// Whether the SLO is currently met
  bool get isMet => currentValue >= target;

  /// Error budget remaining (how much room before SLO violation)
  double get errorBudgetRemaining =>
      ((currentValue - target) / (1.0 - target)).clamp(0.0, 1.0);

  /// Format current value as a display string
  String get displayValue => unit == '%'
      ? '${(currentValue * 100).toStringAsFixed(2)}%'
      : currentValue.toStringAsFixed(2);

  /// Format target as a display string
  String get displayTarget => unit == '%'
      ? '${(target * 100).toStringAsFixed(1)}%'
      : target.toStringAsFixed(2);
}

/// Session record for crash-free tracking
class AppSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final bool crashFree;
  final bool anrFree;
  final int errorCount;
  final String? crashReason;

  AppSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.crashFree = true,
    this.anrFree = true,
    this.errorCount = 0,
    this.crashReason,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'crashFree': crashFree,
        'anrFree': anrFree,
        'errorCount': errorCount,
        'crashReason': crashReason,
      };

  factory AppSession.fromJson(Map<String, dynamic> json) {
    return AppSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      crashFree: json['crashFree'] as bool? ?? true,
      anrFree: json['anrFree'] as bool? ?? true,
      errorCount: json['errorCount'] as int? ?? 0,
      crashReason: json['crashReason'] as String?,
    );
  }
}

/// Overall health dashboard snapshot
class HealthDashboard {
  final HealthStatus overallStatus;
  final List<ServiceLevelObjective> slos;
  final List<HealthAlert> activeAlerts;
  final double crashFreeRate;
  final double anrFreeRate;
  final double apiSuccessRate;
  final double uiResponsivenessRate;
  final int totalSessions;
  final int crashedSessions;
  final int totalApiCalls;
  final int failedApiCalls;
  final DateTime lastUpdated;
  final double errorBudgetUsed;

  HealthDashboard({
    required this.overallStatus,
    required this.slos,
    required this.activeAlerts,
    required this.crashFreeRate,
    required this.anrFreeRate,
    required this.apiSuccessRate,
    required this.uiResponsivenessRate,
    required this.totalSessions,
    required this.crashedSessions,
    required this.totalApiCalls,
    required this.failedApiCalls,
    required this.lastUpdated,
    required this.errorBudgetUsed,
  });
}

// =============================================================================
// HEALTH DASHBOARD SERVICE (SINGLETON)
// =============================================================================

/// Centralized service for app health monitoring, SLO tracking, and alerts.
///
/// Tracks crash-free sessions, API success rates, UI responsiveness,
/// and emits alerts when thresholds are breached.
///
/// Usage:
/// ```dart
/// final health = HealthDashboardService();
/// await health.init();
/// health.startSession();
/// final dashboard = health.getDashboard();
/// ```
class HealthDashboardService {
  // ========================================
  // SINGLETON PATTERN
  // ========================================
  static final HealthDashboardService _instance =
      HealthDashboardService._internal();
  factory HealthDashboardService() => _instance;
  HealthDashboardService._internal();

  // ========================================
  // SLO TARGETS
  // ========================================
  static const double crashFreeTarget = 0.998;    // 99.8%
  static const double crashFreeWarning = 0.999;   // warn below 99.9%
  static const double anrFreeTarget = 0.995;      // 99.5%
  static const double anrFreeWarning = 0.997;     // warn below 99.7%
  static const double apiSuccessTarget = 0.995;   // 99.5%
  static const double apiSuccessWarning = 0.997;  // warn below 99.7%
  static const double launchSuccessTarget = 0.999; // 99.9%
  static const double uiResponsiveTarget = 0.95;  // 95%
  static const double uiResponsiveWarning = 0.97; // warn below 97%

  // ========================================
  // DATA STORAGE
  // ========================================
  final List<AppSession> _sessions = [];
  final List<HealthAlert> _alerts = [];
  int _totalApiCalls = 0;
  int _failedApiCalls = 0;
  int _totalFrames = 0;
  int _jankFrames = 0;
  int _successfulLaunches = 0;
  int _totalLaunches = 0;

  AppSession? _currentSession;
  bool _initialized = false;

  // Stream for real-time dashboard updates
  final StreamController<HealthDashboard> _dashboardController =
      StreamController<HealthDashboard>.broadcast();
  Stream<HealthDashboard> get dashboardStream => _dashboardController.stream;

  // Alert stream for push notifications
  final StreamController<HealthAlert> _alertController =
      StreamController<HealthAlert>.broadcast();
  Stream<HealthAlert> get alertStream => _alertController.stream;

  Timer? _healthCheckTimer;

  // ========================================
  // INITIALIZATION
  // ========================================

  /// Initialize the health dashboard service.
  ///
  /// Loads persisted session and alert data, starts periodic health checks.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _loadPersistedData();

    // Run health checks every 30 seconds
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _runHealthChecks();
    });
  }

  // ========================================
  // SESSION TRACKING
  // ========================================

  /// Start a new app session.
  ///
  /// Creates a session record for crash-free tracking.
  void startSession() {
    _currentSession = AppSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      startTime: DateTime.now(),
    );
    _totalLaunches++;
    _successfulLaunches++;
    _persistData();
  }

  /// End the current session successfully.
  void endSession() {
    if (_currentSession != null) {
      _sessions.add(AppSession(
        id: _currentSession!.id,
        startTime: _currentSession!.startTime,
        endTime: DateTime.now(),
        crashFree: true,
        anrFree: true,
        errorCount: _currentSession!.errorCount,
      ));
      _currentSession = null;
      _persistData();
    }
  }

  /// Record a crash in the current session.
  void recordCrash(String reason) {
    if (_currentSession != null) {
      _sessions.add(AppSession(
        id: _currentSession!.id,
        startTime: _currentSession!.startTime,
        endTime: DateTime.now(),
        crashFree: false,
        anrFree: true,
        errorCount: _currentSession!.errorCount + 1,
        crashReason: reason,
      ));
      _currentSession = null;

      // Immediately check health and raise alert
      _checkCrashFreeRate();
      _persistData();
    }
  }

  /// Record an ANR (App Not Responding) event.
  void recordAnr() {
    if (_currentSession != null) {
      _currentSession = AppSession(
        id: _currentSession!.id,
        startTime: _currentSession!.startTime,
        crashFree: _currentSession!.crashFree,
        anrFree: false,
        errorCount: _currentSession!.errorCount + 1,
      );
    }
  }

  /// Record a failed app launch.
  void recordLaunchFailure() {
    _successfulLaunches = (_successfulLaunches - 1).clamp(0, _totalLaunches);
    _persistData();
  }

  // ========================================
  // API TRACKING
  // ========================================

  /// Record an API call result.
  void recordApiCall({required bool success}) {
    _totalApiCalls++;
    if (!success) _failedApiCalls++;
    _persistData();
  }

  // ========================================
  // UI RESPONSIVENESS TRACKING
  // ========================================

  /// Record frame rendering stats for UI responsiveness SLO.
  void recordFrameStats({required int totalFrames, required int jankFrames}) {
    _totalFrames += totalFrames;
    _jankFrames += jankFrames;
  }

  // ========================================
  // HEALTH CHECKS & ALERTS
  // ========================================

  void _runHealthChecks() {
    _checkCrashFreeRate();
    _checkAnrFreeRate();
    _checkApiSuccessRate();
    _checkUiResponsiveness();
    _emitDashboard();
  }

  void _checkCrashFreeRate() {
    final rate = crashFreeRate;
    if (rate < crashFreeTarget) {
      _raiseAlert(
        title: 'Crash-Free Rate Below SLO',
        message:
            'Crash-free session rate is ${(rate * 100).toStringAsFixed(2)}%, '
            'below the ${(crashFreeTarget * 100).toStringAsFixed(1)}% target.',
        severity: AlertSeverity.critical,
        metric: 'crash_free_rate',
        currentValue: rate,
        threshold: crashFreeTarget,
      );
    } else if (rate < crashFreeWarning) {
      _raiseAlert(
        title: 'Crash-Free Rate Warning',
        message:
            'Crash-free session rate is ${(rate * 100).toStringAsFixed(2)}%, '
            'approaching the SLO threshold.',
        severity: AlertSeverity.warning,
        metric: 'crash_free_rate',
        currentValue: rate,
        threshold: crashFreeWarning,
      );
    }
  }

  void _checkAnrFreeRate() {
    final rate = anrFreeRate;
    if (rate < anrFreeTarget) {
      _raiseAlert(
        title: 'ANR-Free Rate Below SLO',
        message: 'ANR-free rate is ${(rate * 100).toStringAsFixed(2)}%.',
        severity: AlertSeverity.critical,
        metric: 'anr_free_rate',
        currentValue: rate,
        threshold: anrFreeTarget,
      );
    } else if (rate < anrFreeWarning) {
      _raiseAlert(
        title: 'ANR-Free Rate Warning',
        message: 'ANR-free rate approaching threshold.',
        severity: AlertSeverity.warning,
        metric: 'anr_free_rate',
        currentValue: rate,
        threshold: anrFreeWarning,
      );
    }
  }

  void _checkApiSuccessRate() {
    final rate = apiSuccessRate;
    if (_totalApiCalls > 10 && rate < apiSuccessTarget) {
      _raiseAlert(
        title: 'API Success Rate Below SLO',
        message:
            'API success rate is ${(rate * 100).toStringAsFixed(2)}%, '
            '$_failedApiCalls of $_totalApiCalls requests failed.',
        severity: AlertSeverity.critical,
        metric: 'api_success_rate',
        currentValue: rate,
        threshold: apiSuccessTarget,
      );
    } else if (_totalApiCalls > 10 && rate < apiSuccessWarning) {
      _raiseAlert(
        title: 'API Success Rate Warning',
        message: 'API success rate declining.',
        severity: AlertSeverity.warning,
        metric: 'api_success_rate',
        currentValue: rate,
        threshold: apiSuccessWarning,
      );
    }
  }

  void _checkUiResponsiveness() {
    final rate = uiResponsivenessRate;
    if (_totalFrames > 100 && rate < uiResponsiveTarget) {
      _raiseAlert(
        title: 'UI Responsiveness Below SLO',
        message:
            'Jank-free frame rate is ${(rate * 100).toStringAsFixed(1)}%. '
            '$_jankFrames of $_totalFrames frames janked.',
        severity: AlertSeverity.critical,
        metric: 'ui_responsiveness',
        currentValue: rate,
        threshold: uiResponsiveTarget,
      );
    } else if (_totalFrames > 100 && rate < uiResponsiveWarning) {
      _raiseAlert(
        title: 'UI Responsiveness Warning',
        message: 'Frame jank rate increasing.',
        severity: AlertSeverity.warning,
        metric: 'ui_responsiveness',
        currentValue: rate,
        threshold: uiResponsiveWarning,
      );
    }
  }

  void _raiseAlert({
    required String title,
    required String message,
    required AlertSeverity severity,
    required String metric,
    required double currentValue,
    required double threshold,
  }) {
    // Deduplicate: don't raise same alert within 5 minutes
    final recentSame = _alerts.where((a) =>
        a.metric == metric &&
        !a.acknowledged &&
        DateTime.now().difference(a.timestamp).inMinutes < 5);
    if (recentSame.isNotEmpty) return;

    final alert = HealthAlert(
      id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      severity: severity,
      timestamp: DateTime.now(),
      metric: metric,
      currentValue: currentValue,
      threshold: threshold,
    );

    _alerts.add(alert);
    if (!_alertController.isClosed) {
      _alertController.add(alert);
    }
    _persistData();
  }

  /// Acknowledge an alert by ID
  void acknowledgeAlert(String alertId) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(acknowledged: true);
      _persistData();
      _emitDashboard();
    }
  }

  /// Dismiss all acknowledged alerts
  void clearAcknowledgedAlerts() {
    _alerts.removeWhere((a) => a.acknowledged);
    _persistData();
    _emitDashboard();
  }

  // ========================================
  // COMPUTED RATES
  // ========================================

  double get crashFreeRate {
    if (_sessions.isEmpty) return 1.0;
    final crashFree = _sessions.where((s) => s.crashFree).length;
    return crashFree / _sessions.length;
  }

  double get anrFreeRate {
    if (_sessions.isEmpty) return 1.0;
    final anrFree = _sessions.where((s) => s.anrFree).length;
    return anrFree / _sessions.length;
  }

  double get apiSuccessRate {
    if (_totalApiCalls == 0) return 1.0;
    return (_totalApiCalls - _failedApiCalls) / _totalApiCalls;
  }

  double get uiResponsivenessRate {
    if (_totalFrames == 0) return 1.0;
    return (_totalFrames - _jankFrames) / _totalFrames;
  }

  double get launchSuccessRate {
    if (_totalLaunches == 0) return 1.0;
    return _successfulLaunches / _totalLaunches;
  }

  // ========================================
  // DASHBOARD
  // ========================================

  /// Get the current health dashboard snapshot.
  HealthDashboard getDashboard() {
    final slos = [
      ServiceLevelObjective(
        name: 'Crash-Free Sessions',
        description: 'Percentage of sessions without crashes',
        target: crashFreeTarget,
        warningAt: crashFreeWarning,
        currentValue: crashFreeRate,
        status: _getStatus(crashFreeRate, crashFreeTarget, crashFreeWarning),
      ),
      ServiceLevelObjective(
        name: 'ANR-Free Sessions',
        description: 'Percentage of sessions without ANR events',
        target: anrFreeTarget,
        warningAt: anrFreeWarning,
        currentValue: anrFreeRate,
        status: _getStatus(anrFreeRate, anrFreeTarget, anrFreeWarning),
      ),
      ServiceLevelObjective(
        name: 'API Success Rate',
        description: 'Percentage of successful API calls',
        target: apiSuccessTarget,
        warningAt: apiSuccessWarning,
        currentValue: apiSuccessRate,
        status: _getStatus(apiSuccessRate, apiSuccessTarget, apiSuccessWarning),
      ),
      ServiceLevelObjective(
        name: 'App Launch Success',
        description: 'Percentage of successful app launches',
        target: launchSuccessTarget,
        warningAt: 0.9995,
        currentValue: launchSuccessRate,
        status: _getStatus(launchSuccessRate, launchSuccessTarget, 0.9995),
      ),
      ServiceLevelObjective(
        name: 'UI Responsiveness',
        description: 'Percentage of frames rendered without jank',
        target: uiResponsiveTarget,
        warningAt: uiResponsiveWarning,
        currentValue: uiResponsivenessRate,
        status: _getStatus(
            uiResponsivenessRate, uiResponsiveTarget, uiResponsiveWarning),
      ),
    ];

    final activeAlerts = _alerts.where((a) => !a.acknowledged).toList();

    // Calculate error budget consumed
    final crashErrorBudget = _sessions.isEmpty
        ? 0.0
        : (1.0 - crashFreeRate) / (1.0 - crashFreeTarget);

    final overallStatus = activeAlerts.any((a) => a.severity == AlertSeverity.critical)
        ? HealthStatus.unhealthy
        : activeAlerts.any((a) => a.severity == AlertSeverity.warning)
            ? HealthStatus.degraded
            : HealthStatus.healthy;

    return HealthDashboard(
      overallStatus: overallStatus,
      slos: slos,
      activeAlerts: activeAlerts,
      crashFreeRate: crashFreeRate,
      anrFreeRate: anrFreeRate,
      apiSuccessRate: apiSuccessRate,
      uiResponsivenessRate: uiResponsivenessRate,
      totalSessions: _sessions.length,
      crashedSessions: _sessions.where((s) => !s.crashFree).length,
      totalApiCalls: _totalApiCalls,
      failedApiCalls: _failedApiCalls,
      lastUpdated: DateTime.now(),
      errorBudgetUsed: crashErrorBudget.clamp(0.0, 1.0),
    );
  }

  HealthStatus _getStatus(double value, double target, double warning) {
    if (value < target) return HealthStatus.unhealthy;
    if (value < warning) return HealthStatus.degraded;
    return HealthStatus.healthy;
  }

  void _emitDashboard() {
    if (!_dashboardController.isClosed) {
      _dashboardController.add(getDashboard());
    }
  }

  /// Get all alerts (including acknowledged)
  List<HealthAlert> getAllAlerts() => List.from(_alerts);

  /// Get active (unacknowledged) alerts
  List<HealthAlert> getActiveAlerts() =>
      _alerts.where((a) => !a.acknowledged).toList();

  // ========================================
  // PERSISTENCE
  // ========================================

  Future<void> _persistData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Persist last 200 sessions
      final sessionsJson = _sessions
          .reversed
          .take(200)
          .map((s) => s.toJson())
          .toList()
          .reversed
          .toList();
      await prefs.setString('health_sessions', jsonEncode(sessionsJson));

      // Persist last 100 alerts
      final alertsJson = _alerts
          .reversed
          .take(100)
          .map((a) => a.toJson())
          .toList()
          .reversed
          .toList();
      await prefs.setString('health_alerts', jsonEncode(alertsJson));

      // Persist counters
      await prefs.setInt('health_total_api_calls', _totalApiCalls);
      await prefs.setInt('health_failed_api_calls', _failedApiCalls);
      await prefs.setInt('health_total_frames', _totalFrames);
      await prefs.setInt('health_jank_frames', _jankFrames);
      await prefs.setInt('health_total_launches', _totalLaunches);
      await prefs.setInt('health_successful_launches', _successfulLaunches);
    } catch (e) {
      debugPrint('HealthDashboardService: persist error — $e');
    }
  }

  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final sessionsStr = prefs.getString('health_sessions');
      if (sessionsStr != null) {
        final list = jsonDecode(sessionsStr) as List;
        _sessions.addAll(
            list.map((j) => AppSession.fromJson(j as Map<String, dynamic>)));
      }

      final alertsStr = prefs.getString('health_alerts');
      if (alertsStr != null) {
        final list = jsonDecode(alertsStr) as List;
        _alerts.addAll(
            list.map((j) => HealthAlert.fromJson(j as Map<String, dynamic>)));
      }

      _totalApiCalls = prefs.getInt('health_total_api_calls') ?? 0;
      _failedApiCalls = prefs.getInt('health_failed_api_calls') ?? 0;
      _totalFrames = prefs.getInt('health_total_frames') ?? 0;
      _jankFrames = prefs.getInt('health_jank_frames') ?? 0;
      _totalLaunches = prefs.getInt('health_total_launches') ?? 0;
      _successfulLaunches = prefs.getInt('health_successful_launches') ?? 0;
    } catch (e) {
      debugPrint('HealthDashboardService: load error — $e');
    }
  }

  /// Clear all health data
  Future<void> clearAll() async {
    _sessions.clear();
    _alerts.clear();
    _totalApiCalls = 0;
    _failedApiCalls = 0;
    _totalFrames = 0;
    _jankFrames = 0;
    _totalLaunches = 0;
    _successfulLaunches = 0;
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'health_sessions', 'health_alerts', 'health_total_api_calls',
      'health_failed_api_calls', 'health_total_frames', 'health_jank_frames',
      'health_total_launches', 'health_successful_launches',
    ];
    for (final key in keys) {
      await prefs.remove(key);
    }
    _emitDashboard();
  }

  /// Dispose resources
  void dispose() {
    _healthCheckTimer?.cancel();
    _dashboardController.close();
    _alertController.close();
  }
}
