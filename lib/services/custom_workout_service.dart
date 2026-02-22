// ============================================================================
// MUSCLE POWER - Custom Workout Service
// ============================================================================
//
// File: custom_workout_service.dart
// Description: Manages user-created custom workout plans
//
// Features:
// - Create custom workout plans with selected exercises
// - Save and load custom workouts from persistent storage
// - Edit existing custom workouts
// - Delete custom workouts
// - Organize workouts by custom muscle groups
//
// Storage:
// - Uses SharedPreferences for web compatibility
// - Custom workouts stored as JSON array under 'custom_workouts' key
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';
import '../data/data_service.dart';

/// Custom workout model for user-created workouts
class CustomWorkout {
  final String id;
  final String name;
  final String description;
  final String muscleGroup;
  final String difficulty;
  final int estimatedDuration; // in minutes
  final int estimatedCalories;
  final List<String> exerciseIds; // IDs of exercises in this workout
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomWorkout({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.difficulty,
    required this.estimatedDuration,
    required this.estimatedCalories,
    required this.exerciseIds,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to Workout model for compatibility with existing UI
  Workout toWorkout() {
    final allExercises = DataService.getExercises();
    final selectedExercises = exerciseIds
        .map((id) => allExercises.where((e) => e.id == id).firstOrNull)
        .whereType<Exercise>()
        .toList();

    return Workout(
      id: id,
      name: name,
      description: description,
      muscleGroup: muscleGroup,
      duration: '$estimatedDuration min',
      difficulty: difficulty,
      caloriesBurned: estimatedCalories,
      exercises: selectedExercises,
      imageUrl: '',
      targetMuscles: [muscleGroup],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'muscleGroup': muscleGroup,
    'difficulty': difficulty,
    'estimatedDuration': estimatedDuration,
    'estimatedCalories': estimatedCalories,
    'exerciseIds': exerciseIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory CustomWorkout.fromJson(Map<String, dynamic> json) => CustomWorkout(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    muscleGroup: json['muscleGroup'] as String,
    difficulty: json['difficulty'] as String,
    estimatedDuration: json['estimatedDuration'] as int,
    estimatedCalories: json['estimatedCalories'] as int,
    exerciseIds: List<String>.from(json['exerciseIds'] as List),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  CustomWorkout copyWith({
    String? id,
    String? name,
    String? description,
    String? muscleGroup,
    String? difficulty,
    int? estimatedDuration,
    int? estimatedCalories,
    List<String>? exerciseIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomWorkout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Service for managing custom user-created workouts
class CustomWorkoutService {
  static const String _storageKey = 'custom_workouts';
  
  static final CustomWorkoutService _instance = CustomWorkoutService._internal();
  factory CustomWorkoutService() => _instance;
  CustomWorkoutService._internal();

  List<CustomWorkout> _customWorkouts = [];
  bool _initialized = false;

  List<CustomWorkout> get customWorkouts => List.unmodifiable(_customWorkouts);

  /// Get custom workouts as Workout models for UI compatibility
  List<Workout> get customWorkoutsAsWorkouts => 
      _customWorkouts.map((cw) => cw.toWorkout()).toList();

  /// Initialize service and load data
  Future<void> init() async {
    if (_initialized) return;
    await _loadWorkouts();
    _initialized = true;
  }

  Future<void> _loadWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _customWorkouts = jsonList.map((e) => CustomWorkout.fromJson(e)).toList();
        // Sort by creation date (newest first)
        _customWorkouts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      _customWorkouts = [];
    }
  }

  Future<void> _saveWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _customWorkouts.map((w) => w.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      // Handle error silently
    }
  }

  /// Create a new custom workout
  Future<void> createWorkout(CustomWorkout workout) async {
    await init();
    _customWorkouts.insert(0, workout);
    await _saveWorkouts();
  }

  /// Update an existing custom workout
  Future<void> updateWorkout(CustomWorkout workout) async {
    await init();
    final index = _customWorkouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _customWorkouts[index] = workout.copyWith(updatedAt: DateTime.now());
      await _saveWorkouts();
    }
  }

  /// Delete a custom workout by ID
  Future<void> deleteWorkout(String id) async {
    await init();
    _customWorkouts.removeWhere((w) => w.id == id);
    await _saveWorkouts();
  }

  /// Get a custom workout by ID
  CustomWorkout? getWorkout(String id) {
    return _customWorkouts.where((w) => w.id == id).firstOrNull;
  }

  /// Get custom workouts by muscle group
  List<CustomWorkout> getWorkoutsByMuscleGroup(String muscleGroup) {
    if (muscleGroup == 'All') return _customWorkouts;
    return _customWorkouts.where((w) => w.muscleGroup == muscleGroup).toList();
  }

  /// Force reload from storage
  Future<void> reload() async {
    _initialized = false;
    await init();
  }
}
