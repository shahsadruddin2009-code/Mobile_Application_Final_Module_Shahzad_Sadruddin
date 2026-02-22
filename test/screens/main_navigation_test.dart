// ============================================================================
// MUSCLE POWER - Main Navigation & Home Screen Widget Tests
// ============================================================================
//
// NOTE: Many screens use continuous animations (PulsingIcon, ShimmerLoading,
//       AnimatedGradientButton), so we use pump(Duration) instead of
//       pumpAndSettle() which would time out waiting for animations to stop.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodybuilding_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  /// Helper: pump enough frames for animations to render
  Future<void> pumpFrames(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 500));
  }

  // ========================================
  // APP INITIALIZATION TESTS
  // ========================================

  group('BodybuildingApp', () {
    testWidgets('renders MaterialApp', (tester) async {
      await tester.pumpWidget(const BodybuildingApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('starts at landing when not logged in', (tester) async {
      await tester.pumpWidget(const BodybuildingApp(isLoggedIn: false));
      await pumpFrames(tester);

      // Should show landing screen branding
      expect(find.textContaining('MUSCLE'), findsWidgets);
    });

    testWidgets('starts at home when logged in', (tester) async {
      await tester.pumpWidget(const BodybuildingApp(isLoggedIn: true));
      await pumpFrames(tester);

      // Should show main navigation with bottom nav bar
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('hides debug banner', (tester) async {
      await tester.pumpWidget(const BodybuildingApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('uses dark color scheme with orange primary', (tester) async {
      await tester.pumpWidget(const BodybuildingApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme!.colorScheme.primary, const Color(0xFFFF6B35));
      expect(app.theme!.colorScheme.brightness, Brightness.dark);
    });

    testWidgets('default isLoggedIn is false', (tester) async {
      await tester.pumpWidget(const BodybuildingApp());
      await pumpFrames(tester);
      // Default → landing screen, not navigation
      expect(find.byType(BottomNavigationBar), findsNothing);
    });
  });

  // ========================================
  // MAIN NAVIGATION SCREEN TESTS
  // ========================================

  group('MainNavigationScreen', () {
    testWidgets('shows bottom navigation bar with 6 tabs', (tester) async {
      await tester.pumpWidget(const BodybuildingApp(isLoggedIn: true));
      await pumpFrames(tester);

      final bottomNav = find.byType(BottomNavigationBar);
      expect(bottomNav, findsOneWidget);

      // 6 tabs: Home, Workouts, Exercises, Progress, Nutrition, Profile
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Workouts'), findsWidgets);
      expect(find.text('Exercises'), findsWidgets);
      expect(find.text('Progress'), findsWidgets);
      expect(find.text('Nutrition'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('shows Home tab icons when Home is active', (tester) async {
      await tester.pumpWidget(const BodybuildingApp(isLoggedIn: true));
      await pumpFrames(tester);

      // Home active icon + 5 outlined (inactive) icons
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center_outlined), findsOneWidget);
      expect(find.byIcon(Icons.sports_gymnastics_outlined), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_outlined), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('tapping Workouts tab switches active icon', (tester) async {
      await tester.pumpWidget(const BodybuildingApp(isLoggedIn: true));
      await pumpFrames(tester);

      // Tap the outlined (inactive) icon for Workouts
      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await pumpFrames(tester);

      // Verify BottomNavigationBar currentIndex is 1 (Workouts)
      final bnb = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bnb.currentIndex, 1);
      // Home should revert to outlined
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('tapping Exercises tab switches active icon', (tester) async {
      await tester.pumpWidget(const BodybuildingApp(isLoggedIn: true));
      await pumpFrames(tester);

      await tester.tap(find.byIcon(Icons.sports_gymnastics_outlined));
      await pumpFrames(tester);

      // Verify BottomNavigationBar currentIndex is 2 (Exercises)
      final bnb = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bnb.currentIndex, 2);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('tapping Progress tab switches active icon', (tester) async {
      await tester.pumpWidget(const BodybuildingApp(isLoggedIn: true));
      await pumpFrames(tester);

      await tester.tap(find.byIcon(Icons.trending_up_outlined));
      await pumpFrames(tester);

      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('tapping Nutrition tab switches active icon', (tester) async {
      await tester.pumpWidget(const BodybuildingApp(isLoggedIn: true));
      await pumpFrames(tester);

      await tester.tap(find.byIcon(Icons.restaurant_outlined));
      await pumpFrames(tester);

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('tapping Profile tab switches active icon', (tester) async {
      await tester.pumpWidget(const BodybuildingApp(isLoggedIn: true));
      await pumpFrames(tester);

      await tester.tap(find.byIcon(Icons.person_outline));
      await pumpFrames(tester);

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('tab switching preserves bottom nav', (tester) async {
      await tester.pumpWidget(const BodybuildingApp(isLoggedIn: true));
      await pumpFrames(tester);

      // Use icons to tap — text labels can be ambiguous with screen content
      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await pumpFrames(tester);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      await tester.tap(find.byIcon(Icons.sports_gymnastics_outlined));
      await pumpFrames(tester);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Home is now outlined because another tab is active
      await tester.tap(find.byIcon(Icons.home_outlined));
      await pumpFrames(tester);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('BottomNavigationBar has correct styling', (tester) async {
      await tester.pumpWidget(const BodybuildingApp(isLoggedIn: true));
      await pumpFrames(tester);

      final bnb = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bnb.type, BottomNavigationBarType.fixed);
      expect(bnb.items.length, 6);
      expect(bnb.selectedItemColor, const Color(0xFFFF6B35));
    });
  });
}
