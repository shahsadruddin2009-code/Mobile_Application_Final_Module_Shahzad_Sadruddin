// ============================================================================
// MUSCLE POWER - Test Statistics Screen Widget Tests
// ============================================================================
//
// File: test_statistics_screen_test.dart
// Description: Comprehensive widget tests for the TestStatisticsScreen,
//              verifying all sections render correctly with proper data.
//
// Test Groups:
// 1. Screen Rendering — basic scaffold, header, navigation
// 2. Summary Cards — total tests, files, groups, LOC
// 3. Pass Rate Ring — 100% indicator and breakdown stats
// 4. Category Breakdown — Unit, Widget, Integration, Legacy cards
// 5. Test Files List — all 15 test files with pass icons
// 6. Coverage Overview — overall percentage ring and line counts
// 7. Coverage Bars — per-file coverage with progress indicators
// 8. Layer Coverage — Models, Data, Services, Widgets, Screens, App
// 9. Test Groups Detail — expandable panels with sub-tests
// 10. Coverage Highlights — 100% files and near-full (>95%)
// 11. Footer — generation date and pass summary
// 12. Data Model Validation — TestFileStats, CoverageStats, TestGroupInfo
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/screens/test_statistics_screen.dart';

void main() {
  /// Helper to build the test app with correct theme and navigation
  Widget buildTestApp() {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B35),
          secondary: Color(0xFF00D9FF),
          surface: Color(0xFF1A1A2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      ),
      home: const TestStatisticsScreen(),
    );
  }

  /// Helper to scroll until a widget is visible in the CustomScrollView
  Future<void> scrollTo(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(
      target,
      200,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 50,
    );
    await tester.pumpAndSettle();
  }

  // ==========================================================================
  // 1. SCREEN RENDERING
  // ==========================================================================

  group('Screen Rendering', () {
    testWidgets('renders Scaffold with dark background', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.backgroundColor, const Color(0xFF0D0D0D));
    });

    testWidgets('renders header with TEST STATISTICS label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('TEST STATISTICS'), findsOneWidget);
    });

    testWidgets('renders Quality Assurance Profile title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Quality Assurance Profile'), findsOneWidget);
    });

    testWidgets('renders ALL PASS badge', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('ALL PASS'), findsOneWidget);
    });

    testWidgets('has back button in header', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('uses CustomScrollView', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('wraps content in SafeArea', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });

    testWidgets('uses FadeTransition for entrance animation', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(FadeTransition), findsAtLeastNWidgets(1));
    });
  });

  // ==========================================================================
  // 2. SUMMARY CARDS
  // ==========================================================================

  group('Summary Cards', () {
    testWidgets('displays total test count 342', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // 342 appears in summary card and in footer
      expect(find.text('342'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays file count 15', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('15'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays group count 66', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('66'), findsOneWidget);
    });

    testWidgets('displays LOC value 5.6k', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('5.6k'), findsOneWidget);
    });

    testWidgets('shows Tests label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Tests'), findsOneWidget);
    });

    testWidgets('shows Files label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Files'), findsOneWidget);
    });

    testWidgets('shows Groups label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Groups'), findsOneWidget);
    });

    testWidgets('shows LOC label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('LOC'), findsOneWidget);
    });

    testWidgets('shows science icon for tests', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.science_outlined), findsOneWidget);
    });

    testWidgets('shows folder icon for files', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    });
  });

  // ==========================================================================
  // 3. PASS RATE RING
  // ==========================================================================

  group('Pass Rate Ring', () {
    testWidgets('shows 100% pass rate text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('shows Pass Rate label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Pass Rate'), findsOneWidget);
    });

    testWidgets('shows Passed stat', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Passed'), findsOneWidget);
    });

    testWidgets('shows Failed stat', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('shows Skipped stat', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Skipped'), findsOneWidget);
    });

    testWidgets('shows Execution time ~10s', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('~10s'), findsOneWidget);
    });

    testWidgets('renders CircularProgressIndicator widgets', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });
  });

  // ==========================================================================
  // 4. CATEGORY BREAKDOWN
  // ==========================================================================

  group('Category Breakdown', () {
    testWidgets('shows Test Categories section title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Test Categories'));
      expect(find.text('Test Categories'), findsOneWidget);
    });

    testWidgets('shows pie chart icon', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.byIcon(Icons.pie_chart_outline));
      expect(find.byIcon(Icons.pie_chart_outline), findsOneWidget);
    });

    testWidgets('displays Unit Tests category', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Unit Tests'));
      expect(find.text('Unit Tests'), findsOneWidget);
    });

    testWidgets('displays Widget Tests category', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Widget Tests'));
      expect(find.text('Widget Tests'), findsOneWidget);
    });

    testWidgets('displays Integration Tests category', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Integration Tests'));
      expect(find.text('Integration Tests'), findsOneWidget);
    });

    testWidgets('displays Legacy Tests category', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Legacy Tests'));
      expect(find.text('Legacy Tests'), findsOneWidget);
    });

    testWidgets('shows unit test count 202', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('202'));
      expect(find.text('202'), findsOneWidget);
    });

    testWidgets('shows widget test count 94', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('94'));
      expect(find.text('94'), findsOneWidget);
    });

    testWidgets('shows integration test count 39', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Unit Tests'));
      expect(find.text('39'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows category icons', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Unit Tests'));
      expect(find.byIcon(Icons.build_outlined), findsOneWidget);
      expect(find.byIcon(Icons.widgets_outlined), findsOneWidget);
    });

    testWidgets('shows file counts per category', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('7 files'));
      expect(find.text('7 files'), findsOneWidget);
    });
  });

  // ==========================================================================
  // 5. TEST FILES LIST
  // ==========================================================================

  group('Test Files List', () {
    testWidgets('shows Test Files section title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Test Files'));
      expect(find.text('Test Files'), findsOneWidget);
    });

    testWidgets('shows description icon', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Test Files'));
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('shows models_test.dart file entry', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('models_test.dart'));
      expect(find.text('models_test.dart'), findsOneWidget);
    });

    testWidgets('shows encryption_service_test.dart entry', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('encryption_service_test.dart'));
      expect(find.text('encryption_service_test.dart'), findsOneWidget);
    });

    testWidgets('shows check circle icons for passed files', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Test Files'));
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Unit category badge text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('models_test.dart'));
      expect(find.text('Unit'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows test count 47 for encryption service', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('encryption_service_test.dart'));
      expect(find.text('47'), findsAtLeastNWidgets(1));
    });
  });

  // ==========================================================================
  // 6. COVERAGE OVERVIEW
  // ==========================================================================

  group('Coverage Overview', () {
    testWidgets('shows Code Coverage section title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Code Coverage'));
      expect(find.text('Code Coverage'), findsOneWidget);
    });

    testWidgets('shows shield icon', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Code Coverage'));
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets('shows Overall Coverage label', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Overall Coverage'));
      expect(find.text('Overall Coverage'), findsOneWidget);
    });

    testWidgets('shows source files analyzed count', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('23 source files analyzed'));
      expect(find.text('23 source files analyzed'), findsOneWidget);
    });

    testWidgets('shows files at 100% coverage', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('3 files at 100%'));
      expect(find.text('3 files at 100%'), findsOneWidget);
    });

    testWidgets('shows total lines hit / found', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('2855 / 9967 lines'));
      expect(find.text('2855 / 9967 lines'), findsOneWidget);
    });
  });

  // ==========================================================================
  // 7. COVERAGE BARS
  // ==========================================================================

  group('Coverage Bars', () {
    testWidgets('shows Per-File Coverage section title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Per-File Coverage'));
      expect(find.text('Per-File Coverage'), findsOneWidget);
    });

    testWidgets('shows bar chart icon', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Per-File Coverage'));
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    });

    testWidgets('renders LinearProgressIndicator bars', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Per-File Coverage'));
      expect(find.byType(LinearProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('shows data_service.dart coverage entry', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Per-File Coverage'));
      expect(find.text('data_service.dart'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows 100.0% for fully covered files', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Per-File Coverage'));
      expect(find.text('100.0%'), findsAtLeastNWidgets(1));
    });
  });

  // ==========================================================================
  // 8. LAYER COVERAGE
  // ==========================================================================

  group('Layer Coverage', () {
    testWidgets('shows Coverage by Layer section title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Coverage by Layer'));
      expect(find.text('Coverage by Layer'), findsOneWidget);
    });

    testWidgets('shows layers icon', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Coverage by Layer'));
      expect(find.byIcon(Icons.layers_outlined), findsOneWidget);
    });

    testWidgets('displays Models layer', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Coverage by Layer'));
      expect(find.text('Models'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays Services layer', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Services'));
      expect(find.text('Services'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays Screens layer', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Screens'));
      expect(find.text('Screens'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays App layer', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Coverage by Layer'));
      expect(find.text('App'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows circular progress for layers', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Coverage by Layer'));
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });
  });

  // ==========================================================================
  // 9. TEST GROUPS DETAIL
  // ==========================================================================

  group('Test Groups Detail', () {
    testWidgets('shows Test Groups Detail section title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Test Groups Detail'));
      expect(find.text('Test Groups Detail'), findsOneWidget);
    });

    testWidgets('shows list alt icon', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Test Groups Detail'));
      expect(find.byIcon(Icons.list_alt), findsOneWidget);
    });

    testWidgets('renders ExpansionTile widgets', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Test Groups Detail'));
      expect(find.byType(ExpansionTile), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Encryption Service group', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Encryption Service'));
      expect(find.text('Encryption Service'), findsOneWidget);
    });

    testWidgets('shows Data Service group', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Data Service'));
      expect(find.text('Data Service'), findsOneWidget);
    });

    testWidgets('expansion reveals sub-tests when tapped', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Scroll to and tap the Encryption Service group
      await scrollTo(tester, find.text('Encryption Service'));

      // Before tap: sub-test names not visible
      expect(find.text('Singleton pattern — 2 tests'), findsNothing);

      await tester.tap(find.text('Encryption Service'));
      await tester.pumpAndSettle();

      // After tap: sub-tests visible
      expect(find.text('Singleton pattern — 2 tests'), findsOneWidget);
      expect(find.text('Salt generation — 4 tests'), findsOneWidget);
    });

    testWidgets('shows subdirectory arrows after expansion', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Encryption Service'));
      await tester.tap(find.text('Encryption Service'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.subdirectory_arrow_right),
          findsAtLeastNWidgets(1));
    });

    testWidgets('shows test count badge on group tiles', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Encryption Service'));
      expect(find.text('47'), findsAtLeastNWidgets(1));
    });
  });

  // ==========================================================================
  // 10. COVERAGE HIGHLIGHTS
  // ==========================================================================

  group('Coverage Highlights', () {
    testWidgets('shows Coverage Highlights section title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Coverage Highlights'));
      expect(find.text('Coverage Highlights'), findsOneWidget);
    });

    testWidgets('shows star icon', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Coverage Highlights'));
      expect(find.byIcon(Icons.star_outline), findsOneWidget);
    });

    testWidgets('shows 100% Coverage heading', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('100% Coverage'));
      expect(find.text('100% Coverage'), findsOneWidget);
    });

    testWidgets('shows verified icon', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('100% Coverage'));
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('shows 3 files count for full coverage', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('100% Coverage'));
      expect(find.text('3 files'), findsOneWidget);
    });

    testWidgets('shows Near Full heading', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Near Full (>95%)'));
      expect(find.text('Near Full (>95%)'), findsOneWidget);
    });

    testWidgets('shows trending up icon', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Near Full (>95%)'));
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });
  });

  // ==========================================================================
  // 11. FOOTER
  // ==========================================================================

  group('Footer', () {
    testWidgets('shows generation date', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Generated: February 15, 2026'));
      expect(find.text('Generated: February 15, 2026'), findsOneWidget);
    });

    testWidgets('shows framework info', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final target = find.text(
          'Framework: Flutter Test • Runner: flutter test --coverage');
      await scrollTo(tester, target);
      expect(target, findsOneWidget);
    });

    testWidgets('shows all tests passed summary', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final target = find.text('All 342 tests passed — 0 failures');
      await scrollTo(tester, target);
      expect(target, findsOneWidget);
    });
  });

  // ==========================================================================
  // 12. DATA MODEL VALIDATION
  // ==========================================================================

  group('TestFileStats Model', () {
    test('creates instance with all fields', () {
      const stat = TestFileStats(
        fileName: 'test.dart',
        category: 'Unit',
        testCount: 10,
        groupCount: 3,
        loc: 200,
      );

      expect(stat.fileName, 'test.dart');
      expect(stat.category, 'Unit');
      expect(stat.testCount, 10);
      expect(stat.groupCount, 3);
      expect(stat.loc, 200);
      expect(stat.passed, true);
    });

    test('supports passed = false', () {
      const stat = TestFileStats(
        fileName: 'fail.dart',
        category: 'Widget',
        testCount: 5,
        groupCount: 1,
        loc: 50,
        passed: false,
      );

      expect(stat.passed, false);
    });
  });

  group('CoverageStats Model', () {
    test('creates instance with all fields', () {
      const cov = CoverageStats(
        fileName: 'service.dart',
        linesHit: 80,
        linesFound: 100,
      );

      expect(cov.fileName, 'service.dart');
      expect(cov.linesHit, 80);
      expect(cov.linesFound, 100);
    });

    test('calculates percentage correctly', () {
      const cov = CoverageStats(
        fileName: 'file.dart',
        linesHit: 75,
        linesFound: 100,
      );
      expect(cov.percentage, 75.0);
    });

    test('returns 100% for fully covered file', () {
      const cov = CoverageStats(
        fileName: 'full.dart',
        linesHit: 200,
        linesFound: 200,
      );
      expect(cov.percentage, 100.0);
    });

    test('returns 0% when no lines found', () {
      const cov = CoverageStats(
        fileName: 'empty.dart',
        linesHit: 0,
        linesFound: 0,
      );
      expect(cov.percentage, 0.0);
    });

    test('returns 0% when zero lines hit', () {
      const cov = CoverageStats(
        fileName: 'missed.dart',
        linesHit: 0,
        linesFound: 50,
      );
      expect(cov.percentage, 0.0);
    });

    test('computes fractional percentages', () {
      const cov = CoverageStats(
        fileName: 'partial.dart',
        linesHit: 1,
        linesFound: 3,
      );
      expect(cov.percentage, closeTo(33.33, 0.01));
    });
  });

  group('TestGroupInfo Model', () {
    test('creates instance with all fields', () {
      const group = TestGroupInfo(
        groupName: 'Auth',
        testCount: 5,
        testNames: ['Login test', 'Signup test'],
      );

      expect(group.groupName, 'Auth');
      expect(group.testCount, 5);
      expect(group.testNames.length, 2);
      expect(group.testNames[0], 'Login test');
    });

    test('supports empty test names list', () {
      const group = TestGroupInfo(
        groupName: 'Empty',
        testCount: 0,
        testNames: [],
      );
      expect(group.testNames, isEmpty);
    });
  });
}
