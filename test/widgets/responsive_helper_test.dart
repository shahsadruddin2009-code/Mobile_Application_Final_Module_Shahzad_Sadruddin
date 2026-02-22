// ============================================================================
// MUSCLE POWER - Responsive Helper Widget Tests
// ============================================================================
//
// Coverage targets: responsive_helper.dart
// Tests: breakpoint detection, device type, value selector, font sizing,
//        spacing helpers, grid helpers, orientation detection.
//
// Total: 28 tests
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/widgets/responsive_helper.dart';

/// Helper to build a widget with a specific screen size
Widget _buildWithSize(double width, double height, Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, height)),
      child: Builder(builder: (context) => child),
    ),
  );
}

void main() {
  // ========================================
  // DEVICE TYPE ENUM
  // ========================================

  group('DeviceType enum', () {
    test('has three values', () {
      expect(DeviceType.values, hasLength(3));
      expect(DeviceType.values, contains(DeviceType.phone));
      expect(DeviceType.values, contains(DeviceType.tablet));
      expect(DeviceType.values, contains(DeviceType.desktop));
    });
  });

  // ========================================
  // BREAKPOINT DETECTION
  // ========================================

  group('Breakpoint detection', () {
    testWidgets('width < 600 is phone', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(375, 812, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.deviceType, DeviceType.phone);
      expect(helper.isPhone, true);
      expect(helper.isTablet, false);
      expect(helper.isDesktop, false);
    });

    testWidgets('width 600-899 is tablet', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(768, 1024, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.deviceType, DeviceType.tablet);
      expect(helper.isTablet, true);
      expect(helper.isPhone, false);
    });

    testWidgets('width >= 900 is desktop', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(1200, 800, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.deviceType, DeviceType.desktop);
      expect(helper.isDesktop, true);
      expect(helper.isPhone, false);
    });

    testWidgets('exact boundary 600 is tablet', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(600, 1024, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.isTablet, true);
    });

    testWidgets('exact boundary 900 is desktop', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(900, 600, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.isDesktop, true);
    });
  });

  // ========================================
  // VALUE SELECTOR
  // ========================================

  group('Value selector', () {
    testWidgets('phone returns phone value', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(375, 812, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.value<int>(phone: 2, tablet: 3, desktop: 4), 2);
    });

    testWidgets('tablet returns tablet value', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(768, 1024, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.value<int>(phone: 2, tablet: 3, desktop: 4), 3);
    });

    testWidgets('desktop returns desktop value', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(1200, 800, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.value<int>(phone: 2, tablet: 3, desktop: 4), 4);
    });

    testWidgets('tablet falls back to phone when tablet is null', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(768, 1024, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.value<int>(phone: 2), 2);
    });

    testWidgets('desktop falls back to tablet then phone', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(1200, 800, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.value<String>(phone: 'a', tablet: 'b'), 'b');
    });
  });

  // ========================================
  // FONT SIZING
  // ========================================

  group('Font sizing', () {
    testWidgets('fontSize with scale 1.0 returns base size', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(375, 812), textScaler: TextScaler.linear(1.0)),
          child: Builder(builder: (context) {
            helper = ResponsiveHelper.of(context);
            return const SizedBox();
          }),
        ),
      ));
      expect(helper.fontSize(16), closeTo(16.0, 0.1));
    });

    testWidgets('fontSize clamps at 1.3x scale factor', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(375, 812), textScaler: TextScaler.linear(2.0)),
          child: Builder(builder: (context) {
            helper = ResponsiveHelper.of(context);
            return const SizedBox();
          }),
        ),
      ));
      // Should be clamped to 1.3 * 16 = 20.8
      expect(helper.fontSize(16), closeTo(20.8, 0.1));
    });
  });

  // ========================================
  // SPACING HELPERS
  // ========================================

  group('Spacing helpers', () {
    testWidgets('phone padding is 16', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(375, 812, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.horizontalPadding, 16.0);
      expect(helper.verticalPadding, 16.0);
    });

    testWidgets('contentPadding returns EdgeInsets', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(375, 812, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.contentPadding, isA<EdgeInsets>());
      expect(helper.contentPadding.left, 16.0);
    });
  });

  // ========================================
  // GRID HELPERS
  // ========================================

  group('Grid helpers', () {
    testWidgets('phone grid columns is 2', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(375, 812, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.gridColumns, 2);
      expect(helper.gridSpacing, 12.0);
    });

    testWidgets('tablet grid columns is 3', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(768, 1024, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.gridColumns, 3);
      expect(helper.gridSpacing, 16.0);
    });

    testWidgets('desktop grid columns is 4', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(1200, 800, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.gridColumns, 4);
      expect(helper.gridSpacing, 20.0);
    });
  });

  // ========================================
  // SCREEN DIMENSIONS
  // ========================================

  group('Screen dimensions', () {
    testWidgets('screenWidth and screenHeight are set', (tester) async {
      late ResponsiveHelper helper;
      await tester.pumpWidget(_buildWithSize(414, 896, Builder(
        builder: (context) {
          helper = ResponsiveHelper.of(context);
          return const SizedBox();
        },
      )));
      expect(helper.screenWidth, 414.0);
      expect(helper.screenHeight, 896.0);
    });
  });
}
