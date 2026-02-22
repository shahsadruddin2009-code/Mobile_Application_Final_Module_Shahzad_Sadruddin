// ============================================================================
// MUSCLE POWER - Offline Banner Widget
// ============================================================================
//
// File: offline_banner.dart
// Description: A banner widget that appears when the device loses network
//              connectivity, providing clear user feedback.
//
// Features:
// - Listens to ConnectivityService stream for real-time updates
// - Animated slide-in/out transition
// - Dismisses automatically when connectivity is restored
// - Accessible with Semantics for screen readers
//
// Usage:
// Wrap your Scaffold body with OfflineBanner:
// ```dart
// OfflineBanner(child: YourContent())
// ```
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// Displays a persistent banner at the top of the screen when offline.
///
/// Wraps a [child] widget and shows/hides an animated offline indicator
/// based on the [ConnectivityService] state.
class OfflineBanner extends StatefulWidget {
  /// The child widget to display below the banner.
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  StreamSubscription<bool>? _subscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    // Read current state
    _isOffline = _connectivityService.isOffline;
    if (_isOffline) _animController.value = 1.0;

    // Listen for changes
    _subscription = _connectivityService.connectivityStream.listen((offline) {
      if (!mounted) return;
      setState(() => _isOffline = offline);
      if (offline) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated offline banner
        SlideTransition(
          position: _slideAnimation,
          child: _isOffline
              ? Semantics(
                  label: 'You are offline. Some features may be unavailable.',
                  liveRegion: true,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: const Color(0xFFE74C3C),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.wifi_off, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'You are offline',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Main content
        Expanded(child: widget.child),
      ],
    );
  }
}
