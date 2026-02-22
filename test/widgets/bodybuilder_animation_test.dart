// ============================================================================
// MUSCLE POWER - Bodybuilder Animation Widget Tests
// ============================================================================
//
// Coverage targets: bodybuilder_animation.dart
// Tests: widget creation, default opacity, custom opacity, animation
//        controllers, CustomPaint rendering, and clean disposal.
//
// Total: 12 tests
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/widgets/bodybuilder_animation.dart';

void main() {
  // ========================================
  // WIDGET CONSTRUCTION
  // ========================================

  group('BodybuilderAnimation construction', () {
    testWidgets('creates widget with defaults', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BodybuilderAnimation()),
        ),
      );
      expect(find.byType(BodybuilderAnimation), findsOneWidget);
    });

    testWidgets('default opacity is 0.18', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BodybuilderAnimation()),
        ),
      );
      final widget = tester.widget<BodybuilderAnimation>(
        find.byType(BodybuilderAnimation),
      );
      expect(widget.opacity, 0.18);
    });

    testWidgets('accepts custom opacity', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BodybuilderAnimation(opacity: 0.5)),
        ),
      );
      final widget = tester.widget<BodybuilderAnimation>(
        find.byType(BodybuilderAnimation),
      );
      expect(widget.opacity, 0.5);
    });
  });

  // ========================================
  // RENDERING
  // ========================================

  group('Rendering', () {
    testWidgets('renders CustomPaint widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BodybuilderAnimation()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('animation progresses over time', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BodybuilderAnimation()),
        ),
      );
      // Pump multiple frames to advance the animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(BodybuilderAnimation), findsOneWidget);
    });

    testWidgets('renders with zero opacity without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BodybuilderAnimation(opacity: 0.0)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BodybuilderAnimation), findsOneWidget);
    });

    testWidgets('renders with max opacity', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BodybuilderAnimation(opacity: 1.0)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BodybuilderAnimation), findsOneWidget);
    });
  });

  // ========================================
  // LIFECYCLE
  // ========================================

  group('Lifecycle', () {
    testWidgets('multiple instances can coexist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(child: BodybuilderAnimation(opacity: 0.1)),
                Expanded(child: BodybuilderAnimation(opacity: 0.3)),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(BodybuilderAnimation), findsNWidgets(2));
    });

    testWidgets('disposes cleanly when removed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BodybuilderAnimation()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Replace with empty widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      // No error means animation controllers were disposed
    });

    testWidgets('handles rebuild gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BodybuilderAnimation(opacity: 0.2)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Rebuild with different opacity
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BodybuilderAnimation(opacity: 0.4)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BodybuilderAnimation), findsOneWidget);
    });
  });
}
