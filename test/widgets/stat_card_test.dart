// ============================================================================
// MUSCLE POWER - Stat Card Widget Tests
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/widgets/stat_card.dart';

void main() {
  // ========================================
  // STAT CARD TESTS
  // ========================================

  group('StatCard', () {
    testWidgets('renders icon, value, and label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.fitness_center,
              value: '42',
              label: 'Workouts',
              gradient: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Workouts'), findsOneWidget);
    });

    testWidgets('displays correct value text style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.timer,
              value: '120h',
              label: 'Total Time',
              gradient: [Color(0xFF00D9FF), Color(0xFF00B4D8)],
            ),
          ),
        ),
      );

      final valueText = tester.widget<Text>(find.text('120h'));
      expect(valueText.style?.fontWeight, FontWeight.bold);
      expect(valueText.style?.fontSize, 20);
      expect(valueText.style?.color, Colors.white);
    });

    testWidgets('displays label text in grey', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.local_fire_department,
              value: '1500',
              label: 'Calories',
              gradient: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
            ),
          ),
        ),
      );

      final labelText = tester.widget<Text>(find.text('Calories'));
      expect(labelText.style?.fontSize, 12);
    });

    testWidgets('icon is white', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.star,
              value: '5',
              label: 'Stars',
              gradient: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, Colors.white);
      expect(icon.size, 24);
    });

    testWidgets('has dark gradient background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.star,
              value: '5',
              label: 'Stars',
              gradient: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
            ),
          ),
        ),
      );

      // The outer container should have a dark gradient
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool foundDarkGradient = false;
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.gradient is LinearGradient) {
            final lg = decoration.gradient as LinearGradient;
            if (lg.colors.contains(const Color(0xFF1A1A2E))) {
              foundDarkGradient = true;
              break;
            }
          }
        }
      }
      expect(foundDarkGradient, isTrue);
    });

    testWidgets('has border radius of 20', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.star,
              value: '5',
              label: 'Stars',
              gradient: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      bool found = false;
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.borderRadius == BorderRadius.circular(20) &&
              decoration.border != null) {
            found = true;
            break;
          }
        }
      }
      expect(found, isTrue);
    });

    testWidgets('uses Row layout with icon on left', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.fitness_center,
              value: '42',
              label: 'Workouts',
              gradient: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
            ),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
    });
  });

  // ========================================
  // ANIMATED STAT CARD TESTS
  // ========================================

  group('AnimatedStatCard', () {
    testWidgets('renders with StatCard inside', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedStatCard(
              icon: Icons.timer,
              value: '120h',
              label: 'Total Time',
              gradient: [Color(0xFF00D9FF), Color(0xFF00B4D8)],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(StatCard), findsOneWidget);
      expect(find.text('120h'), findsOneWidget);
      expect(find.text('Total Time'), findsOneWidget);
    });

    testWidgets('animates in with delay', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedStatCard(
              icon: Icons.timer,
              value: '120h',
              label: 'Total Time',
              gradient: [Color(0xFF00D9FF), Color(0xFF00B4D8)],
              animationDelay: 200,
            ),
          ),
        ),
      );

      // Initially should be scaled down / faded
      await tester.pump(const Duration(milliseconds: 100));
      // After delay + animation duration, should be visible
      await tester.pumpAndSettle();

      expect(find.text('120h'), findsOneWidget);
    });

    testWidgets('disposes animation controller cleanly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedStatCard(
              icon: Icons.timer,
              value: '120h',
              label: 'Total Time',
              gradient: [Color(0xFF00D9FF), Color(0xFF00B4D8)],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SizedBox()),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('uses default animation delay of 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedStatCard(
              icon: Icons.star,
              value: '5',
              label: 'Rating',
              gradient: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
            ),
          ),
        ),
      );

      // Should begin animation immediately
      await tester.pumpAndSettle();
      expect(find.text('5'), findsOneWidget);
    });
  });

  // ========================================
  // CIRCULAR STAT CARD TESTS
  // ========================================

  group('CircularStatCard', () {
    testWidgets('renders icon, value, and label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularStatCard(
              icon: Icons.fitness_center,
              value: '75%',
              label: 'Progress',
              color: Color(0xFFFF6B35),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
    });

    testWidgets('shows circular progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularStatCard(
              icon: Icons.star,
              value: '3/4',
              label: 'Goals',
              color: Colors.blue,
              progress: 0.75,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('applies progress value to indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularStatCard(
              icon: Icons.star,
              value: '50%',
              label: 'Done',
              color: Colors.green,
              progress: 0.5,
            ),
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, 0.5);
    });

    testWidgets('uses default progress of 0.75', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularStatCard(
              icon: Icons.star,
              value: 'Default',
              label: 'Test',
              color: Colors.green,
            ),
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, 0.75);
    });

    testWidgets('value text is bold and white', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularStatCard(
              icon: Icons.star,
              value: '100',
              label: 'Score',
              color: Colors.orange,
            ),
          ),
        ),
      );

      final valueText = tester.widget<Text>(find.text('100'));
      expect(valueText.style?.fontWeight, FontWeight.bold);
      expect(valueText.style?.color, Colors.white);
      expect(valueText.style?.fontSize, 20);
    });

    testWidgets('icon uses specified color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularStatCard(
              icon: Icons.star,
              value: '5',
              label: 'Stars',
              color: Colors.amber,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, Colors.amber);
    });

    testWidgets('uses Column layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularStatCard(
              icon: Icons.star,
              value: '5',
              label: 'Test',
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
    });
  });

  // ========================================
  // MINI STAT CHIP TESTS  
  // ========================================

  group('MiniStatChip', () {
    testWidgets('renders icon and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniStatChip(
              icon: Icons.local_fire_department,
              value: '150 cal',
              color: Colors.orange,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.text('150 cal'), findsOneWidget);
    });

    testWidgets('icon uses specified color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniStatChip(
              icon: Icons.timer,
              value: '30m',
              color: Colors.blue,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.timer));
      expect(icon.color, Colors.blue);
      expect(icon.size, 16);
    });

    testWidgets('text uses specified color and is bold', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniStatChip(
              icon: Icons.timer,
              value: '30m',
              color: Colors.blue,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('30m'));
      expect(text.style?.color, Colors.blue);
      expect(text.style?.fontWeight, FontWeight.bold);
      expect(text.style?.fontSize, 12);
    });

    testWidgets('has rounded background with low opacity', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniStatChip(
              icon: Icons.star,
              value: '5',
              color: Colors.amber,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(20));
      expect(decoration.color!.opacity, lessThan(0.5));
    });

    testWidgets('uses Row with minimum size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniStatChip(
              icon: Icons.star,
              value: '5',
              color: Colors.amber,
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisSize, MainAxisSize.min);
    });
  });
}
