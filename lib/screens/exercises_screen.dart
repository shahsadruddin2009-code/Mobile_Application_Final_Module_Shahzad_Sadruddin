// ============================================================================
// IRON FORGE - Exercise Library Screen
// ============================================================================
//
// File: exercises_screen.dart
// Description: Browse and search the complete exercise database
//
// Features:
// - Searchable exercise database with 30+ exercises
// - Filter by muscle group with animated category chips
// - Grid view with exercise cards showing key info
// - Animated exercise illustrations on each card
// - Difficulty and equipment indicators
// - Navigation to detailed exercise view
//
// Muscle Group Categories:
// - All (shows complete library)
// - Chest (5 exercises)
// - Back (5 exercises)
// - Shoulders (4 exercises)
// - Arms (5 exercises)
// - Legs (6 exercises)
// - Core (4 exercises)
//
// Search Functionality:
// - Real-time filtering as user types
// - Searches exercise names and muscle groups
// - Clear button to reset search
// - Results count display
//
// Card Information Displayed:
// - Exercise name
// - Target muscle group badge
// - Sets x Reps recommendation
// - Difficulty indicator
// - Animated exercise illustration
// ============================================================================

import 'package:flutter/material.dart';
import '../data/data_service.dart';
import '../models/models.dart';
import '../widgets/exercise_illustration.dart';
import 'exercise_detail_screen.dart';

/// Exercise library browsing screen
///
/// Provides a searchable, filterable view of all available exercises.
/// Users can browse by muscle group, search by name, and tap cards
/// to view detailed exercise information and log workouts.
///
/// The grid layout adapts to show 2 columns with exercise cards
/// featuring animated illustrations and key workout parameters.
class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedMuscle = 'All';
  final exercises = DataService.getExercises();

  final List<Map<String, dynamic>> _muscleGroups = [
    {'name': 'All', 'icon': Icons.grid_view, 'color': const Color(0xFFFF6B35)},
    {'name': 'Chest', 'icon': Icons.sports_gymnastics, 'color': const Color(0xFF00CED1)},
    {'name': 'Back', 'icon': Icons.accessibility_new, 'color': const Color(0xFF3498DB)},
    {'name': 'Shoulders', 'icon': Icons.person, 'color': const Color(0xFF9B59B6)},
    {'name': 'Arms', 'icon': Icons.fitness_center, 'color': const Color(0xFF27AE60)},
    {'name': 'Legs', 'icon': Icons.directions_walk, 'color': const Color(0xFFFFD700)},
    {'name': 'Core', 'icon': Icons.airline_seat_flat, 'color': const Color(0xFF00D9FF)},
  ];

  List<Exercise> get filteredExercises {
    return exercises.where((e) {
      final matchesMuscle = _selectedMuscle == 'All' || e.muscleGroup == _selectedMuscle;
      final matchesSearch = _searchQuery.isEmpty ||
          e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.muscleGroup.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesMuscle && matchesSearch;
    }).toList();
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
                    'Exercise Library',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${exercises.length} exercises available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFFF6B35).withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFFF6B35),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Muscle Group Filter
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: _muscleGroups.length,
                itemBuilder: (context, index) {
                  final muscle = _muscleGroups[index];
                  final isSelected = _selectedMuscle == muscle['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMuscle = muscle['name'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  muscle['color'],
                                  muscle['color'].withOpacity(0.7),
                                ],
                              )
                            : null,
                        color: isSelected ? null : const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : muscle['color'].withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: muscle['color'].withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            muscle['icon'],
                            color: isSelected ? Colors.white : muscle['color'],
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            muscle['name'],
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[400],
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${filteredExercises.length} exercises found',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Exercises Grid
            Expanded(
              child: filteredExercises.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No exercises found',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        return _buildExerciseCard(
                          context,
                          filteredExercises[index],
                          index,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    Exercise exercise,
    int index,
  ) {
    final colors = {
      'Chest': [const Color(0xFF00CED1), const Color(0xFF008B8B)],
      'Back': [const Color(0xFF3498DB), const Color(0xFF2980B9)],
      'Shoulders': [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
      'Arms': [const Color(0xFF27AE60), const Color(0xFF219A52)],
      'Legs': [const Color(0xFFFFD700), const Color(0xFFFFA500)],
      'Core': [const Color(0xFF00D9FF), const Color(0xFF00B4D8)],
    };

    final gradientColors =
        colors[exercise.muscleGroup] ?? [const Color(0xFFFF6B35), const Color(0xFFFF8E53)];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailScreen(exercise: exercise),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gradientColors[0].withOpacity(0.3),
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
        child: Stack(
          children: [
            // Background Icon
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.fitness_center,
                size: 80,
                color: gradientColors[0].withOpacity(0.1),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container with Illustration
                  Container(
                    height: 70,
                    width: 70,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          gradientColors[0].withOpacity(0.2),
                          gradientColors[1].withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: gradientColors[0].withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ExerciseIllustration(
                      exerciseName: exercise.name,
                      size: 54,
                      primaryColor: gradientColors[0],
                      secondaryColor: gradientColors[1],
                      animate: false,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Exercise Name
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Muscle Group
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: gradientColors[0].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      exercise.muscleGroup,
                      style: TextStyle(
                        color: gradientColors[0],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Sets x Reps
                  Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${exercise.sets} x ${exercise.reps}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: gradientColors[0].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: gradientColors[0],
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
}
