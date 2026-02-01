// ============================================================================
// IRON FORGE - Workout Detail Screen
// ============================================================================
//
// File: workout_detail_screen.dart
// Description: Detailed workout view with exercise list and active tracking
//
// Features:
// - Gradient header with workout info and image
// - Workout statistics (duration, calories, exercise count, difficulty)
// - Target muscles display with chips
// - Exercise list with navigation to exercise details
// - Active workout mode with set/rep tracking
// - Weight tracking for each exercise
// - Bookmark and share functionality (placeholder)
//
// Workout Information Displayed:
// - Workout name and description
// - Primary muscle group
// - Duration estimate
// - Calorie burn estimate
// - Difficulty level
// - Target muscles list
//
// Exercise List Features:
// - Animated exercise illustrations
// - Sets and reps display
// - Configurable weight per exercise
// - Tap to view full exercise details
// - Current exercise highlighting during active workout
//
// Active Workout Mode:
// - Track completion of each set
// - Adjust weight in real-time
// - Rest timer between sets
// - Progress through exercises sequentially
//
// Color Coding by Muscle Group:
// - Chest: Red/Orange
// - Back: Blue
// - Shoulders: Purple
// - Arms: Green
// - Legs: Gold
// - Core: Cyan
// - Push/Pull: Orange/Cyan
// ============================================================================

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/exercise_illustration.dart';
import 'exercise_detail_screen.dart';

/// Detailed workout view screen
///
/// Shows comprehensive workout information and allows users to:
/// - View all exercises in the workout
/// - Start an active workout session
/// - Track sets, reps, and weights
/// - Navigate to individual exercise details
///
/// The [workout] parameter contains all workout data including exercises.
class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isWorkoutStarted = false;
  int _currentExerciseIndex = 0;

  // Track sets and weights for each exercise
  late Map<int, int> _exerciseSets; // exercise index -> number of sets
  late Map<int, double> _exerciseWeights; // exercise index -> weight in kg

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Initialize sets and weights from exercise defaults
    _exerciseSets = {};
    _exerciseWeights = {};
    for (int i = 0; i < widget.workout.exercises.length; i++) {
      _exerciseSets[i] = widget.workout.exercises[i].sets;
      _exerciseWeights[i] = 20.0; // Default weight 20kg
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _primaryColor {
    switch (widget.workout.muscleGroup) {
      case 'Chest':
        return const Color(0xFFE74C3C);
      case 'Back':
        return const Color(0xFF3498DB);
      case 'Shoulders':
        return const Color(0xFF9B59B6);
      case 'Arms':
        return const Color(0xFF27AE60);
      case 'Legs':
        return const Color(0xFFFFD700);
      case 'Core':
        return const Color(0xFF00D9FF);
      case 'Push':
        return const Color(0xFFFF6B35);
      case 'Pull':
        return const Color(0xFF00D9FF);
      default:
        return const Color(0xFFFF6B35);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Gradient Header
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1A1A2E),
            leadingWidth: 110,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.home, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bookmark_border, color: Colors.white),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image for workouts with images
                  if (widget.workout.imageUrl.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(widget.workout.imageUrl),
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                        color: _primaryColor,
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _primaryColor,
                            _primaryColor.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  // Dark overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Decorative Elements
                  Positioned(
                    right: -50,
                    bottom: -50,
                    child: Icon(
                      Icons.fitness_center,
                      size: 200,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  // Content
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.workout.muscleGroup,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.workout.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.workout.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Workout Stats
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.timer_outlined,
                      widget.workout.duration,
                      'Duration',
                    ),
                    _buildStatItem(
                      Icons.local_fire_department,
                      '${widget.workout.caloriesBurned}',
                      'Calories',
                    ),
                    _buildStatItem(
                      Icons.fitness_center,
                      '${widget.workout.exercises.length}',
                      'Exercises',
                    ),
                    _buildStatItem(
                      Icons.speed,
                      widget.workout.difficulty,
                      'Level',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Target Muscles
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Target Muscles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.workout.targetMuscles.map((muscle) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _primaryColor.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          muscle,
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Exercises Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Exercises',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${widget.workout.exercises.length} exercises',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Exercises List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final exercise = widget.workout.exercises[index];
                final isCompleted =
                    _isWorkoutStarted && index < _currentExerciseIndex;
                final isCurrent =
                    _isWorkoutStarted && index == _currentExerciseIndex;
                final currentSets = _exerciseSets[index] ?? exercise.sets;
                final currentWeight = _exerciseWeights[index] ?? 20.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? _primaryColor.withOpacity(0.2)
                          : const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCurrent ? _primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Exercise header - tappable for details
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExerciseDetailScreen(exercise: exercise),
                              ),
                            );
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color(0xFF27AE60)
                                    : _primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: ExerciseIllustration(
                                        exerciseName: exercise.name,
                                        size: 60,
                                        primaryColor: _primaryColor,
                                        secondaryColor: const Color(0xFF00D9FF),
                                        animate: isCurrent,
                                      ),
                                    ),
                            ),
                            title: Text(
                              exercise.name,
                              style: TextStyle(
                                color: isCompleted
                                    ? Colors.grey[500]
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Text(
                                    '${exercise.reps} reps • ${exercise.restTime} rest',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                          ),
                        ),

                        // Sets and Weight Controls
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Sets Control
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SETS',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _buildControlButton(
                                          Icons.remove,
                                          () {
                                            if (currentSets > 1) {
                                              setState(() {
                                                _exerciseSets[index] =
                                                    currentSets - 1;
                                              });
                                            }
                                          },
                                        ),
                                        Container(
                                          width: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '$currentSets',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        _buildControlButton(
                                          Icons.add,
                                          () {
                                            if (currentSets < 10) {
                                              setState(() {
                                                _exerciseSets[index] =
                                                    currentSets + 1;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Divider
                              Container(
                                height: 50,
                                width: 1,
                                color: Colors.grey[700],
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                              ),

                              // Weight Control
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'WEIGHT (KG)',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _buildControlButton(
                                          Icons.remove,
                                          () {
                                            if (currentWeight > 0) {
                                              setState(() {
                                                _exerciseWeights[index] =
                                                    currentWeight - 2.5;
                                              });
                                            }
                                          },
                                        ),
                                        Container(
                                          width: 50,
                                          alignment: Alignment.center,
                                          child: Text(
                                            currentWeight % 1 == 0
                                                ? '${currentWeight.toInt()}'
                                                : currentWeight
                                                    .toStringAsFixed(1),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        _buildControlButton(
                                          Icons.add,
                                          () {
                                            if (currentWeight < 500) {
                                              setState(() {
                                                _exerciseWeights[index] =
                                                    currentWeight + 2.5;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: widget.workout.exercises.length,
            ),
          ),

          // Bottom Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Start Workout Button
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width - 40,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: FloatingActionButton.extended(
          onPressed: () {
            if (!_isWorkoutStarted) {
              setState(() {
                _isWorkoutStarted = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Workout started! 💪'),
                  backgroundColor: _primaryColor,
                ),
              );
            } else if (_currentExerciseIndex <
                widget.workout.exercises.length - 1) {
              setState(() {
                _currentExerciseIndex++;
              });
            } else {
              // Workout completed
              _showWorkoutCompleteDialog();
            }
          },
          backgroundColor: _primaryColor,
          icon: Icon(
            _isWorkoutStarted ? Icons.check : Icons.play_arrow,
            color: Colors.white,
          ),
          label: Text(
            _isWorkoutStarted
                ? (_currentExerciseIndex < widget.workout.exercises.length - 1
                    ? 'Complete Exercise'
                    : 'Finish Workout')
                : 'Start Workout',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: _primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _primaryColor.withOpacity(0.4),
          ),
        ),
        child: Icon(
          icon,
          color: _primaryColor,
          size: 18,
        ),
      ),
    );
  }

  void _showWorkoutCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Workout Complete!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Great job! You crushed ${widget.workout.name}!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCompleteStatItem(
                      Icons.timer,
                      widget.workout.duration,
                      'Duration',
                    ),
                    _buildCompleteStatItem(
                      Icons.local_fire_department,
                      '${widget.workout.caloriesBurned}',
                      'Calories',
                    ),
                    _buildCompleteStatItem(
                      Icons.fitness_center,
                      '${widget.workout.exercises.length}',
                      'Exercises',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompleteStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
