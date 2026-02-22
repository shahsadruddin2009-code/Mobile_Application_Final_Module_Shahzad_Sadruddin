// ============================================================================
// MUSCLE POWER - Progress Tracking Service
// ============================================================================
//
// File: progress_service.dart
// Description: Manages body measurement tracking, user profile stats, and progress history
//
// Features:
// - Track weight, height, age, BMI over time
// - Record body measurements (chest, waist, arms, thighs, etc.)
// - Body fat percentage tracking
// - User profile stats (current height, weight, age)
// - BMI calculation
// - Date-based entry organization
// - Progress comparison (weight/body fat change over time)
//
// Storage:
// - Uses SharedPreferences for web compatibility
// - Progress entries stored as JSON array under 'progress_entries' key
// - User stats stored under 'user_body_stats' key
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// User body stats model
///
/// Stores the user's current body statistics for profile display.
/// These are updated when new progress entries are added.
class UserBodyStats {
  final int? age;
  final double? height; // in cm
  final double? weight; // in kg
  final double? targetWeight; // goal weight in kg
  final double? startingWeight; // initial weight when user started
  final String? fitnessGoal; // e.g., "Lose Weight", "Build Muscle", "Maintain"
  final DateTime? lastUpdated;

  UserBodyStats({
    this.age,
    this.height,
    this.weight,
    this.targetWeight,
    this.startingWeight,
    this.fitnessGoal,
    this.lastUpdated,
  });

  /// Calculate BMI from height (cm) and weight (kg)
  double? get bmi {
    if (height == null || weight == null || height! <= 0) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  /// Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return 'Unknown';
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Get BMI category color
  int get bmiCategoryColor {
    final bmiValue = bmi;
    if (bmiValue == null) return 0xFF9E9E9E; // Grey
    if (bmiValue < 18.5) return 0xFF3498DB; // Blue
    if (bmiValue < 25) return 0xFF27AE60; // Green
    if (bmiValue < 30) return 0xFFFF9800; // Orange
    return 0xFFE74C3C; // Red
  }

  Map<String, dynamic> toJson() => {
    'age': age,
    'height': height,
    'weight': weight,
    'targetWeight': targetWeight,
    'startingWeight': startingWeight,
    'fitnessGoal': fitnessGoal,
    'lastUpdated': lastUpdated?.toIso8601String(),
  };

  factory UserBodyStats.fromJson(Map<String, dynamic> json) => UserBodyStats(
    age: json['age'] as int?,
    height: json['height'] != null ? (json['height'] as num).toDouble() : null,
    weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
    targetWeight: json['targetWeight'] != null ? (json['targetWeight'] as num).toDouble() : null,
    startingWeight: json['startingWeight'] != null ? (json['startingWeight'] as num).toDouble() : null,
    fitnessGoal: json['fitnessGoal'] as String?,
    lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated'] as String) : null,
  );

  UserBodyStats copyWith({
    int? age,
    double? height,
    double? weight,
    double? targetWeight,
    double? startingWeight,
    String? fitnessGoal,
    DateTime? lastUpdated,
  }) {
    return UserBodyStats(
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      startingWeight: startingWeight ?? this.startingWeight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Data model for a single progress entry
class ProgressEntry {
  final String id;
  final DateTime date;
  final double weight;
  final double? height;
  final double? bodyFat;
  final double? chest;
  final double? waist;
  final double? arms;
  final double? thighs;
  final double? hips;
  final double? shoulders;
  final String? notes;
  final DateTime createdAt;

  ProgressEntry({
    required this.id,
    required this.date,
    required this.weight,
    this.height,
    this.bodyFat,
    this.chest,
    this.waist,
    this.arms,
    this.thighs,
    this.hips,
    this.shoulders,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Calculate BMI if height is available
  double? get bmi {
    if (height == null || height! <= 0) return null;
    final heightInMeters = height! / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'weight': weight,
    'height': height,
    'bodyFat': bodyFat,
    'chest': chest,
    'waist': waist,
    'arms': arms,
    'thighs': thighs,
    'hips': hips,
    'shoulders': shoulders,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ProgressEntry.fromJson(Map<String, dynamic> json) => ProgressEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    weight: (json['weight'] as num).toDouble(),
    height: json['height'] != null ? (json['height'] as num).toDouble() : null,
    bodyFat: json['bodyFat'] != null ? (json['bodyFat'] as num).toDouble() : null,
    chest: json['chest'] != null ? (json['chest'] as num).toDouble() : null,
    waist: json['waist'] != null ? (json['waist'] as num).toDouble() : null,
    arms: json['arms'] != null ? (json['arms'] as num).toDouble() : null,
    thighs: json['thighs'] != null ? (json['thighs'] as num).toDouble() : null,
    hips: json['hips'] != null ? (json['hips'] as num).toDouble() : null,
    shoulders: json['shoulders'] != null ? (json['shoulders'] as num).toDouble() : null,
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

/// Progress tracking service singleton
class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  List<ProgressEntry> _entries = [];
  UserBodyStats _userStats = UserBodyStats();
  bool _initialized = false;

  List<ProgressEntry> get entries => List.unmodifiable(_entries);
  UserBodyStats get userStats => _userStats;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _loadEntries();
    await _loadUserStats();
  }

  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getString('progress_entries');
      if (entriesJson != null && entriesJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(entriesJson);
        _entries = decoded.map((e) => ProgressEntry.fromJson(e as Map<String, dynamic>)).toList();
        _entries.sort((a, b) => a.date.compareTo(b.date));
      }
    } catch (e) {
      _entries = [];
    }
  }

  Future<void> _loadUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('user_body_stats');
      if (statsJson != null && statsJson.isNotEmpty) {
        _userStats = UserBodyStats.fromJson(json.decode(statsJson));
      }
    } catch (e) {
      _userStats = UserBodyStats();
    }
  }

  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = json.encode(_entries.map((e) => e.toJson()).toList());
      await prefs.setString('progress_entries', entriesJson);
    } catch (e) {
      // Silently handle save errors
    }
  }

  Future<void> _saveUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(_userStats.toJson());
      await prefs.setString('user_body_stats', statsJson);
    } catch (e) {
      // Silently handle save errors
    }
  }

  /// Update user body stats (age, height, weight, goals)
  Future<void> updateUserStats({
    int? age, 
    double? height, 
    double? weight,
    double? targetWeight,
    double? startingWeight,
    String? fitnessGoal,
  }) async {
    await init();
    _userStats = _userStats.copyWith(
      age: age ?? _userStats.age,
      height: height ?? _userStats.height,
      weight: weight ?? _userStats.weight,
      targetWeight: targetWeight ?? _userStats.targetWeight,
      startingWeight: startingWeight ?? _userStats.startingWeight,
      fitnessGoal: fitnessGoal ?? _userStats.fitnessGoal,
      lastUpdated: DateTime.now(),
    );
    await _saveUserStats();
  }

  /// Add a new progress entry and update user stats
  Future<void> addEntry(ProgressEntry entry) async {
    await init();
    _entries.add(entry);
    _entries.sort((a, b) => a.date.compareTo(b.date));
    await _saveEntries();
    
    // Update user stats with latest weight and height
    _userStats = _userStats.copyWith(
      weight: entry.weight,
      height: entry.height ?? _userStats.height,
      lastUpdated: DateTime.now(),
    );
    await _saveUserStats();
  }

  Future<void> updateEntry(ProgressEntry entry) async {
    await init();
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      _entries.sort((a, b) => a.date.compareTo(b.date));
      await _saveEntries();
    }
  }

  Future<void> deleteEntry(String id) async {
    await init();
    _entries.removeWhere((e) => e.id == id);
    await _saveEntries();
  }

  List<ProgressEntry> getEntriesForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _entries.where((e) {
      final entryDate = DateTime(e.date.year, e.date.month, e.date.day);
      return entryDate == dateOnly;
    }).toList();
  }

  List<ProgressEntry> getEntriesInRange(DateTime start, DateTime end) {
    return _entries.where((e) => e.date.isAfter(start) && e.date.isBefore(end)).toList();
  }

  /// Group all entries by date
  ///
  /// Returns a map where keys are dates (time stripped) and values are
  /// lists of entries for that date. Useful for calendar views.
  Map<DateTime, List<ProgressEntry>> getEntriesByDate() {
    final Map<DateTime, List<ProgressEntry>> grouped = {};
    for (final entry in _entries) {
      final dateKey = DateTime(entry.date.year, entry.date.month, entry.date.day);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(entry);
    }
    return grouped;
  }

  /// Get the most recent progress entry
  ///
  /// Returns null if no entries exist.
  /// Entries are sorted by date, so last entry is most recent.
  ProgressEntry? getLatestEntry() {
    if (_entries.isEmpty) return null;
    return _entries.last;
  }

  /// Calculate total weight change from first to last entry
  ///
  /// Returns:
  /// - Positive number: Weight gained
  /// - Negative number: Weight lost
  /// - null: Not enough entries to calculate
  double? getWeightChange() {
    if (_entries.length < 2) return null;
    return _entries.last.weight - _entries.first.weight;
  }

  /// Calculate body fat percentage change from first to last entry
  ///
  /// Only considers entries that have body fat data.
  /// Returns null if less than 2 entries have body fat values.
  double? getBodyFatChange() {
    final entriesWithBf = _entries.where((e) => e.bodyFat != null).toList();
    if (entriesWithBf.length < 2) return null;
    return entriesWithBf.last.bodyFat! - entriesWithBf.first.bodyFat!;
  }

  /// Get weight history for charting
  ///
  /// Returns a list of maps with 'date' and 'weight' keys
  /// suitable for line chart rendering.
  List<Map<String, dynamic>> getWeightHistory() {
    return _entries.map((e) => {
      'date': e.date,
      'weight': e.weight,
    }).toList();
  }

  /// Get history for a specific body measurement
  ///
  /// [measurement] should be one of: chest, waist, arms, thighs, hips, shoulders
  ///
  /// Returns list of maps with 'date' and 'value' keys,
  /// filtered to only include entries with that measurement.
  List<Map<String, dynamic>> getMeasurementHistory(String measurement) {
    return _entries.where((e) {
      switch (measurement) {
        case 'chest': return e.chest != null;
        case 'waist': return e.waist != null;
        case 'arms': return e.arms != null;
        case 'thighs': return e.thighs != null;
        case 'hips': return e.hips != null;
        case 'shoulders': return e.shoulders != null;
        default: return false;
      }
    }).map((e) {
      double? value;
      switch (measurement) {
        case 'chest': value = e.chest; break;
        case 'waist': value = e.waist; break;
        case 'arms': value = e.arms; break;
        case 'thighs': value = e.thighs; break;
        case 'hips': value = e.hips; break;
        case 'shoulders': value = e.shoulders; break;
      }
      return {
        'date': e.date,
        'value': value,
      };
    }).toList();
  }

  /// Force reload data from storage
  ///
  /// Clears initialization flag and reloads both entries and user stats.
  Future<void> reload() async {
    _initialized = false;
    await init();
  }
}
