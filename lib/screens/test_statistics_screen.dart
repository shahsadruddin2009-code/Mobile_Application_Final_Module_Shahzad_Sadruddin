// ============================================================================
// MUSCLE POWER - Test Statistics & Coverage Profile
// ============================================================================
//
// File: test_statistics_screen.dart
// Description: Displays comprehensive testing metrics, coverage data,
//              and quality assurance profile for the MUSCLE POWER app.
//
// Features:
// - Overall test summary (total, passed, failed, pass rate)
// - Animated stat cards with test category breakdowns
// - Per-file coverage bar charts
// - Feature coverage matrix
// - Test group detail expansion panels
// - Layer-level coverage pie-style indicators
//
// Data:
// - All statistics derived from flutter test --coverage run
// - 342 tests across 15 files, 66 groups
// - Coverage from lcov.info analysis
//
// UI Components:
// - GradientCard for section headers
// - GlassCard for data panels
// - Circular progress for coverage
// - Animated entrance transitions
// ============================================================================

import 'package:flutter/material.dart';
import '../widgets/gradient_card.dart';

// ============================================================================
// DATA MODELS
// ============================================================================

/// Represents a single test file's statistics
class TestFileStats {
  final String fileName;
  final String category;
  final int testCount;
  final int groupCount;
  final int loc;
  final bool passed;

  const TestFileStats({
    required this.fileName,
    required this.category,
    required this.testCount,
    required this.groupCount,
    required this.loc,
    this.passed = true,
  });
}

/// Represents a source file's coverage data
class CoverageStats {
  final String fileName;
  final int linesHit;
  final int linesFound;

  const CoverageStats({
    required this.fileName,
    required this.linesHit,
    required this.linesFound,
  });

  double get percentage =>
      linesFound > 0 ? (linesHit / linesFound) * 100 : 0;
}

/// Represents a test group with its test names
class TestGroupInfo {
  final String groupName;
  final int testCount;
  final List<String> testNames;

  const TestGroupInfo({
    required this.groupName,
    required this.testCount,
    required this.testNames,
  });
}

// ============================================================================
// STATIC TEST DATA
// ============================================================================

/// All test file statistics from the latest test run
const List<TestFileStats> _testFiles = [
  // Unit Tests
  TestFileStats(fileName: 'models_test.dart', category: 'Unit', testCount: 21, groupCount: 9, loc: 543),
  TestFileStats(fileName: 'encryption_service_test.dart', category: 'Unit', testCount: 47, groupCount: 9, loc: 401),
  TestFileStats(fileName: 'exercise_log_service_test.dart', category: 'Unit', testCount: 28, groupCount: 2, loc: 583),
  TestFileStats(fileName: 'nutrition_service_test.dart', category: 'Unit', testCount: 24, groupCount: 2, loc: 307),
  TestFileStats(fileName: 'progress_service_test.dart', category: 'Unit', testCount: 39, groupCount: 3, loc: 566),
  TestFileStats(fileName: 'custom_workout_service_test.dart', category: 'Unit', testCount: 17, groupCount: 2, loc: 301),
  TestFileStats(fileName: 'data_service_test.dart', category: 'Unit', testCount: 26, groupCount: 5, loc: 247),
  // Widget Tests
  TestFileStats(fileName: 'gradient_card_test.dart', category: 'Widget', testCount: 28, groupCount: 5, loc: 497),
  TestFileStats(fileName: 'stat_card_test.dart', category: 'Widget', testCount: 23, groupCount: 4, loc: 495),
  TestFileStats(fileName: 'auth_screen_test.dart', category: 'Widget', testCount: 19, groupCount: 5, loc: 235),
  TestFileStats(fileName: 'landing_screen_test.dart', category: 'Widget', testCount: 9, groupCount: 1, loc: 103),
  TestFileStats(fileName: 'main_navigation_test.dart', category: 'Widget', testCount: 15, groupCount: 2, loc: 202),
  // Integration Tests
  TestFileStats(fileName: 'service_integration_test.dart', category: 'Integration', testCount: 23, groupCount: 6, loc: 557),
  TestFileStats(fileName: 'app_integration_test.dart', category: 'Integration', testCount: 16, groupCount: 11, loc: 393),
  // Legacy
  TestFileStats(fileName: 'widget_test.dart', category: 'Legacy', testCount: 7, groupCount: 0, loc: 150),
];

/// Coverage data per source file from lcov.info
const List<CoverageStats> _coverageData = [
  CoverageStats(fileName: 'data_service.dart', linesHit: 141, linesFound: 141),
  CoverageStats(fileName: 'models.dart', linesHit: 9, linesFound: 9),
  CoverageStats(fileName: 'encryption_service.dart', linesHit: 91, linesFound: 91),
  CoverageStats(fileName: 'custom_workout_service.dart', linesHit: 92, linesFound: 93),
  CoverageStats(fileName: 'landing_screen.dart', linesHit: 121, linesFound: 123),
  CoverageStats(fileName: 'nutrition_service.dart', linesHit: 103, linesFound: 105),
  CoverageStats(fileName: 'stat_card.dart', linesHit: 92, linesFound: 95),
  CoverageStats(fileName: 'bodybuilder_animation.dart', linesHit: 472, linesFound: 490),
  CoverageStats(fileName: 'gradient_card.dart', linesHit: 115, linesFound: 121),
  CoverageStats(fileName: 'progress_service.dart', linesHit: 171, linesFound: 188),
  CoverageStats(fileName: 'exercise_log_service.dart', linesHit: 106, linesFound: 118),
  CoverageStats(fileName: 'exercises_screen.dart', linesHit: 134, linesFound: 159),
  CoverageStats(fileName: 'main.dart', linesHit: 50, linesFound: 61),
  CoverageStats(fileName: 'home_screen.dart', linesHit: 238, linesFound: 448),
  CoverageStats(fileName: 'auth_screen.dart', linesHit: 212, linesFound: 493),
  CoverageStats(fileName: 'progress_screen.dart', linesHit: 303, linesFound: 724),
  CoverageStats(fileName: 'workouts_screen.dart', linesHit: 127, linesFound: 369),
  CoverageStats(fileName: 'nutrition_screen.dart', linesHit: 198, linesFound: 586),
  CoverageStats(fileName: 'profile_screen.dart', linesHit: 24, linesFound: 391),
  CoverageStats(fileName: 'auth_service.dart', linesHit: 12, linesFound: 321),
  CoverageStats(fileName: 'exercise_illustration.dart', linesHit: 44, linesFound: 4160),
  CoverageStats(fileName: 'exercise_detail_screen.dart', linesHit: 0, linesFound: 368),
  CoverageStats(fileName: 'workout_detail_screen.dart', linesHit: 0, linesFound: 313),
];

/// Test groups with detailed breakdown
const List<TestGroupInfo> _testGroups = [
  TestGroupInfo(groupName: 'Models', testCount: 21, testNames: [
    'Exercise model — 3 tests',
    'Workout model — 2 tests',
    'SetLog model — 2 tests',
    'ExerciseLog model — 2 tests',
    'WorkoutLog model — 2 tests',
    'UserProfile model — 3 tests',
    'Meal model — 3 tests',
    'MealPlan model — 2 tests',
    'ProgressEntry model — 2 tests',
  ]),
  TestGroupInfo(groupName: 'Encryption Service', testCount: 47, testNames: [
    'Singleton pattern — 2 tests',
    'Salt generation — 4 tests',
    'Password hashing — 7 tests',
    'Password verification — 7 tests',
    'Field encryption — 5 tests',
    'Field decryption — 5 tests',
    'isEncrypted detection — 6 tests',
    'encryptIfNeeded guard — 5 tests',
    'End-to-end flows — 6 tests',
  ]),
  TestGroupInfo(groupName: 'Exercise Log Service', testCount: 28, testNames: [
    'ExerciseLogEntry model — 7 tests',
    'ExerciseLogService CRUD & queries — 21 tests',
  ]),
  TestGroupInfo(groupName: 'Nutrition Service', testCount: 24, testNames: [
    'MealLog model — 6 tests',
    'NutritionService operations — 18 tests',
  ]),
  TestGroupInfo(groupName: 'Progress Service', testCount: 39, testNames: [
    'UserBodyStats BMI calculations — 7 tests',
    'ProgressEntry model — 6 tests',
    'ProgressService operations — 26 tests',
  ]),
  TestGroupInfo(groupName: 'Custom Workout Service', testCount: 17, testNames: [
    'CustomWorkout model — 7 tests',
    'CustomWorkoutService operations — 10 tests',
  ]),
  TestGroupInfo(groupName: 'Data Service', testCount: 26, testNames: [
    'getExercises() validation — 5 tests',
    'getWorkouts() validation — 5 tests',
    'getMeals() validation — 6 tests',
    'getProgressHistory() validation — 4 tests',
    'getUserProfile() validation — 6 tests',
  ]),
  TestGroupInfo(groupName: 'Widget - GradientCard', testCount: 28, testNames: [
    'GradientCard rendering — 6 tests',
    'GlassCard rendering — 5 tests',
    'AnimatedGradientButton — 7 tests',
    'PulsingIcon animation — 5 tests',
    'ShimmerLoading animation — 5 tests',
  ]),
  TestGroupInfo(groupName: 'Widget - StatCard', testCount: 23, testNames: [
    'StatCard rendering — 5 tests',
    'AnimatedStatCard — 6 tests',
    'CircularStatCard — 7 tests',
    'MiniStatChip — 5 tests',
  ]),
  TestGroupInfo(groupName: 'Screen - AuthScreen', testCount: 19, testNames: [
    'Sign In mode — 5 tests',
    'Sign Up mode — 4 tests',
    'Mode toggle switching — 4 tests',
    'Email validation — 3 tests',
    'Social login buttons — 3 tests',
  ]),
  TestGroupInfo(groupName: 'Screen - LandingScreen', testCount: 9, testNames: [
    'Brand display, tagline, buttons, features — 9 tests',
  ]),
  TestGroupInfo(groupName: 'Screen - MainNavigation', testCount: 15, testNames: [
    'BodybuildingApp setup — 3 tests',
    'Tab navigation (6 tabs) — 12 tests',
  ]),
  TestGroupInfo(groupName: 'Integration - Services', testCount: 23, testNames: [
    'Auth + Encryption flows — 5 tests',
    'ExerciseLogService integration — 3 tests',
    'NutritionService integration — 3 tests',
    'ProgressService integration — 4 tests',
    'CustomWorkoutService integration — 4 tests',
    'DataService cross-validation — 4 tests',
  ]),
  TestGroupInfo(groupName: 'Integration - App', testCount: 16, testNames: [
    'App launch flows — 2 tests',
    'Landing → Auth navigation — 3 tests',
    '6-tab navigation flow — 2 tests',
    'Auth form interaction — 2 tests',
    'Per-tab content verification — 4 tests',
    'Rapid tab switching stress — 1 test',
    'Guest mode + Bottom nav — 2 tests',
  ]),
];

// ============================================================================
// SCREEN WIDGET
// ============================================================================

/// Test Statistics & Coverage Profile screen
///
/// Displays comprehensive QA metrics for MUSCLE POWER:
/// - Summary dashboard with animated stat cards
/// - Category breakdown (Unit / Widget / Integration)
/// - Per-file code coverage with progress bars
/// - Expandable test group details
/// - Layer-level coverage analysis
class TestStatisticsScreen extends StatefulWidget {
  const TestStatisticsScreen({super.key});

  @override
  State<TestStatisticsScreen> createState() => _TestStatisticsScreenState();
}

class _TestStatisticsScreenState extends State<TestStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Computed summary values
  int get _totalTests => _testFiles.fold(0, (sum, f) => sum + f.testCount);
  int get _totalGroups => _testFiles.fold(0, (sum, f) => sum + f.groupCount);
  int get _totalTestLoc => _testFiles.fold(0, (sum, f) => sum + f.loc);
  int get _totalLinesHit => _coverageData.fold(0, (sum, c) => sum + c.linesHit);
  int get _totalLinesFound => _coverageData.fold(0, (sum, c) => sum + c.linesFound);
  double get _overallCoverage =>
      _totalLinesFound > 0 ? (_totalLinesHit / _totalLinesFound) * 100 : 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(child: _buildHeader()),
              // Summary Cards
              SliverToBoxAdapter(child: _buildSummaryCards()),
              // Pass Rate Ring
              SliverToBoxAdapter(child: _buildPassRateRing()),
              // Category Breakdown
              SliverToBoxAdapter(child: _buildCategoryBreakdown()),
              // Test Files Detail
              SliverToBoxAdapter(child: _buildTestFilesSection()),
              // Coverage Overview
              SliverToBoxAdapter(child: _buildCoverageOverview()),
              // Per-File Coverage Bars
              SliverToBoxAdapter(child: _buildCoverageBars()),
              // Layer Coverage
              SliverToBoxAdapter(child: _buildLayerCoverage()),
              // Test Groups Detail
              SliverToBoxAdapter(child: _buildTestGroupsSection()),
              // Fully Covered Section
              SliverToBoxAdapter(child: _buildFullyCoveredSection()),
              // Footer
              SliverToBoxAdapter(child: _buildFooter()),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TEST STATISTICS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Quality Assurance Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.4),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF00E676), size: 16),
                SizedBox(width: 4),
                Text(
                  'ALL PASS',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SUMMARY CARDS
  // ==========================================================================

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          _buildMiniStat(
            icon: Icons.science_outlined,
            value: '$_totalTests',
            label: 'Tests',
            colors: [const Color(0xFFFF6B35), const Color(0xFFFF8E53)],
          ),
          const SizedBox(width: 12),
          _buildMiniStat(
            icon: Icons.folder_outlined,
            value: '${_testFiles.length}',
            label: 'Files',
            colors: [const Color(0xFF00D9FF), const Color(0xFF00B4D8)],
          ),
          const SizedBox(width: 12),
          _buildMiniStat(
            icon: Icons.category_outlined,
            value: '$_totalGroups',
            label: 'Groups',
            colors: [const Color(0xFFBB86FC), const Color(0xFF9C27B0)],
          ),
          const SizedBox(width: 12),
          _buildMiniStat(
            icon: Icons.code,
            value: '${(_totalTestLoc / 1000).toStringAsFixed(1)}k',
            label: 'LOC',
            colors: [const Color(0xFF00E676), const Color(0xFF00C853)],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
    required List<Color> colors,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors[0].withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // PASS RATE RING
  // ==========================================================================

  Widget _buildPassRateRing() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: GradientCard(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Circular pass rate indicator
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00E676),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '100%',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pass Rate',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPassRateStat('Passed', '$_totalTests', const Color(0xFF00E676)),
                  const SizedBox(height: 8),
                  _buildPassRateStat('Failed', '0', const Color(0xFFFF5252)),
                  const SizedBox(height: 8),
                  _buildPassRateStat('Skipped', '0', const Color(0xFFFFD740)),
                  const Divider(color: Colors.white12, height: 24),
                  _buildPassRateStat('Execution', '~10s', const Color(0xFF00D9FF)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassRateStat(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // CATEGORY BREAKDOWN
  // ==========================================================================

  Widget _buildCategoryBreakdown() {
    final categories = <String, Map<String, int>>{};
    for (final file in _testFiles) {
      categories.putIfAbsent(file.category, () => {'tests': 0, 'files': 0});
      categories[file.category]!['tests'] =
          categories[file.category]!['tests']! + file.testCount;
      categories[file.category]!['files'] =
          categories[file.category]!['files']! + 1;
    }

    final colors = {
      'Unit': const Color(0xFFFF6B35),
      'Widget': const Color(0xFF00D9FF),
      'Integration': const Color(0xFFBB86FC),
      'Legacy': const Color(0xFF78909C),
    };

    final icons = {
      'Unit': Icons.build_outlined,
      'Widget': Icons.widgets_outlined,
      'Integration': Icons.integration_instructions_outlined,
      'Legacy': Icons.history,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Test Categories', Icons.pie_chart_outline),
          const SizedBox(height: 12),
          // Stacked bar showing proportions
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: categories.entries.map((entry) {
                final fraction = entry.value['tests']! / _totalTests;
                return Expanded(
                  flex: (fraction * 100).round(),
                  child: Container(
                    height: 8,
                    color: colors[entry.key] ?? Colors.grey,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Category cards
          ...categories.entries.map((entry) {
            final color = colors[entry.key] ?? Colors.grey;
            final icon = icons[entry.key] ?? Icons.help;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key} Tests',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${entry.value['files']} files',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${entry.value['tests']}',
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================================================
  // TEST FILES SECTION
  // ==========================================================================

  Widget _buildTestFilesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Test Files', Icons.description_outlined),
          const SizedBox(height: 12),
          ..._testFiles.map((file) => _buildTestFileRow(file)),
        ],
      ),
    );
  }

  Widget _buildTestFileRow(TestFileStats file) {
    final color = _getCategoryColor(file.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF00E676), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file.fileName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              file.category,
              style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            child: Text(
              '${file.testCount}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // COVERAGE OVERVIEW
  // ==========================================================================

  Widget _buildCoverageOverview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: GradientCard(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E3F), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSectionTitle('Code Coverage', Icons.shield_outlined),
            const SizedBox(height: 16),
            Row(
              children: [
                // Coverage ring
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          value: _overallCoverage / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCoverageColor(_overallCoverage),
                          ),
                        ),
                      ),
                      Text(
                        '${_overallCoverage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: _getCoverageColor(_overallCoverage),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Coverage',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_totalLinesHit / $_totalLinesFound lines',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_coverageData.length} source files analyzed',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${_coverageData.where((c) => c.percentage == 100).length} files at 100%',
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // COVERAGE BARS
  // ==========================================================================

  Widget _buildCoverageBars() {
    final sorted = List<CoverageStats>.from(_coverageData)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Per-File Coverage', Icons.bar_chart),
          const SizedBox(height: 12),
          ...sorted.map((c) => _buildCoverageBar(c)),
        ],
      ),
    );
  }

  Widget _buildCoverageBar(CoverageStats coverage) {
    final pct = coverage.percentage;
    final color = _getCoverageColor(pct);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  coverage.fileName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // LAYER COVERAGE
  // ==========================================================================

  Widget _buildLayerCoverage() {
    final layers = <String, Map<String, int>>{
      'Models': {'hit': 0, 'found': 0},
      'Data': {'hit': 0, 'found': 0},
      'Services': {'hit': 0, 'found': 0},
      'Widgets': {'hit': 0, 'found': 0},
      'Screens': {'hit': 0, 'found': 0},
      'App': {'hit': 0, 'found': 0},
    };

    for (final c in _coverageData) {
      final name = c.fileName;
      String layer;
      if (name == 'models.dart') {
        layer = 'Models';
      } else if (name == 'data_service.dart') {
        layer = 'Data';
      } else if (name.contains('service')) {
        layer = 'Services';
      } else if (name.contains('screen') || name == 'main.dart') {
        layer = name == 'main.dart' ? 'App' : 'Screens';
      } else {
        layer = 'Widgets';
      }
      layers[layer]!['hit'] = layers[layer]!['hit']! + c.linesHit;
      layers[layer]!['found'] = layers[layer]!['found']! + c.linesFound;
    }

    final layerColors = {
      'Models': const Color(0xFF00E676),
      'Data': const Color(0xFF00E676),
      'Services': const Color(0xFFFF6B35),
      'Widgets': const Color(0xFFBB86FC),
      'Screens': const Color(0xFFFFD740),
      'App': const Color(0xFF00D9FF),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Coverage by Layer', Icons.layers_outlined),
          const SizedBox(height: 12),
          ...layers.entries.map((entry) {
            final hit = entry.value['hit']!;
            final found = entry.value['found']!;
            final pct = found > 0 ? (hit / found) * 100 : 0.0;
            final color = layerColors[entry.key] ?? Colors.grey;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 42,
                          height: 42,
                          child: CircularProgressIndicator(
                            value: pct / 100,
                            strokeWidth: 4,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                        Text(
                          '${pct.round()}',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$hit / $found lines',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================================================
  // TEST GROUPS DETAIL (EXPANDABLE)
  // ==========================================================================

  Widget _buildTestGroupsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Test Groups Detail', Icons.list_alt),
          const SizedBox(height: 12),
          ..._testGroups.map((group) => _buildGroupTile(group)),
        ],
      ),
    );
  }

  Widget _buildGroupTile(TestGroupInfo group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          childrenPadding:
              const EdgeInsets.only(left: 14, right: 14, bottom: 12),
          iconColor: Colors.white54,
          collapsedIconColor: Colors.white38,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  group.groupName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${group.testCount}',
                  style: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          children: group.testNames
              .map((name) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.subdirectory_arrow_right,
                            color: Colors.white24, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ==========================================================================
  // FULLY COVERED SECTION
  // ==========================================================================

  Widget _buildFullyCoveredSection() {
    final fullyCovered =
        _coverageData.where((c) => c.percentage == 100).toList();
    final nearFull =
        _coverageData.where((c) => c.percentage >= 95 && c.percentage < 100).toList()
          ..sort((a, b) => b.percentage.compareTo(a.percentage));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Coverage Highlights', Icons.star_outline),
          const SizedBox(height: 12),
          // 100% covered
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: Color(0xFF00E676), size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      '100% Coverage',
                      style: TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${fullyCovered.length} files',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...fullyCovered.map((c) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check, color: Color(0xFF00E676), size: 14),
                          const SizedBox(width: 8),
                          Text(
                            c.fileName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${c.linesHit} lines',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Near full coverage (>95%)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: Color(0xFF00D9FF), size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Near Full (>95%)',
                      style: TextStyle(
                        color: Color(0xFF00D9FF),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${nearFull.length} files',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...nearFull.map((c) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, color: Color(0xFF00D9FF), size: 8),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              c.fileName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          Text(
                            '${c.percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Color(0xFF00D9FF),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // FOOTER
  // ==========================================================================

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        children: [
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Text(
            'Generated: February 15, 2026',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Framework: Flutter Test • Runner: flutter test --coverage',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All $_totalTests tests passed — 0 failures',
            style: TextStyle(
              color: const Color(0xFF00E676).withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF6B35), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Unit':
        return const Color(0xFFFF6B35);
      case 'Widget':
        return const Color(0xFF00D9FF);
      case 'Integration':
        return const Color(0xFFBB86FC);
      default:
        return const Color(0xFF78909C);
    }
  }

  Color _getCoverageColor(double pct) {
    if (pct >= 90) return const Color(0xFF00E676);
    if (pct >= 70) return const Color(0xFF00D9FF);
    if (pct >= 50) return const Color(0xFFFFD740);
    if (pct >= 30) return const Color(0xFFFF6B35);
    return const Color(0xFFFF5252);
  }
}
