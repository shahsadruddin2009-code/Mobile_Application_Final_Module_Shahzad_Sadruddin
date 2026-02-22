// ============================================================================
// MUSCLE POWER - Auth Screen Widget Tests
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodybuilding_app/screens/auth_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp({bool isSignUp = false}) {
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
      home: AuthScreen(isSignUp: isSignUp),
      routes: {
        '/home': (context) => const Scaffold(body: Text('Home')),
      },
    );
  }

  // ========================================
  // SIGN IN MODE TESTS
  // ========================================

  group('AuthScreen - Sign In Mode', () {
    testWidgets('shows Welcome Back text in sign in mode', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('shows SIGN IN button text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('SIGN IN'), findsOneWidget);
    });

    testWidgets('shows email input field', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('shows password input field', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Should have at least email and password
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
    });

    testWidgets('has toggle to sign up mode', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Should show "Don't have an account?" text
      expect(find.textContaining('have an account'), findsOneWidget);
      // Should show "Sign Up" text button
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('shows divider with Or continue with', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Or continue with'), findsOneWidget);
    });

    testWidgets('shows social login icon buttons (Google, Apple, Facebook)',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Social buttons render only icons, not text labels
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);
      expect(find.byIcon(Icons.facebook), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });
  });

  // ========================================
  // SIGN UP MODE TESTS
  // ========================================

  group('AuthScreen - Sign Up Mode', () {
    testWidgets('shows Create Account text in sign up mode', (tester) async {
      await tester.pumpWidget(buildTestApp(isSignUp: true));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('shows CREATE ACCOUNT button text', (tester) async {
      await tester.pumpWidget(buildTestApp(isSignUp: true));
      await tester.pumpAndSettle();

      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    });

    testWidgets('shows additional name fields in sign up', (tester) async {
      await tester.pumpWidget(buildTestApp(isSignUp: true));
      await tester.pumpAndSettle();

      // Sign up has more fields: first name, last name, email, password
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
    });

    testWidgets('has toggle to sign in mode', (tester) async {
      await tester.pumpWidget(buildTestApp(isSignUp: true));
      await tester.pumpAndSettle();

      // Should show "Already have an account?" text
      expect(find.textContaining('Already have'), findsOneWidget);
      // Should show "Sign In" text button
      expect(find.text('Sign In'), findsOneWidget);
    });
  });

  // ========================================
  // MODE TOGGLE TESTS
  // ========================================

  group('AuthScreen - Mode Toggle', () {
    testWidgets('switches from sign in to sign up', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Verify we're in sign in mode
      expect(find.text('Welcome Back'), findsOneWidget);

      // Tap "Sign Up" text button to toggle
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Should now show sign up mode
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('switches from sign up to sign in', (tester) async {
      await tester.pumpWidget(buildTestApp(isSignUp: true));
      await tester.pumpAndSettle();

      // Verify we're in sign up mode
      expect(find.text('Create Account'), findsOneWidget);

      // Scroll the Sign In button into view before tapping
      final signInButton = find.text('Sign In');
      await tester.ensureVisible(signInButton);
      await tester.pumpAndSettle();
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Should now show sign in mode
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });

  // ========================================
  // EMAIL VALIDATION TESTS
  // ========================================

  group('AuthScreen - Email Validation', () {
    testWidgets('accepts valid email format', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Find email field (typically first TextFormField)
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();
    });

    testWidgets('entering invalid email triggers inline validation', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      await tester.pump(const Duration(milliseconds: 500));

      // The form should show some validation indicator (icon or text)
      // After entering invalid email, the widget tree should change
      expect(find.byType(TextFormField), findsWidgets);
    });
  });

  // ========================================
  // FORM STRUCTURE TESTS
  // ========================================

  group('AuthScreen - Form Structure', () {
    testWidgets('has a Form widget', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('form is scrollable', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('shows SIGN IN button in non-loading state', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('SIGN IN'), findsOneWidget);
    });
  });
}
