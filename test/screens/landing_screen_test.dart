// ============================================================================
// MUSCLE POWER - Landing Screen Widget Tests
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/screens/landing_screen.dart';

void main() {
  Widget buildTestApp() {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B35),
          secondary: Color(0xFF00D9FF),
          surface: Color(0xFF1A1A2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      ),
      home: const LandingScreen(),
      routes: {
        '/auth': (context) => const Scaffold(body: Text('Auth Screen')),
        '/signup': (context) => const Scaffold(body: Text('Sign Up Screen')),
        '/home': (context) => const Scaffold(body: Text('Home Screen')),
      },
    );
  }

  group('LandingScreen', () {
    testWidgets('shows MUSCLE FITNESS brand name', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('MUSCLE FITNESS'), findsOneWidget);
    });

    testWidgets('shows FORGE YOUR LEGACY tagline', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('FORGE YOUR LEGACY'), findsOneWidget);
    });

    testWidgets('shows SIGN IN button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('SIGN IN'), findsOneWidget);
    });

    testWidgets('shows CREATE ACCOUNT button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    });

    testWidgets('shows Continue as Guest option', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('shows feature highlights', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('+ Workouts'), findsOneWidget);
      expect(find.text('Meal Plans'), findsOneWidget);
      expect(find.text('Track Progress'), findsOneWidget);
    });

    testWidgets('shows feature icons', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // fitness_center appears twice (hero icon + feature icon)
      expect(find.byIcon(Icons.fitness_center), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('has login and person_add icons on buttons', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.login), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('Continue as Guest navigates to home', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue as Guest'));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
    });
  });
}
