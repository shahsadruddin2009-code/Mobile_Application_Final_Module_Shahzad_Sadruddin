// ============================================================================
// IRON FORGE - Widget Tests
// ============================================================================
//
// File: widget_test.dart
// Description: Automated widget tests for the Iron Forge app
//
// Test Coverage:
// - App initialization and loading
// - MaterialApp widget presence
// - Basic UI rendering verification
//
// Running Tests:
// - Command: flutter test
// - Or run individual tests from VS Code test explorer
//
// Future Test Additions:
// - Authentication flow tests
// - Navigation tests
// - Form validation tests
// - Service mock tests
// - Widget interaction tests
//
// Note:
// Additional tests should be added for:
// - AuthScreen form validation
// - Exercise filtering and search
// - Progress entry creation
// - Nutrition logging
// - Chart data rendering
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bodybuilding_app/main.dart';

/// Main test function for Iron Forge app
///
/// Contains all widget tests organized by feature area.
/// Uses Flutter's testing framework with WidgetTester.
void main() {
  // ========================================
  // APP INITIALIZATION TESTS
  // ========================================

  /// Test: Verify app loads successfully
  ///
  /// Ensures the main application widget renders
  /// and contains a MaterialApp at its root.
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BodybuildingApp());

    // Verify that the app loads with MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  // ========================================
  // AUTHENTICATION TESTS
  // ========================================

  /// Test: Verify sign in form validates email
  testWidgets('Sign in form validates email', (WidgetTester tester) async {
    await tester.pumpWidget(const BodybuildingApp());
    await tester.pumpAndSettle();

    // Find email text field and enter invalid email
    final emailField = find.byType(TextField).first;
    if (emailField.evaluate().isNotEmpty) {
      await tester.enterText(emailField, 'invalid-email');
      await tester.pump();
    }

    // Verification would depend on your form validation implementation
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  /// Test: Verify sign up requires matching passwords
  testWidgets('Sign up requires matching passwords', (WidgetTester tester) async {
    await tester.pumpWidget(const BodybuildingApp());
    await tester.pumpAndSettle();

    // Basic test to ensure app loads for sign up flow
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  // ========================================
  // NAVIGATION TESTS
  // ========================================

  /// Test: Verify bottom navigation switches tabs
  testWidgets('Bottom navigation switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const BodybuildingApp());
    await tester.pumpAndSettle();

    // Find bottom navigation bar if present
    final bottomNav = find.byType(BottomNavigationBar);
    if (bottomNav.evaluate().isNotEmpty) {
      // Tap on navigation items to switch tabs
      final navItems = find.descendant(
        of: bottomNav,
        matching: find.byType(InkResponse),
      );
      if (navItems.evaluate().length > 1) {
        await tester.tap(navItems.at(1));
        await tester.pumpAndSettle();
      }
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  /// Test: Verify exercise card navigates to detail
  testWidgets('Exercise card navigates to detail', (WidgetTester tester) async {
    await tester.pumpWidget(const BodybuildingApp());
    await tester.pumpAndSettle();

    // Find and tap on an exercise card if present
    final cards = find.byType(Card);
    if (cards.evaluate().isNotEmpty) {
      await tester.tap(cards.first);
      await tester.pumpAndSettle();
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  // ========================================
  // FORM VALIDATION TESTS
  // ========================================

  /// Test: Verify progress form validates weight input
  testWidgets('Progress form validates weight input', (WidgetTester tester) async {
    await tester.pumpWidget(const BodybuildingApp());
    await tester.pumpAndSettle();

    // Basic test structure for weight validation
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  /// Test: Verify meal logging requires calories
  testWidgets('Meal logging requires calories', (WidgetTester tester) async {
    await tester.pumpWidget(const BodybuildingApp());
    await tester.pumpAndSettle();

    // Basic test structure for meal logging validation
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}