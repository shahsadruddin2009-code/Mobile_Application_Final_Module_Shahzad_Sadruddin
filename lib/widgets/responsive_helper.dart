// ============================================================================
// MUSCLE POWER - Responsive Helper Utility
// ============================================================================
//
// File: responsive_helper.dart
// Description: Utility class for responsive layouts across different screen
//              sizes and orientations (phone, tablet, desktop).
//
// Breakpoints:
// - Compact (phone):       width < 600
// - Medium  (tablet):      600 <= width < 900
// - Expanded (desktop/lg): width >= 900
//
// Features:
// - Device type detection (phone, tablet, desktop)
// - Responsive value selector based on breakpoint
// - Scaled font sizes that respect system text scaling
// - Responsive padding and spacing helpers
// - Orientation-aware layout decisions
//
// Usage:
// ```dart
// final r = ResponsiveHelper.of(context);
// r.isPhone;
// r.value(phone: 2, tablet: 3, desktop: 4);
// r.fontSize(16);
// ```
// ============================================================================

import 'dart:math';
import 'package:flutter/material.dart';

/// Responsive breakpoint categories.
enum DeviceType { phone, tablet, desktop }

/// Utility class providing responsive layout helpers.
///
/// Create an instance via [ResponsiveHelper.of] and use its properties
/// and methods to adapt UI to different screen sizes.
///
/// ```dart
/// final r = ResponsiveHelper.of(context);
/// final columns = r.value<int>(phone: 2, tablet: 3, desktop: 4);
/// ```
class ResponsiveHelper {
  /// Current screen width in logical pixels.
  final double screenWidth;

  /// Current screen height in logical pixels.
  final double screenHeight;

  /// Current system text scale factor.
  final double textScaleFactor;

  /// Whether the device is in landscape orientation.
  final bool isLandscape;

  const ResponsiveHelper._({
    required this.screenWidth,
    required this.screenHeight,
    required this.textScaleFactor,
    required this.isLandscape,
  });

  /// Factory that reads dimensions from [MediaQuery].
  factory ResponsiveHelper.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ResponsiveHelper._(
      screenWidth: mq.size.width,
      screenHeight: mq.size.height,
      textScaleFactor: mq.textScaler.scale(1.0),
      isLandscape: mq.orientation == Orientation.landscape,
    );
  }

  // ========================================
  // BREAKPOINT HELPERS
  // ========================================

  /// The current device type based on width breakpoints.
  DeviceType get deviceType {
    if (screenWidth >= 900) return DeviceType.desktop;
    if (screenWidth >= 600) return DeviceType.tablet;
    return DeviceType.phone;
  }

  bool get isPhone => deviceType == DeviceType.phone;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// Return different values depending on the current device type.
  ///
  /// [phone] is required; [tablet] defaults to [phone] and [desktop]
  /// defaults to [tablet].
  T value<T>({required T phone, T? tablet, T? desktop}) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.phone:
        return phone;
    }
  }

  // ========================================
  // FONT SIZING
  // ========================================

  /// Returns a font size that is clamped so that very large system text
  /// scale factors do not break layouts.
  ///
  /// The returned value is the design-time [size] multiplied by a clamped
  /// text scale factor (max 1.3×).
  double fontSize(double size) {
    final clampedScale = min(textScaleFactor, 1.3);
    return size * clampedScale;
  }

  // ========================================
  // SPACING
  // ========================================

  /// Responsive horizontal padding.
  double get horizontalPadding => value<double>(phone: 16, tablet: 24, desktop: 32);

  /// Responsive vertical padding.
  double get verticalPadding => value<double>(phone: 16, tablet: 20, desktop: 24);

  /// Responsive content padding as [EdgeInsets].
  EdgeInsets get contentPadding => EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      );

  // ========================================
  // GRID HELPERS
  // ========================================

  /// Suggested number of columns for a grid layout.
  int get gridColumns => value<int>(phone: 2, tablet: 3, desktop: 4);

  /// Suggested grid cross-axis spacing.
  double get gridSpacing => value<double>(phone: 12, tablet: 16, desktop: 20);
}
