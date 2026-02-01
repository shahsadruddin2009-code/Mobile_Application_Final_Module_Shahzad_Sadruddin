// ============================================================================
// IRON FORGE - Home Screen (Dashboard)
// ============================================================================
//
// File: home_screen.dart
// Description: Main dashboard showing user progress and quick actions
//
// Features:
// - Personalized greeting with user's first name
// - Today's progress card with circular percentage indicator
// - Quick stats grid (workouts, time, calories, achievements)
// - Featured workouts horizontal carousel
// - Quick action buttons (Start Workout, Log Progress)
// - Weekly challenge card with progress tracking
// - Notification bell button
//
// Data Sources:
// - User profile from DataService.getUserProfile()
// - Workouts from DataService.getWorkouts()
// - Progress data from ProgressService
// - Auth info from AuthService for user name
//
// UI Components:
// - ScaleTransition animated progress card
// - StatCard widgets for statistics display
// - GradientCard for weekly challenge
// - Horizontal ListView for workout carousel
// - Bouncing scroll physics for fluid scrolling
//
// Navigation:
// - Workout cards -> WorkoutDetailScreen
// - Start Workout -> Workout selection dialog
// - Log Progress -> Progress logging dialog
// ============================================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../data/data_service.dart';
import '../widgets/gradient_card.dart';
import '../widgets/stat_card.dart';
import 'workout_detail_screen.dart';
import 'package:intl/intl.dart';
import '../services/progress_service.dart';
import '../services/exercise_log_service.dart';

/// Main dashboard home screen
///
/// Displays a comprehensive overview of the user's fitness journey:
/// - Today's workout progress with visual indicators
/// - Accumulated statistics (total workouts, time, calories)
/// - Featured workout recommendations
/// - Quick action shortcuts for common tasks
///
/// Uses [SingleTickerProviderStateMixin] for entrance animations.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final user = DataService.getUserProfile();
  final workouts = DataService.getWorkouts();

  // Services for real user data
  final ProgressService _progressService = ProgressService();
  final ExerciseLogService _exerciseLogService = ExerciseLogService();

  // Dynamic stats from user data
  int _totalWorkouts = 0;
  int _totalMinutes = 0;
  int _totalCaloriesBurned = 0;
  int _todayExercises = 0;
  int _todayCalories = 0;
  int _todayMinutes = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
    _loadUserStats();
  }

  /// Load real user statistics from services
  Future<void> _loadUserStats() async {
    await _progressService.init();
    await _exerciseLogService.init();

    // Get exercise statistics
    final exerciseStats = _exerciseLogService.getStatistics();

    // Calculate today's stats
    final today = DateTime.now();
    final todayEntries = _exerciseLogService.getEntriesForDate(today);

    // Calculate total minutes (estimate: 5 min per set)
    int totalSets = exerciseStats['totalSets'] as int;
    int estimatedMinutes = totalSets * 5;

    // Calculate total calories (estimate: 8 calories per set)
    int estimatedCalories = totalSets * 8;

    // Today's stats
    int todaySets = todayEntries.fold(0, (sum, e) => sum + e.sets);
    int todayCalories = todaySets * 8;
    int todayMinutes = todaySets * 5;

    if (mounted) {
      setState(() {
        _totalWorkouts = exerciseStats['totalWorkouts'] as int;
        _totalMinutes = estimatedMinutes;
        _totalCaloriesBurned = estimatedCalories;
        _todayExercises = todayEntries.length;
        _todayCalories = todayCalories;
        _todayMinutes = todayMinutes;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AuthService().currentUser?['firstName'] ?? 'Athlete',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B35).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Today's Progress Card
            SliverToBoxAdapter(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A1A2E),
                        Color(0xFF16213E),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Today's Progress",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _todayExercises > 0
                                    ? 'Great work today! 💪'
                                    : 'Start your workout! 💪',
                                style: const TextStyle(
                                  color: Color(0xFFFF6B35),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          CircularPercentIndicator(
                            radius: 45,
                            lineWidth: 8,
                            // Calculate progress based on daily goal (e.g., 5 exercises per day)
                            percent: (_todayExercises / 5).clamp(0.0, 1.0),
                            center: Text(
                              '${((_todayExercises / 5) * 100).clamp(0, 100).toInt()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            progressColor: const Color(0xFFFF6B35),
                            backgroundColor: Colors.grey[800]!,
                            circularStrokeCap: CircularStrokeCap.round,
                            animation: true,
                            animationDuration: 1500,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildProgressItem(
                            icon: Icons.local_fire_department,
                            value: '$_todayCalories',
                            label: 'Calories',
                            color: const Color(0xFFFF6B35),
                          ),
                          _buildProgressItem(
                            icon: Icons.timer,
                            value: '$_todayMinutes',
                            label: 'Minutes',
                            color: const Color(0xFF00D9FF),
                          ),
                          _buildProgressItem(
                            icon: Icons.fitness_center,
                            value: '$_todayExercises',
                            label: 'Exercises',
                            color: const Color(0xFFFFD700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Quick Stats Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Stats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.fitness_center,
                            value: '$_totalWorkouts',
                            label: 'Workouts',
                            gradient: const [
                              Color(0xFFFF6B35),
                              Color(0xFFFF8E53)
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.timer,
                            value:
                                '${(_totalMinutes / 60).toStringAsFixed(0)}h',
                            label: 'Total Time',
                            gradient: const [
                              Color(0xFF00D9FF),
                              Color(0xFF00B4D8)
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.local_fire_department,
                            value:
                                '${(_totalCaloriesBurned / 1000).toStringAsFixed(1)}k',
                            label: 'Calories',
                            gradient: const [
                              Color(0xFFFFD700),
                              Color(0xFFFFA500)
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.emoji_events,
                            value: '${user.achievements.length}',
                            label: 'Achievements',
                            gradient: const [
                              Color(0xFF9B59B6),
                              Color(0xFF8E44AD)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Featured Workouts Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Workouts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'See All',
                        style: TextStyle(color: Color(0xFFFF6B35)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Featured Workouts Horizontal List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return _buildWorkoutCard(context, workout, index);
                  },
                ),
              ),
            ),

            // Quick Actions Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.play_circle_filled,
                            label: 'Start Workout',
                            gradient: const [
                              Color(0xFFFF6B35),
                              Color(0xFFFF8E53)
                            ],
                            onTap: () => _showStartWorkoutDialog(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.add_circle,
                            label: 'Log Progress',
                            gradient: const [
                              Color(0xFF00D9FF),
                              Color(0xFF00B4D8)
                            ],
                            onTap: () => _showLogProgressDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Weekly Challenge Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => _showWeeklyChallengeDialog(context),
                  child: GradientCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Weekly Challenge',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Complete ${_exerciseLogService.weeklyGoal} workouts this week!',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_exerciseLogService.weeklyWorkoutCount}/${_exerciseLogService.weeklyGoal}',
                                  style: const TextStyle(
                                    color: Color(0xFF9B59B6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (_exerciseLogService.weeklyWorkoutCount / _exerciseLogService.weeklyGoal).clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _exerciseLogService.weeklyWorkoutCount >= _exerciseLogService.weeklyGoal
                                    ? '🎉 Challenge Complete!'
                                    : '${_exerciseLogService.weeklyGoal - _exerciseLogService.weeklyWorkoutCount} more to go',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const Text(
                                'Tap to change goal',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(BuildContext context, workout, int index) {
    final colors = [
      [const Color(0xFFFF6B35), const Color(0xFFFF8E53)],
      [const Color(0xFF00D9FF), const Color(0xFF00B4D8)],
      [const Color(0xFFFFD700), const Color(0xFFFFA500)],
      [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
      [const Color(0xFF27AE60), const Color(0xFF2ECC71)],
      [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
    ];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(workout: workout),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors[index % colors.length],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[index % colors.length][0].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.fitness_center,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      workout.muscleGroup,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    workout.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        workout.duration,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.caloriesBurned}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartWorkoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Choose a Workout',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a workout to start your training session',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final workout = workouts[index];
                        final colors = [
                          [const Color(0xFFFF6B35), const Color(0xFFFF8E53)],
                          [const Color(0xFF00D9FF), const Color(0xFF00B4D8)],
                          [const Color(0xFFFFD700), const Color(0xFFFFA500)],
                          [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
                          [const Color(0xFF27AE60), const Color(0xFF2ECC71)],
                          [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
                        ];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WorkoutDetailScreen(workout: workout),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F0F1A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colors[index % colors.length][0]
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: colors[index % colors.length],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        workout.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${workout.muscleGroup} • ${workout.duration} • ${workout.exercises.length} exercises',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[600],
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLogProgressDialog(BuildContext context) {
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final bodyFatController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Log Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your body measurements',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
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
                          primary: Color(0xFF00D9FF),
                          surface: Color(0xFF1A1A2E),
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F1A),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFF00D9FF)),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
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
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.monitor_weight,
                          color: Color(0xFF00D9FF),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
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
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.height,
                          color: Color(0xFF00D9FF),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
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
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.percent,
                    color: Color(0xFF00D9FF),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final weight = double.tryParse(weightController.text);
                    final height = double.tryParse(heightController.text);
                    final bodyFat = double.tryParse(bodyFatController.text);

                    if (weight != null) {
                      final progressService = ProgressService();
                      await progressService.init();

                      final entry = ProgressEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        date: selectedDate,
                        weight: weight,
                        height: height,
                        bodyFat: bodyFat,
                      );
                      await progressService.addEntry(entry);

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Progress logged successfully!'),
                          backgroundColor: Color(0xFF27AE60),
                        ),
                      );
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter at least your weight'),
                          backgroundColor: Color(0xFFE74C3C),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Save Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeeklyChallengeDialog(BuildContext context) {
    int selectedGoal = _exerciseLogService.weeklyGoal;
    final goalOptions = [3, 5, 7, 10, 14, 20];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Icon(
                    Icons.emoji_events,
                    color: Color(0xFF9B59B6),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Weekly Challenge Goal',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How many workouts do you want to complete this week?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: goalOptions.map((goal) {
                      final isSelected = selectedGoal == goal;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedGoal = goal),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                                  )
                                : null,
                            color: isSelected ? null : const Color(0xFF0F0F1A),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected 
                                  ? Colors.transparent 
                                  : const Color(0xFF9B59B6).withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF9B59B6).withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$goal',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.grey[400],
                                ),
                              ),
                              Text(
                                'workouts',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected ? Colors.white70 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B59B6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF9B59B6),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedGoal <= 3
                                ? 'Great for beginners! Start steady.'
                                : selectedGoal <= 5
                                    ? 'A balanced goal for consistent progress.'
                                    : selectedGoal <= 7
                                        ? 'Everyday commitment! Stay dedicated.'
                                        : selectedGoal <= 10
                                            ? 'Intense schedule! You\'re serious!'
                                            : 'Beast mode! Maximum dedication! 💪',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await _exerciseLogService.setWeeklyGoal(selectedGoal);
                        if (mounted) {
                          navigator.pop();
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B59B6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Set Challenge',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
