// ============================================================================
// MUSCLE POWER - Progress Tracking Screen
// ============================================================================
//
// File: progress_screen.dart
// Description: Comprehensive progress tracking with charts and history
//
// Features:
// - Multi-tab interface (Overview, Weight, Body, Exercises)
// - Weight trend line chart with FL Chart library
// - Body measurement tracking (chest, waist, arms, etc.)
// - Exercise-specific progress graphs
// - BMI display with category indicator
// - Add/edit progress entries
// - User stats management (age, height, weight)
//
// Tabs:
// 1. Overview Tab:
//    - My Body Stats card (age, height, weight, BMI)
//    - Current progress summary (weight, workouts, exercises)
//    - Recent entries list
//
// 2. Weight Tab:
//    - Line chart showing weight trend over time
//    - Weight history list with dates
//    - Visual indicators for weight changes
//
// 3. Body Tab:
//    - BMI card with category and color coding
//    - Body measurements display
//    - Measurement comparison charts
//
// 4. Exercises Tab:
//    - Exercise selector dropdown
//    - Weight progression chart per exercise
//    - Volume tracking (sets × reps × weight)
//
// Data Sources:
// - ProgressService: Weight and body measurements
// - ExerciseLogService: Exercise-specific logs
// - UserBodyStats: BMI calculation and categories
//
// Charts:
// - Uses fl_chart library for line graphs
// - Curved lines with gradient fill
// - Interactive touch points
// - Auto-scaling axes
// ============================================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/progress_service.dart';
import '../services/exercise_log_service.dart';
import '../services/nutrition_service.dart';

/// Progress tracking screen with charts and analytics
///
/// Provides a comprehensive view of the user's fitness journey through:
/// - Visual charts for weight trends
/// - Body measurement tracking
/// - Exercise-specific progress
/// - BMI monitoring with health indicators
///
/// Uses [TabController] for navigating between different progress views.
/// Data is loaded from both ProgressService and ExerciseLogService.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProgressService _progressService = ProgressService();
  final ExerciseLogService _exerciseLogService = ExerciseLogService();
  final NutritionService _nutritionService = NutritionService();

  String? _selectedExercise;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initServices();
  }

  Future<void> _initServices() async {
    await _progressService.init();
    await _exerciseLogService.init();
    await _nutritionService.init();
    final exercises = _exerciseLogService.getLoggedExerciseNames();
    if (exercises.isNotEmpty && _selectedExercise == null) {
      _selectedExercise = exercises.first;
    }
    if (mounted) setState(() {});
  }

  /// Get daily calorie statistics for a specific date
  Map<String, int> _getDailyCalorieStats(DateTime date) {
    // Get calories intake from meals
    final mealsOnDate = _nutritionService.mealLogs.where((m) =>
        m.loggedAt.year == date.year &&
        m.loggedAt.month == date.month &&
        m.loggedAt.day == date.day);
    final caloriesIntake = mealsOnDate.fold<int>(0, (sum, m) => sum + m.calories);

    // Get calories burned from exercises
    final exercisesOnDate = _exerciseLogService.entries.where((e) =>
        e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day);
    final userWeight = _progressService.userStats.weight ?? 70.0;
    final totalSets = exercisesOnDate.fold<int>(0, (sum, e) => sum + e.sets);
    final durationHours = (totalSets * 2) / 60.0;
    final caloriesBurned = (5.0 * userWeight * durationHours).round();

    return {
      'intake': caloriesIntake,
      'burned': caloriesBurned,
      'net': caloriesIntake - caloriesBurned,
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progress Tracker',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Track your fitness journey',
                          style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14)),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)]),
                            borderRadius: BorderRadius.circular(15)),
                        child: IconButton(
                            onPressed: () => _showAddProgressDialog(context),
                            icon: const Icon(Icons.add),
                            color: Colors.white,
                            tooltip: 'Add progress entry'),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: const Color(0xFFFF6B35).withOpacity(0.3))),
                        child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            color: Colors.white,
                            tooltip: 'Go back'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(15)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)]),
                    borderRadius: BorderRadius.circular(12)),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFFB0B0B0),
                labelStyle:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Weight'),
                  Tab(text: 'Body'),
                  Tab(text: 'Exercises')
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildWeightTab(),
                  _buildBodyTab(),
                  _buildExercisesTab()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final stats = _progressService.userStats;
    final entries = _progressService.entries;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('My Body Stats',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    IconButton(
                        icon: const Icon(Icons.edit,
                            color: Color(0xFFFF6B35), size: 20),
                        onPressed: _showEditUserStatsDialog),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildUserStatItem(
                        'Age',
                        stats.age != null ? '${stats.age}' : '--',
                        'yrs',
                        const Color(0xFFFF6B35)),
                    _buildUserStatItem(
                        'Height',
                        stats.height != null
                            ? '${stats.height!.toInt()}'
                            : '--',
                        'cm',
                        const Color(0xFF00D9FF)),
                    _buildUserStatItem(
                        'Weight',
                        stats.weight != null
                            ? stats.weight!.toStringAsFixed(1)
                            : '--',
                        'kg',
                        const Color(0xFFFFD700)),
                    _buildUserStatItem(
                        'BMI',
                        stats.bmi != null
                            ? stats.bmi!.toStringAsFixed(1)
                            : '--',
                        stats.bmiCategory,
                        Color(stats.bmiCategoryColor)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCurrentProgressCard(),
          const SizedBox(height: 20),
          _buildDailyCaloriesCard(),
          const SizedBox(height: 20),
          const Text('Recent Entries',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                  child: Column(children: [
                Icon(Icons.fitness_center, color: Colors.grey[600], size: 48),
                const SizedBox(height: 12),
                Text('No progress entries yet',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                const SizedBox(height: 8),
                Text('Tap + to add your first entry',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14))
              ])),
            )
          else
            ...entries.take(3).map((entry) => _buildProgressEntryCard(entry)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildUserStatItem(
      String label, String value, String unit, Color color) {
    return Column(
      children: [
        Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)))),
        const SizedBox(height: 8),
        Text(unit,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
        Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 12)),
      ],
    );
  }

  Widget _buildCurrentProgressCard() {
    final entries = _progressService.entries;
    final latestWeight = entries.isNotEmpty ? entries.first.weight : null;
    final stats = _exerciseLogService.getStatistics();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Progress',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildStatBox(
                      'Weight',
                      latestWeight != null
                          ? '${latestWeight.toStringAsFixed(1)} kg'
                          : '--',
                      Icons.monitor_weight,
                      const Color(0xFFFF6B35))),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatBox('Workouts', '${stats['totalWorkouts']}',
                      Icons.fitness_center, const Color(0xFF00D9FF))),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatBox(
                      'Exercises',
                      '${stats['uniqueExercises']}',
                      Icons.list_alt,
                      const Color(0xFFFFD700))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }

  /// Daily Calorie Statistics Card showing intake, burned, and net calories
  Widget _buildDailyCaloriesCard() {
    final today = DateTime.now();
    final stats = _getDailyCalorieStats(today);
    final caloriesIntake = stats['intake']!;
    final caloriesBurned = stats['burned']!;
    final netCalories = stats['net']!;

    // Get last 7 days for the mini chart
    List<Map<String, int>> weeklyStats = [];
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      weeklyStats.add(_getDailyCalorieStats(date));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Calories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  DateFormat('MMM d').format(today),
                  style: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildCalorieStatItem(
                  'Intake',
                  caloriesIntake,
                  Icons.restaurant,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCalorieStatItem(
                  'Burned',
                  caloriesBurned,
                  Icons.local_fire_department,
                  const Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCalorieStatItem(
                  'Net',
                  netCalories,
                  Icons.balance,
                  netCalories >= 0 ? const Color(0xFF00D9FF) : const Color(0xFFE74C3C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Weekly Overview',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final dayStats = weeklyStats[index];
                final intake = dayStats['intake']!;
                final burned = dayStats['burned']!;
                final date = today.subtract(Duration(days: 6 - index));
                const maxVal = 2500; // Normalize to reasonable daily max
                final intakeHeight = (intake / maxVal * 50).clamp(2.0, 50.0);
                final burnedHeight = (burned / maxVal * 50).clamp(2.0, 50.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 8,
                          height: intakeHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Container(
                          width: 8,
                          height: burnedHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('E').format(date).substring(0, 1),
                      style: TextStyle(
                        color: index == 6 ? Colors.white : Colors.grey[500],
                        fontSize: 10,
                        fontWeight: index == 6 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              Text('Intake', style: TextStyle(color: Colors.grey[300], fontSize: 10)),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              Text('Burned', style: TextStyle(color: Colors.grey[300], fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieStatItem(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
          Text(
            'kcal',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTab() {
    final entries = _progressService.entries;
    if (entries.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.show_chart, color: Colors.grey[600], size: 64),
        const SizedBox(height: 16),
        Text('No weight data yet',
            style: TextStyle(color: Colors.grey[500], fontSize: 18)),
        Text('Add entries to see your progress',
            style: TextStyle(color: Colors.grey[600], fontSize: 14))
      ]));
    }
    final sortedEntries = List<ProgressEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    final spots = sortedEntries
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
        .toList();
    final minY = (spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 5)
        .clamp(0.0, double.infinity);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weight Trend',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 20),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5,
                          getDrawingHorizontalLine: (value) =>
                              FlLine(color: Colors.grey[800]!, strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (value == idx.toDouble() &&
                                      idx >= 0 &&
                                      idx < sortedEntries.length) {
                                    return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                            DateFormat('d/M').format(
                                                sortedEntries[idx].date),
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 10)));
                                  }
                                  return const SizedBox.shrink();
                                })),
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) => Text(
                                    '${value.toInt()}',
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 10)))),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (spots.length - 1).toDouble(),
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFFD700)]),
                          barWidth: 3,
                          dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                      radius: 4,
                                      color: const Color(0xFFFF6B35),
                                      strokeWidth: 2,
                                      strokeColor: Colors.white)),
                          belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFFFF6B35).withOpacity(0.3),
                                    const Color(0xFFFF6B35).withOpacity(0.0)
                                  ])),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Weight History',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 12),
          ...entries.take(10).map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMM d, yyyy').format(entry.date),
                        style: TextStyle(color: Colors.grey[300])),
                    Text('${entry.weight.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBodyTab() {
    final stats = _progressService.userStats;
    final entries = _progressService.entries;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(stats.bmiCategoryColor).withOpacity(0.2),
                const Color(0xFF1A1A2E)
              ]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Color(stats.bmiCategoryColor).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: Color(stats.bmiCategoryColor).withOpacity(0.2),
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text(stats.bmi?.toStringAsFixed(1) ?? '--',
                              style: TextStyle(
                                  color: Color(stats.bmiCategoryColor),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('BMI',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text(stats.bmiCategory,
                            style: TextStyle(
                                color: Color(stats.bmiCategoryColor),
                                fontSize: 16)),
                        Text('Body Mass Index',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Body Fat %',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 16),
                if (entries.isNotEmpty && entries.first.bodyFat != null)
                  Text('${entries.first.bodyFat!.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          color: Color(0xFF00D9FF),
                          fontSize: 32,
                          fontWeight: FontWeight.bold))
                else
                  Text('Not recorded',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Body Measurements',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 12),
          if (entries.isNotEmpty)
            _buildMeasurementsList(entries.first)
          else
            Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                    child: Text('No measurements recorded',
                        style: TextStyle(color: Colors.grey[500])))),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMeasurementsList(ProgressEntry entry) {
    final measurements = [
      if (entry.chest != null)
        {
          'name': 'Chest',
          'value': entry.chest!,
          'icon': Icons.accessibility_new
        },
      if (entry.waist != null)
        {'name': 'Waist', 'value': entry.waist!, 'icon': Icons.straighten},
      if (entry.hips != null)
        {'name': 'Hips', 'value': entry.hips!, 'icon': Icons.accessibility},
      if (entry.arms != null)
        {'name': 'Biceps', 'value': entry.arms!, 'icon': Icons.fitness_center},
      if (entry.thighs != null)
        {
          'name': 'Thighs',
          'value': entry.thighs!,
          'icon': Icons.directions_walk
        },
    ];
    if (measurements.isEmpty) {
      return Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20)),
          child: Center(
              child: Text('No measurements recorded',
                  style: TextStyle(color: Colors.grey[500]))));
    }
    return Column(
      children: measurements
          .map((m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8)),
                        child: Icon(m['icon'] as IconData,
                            color: const Color(0xFFFF6B35), size: 20)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Text(m['name'] as String,
                            style: const TextStyle(color: Colors.white))),
                    Text('${(m['value'] as double).toStringAsFixed(1)} cm',
                        style: const TextStyle(
                            color: Color(0xFFFF6B35),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // NEW: Exercise Statistics Tab with Graphs
  Widget _buildExercisesTab() {
    final loggedExercises = _exerciseLogService.getLoggedExerciseNames();

    if (loggedExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, color: Colors.grey[600], size: 64),
            const SizedBox(height: 16),
            Text('No exercise logs yet',
                style: TextStyle(color: Colors.grey[500], fontSize: 18)),
            const SizedBox(height: 8),
            Text('Log workouts from exercise details',
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 8),
            Text('to see your progress charts',
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Selector Dropdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Exercise',
                    style: TextStyle(color: Colors.grey[300], fontSize: 12)),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedExercise,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Color(0xFFFF6B35)),
                  items: loggedExercises
                      .map((name) =>
                          DropdownMenuItem(value: name, child: Text(name)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedExercise = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_selectedExercise != null) ...[
            // Weight Progress Chart
            _buildExerciseWeightChart(_selectedExercise!),
            const SizedBox(height: 20),

            // Exercise History List
            _buildExerciseHistoryList(_selectedExercise!),
          ],

          const SizedBox(height: 20),

          // All Exercises Summary
          const Text('All Exercises Summary',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 12),
          ...loggedExercises.map((name) => _buildExerciseSummaryCard(name)),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildExerciseWeightChart(String exerciseName) {
    final history = _exerciseLogService.getWeightHistory(exerciseName);

    if (history.length < 2) {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.show_chart, color: Colors.grey[600], size: 48),
              const SizedBox(height: 12),
              Text('Need at least 2 entries',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              Text('to show progress chart',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      );
    }

    final spots = history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value['weight'] as double))
        .toList();
    final weights = history.map((h) => h['weight'] as double).toList();
    final minY = (weights.reduce((a, b) => a < b ? a : b) - 5)
        .clamp(0.0, double.infinity);
    final maxY = weights.reduce((a, b) => a > b ? a : b) + 5;

    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weight Progress',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('${history.length} entries',
                    style: const TextStyle(
                        color: Color(0xFF27AE60), fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey[800]!, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (value == idx.toDouble() &&
                                idx >= 0 &&
                                idx < history.length) {
                              final date = history[idx]['date'] as DateTime;
                              return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(DateFormat('d/M').format(date),
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 9)));
                            }
                            return const SizedBox.shrink();
                          })),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 10)))),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                        colors: [Color(0xFF00D9FF), Color(0xFF27AE60)]),
                    barWidth: 3,
                    dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                                radius: 4,
                                color: const Color(0xFF00D9FF),
                                strokeWidth: 2,
                                strokeColor: Colors.white)),
                    belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF00D9FF).withOpacity(0.3),
                              const Color(0xFF00D9FF).withOpacity(0.0)
                            ])),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseHistoryList(String exerciseName) {
    final entries = _exerciseLogService.getEntriesForExercise(exerciseName);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Workout History',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 16),
          ...entries.take(5).map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text('${entry.weight.toInt()}',
                              style: const TextStyle(
                                  color: Color(0xFFFF6B35),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat('EEEE, MMM d').format(entry.date),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(
                              '${entry.sets} sets x ${entry.reps} reps @ ${entry.weight} kg',
                              style: TextStyle(
                                  color: Colors.grey[300], fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: Colors.grey[600], size: 20),
                      onPressed: () async {
                        await _exerciseLogService.deleteEntry(entry.id);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              )),
          if (entries.length > 5)
            Center(
                child: Text('+ ${entries.length - 5} more entries',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildExerciseSummaryCard(String exerciseName) {
    final entries = _exerciseLogService.getEntriesForExercise(exerciseName);
    if (entries.isEmpty) return const SizedBox();

    final latest = entries.first;
    final maxWeight =
        entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _selectedExercise == exerciseName
                ? const Color(0xFFFF6B35)
                : Colors.transparent),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedExercise = exerciseName),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color(0xFFFF6B35).withOpacity(0.3),
                  const Color(0xFFFFD700).withOpacity(0.2)
                ]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                  child: Icon(Icons.fitness_center,
                      color: Color(0xFFFF6B35), size: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exerciseName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                      '${entries.length} workouts | Max: ${maxWeight.toStringAsFixed(1)} kg',
                      style: TextStyle(color: Colors.grey[300], fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${latest.weight} kg',
                    style: const TextStyle(
                        color: Color(0xFF00D9FF), fontWeight: FontWeight.bold)),
                Text(DateFormat('MMM d').format(latest.date),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressEntryCard(ProgressEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
            child: const Center(
                child: Icon(Icons.monitor_weight, color: Color(0xFFFF6B35))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('EEEE, MMM d').format(entry.date),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${entry.weight.toStringAsFixed(1)} kg',
                    style: TextStyle(color: Colors.grey[300])),
              ],
            ),
          ),
          if (entry.bodyFat != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFF00D9FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${entry.bodyFat!.toStringAsFixed(1)}% BF',
                  style:
                      const TextStyle(color: Color(0xFF00D9FF), fontSize: 12)),
            ),
        ],
      ),
    );
  }

  void _showAddProgressDialog(BuildContext context) {
    final weightController = TextEditingController();
    final heightController = TextEditingController(
        text: _progressService.userStats.height?.toInt().toString() ?? '');
    final bodyFatController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text('Log Progress',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                          data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFFFF6B35),
                                  surface: Color(0xFF1A1A2E))),
                          child: child!));
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFF0F0F1A),
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today, color: Color(0xFFFF6B35)),
                    const SizedBox(width: 12),
                    Text(DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
                        style: const TextStyle(color: Colors.white))
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: weightController,
                        decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: const Color(0xFF0F0F1A),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.monitor_weight,
                                color: Color(0xFFFF6B35))),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: heightController,
                        decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: const Color(0xFF0F0F1A),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.height,
                                color: Color(0xFF00D9FF))),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 16),
              TextField(
                  controller: bodyFatController,
                  decoration: InputDecoration(
                      labelText: 'Body Fat % (optional)',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFF0F0F1A),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none),
                      prefixIcon:
                          const Icon(Icons.percent, color: Color(0xFFFFD700))),
                  style: const TextStyle(color: Colors.white),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final weight = double.tryParse(weightController.text);
                    final height = double.tryParse(heightController.text);
                    final bodyFat = double.tryParse(bodyFatController.text);
                    if (weight != null) {
                      final entry = ProgressEntry(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          date: selectedDate,
                          weight: weight,
                          height: height,
                          bodyFat: bodyFat);
                      await _progressService.addEntry(entry);
                      if (mounted) {
                        setState(() {});
                        nav.pop();
                        messenger.showSnackBar(const SnackBar(
                            content: Text('Progress logged successfully!'),
                            backgroundColor: Color(0xFF27AE60)));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: const Text('Save Entry',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditUserStatsDialog() {
    final stats = _progressService.userStats;
    final ageController =
        TextEditingController(text: stats.age?.toString() ?? '');
    final heightController =
        TextEditingController(text: stats.height?.toInt().toString() ?? '');
    final weightController =
        TextEditingController(text: stats.weight?.toStringAsFixed(1) ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const Text('Edit Body Stats',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 24),
            TextField(
                controller: ageController,
                decoration: InputDecoration(
                    labelText: 'Age',
                    filled: true,
                    fillColor: const Color(0xFF0F0F1A),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                    prefixIcon:
                        const Icon(Icons.cake, color: Color(0xFFFF6B35))),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: heightController,
                      decoration: InputDecoration(
                          labelText: 'Height (cm)',
                          filled: true,
                          fillColor: const Color(0xFF0F0F1A),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.height,
                              color: Color(0xFF00D9FF))),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                  child: TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          filled: true,
                          fillColor: const Color(0xFF0F0F1A),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.monitor_weight,
                              color: Color(0xFFFFD700))),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true))),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final nav = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  await _progressService.updateUserStats(
                      age: int.tryParse(ageController.text),
                      height: double.tryParse(heightController.text),
                      weight: double.tryParse(weightController.text));
                  if (mounted) {
                    setState(() {});
                    nav.pop();
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Body stats updated!'),
                        backgroundColor: Color(0xFF27AE60)));
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: const Text('Save Changes',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
