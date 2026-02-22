// ============================================================================
// MUSCLE POWER - Exercise Illustration Widget Tests
// ============================================================================
//
// Coverage targets: exercise_illustration.dart
// Tests: widget construction, animation controller, various exercise painters,
//        alternating exercises detection, custom colors, size, and animation toggle.
//
// Total: 22 tests
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/widgets/exercise_illustration.dart';

void main() {
  // ========================================
  // WIDGET CONSTRUCTION
  // ========================================

  group('ExerciseIllustration construction', () {
    testWidgets('creates widget with required exerciseName', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseIllustration(exerciseName: 'Bench Press'),
          ),
        ),
      );
      expect(find.byType(ExerciseIllustration), findsOneWidget);
    });

    testWidgets('default size is 200', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseIllustration(exerciseName: 'Squats'),
          ),
        ),
      );
      final widget = tester.widget<ExerciseIllustration>(
        find.byType(ExerciseIllustration),
      );
      expect(widget.size, 200);
    });

    testWidgets('accepts custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseIllustration(exerciseName: 'Squats', size: 150),
          ),
        ),
      );
      final widget = tester.widget<ExerciseIllustration>(
        find.byType(ExerciseIllustration),
      );
      expect(widget.size, 150);
    });

    testWidgets('default primaryColor is orange', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseIllustration(exerciseName: 'Deadlift'),
          ),
        ),
      );
      final widget = tester.widget<ExerciseIllustration>(
        find.byType(ExerciseIllustration),
      );
      expect(widget.primaryColor, const Color(0xFFFF6B35));
    });

    testWidgets('default secondaryColor is cyan', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseIllustration(exerciseName: 'Pull-Ups'),
          ),
        ),
      );
      final widget = tester.widget<ExerciseIllustration>(
        find.byType(ExerciseIllustration),
      );
      expect(widget.secondaryColor, const Color(0xFF00D9FF));
    });

    testWidgets('custom colors are applied', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseIllustration(
              exerciseName: 'Bench Press',
              primaryColor: Colors.red,
              secondaryColor: Colors.blue,
            ),
          ),
        ),
      );
      final widget = tester.widget<ExerciseIllustration>(
        find.byType(ExerciseIllustration),
      );
      expect(widget.primaryColor, Colors.red);
      expect(widget.secondaryColor, Colors.blue);
    });
  });

  // ========================================
  // ANIMATION
  // ========================================

  group('Animation behaviour', () {
    testWidgets('animate defaults to true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseIllustration(exerciseName: 'Bench Press'),
          ),
        ),
      );
      final widget = tester.widget<ExerciseIllustration>(
        find.byType(ExerciseIllustration),
      );
      expect(widget.animate, true);
    });

    testWidgets('animate false does not crash', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseIllustration(
              exerciseName: 'Squats',
              animate: false,
            ),
          ),
        ),
      );
      expect(find.byType(ExerciseIllustration), findsOneWidget);
    });

    testWidgets('renders CustomPaint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseIllustration(exerciseName: 'Bench Press'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  // ========================================
  // DIFFERENT EXERCISE TYPES
  // ========================================

  group('Exercise painter selection', () {
    final exercises = [
      'Bench Press',
      'Incline Press',
      'Cable Flyes',
      'Push-Ups',
      'Dips',
      'Deadlift',
      'Pull-Ups',
      'Barbell Rows',
      'Overhead Press',
      'Squats',
      'Lunges',
      'Bicep Curl',
      'Hammer Curl',
      'Plank',
    ];

    for (final exercise in exercises) {
      testWidgets('renders $exercise without error', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ExerciseIllustration(exerciseName: exercise),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(ExerciseIllustration), findsOneWidget);
      });
    }
  });

  // ========================================
  // DISPOSAL
  // ========================================

  group('Widget disposal', () {
    testWidgets('disposes cleanly when removed from tree', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseIllustration(exerciseName: 'Bench Press'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Remove widget from tree
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      // No error means disposal was successful
    });
  });
}
