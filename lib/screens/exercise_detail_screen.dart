// ============================================================================
// MUSCLE POWER - Exercise Detail Screen
// ============================================================================
//
// File: exercise_detail_screen.dart
// Description: Detailed view for individual exercises with workout logging
//
// Features:
// - Animated exercise illustration header
// - Exercise metadata (muscle group, difficulty, equipment)
// - Configurable sets, reps, and weight controls
// - Date picker for logging workouts on specific dates
// - Set completion tracking with visual indicators
// - Rest timer functionality
// - Form tips and technique guidance
// - Workout history for the selected exercise
//
// Workout Logging:
// - Users can log exercise performance for any date
// - Tracks sets completed, reps performed, and weight used
// - Saves to ExerciseLogService for progress tracking
// - Shows existing entry indicator when date already logged
//
// UI Components:
// - SliverAppBar with gradient background and exercise illustration
// - Expandable set tracker cards
// - Weight adjustment controls with increment/decrement buttons
// - Animated progress indicators
//
// Color Coding:
// - Each muscle group has a unique accent color
// - Difficulty badges use traffic light colors
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../widgets/exercise_illustration.dart';
import '../services/exercise_log_service.dart';

/// Detailed exercise view screen with workout logging capabilities
///
/// Displays comprehensive information about a single exercise including:
/// - Animated visual demonstration
/// - Recommended sets, reps, and rest times
/// - Form tips and technique guidance
/// - Equipment requirements
///
/// Provides interactive workout logging:
/// - Configurable sets and weight
/// - Date selection for historical logging
/// - Set-by-set completion tracking
/// - Automatic saving to progress history
class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentSet = 0;
  List<bool> _completedSets = [];

  // User-editable sets, reps and weight
  late int _numberOfSets;
  late int _numberOfReps;
  double _currentWeight = 50.0;

  // Exercise logging
  final ExerciseLogService _logService = ExerciseLogService();
  DateTime _selectedDate = DateTime.now();
  ExerciseLogEntry? _existingEntry;

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
    _numberOfSets = widget.exercise.sets;
    _numberOfReps = widget.exercise.reps;
    _completedSets = List.filled(_numberOfSets, false);
    _initLogService();
  }

  Future<void> _initLogService() async {
    await _logService.init();
    _loadExistingEntry();
    if (mounted) setState(() {});
  }

  void _loadExistingEntry() {
    _existingEntry = null;
    final entries = _logService.getEntriesForExercise(widget.exercise.name);
    for (final entry in entries) {
      if (entry.date.year == _selectedDate.year &&
          entry.date.month == _selectedDate.month &&
          entry.date.day == _selectedDate.day) {
        _existingEntry = entry;
        _numberOfSets = entry.sets;
        _numberOfReps = entry.reps;
        _currentWeight = entry.weight;
        _completedSets = List.filled(_numberOfSets, true);
        break;
      }
    }
  }

  void _updateSets(int newSets) {
    setState(() {
      _numberOfSets = newSets;
      final oldCompleted = List<bool>.from(_completedSets);
      _completedSets = List.filled(newSets, false);
      for (int i = 0; i < oldCompleted.length && i < newSets; i++) {
        _completedSets[i] = oldCompleted[i];
      }
      if (_currentSet >= newSets) {
        _currentSet = newSets - 1;
        if (_currentSet < 0) _currentSet = 0;
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _primaryColor,
              surface: const Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _currentSet = 0;
        _completedSets = List.filled(_numberOfSets, false);
      });
      _loadExistingEntry();
      setState(() {});
    }
  }

  Future<void> _saveWorkoutLog() async {
    final entry = ExerciseLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseName: widget.exercise.name,
      muscleGroup: widget.exercise.muscleGroup,
      date: _selectedDate,
      sets: _numberOfSets,
      reps: _numberOfReps,
      weight: _currentWeight,
    );

    await _logService.logExercise(entry);
    _existingEntry = entry;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Workout logged for ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF27AE60),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _primaryColor {
    switch (widget.exercise.muscleGroup) {
      case 'Chest':
        return const Color(0xFF00CED1);
      case 'Back':
        return const Color(0xFF3498DB);
      case 'Shoulders':
        return const Color(0xFF9B59B6);
      case 'Arms':
        return const Color(0xFF27AE60);
      case 'Legs':
        return const Color(0xFFFFD700);
      case 'Core':
        return const Color.fromARGB(255, 87, 198, 218);
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
          SliverAppBar(
            expandedHeight: 300,
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
                      shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border, color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _primaryColor,
                          _primaryColor.withOpacity(0.8),
                          const Color(0xFF1A1A2E)
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: ExerciseIllustration(
                        exerciseName: widget.exercise.name,
                        size: 180,
                        primaryColor: Colors.white,
                        secondaryColor: const Color(0xFFFFD700),
                        animate: true,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0F0F1A).withOpacity(0.8),
                            const Color(0xFF0F0F1A)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(widget.exercise.muscleGroup,
                              style: TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: _getDifficultyColor(
                                      widget.exercise.difficulty)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(widget.exercise.difficulty,
                              style: TextStyle(
                                  color: _getDifficultyColor(
                                      widget.exercise.difficulty),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(widget.exercise.name,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.sports_martial_arts,
                            color: Colors.grey[300], size: 18),
                        const SizedBox(width: 8),
                        Text(widget.exercise.equipment,
                            style: TextStyle(
                                color: Colors.grey[300], fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Date Selector Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          _primaryColor.withOpacity(0.2),
                          _primaryColor.withOpacity(0.1)
                        ]),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: _primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: _primaryColor, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Workout Date',
                                    style: TextStyle(
                                        color: Colors.grey[300], fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                    DateFormat('EEEE, MMM d, yyyy')
                                        .format(_selectedDate),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _selectDate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                            child: const Text('Change',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    if (_existingEntry != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: const Color(0xFF27AE60).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                color: Color(0xFF27AE60), size: 16),
                            const SizedBox(width: 8),
                            Text('Already logged for this date',
                                style: TextStyle(
                                    color: Colors.green[300], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Sets and Weight Controls
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: _primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text('SETS',
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildControlButton(Icons.remove, () {
                                      if (_numberOfSets > 1) {
                                        _updateSets(_numberOfSets - 1);
                                      }
                                    }),
                                    Container(
                                        width: 50,
                                        alignment: Alignment.center,
                                        child: Text('$_numberOfSets',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24))),
                                    _buildControlButton(Icons.add, () {
                                      if (_numberOfSets < 10) {
                                        _updateSets(_numberOfSets + 1);
                                      }
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                              height: 60,
                              width: 1,
                              color: Colors.grey[700],
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16)),
                          Expanded(
                            child: Column(
                              children: [
                                Text('WEIGHT (KG)',
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildControlButton(Icons.remove, () {
                                      if (_currentWeight > 0) {
                                        setState(() => _currentWeight -= 2.5);
                                      }
                                    }),
                                    Container(
                                      width: 60,
                                      alignment: Alignment.center,
                                      child: Text(
                                          _currentWeight % 1 == 0
                                              ? '${_currentWeight.toInt()}'
                                              : _currentWeight
                                                  .toStringAsFixed(1),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24)),
                                    ),
                                    _buildControlButton(Icons.add, () {
                                      if (_currentWeight < 500) {
                                        setState(() => _currentWeight += 2.5);
                                      }
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reps and Rest
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text('REPS',
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildControlButton(Icons.remove, () {
                                      if (_numberOfReps > 1) {
                                        setState(() => _numberOfReps--);
                                      }
                                    }),
                                    Container(
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: Text('$_numberOfReps',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24)),
                                    ),
                                    _buildControlButton(Icons.add, () {
                                      if (_numberOfReps < 100) {
                                        setState(() => _numberOfReps++);
                                      }
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                              width: 1, height: 60, color: Colors.grey[700]),
                          Expanded(
                            child: Column(
                              children: [
                                Text('REST',
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.timer,
                                        color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(widget.exercise.restTime,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    const Text('How to Perform',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 12),
                    Text(widget.exercise.description,
                        style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                            height: 1.6)),
                    const SizedBox(height: 24),

                    // Tips
                    const Text('Pro Tips',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 12),
                    ...widget.exercise.tips.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                  color: _primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                  child: Text('${entry.key + 1}',
                                      style: TextStyle(
                                          color: _primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(entry.value,
                                    style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 14,
                                        height: 1.4))),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Set Tracker
                    const Text('Set Tracker',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_numberOfSets, (index) {
                        final isCompleted = index < _completedSets.length &&
                            _completedSets[index];
                        final isCurrent = index == _currentSet;
                        return GestureDetector(
                          onTap: () {
                            if (index < _completedSets.length) {
                              setState(() {
                                _completedSets[index] = !_completedSets[index];
                                if (_completedSets[index] &&
                                    _currentSet == index) {
                                  _currentSet = index + 1;
                                }
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: isCompleted
                                  ? const LinearGradient(colors: [
                                      Color(0xFF27AE60),
                                      Color(0xFF2ECC71)
                                    ])
                                  : null,
                              color:
                                  isCompleted ? null : const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: isCurrent
                                      ? _primaryColor
                                      : (isCompleted
                                          ? Colors.transparent
                                          : Colors.grey[700]!),
                                  width: isCurrent ? 2 : 1),
                              boxShadow: isCompleted
                                  ? [
                                      BoxShadow(
                                          color: const Color(0xFF27AE60)
                                              .withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4))
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 28)
                                  : Text('${index + 1}',
                                      style: TextStyle(
                                          color: isCurrent
                                              ? _primaryColor
                                              : Colors.grey[500],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width - 40,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: FloatingActionButton.extended(
          onPressed: () async {
            if (_currentSet < _numberOfSets) {
              setState(() {
                if (_currentSet < _completedSets.length) {
                  _completedSets[_currentSet] = true;
                }
                _currentSet++;
              });
              if (_currentSet == _numberOfSets) {
                await _saveWorkoutLog();
              }
            } else if (_completedSets.every((s) => s)) {
              await _saveWorkoutLog();
            }
          },
          backgroundColor: _completedSets.every((s) => s)
              ? const Color(0xFF27AE60)
              : _primaryColor,
          icon: Icon(
              _completedSets.every((s) => s) ? Icons.save : Icons.play_arrow,
              color: Colors.white),
          label: Text(
            _completedSets.every((s) => s)
                ? 'Save Workout Log'
                : 'Complete Set ${_currentSet + 1}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _primaryColor.withOpacity(0.4))),
        child: Icon(icon, color: _primaryColor, size: 20),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF27AE60);
      case 'intermediate':
        return const Color(0xFFFFD700);
      case 'advanced':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }
}
