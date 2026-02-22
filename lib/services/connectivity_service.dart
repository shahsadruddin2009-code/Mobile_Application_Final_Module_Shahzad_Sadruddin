// ============================================================================
// MUSCLE POWER - Connectivity Service
// ============================================================================
//
// File: connectivity_service.dart
// Description: Monitors network connectivity status and provides a stream
//              of connectivity changes for offline-aware UI behaviour.
//
// Features:
// - Real-time connectivity monitoring via connectivity_plus
// - Stream-based notifications for connection changes
// - Singleton pattern for global access
// - Graceful fallback when connectivity_plus is unavailable
//
// Usage:
// ```dart
// final connectivity = ConnectivityService();
// connectivity.isOffline; // current status
// connectivity.connectivityStream.listen((isOffline) { ... });
// ```
// ============================================================================

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Singleton service that monitors network connectivity.
///
/// Exposes a boolean [isOffline] property and a [connectivityStream]
/// that emits `true` when the device loses connectivity and `false`
/// when connectivity is restored.
class ConnectivityService {
  // ========================================
  // SINGLETON PATTERN
  // ========================================
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  // ========================================
  // STATE
  // ========================================
  final Connectivity _connectivity = Connectivity();
  bool _isOffline = false;
  bool _initialized = false;

  /// Stream controller that broadcasts connectivity changes.
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  /// Whether the device currently has no network connectivity.
  bool get isOffline => _isOffline;

  /// Stream that emits `true` when offline and `false` when online.
  Stream<bool> get connectivityStream => _controller.stream;

  // ========================================
  // INITIALIZATION
  // ========================================

  /// Initialize the connectivity service.
  ///
  /// Checks the current connectivity status and begins listening for changes.
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Check initial status
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);

      // Listen for changes
      _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          _updateStatus(results);
        },
        onError: (error) {
          debugPrint('ConnectivityService: stream error — $error');
        },
      );
    } catch (e) {
      // Graceful fallback — assume online if plugin unavailable (e.g. web)
      debugPrint('ConnectivityService: init failed — $e');
      _isOffline = false;
    }
  }

  // ========================================
  // INTERNAL
  // ========================================

  void _updateStatus(List<ConnectivityResult> results) {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (offline != _isOffline) {
      _isOffline = offline;
      if (!_controller.isClosed) {
        _controller.add(_isOffline);
      }
      debugPrint('ConnectivityService: ${_isOffline ? "OFFLINE" : "ONLINE"}');
    }
  }

  /// Dispose resources.
  void dispose() {
    _controller.close();
  }
}
