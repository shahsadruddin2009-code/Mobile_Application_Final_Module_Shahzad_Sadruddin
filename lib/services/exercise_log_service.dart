// ============================================================================
// MUSCLE POWER - Exercise Log Service
// ============================================================================
//
// File: exercise_log_service.dart
// Description: Manages workout logging for individual exercises
//
// Features:
// - Log exercise performance with date, sets, reps, and weight
// - One entry per exercise per day (updates replace existing)
// - Retrieve exercise history for progress charts
// - Filter entries by exercise name or date
// - Calculate workout statistics
// - Persistent storage using SharedPreferences
//
// Data Model (ExerciseLogEntry):
// - id: Unique identifier (timestamp-based)
// - exerciseName: Name of the exercise performed
// - muscleGroup: Target muscle group
// - date: When the exercise was performed
// - sets: Number of sets completed
// - reps: Repetitions per set
// - weight: Weight used in kg
// - notes: Optional additional notes
//
// Key Methods:
// - logExercise(): Add or update an exercise entry
// - getEntriesForExercise(): Get all entries for specific exercise
// - getEntriesForDate(): Get all exercises logged on a date
// - getWeightHistory(): Get weight progression for charts
// - getStatistics(): Get aggregate statistics
//
// Storage:
// - Key: 'exercise_logs'
// - Format: JSON array of ExerciseLogEntry objects
// - Sorted by date descending (newest first)
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Data model representing a single exercise log entry
///
/// Captures all details about an exercise performed during a workout:
/// - Exercise identification (name, muscle group)
/// - Performance metrics (sets, reps, weight)
/// - Temporal data (date performed)
///
/// Each entry is uniquely identified by exercise name + date combination.
/// Only one entry per exercise per day is stored (newer updates replace older).
class ExerciseLogEntry {
  final String id;
  final String exerciseName;
  final String muscleGroup;
  final DateTime date;
  final int sets;
  final int reps;
  final double weight;
  final String notes;

  ExerciseLogEntry({
    required this.id,
    required this.exerciseName,
    required this.muscleGroup,
    required this.date,
    required this.sets,
    required this.reps,
    required this.weight,
    this.notes = '',
  });

  /// Unique key for date-based deduplication (one entry per exercise per day)
  String get dateKey => '${exerciseName}_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseName': exerciseName,
    'muscleGroup': muscleGroup,
    'date': date.toIso8601String(),
    'sets': sets,
    'reps': reps,
    'weight': weight,
    'notes': notes,
  };

  factory ExerciseLogEntry.fromJson(Map<String, dynamic> json) => ExerciseLogEntry(
    id: json['id'] as String,
    exerciseName: json['exerciseName'] as String,
    muscleGroup: json['muscleGroup'] as String? ?? 'Other',
    date: DateTime.parse(json['date'] as String),
    sets: json['sets'] as int,
    reps: json['reps'] as int,
    weight: (json['weight'] as num).toDouble(),
    notes: json['notes'] as String? ?? '',
  );

  ExerciseLogEntry copyWith({
    String? id,
    String? exerciseName,
    String? muscleGroup,
    DateTime? date,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
  }) {
    return ExerciseLogEntry(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      date: date ?? this.date,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
    );
  }
}

/// Service for managing exercise workout logs
///
/// Provides CRUD operations for exercise entries and analytics:
/// - Persistent storage with SharedPreferences
/// - Automatic date-based deduplication
/// - History retrieval for progress tracking
/// - Statistics calculation for dashboard
///
/// Usage:
/// ```dart
/// final service = ExerciseLogService();
/// await service.init();
///
/// // Log an exercise
/// await service.logExercise(ExerciseLogEntry(
///   id: DateTime.now().millisecondsSinceEpoch.toString(),
///   exerciseName: 'Bench Press',
///   muscleGroup: 'Chest',
///   date: DateTime.now(),
///   sets: 4,
///   reps: 10,
///   weight: 80.0,
/// ));
///
/// // Get history for charts
/// final history = service.getWeightHistory('Bench Press');
/// ```
class ExerciseLogService {
  // ========================================
  // CONSTANTS
  // ========================================

  /// SharedPreferences key for storing exercise logs
  static const String _storageKey = 'exercise_logs';

  // ========================================
  // STATE
  // ========================================

  /// In-memory cache of all exercise log entries
  List<ExerciseLogEntry> _entries = [];

  /// Flag to prevent multiple initializations
  bool _initialized = false;

  /// Weekly challenge goal (number of workouts)
  int _weeklyGoal = 5;

  /// Read-only access to all entries
  List<ExerciseLogEntry> get entries => List.unmodifiable(_entries);

  /// Get weekly challenge goal
  int get weeklyGoal => _weeklyGoal;

  /// Get current week's workout count
  int get weeklyWorkoutCount {
    final now = DateTime.now();
    // Get start of current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    // Count unique days with workouts this week
    final Set<String> uniqueDays = {};
    for (final entry in _entries) {
      if (entry.date.isAfter(startDate) || 
          (entry.date.year == startDate.year && 
           entry.date.month == startDate.month && 
           entry.date.day == startDate.day)) {
        final dayKey = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
        uniqueDays.add(dayKey);
      }
    }
    return uniqueDays.length;
  }

  /// Initialize the service and load data
  Future<void> init() async {
    if (_initialized) return;
    await _loadEntries();
    _initialized = true;
  }

  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _entries = jsonList.map((e) => ExerciseLogEntry.fromJson(e)).toList();
        // Sort by date descending
        _entries.sort((a, b) => b.date.compareTo(a.date));
      }
      // Load weekly goal
      _weeklyGoal = prefs.getInt('weekly_challenge_goal') ?? 5;
    } catch (e) {
      _entries = [];
    }
  }

  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _entries.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      // Handle error
    }
  }

  /// Add or update an exercise log entry (only one per exercise per date)
  Future<void> logExercise(ExerciseLogEntry entry) async {
    await init();
    
    // Remove existing entry for same exercise on same date
    _entries.removeWhere((e) => e.dateKey == entry.dateKey);
    
    // Add new entry
    _entries.add(entry);
    
    // Sort by date descending
    _entries.sort((a, b) => b.date.compareTo(a.date));
    
    await _saveEntries();
  }

  /// Get all entries for a specific exercise
  List<ExerciseLogEntry> getEntriesForExercise(String exerciseName) {
    return _entries.where((e) => e.exerciseName == exerciseName).toList();
  }

  /// Get all entries for a specific date
  List<ExerciseLogEntry> getEntriesForDate(DateTime date) {
    return _entries.where((e) => 
      e.date.year == date.year && 
      e.date.month == date.month && 
      e.date.day == date.day
    ).toList();
  }

  /// Get all unique exercise names that have been logged
  List<String> getLoggedExerciseNames() {
    return _entries.map((e) => e.exerciseName).toSet().toList();
  }

  /// Get weight history for a specific exercise (for graphing)
  /// Ensures unique dates - only one entry per date (uses the latest if duplicates exist)
  List<Map<String, dynamic>> getWeightHistory(String exerciseName) {
    final exerciseEntries = getEntriesForExercise(exerciseName);
    // Sort by date ascending for chart
    exerciseEntries.sort((a, b) => a.date.compareTo(b.date));
    
    // Deduplicate by date - keep only one entry per unique date
    final Map<String, Map<String, dynamic>> uniqueByDate = {};
    for (final e in exerciseEntries) {
      final dateKey = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
      uniqueByDate[dateKey] = {
        'date': e.date,
        'weight': e.weight,
        'sets': e.sets,
        'reps': e.reps,
      };
    }
    
    // Sort by date after deduplication to ensure proper chart order
    final result = uniqueByDate.values.toList();
    result.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    return result;
  }

  /// Get the latest log for a specific exercise
  ExerciseLogEntry? getLatestEntry(String exerciseName) {
    final exerciseEntries = getEntriesForExercise(exerciseName);
    if (exerciseEntries.isEmpty) return null;
    return exerciseEntries.first; // Already sorted by date desc
  }

  /// Check if an entry exists for a specific exercise on a specific date
  bool hasEntryForDate(String exerciseName, DateTime date) {
    return _entries.any((e) => 
      e.exerciseName == exerciseName &&
      e.date.year == date.year && 
      e.date.month == date.month && 
      e.date.day == date.day
    );
  }

  /// Delete an exercise log entry by ID
  ///
  /// Removes the entry from both in-memory cache and persistent storage.
  /// Does nothing if entry with given ID doesn't exist.
  ///
  /// [id] - Unique identifier of the entry to delete
  Future<void> deleteEntry(String id) async {
    await init();
    _entries.removeWhere((e) => e.id == id);
    await _saveEntries();
  }

  /// Get aggregate statistics summary
  ///
  /// Calculates overall workout statistics including:
  /// - totalWorkouts: Total number of exercise entries logged
  /// - uniqueExercises: Number of different exercises performed
  /// - totalSets: Sum of all sets across all entries
  /// - maxWeight: Highest weight used across all exercises
  ///
  /// Returns zeros for all values if no entries exist.
  Map<String, dynamic> getStatistics() {
    if (_entries.isEmpty) {
      return {
        'totalWorkouts': 0,
        'uniqueExercises': 0,
        'totalSets': 0,
        'maxWeight': 0.0,
      };
    }
    
    return {
      'totalWorkouts': _entries.length,
      'uniqueExercises': getLoggedExerciseNames().length,
      'totalSets': _entries.fold(0, (sum, e) => sum + e.sets),
      'maxWeight': _entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b),
    };
  }

  /// Force reload data from storage
  ///
  /// Useful when data may have been modified externally
  /// or to ensure fresh data after app lifecycle changes.
  Future<void> reload() async {
    _initialized = false;
    await init();
  }

  /// Set weekly challenge goal
  ///
  /// [goal] - Number of workouts to complete per week (1-20)
  Future<void> setWeeklyGoal(int goal) async {
    _weeklyGoal = goal.clamp(1, 20);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('weekly_challenge_goal', _weeklyGoal);
    } catch (e) {
      // Handle error silently
    }
  }
}
