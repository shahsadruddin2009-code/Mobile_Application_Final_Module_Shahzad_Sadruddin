// ============================================================================
// MUSCLE POWER - App Lifecycle Observer
// ============================================================================
//
// File: app_lifecycle_observer.dart
// Description: Monitors app lifecycle events to track cold/warm starts,
//              session boundaries, and feed data to the performance and
//              health monitoring services.
//
// Lifecycle Events Tracked:
// - App Launch (cold start measurement)
// - App Resume (warm start measurement)
// - App Pause (session checkpoint)
// - App Detach (session end)
//
// ============================================================================

import 'package:flutter/widgets.dart';
import 'performance_service.dart';
import 'health_dashboard_service.dart';

/// Observes app lifecycle transitions and feeds metrics to monitoring services.
///
/// Attach this observer in the app's main widget to automatically track:
/// - Cold start duration (from init to first frame)
/// - Warm start duration (from resume to UI ready)
/// - Session start/end for crash-free rate tracking
///
/// Usage:
/// ```dart
/// final observer = AppLifecycleObserver();
/// observer.initialize();
/// WidgetsBinding.instance.addObserver(observer);
/// ```
class AppLifecycleObserver extends WidgetsBindingObserver {
  final PerformanceService _perfService = PerformanceService();
  final HealthDashboardService _healthService = HealthDashboardService();

  /// Timestamp of when the app was first initialized
  DateTime? _appInitTime;

  /// Whether the cold start has been recorded
  bool _coldStartRecorded = false;

  /// Initialize the observer and record the app init timestamp.
  ///
  /// Call this as early as possible in the app startup sequence,
  /// ideally right after `WidgetsFlutterBinding.ensureInitialized()`.
  void initialize() {
    _appInitTime = DateTime.now();
  }

  /// Record the cold start metric once the first frame has been rendered.
  ///
  /// Call this from the app's first meaningful widget's `initState` or
  /// after `WidgetsBinding.instance.addPostFrameCallback`.
  void recordColdStartComplete() {
    if (_coldStartRecorded || _appInitTime == null) return;
    _coldStartRecorded = true;

    final duration = DateTime.now().difference(_appInitTime!);
    _perfService.recordColdStart(duration);

    // Start a new health session
    _healthService.startSession();

    // Begin frame monitoring
    _perfService.startFrameMonitoring();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App returned from background - measure warm start
        _perfService.markResumeEnd();
        break;

      case AppLifecycleState.inactive:
        // App is about to go to background
        _perfService.markResumeStart();
        break;

      case AppLifecycleState.paused:
        // App is in background
        break;

      case AppLifecycleState.detached:
        // App is being terminated
        _healthService.endSession();
        _perfService.stopFrameMonitoring();
        break;

      case AppLifecycleState.hidden:
        // App is hidden (not visible but still running)
        break;
    }
  }

  /// Call this when a fatal error/crash is caught to record it
  /// before the app terminates.
  void recordCrash(String reason) {
    _healthService.recordCrash(reason);
  }

  /// Clean up and end the current session gracefully.
  void dispose() {
    _healthService.endSession();
    _perfService.stopFrameMonitoring();
  }
}
