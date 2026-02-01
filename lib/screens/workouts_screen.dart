// ============================================================================
// IRON FORGE - Workouts Screen
// ============================================================================
//
// File: workouts_screen.dart
// Description: Browse and manage workout programs
//
// Features:
// - Tabbed navigation by muscle group/category
// - Pre-built workout programs (8+ workouts)
// - Workout cards with key information
// - Create custom workout modal
// - Filter by: All, Chest, Back, Shoulders, Arms, Legs, Core, Push, Pull
// - Navigate to workout details on tap
//
// Workout Categories:
// - All: Shows all available workouts
// - Chest: Chest-focused workouts
// - Back: Back and pulling workouts
// - Shoulders: Shoulder workouts
// - Arms: Bicep and tricep focused
// - Legs: Lower body workouts
// - Core: Abdominal and core workouts
// - Push: Push day compound workouts
// - Pull: Pull day compound workouts
//
// Workout Card Information:
// - Workout name and description
// - Muscle group and difficulty badges
// - Duration, calorie burn, exercise count
// - Color-coded by category
//
// Create Custom Workout:
// - Floating action button opens modal
// - Enter workout name and description
// - Placeholder for full workout builder
//
// Data Source:
// - Workouts from DataService.getWorkouts()
// ============================================================================

import 'package:flutter/material.dart';
import '../data/data_service.dart';
import '../models/models.dart';
import '../services/custom_workout_service.dart';
import 'workout_detail_screen.dart';

/// Workout browsing and management screen
///
/// Displays all available workout programs with filtering by category.
/// Users can browse workouts, view details, and create custom workouts.
///
/// Uses [SingleTickerProviderStateMixin] for the category tab controller.
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = [
    'All',
    'My Workouts',
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
    'Push',
    'Pull',
  ];

  String _selectedCategory = 'All';
  final workouts = DataService.getWorkouts();
  final CustomWorkoutService _customWorkoutService = CustomWorkoutService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = _categories[_tabController.index];
      });
    });
    _initCustomWorkouts();
  }

  Future<void> _initCustomWorkouts() async {
    await _customWorkoutService.init();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Workout> get filteredWorkouts {
    if (_selectedCategory == 'My Workouts') {
      return _customWorkoutService.customWorkoutsAsWorkouts;
    }
    
    // Combine built-in and custom workouts
    final allWorkouts = [...workouts, ..._customWorkoutService.customWorkoutsAsWorkouts];
    
    if (_selectedCategory == 'All') return allWorkouts;
    return allWorkouts
        .where((w) => w.muscleGroup == _selectedCategory)
        .toList();
  }

  bool _isCustomWorkout(Workout workout) {
    return _customWorkoutService.getWorkout(workout.id) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Workout Plans',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your workout and start training',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),

            // Category Tabs
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 16),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                indicatorColor: const Color(0xFFFF6B35),
                indicatorWeight: 3,
                labelColor: const Color(0xFFFF6B35),
                unselectedLabelColor: Colors.grey[500],
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: _categories.map((cat) => Tab(text: cat)).toList(),
              ),
            ),

            // Workouts List
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: filteredWorkouts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No workouts in this category',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        key: ValueKey(_selectedCategory),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredWorkouts.length,
                        itemBuilder: (context, index) {
                          return _buildWorkoutCard(
                            context,
                            filteredWorkouts[index],
                            index,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateWorkoutDialog(context),
        backgroundColor: const Color(0xFFFF6B35),
        icon: const Icon(Icons.add),
        label: const Text('Create Workout'),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout, int index) {
    final colors = [
      [const Color(0xFFFF6B35), const Color(0xFFFF8E53)],
      [const Color(0xFF00D9FF), const Color(0xFF00B4D8)],
      [const Color(0xFFFFD700), const Color(0xFFFFA500)],
      [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
      [const Color(0xFF27AE60), const Color(0xFF2ECC71)],
      [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
    ];

    final isCustom = _isCustomWorkout(workout);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(workout: workout),
          ),
        );
      },
      onLongPress: isCustom ? () => _showWorkoutOptions(context, workout) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors[index % colors.length][0].withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Workout Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors[index % colors.length],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors[index % colors.length][0].withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              // Workout Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors[index % colors.length][0]
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            workout.muscleGroup,
                            style: TextStyle(
                              color: colors[index % colors.length][0],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(workout.difficulty)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            workout.difficulty,
                            style: TextStyle(
                              color: _getDifficultyColor(workout.difficulty),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      workout.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildWorkoutInfo(
                          Icons.timer_outlined,
                          workout.duration,
                        ),
                        const SizedBox(width: 16),
                        _buildWorkoutInfo(
                          Icons.local_fire_department,
                          '${workout.caloriesBurned} cal',
                        ),
                        const SizedBox(width: 16),
                        _buildWorkoutInfo(
                          Icons.fitness_center,
                          '${workout.exercises.length} exercises',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[500], size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
      ],
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

  void _showCreateWorkoutDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _CreateWorkoutScreen(
          onWorkoutCreated: () {
            _customWorkoutService.reload().then((_) {
              if (mounted) setState(() {});
            });
          },
        ),
      ),
    );
  }

  void _showWorkoutOptions(BuildContext context, Workout workout) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
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
              Text(
                workout.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF00D9FF)),
                title: const Text('Edit Workout', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  final customWorkout = _customWorkoutService.getWorkout(workout.id);
                  if (customWorkout != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _CreateWorkoutScreen(
                          existingWorkout: customWorkout,
                          onWorkoutCreated: () {
                            _customWorkoutService.reload().then((_) {
                              if (mounted) setState(() {});
                            });
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Workout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  navigator.pop();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A2E),
                      title: const Text('Delete Workout?', style: TextStyle(color: Colors.white)),
                      content: Text(
                        'Are you sure you want to delete "${workout.name}"?',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _customWorkoutService.deleteWorkout(workout.id);
                    if (mounted) {
                      setState(() {});
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Workout deleted'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// Full-screen workout creation/editing screen
class _CreateWorkoutScreen extends StatefulWidget {
  final CustomWorkout? existingWorkout;
  final VoidCallback onWorkoutCreated;

  const _CreateWorkoutScreen({
    this.existingWorkout,
    required this.onWorkoutCreated,
  });

  @override
  State<_CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<_CreateWorkoutScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedMuscleGroup = 'Chest';
  String _selectedDifficulty = 'Intermediate';
  final List<String> _selectedExerciseIds = [];
  final List<Exercise> _allExercises = DataService.getExercises();
  
  final List<String> _muscleGroups = [
    'Chest', 'Back', 'Shoulders', 'Arms', 'Legs', 'Core', 'Push', 'Pull', 'Full Body'
  ];
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    if (widget.existingWorkout != null) {
      _nameController.text = widget.existingWorkout!.name;
      _descriptionController.text = widget.existingWorkout!.description;
      _selectedMuscleGroup = widget.existingWorkout!.muscleGroup;
      _selectedDifficulty = widget.existingWorkout!.difficulty;
      _selectedExerciseIds.addAll(widget.existingWorkout!.exerciseIds);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<Exercise> get _filteredExercises {
    if (_selectedMuscleGroup == 'Full Body' || 
        _selectedMuscleGroup == 'Push' || 
        _selectedMuscleGroup == 'Pull') {
      return _allExercises;
    }
    return _allExercises.where((e) => e.muscleGroup == _selectedMuscleGroup).toList();
  }

  int get _estimatedDuration => _selectedExerciseIds.length * 8; // ~8 min per exercise
  int get _estimatedCalories => _selectedExerciseIds.length * 50; // ~50 cal per exercise

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingWorkout != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isEditing ? 'Edit Workout' : 'Create Workout'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workout Name
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Workout Name',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFF1A1A2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.fitness_center, color: Color(0xFFFF6B35)),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Description (optional)',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFF1A1A2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.description, color: Color(0xFFFF6B35)),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Muscle Group Selection
                  const Text(
                    'Target Muscle Group',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _muscleGroups.map((group) {
                      final isSelected = _selectedMuscleGroup == group;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMuscleGroup = group),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)])
                                : null,
                            color: isSelected ? null : const Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.grey[700]!,
                            ),
                          ),
                          child: Text(
                            group,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[400],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Difficulty Selection
                  const Text(
                    'Difficulty',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _difficulties.map((diff) {
                      final isSelected = _selectedDifficulty == diff;
                      final color = diff == 'Beginner' 
                          ? const Color(0xFF27AE60)
                          : diff == 'Intermediate'
                              ? const Color(0xFFFFD700)
                              : const Color(0xFFE74C3C);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDifficulty = diff),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withOpacity(0.2) : const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? color : Colors.grey[700]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                diff,
                                style: TextStyle(
                                  color: isSelected ? color : Colors.grey[400],
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Exercise Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Exercises',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_selectedExerciseIds.length} selected',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Exercise List
                  ..._filteredExercises.map((exercise) {
                    final isSelected = _selectedExerciseIds.contains(exercise.id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedExerciseIds.remove(exercise.id);
                          } else {
                            _selectedExerciseIds.add(exercise.id);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFFFF6B35).withOpacity(0.15)
                              : const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFFFF6B35)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${exercise.sets} sets × ${exercise.reps} reps • ${exercise.muscleGroup}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                              color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom Bar with Stats and Save Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.fitness_center, '${_selectedExerciseIds.length}', 'Exercises'),
                      _buildStatItem(Icons.timer, '$_estimatedDuration', 'Minutes'),
                      _buildStatItem(Icons.local_fire_department, '$_estimatedCalories', 'Calories'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedExerciseIds.isEmpty || _nameController.text.trim().isEmpty
                          ? null
                          : () async {
                              final navigator = Navigator.of(context);
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              final workout = CustomWorkout(
                                id: widget.existingWorkout?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                name: _nameController.text.trim(),
                                description: _descriptionController.text.trim(),
                                muscleGroup: _selectedMuscleGroup,
                                difficulty: _selectedDifficulty,
                                estimatedDuration: _estimatedDuration,
                                estimatedCalories: _estimatedCalories,
                                exerciseIds: _selectedExerciseIds,
                                createdAt: widget.existingWorkout?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );

                              final service = CustomWorkoutService();
                              await service.init();
                              
                              if (widget.existingWorkout != null) {
                                await service.updateWorkout(workout);
                              } else {
                                await service.createWorkout(workout);
                              }

                              widget.onWorkoutCreated();
                              
                              if (mounted) {
                                navigator.pop();
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(isEditing 
                                        ? 'Workout updated successfully!' 
                                        : 'Workout created successfully!'),
                                    backgroundColor: const Color(0xFF27AE60),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        disabledBackgroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Update Workout' : 'Create Workout',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFFF6B35), size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
