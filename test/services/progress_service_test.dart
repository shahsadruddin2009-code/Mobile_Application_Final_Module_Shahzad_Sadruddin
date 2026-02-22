// ============================================================================
// MUSCLE POWER - Progress Service Unit Tests
// ============================================================================
//
// Tests for ProgressService, ProgressEntry and UserBodyStats models.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodybuilding_app/services/progress_service.dart';

void main() {
  // ========================================
  // USER BODY STATS MODEL TESTS
  // ========================================

  group('UserBodyStats Model', () {
    test('creates stats with all optional fields', () {
      final stats = UserBodyStats(
        age: 28,
        height: 180.0,
        weight: 85.0,
        targetWeight: 80.0,
        startingWeight: 90.0,
        fitnessGoal: 'Lose Weight',
        lastUpdated: DateTime(2025, 6, 15),
      );

      expect(stats.age, 28);
      expect(stats.height, 180.0);
      expect(stats.weight, 85.0);
      expect(stats.targetWeight, 80.0);
      expect(stats.startingWeight, 90.0);
      expect(stats.fitnessGoal, 'Lose Weight');
    });

    test('creates empty stats with null fields', () {
      final stats = UserBodyStats();
      expect(stats.age, isNull);
      expect(stats.height, isNull);
      expect(stats.weight, isNull);
      expect(stats.bmi, isNull);
    });

    test('calculates BMI correctly', () {
      final stats = UserBodyStats(
        height: 180.0, // cm
        weight: 81.0,  // kg
      );
      // BMI = 81 / (1.8^2) = 81 / 3.24 = 25.0
      expect(stats.bmi, closeTo(25.0, 0.1));
    });

    test('BMI is null when height is null', () {
      final stats = UserBodyStats(weight: 80.0);
      expect(stats.bmi, isNull);
    });

    test('BMI is null when weight is null', () {
      final stats = UserBodyStats(height: 180.0);
      expect(stats.bmi, isNull);
    });

    test('BMI is null when height is zero', () {
      final stats = UserBodyStats(height: 0.0, weight: 80.0);
      expect(stats.bmi, isNull);
    });

    test('bmiCategory returns Underweight', () {
      final stats = UserBodyStats(height: 180.0, weight: 55.0);
      // BMI = 55 / 3.24 ≈ 16.97
      expect(stats.bmiCategory, 'Underweight');
    });

    test('bmiCategory returns Normal', () {
      final stats = UserBodyStats(height: 180.0, weight: 75.0);
      // BMI = 75 / 3.24 ≈ 23.15
      expect(stats.bmiCategory, 'Normal');
    });

    test('bmiCategory returns Overweight', () {
      final stats = UserBodyStats(height: 180.0, weight: 90.0);
      // BMI = 90 / 3.24 ≈ 27.78
      expect(stats.bmiCategory, 'Overweight');
    });

    test('bmiCategory returns Obese', () {
      final stats = UserBodyStats(height: 170.0, weight: 100.0);
      // BMI = 100 / 2.89 ≈ 34.60
      expect(stats.bmiCategory, 'Obese');
    });

    test('bmiCategory returns Unknown when BMI is null', () {
      final stats = UserBodyStats();
      expect(stats.bmiCategory, 'Unknown');
    });

    test('bmiCategoryColor returns correct color codes', () {
      // Unknown → Grey
      expect(UserBodyStats().bmiCategoryColor, 0xFF9E9E9E);

      // Underweight → Blue
      expect(UserBodyStats(height: 180.0, weight: 55.0).bmiCategoryColor, 0xFF3498DB);

      // Normal → Green
      expect(UserBodyStats(height: 180.0, weight: 75.0).bmiCategoryColor, 0xFF27AE60);

      // Overweight → Orange
      expect(UserBodyStats(height: 180.0, weight: 90.0).bmiCategoryColor, 0xFFFF9800);

      // Obese → Red
      expect(UserBodyStats(height: 170.0, weight: 100.0).bmiCategoryColor, 0xFFE74C3C);
    });

    test('toJson includes all fields', () {
      final stats = UserBodyStats(
        age: 25,
        height: 175.0,
        weight: 70.0,
        targetWeight: 65.0,
        startingWeight: 80.0,
        fitnessGoal: 'Build Muscle',
        lastUpdated: DateTime(2025, 6, 15),
      );
      final json = stats.toJson();
      expect(json['age'], 25);
      expect(json['height'], 175.0);
      expect(json['weight'], 70.0);
      expect(json['targetWeight'], 65.0);
      expect(json['fitnessGoal'], 'Build Muscle');
    });

    test('fromJson reconstructs correctly', () {
      final json = {
        'age': 30,
        'height': 185.0,
        'weight': 90.0,
        'targetWeight': 85.0,
        'startingWeight': 95.0,
        'fitnessGoal': 'Maintain',
        'lastUpdated': '2025-06-15T00:00:00.000',
      };
      final stats = UserBodyStats.fromJson(json);
      expect(stats.age, 30);
      expect(stats.height, 185.0);
      expect(stats.weight, 90.0);
      expect(stats.fitnessGoal, 'Maintain');
    });

    test('fromJson handles null fields', () {
      final json = <String, dynamic>{};
      final stats = UserBodyStats.fromJson(json);
      expect(stats.age, isNull);
      expect(stats.height, isNull);
      expect(stats.weight, isNull);
    });

    test('copyWith creates updated copy', () {
      final original = UserBodyStats(
        age: 25,
        height: 175.0,
        weight: 70.0,
      );
      final updated = original.copyWith(weight: 72.0);
      expect(updated.weight, 72.0);
      expect(updated.height, 175.0); // unchanged
      expect(updated.age, 25); // unchanged
    });
  });

  // ========================================
  // PROGRESS ENTRY MODEL TESTS
  // ========================================

  group('ProgressEntry Model (Service)', () {
    test('creates entry with required fields', () {
      final entry = ProgressEntry(
        id: 'p001',
        date: DateTime(2025, 6, 15),
        weight: 82.0,
      );
      expect(entry.id, 'p001');
      expect(entry.weight, 82.0);
      expect(entry.bodyFat, isNull);
      expect(entry.chest, isNull);
    });

    test('creates entry with all optional fields', () {
      final entry = ProgressEntry(
        id: 'p001',
        date: DateTime(2025, 6, 15),
        weight: 82.0,
        height: 180.0,
        bodyFat: 15.0,
        chest: 42.0,
        waist: 32.0,
        arms: 15.0,
        thighs: 24.0,
        hips: 38.0,
        shoulders: 48.0,
        notes: 'Feeling strong',
      );
      expect(entry.bodyFat, 15.0);
      expect(entry.chest, 42.0);
      expect(entry.waist, 32.0);
      expect(entry.notes, 'Feeling strong');
    });

    test('calculates BMI when height available', () {
      final entry = ProgressEntry(
        id: 'p001',
        date: DateTime(2025, 6, 15),
        weight: 81.0,
        height: 180.0,
      );
      expect(entry.bmi, closeTo(25.0, 0.1));
    });

    test('BMI is null without height', () {
      final entry = ProgressEntry(
        id: 'p001',
        date: DateTime(2025, 6, 15),
        weight: 80.0,
      );
      expect(entry.bmi, isNull);
    });

    test('toJson → fromJson round-trip', () {
      final original = ProgressEntry(
        id: 'p001',
        date: DateTime(2025, 6, 15),
        weight: 82.0,
        height: 180.0,
        bodyFat: 15.0,
        chest: 42.0,
        waist: 32.0,
        arms: 15.0,
        thighs: 24.0,
        hips: 38.0,
        shoulders: 48.0,
        notes: 'Test',
      );

      final restored = ProgressEntry.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.weight, original.weight);
      expect(restored.height, original.height);
      expect(restored.bodyFat, original.bodyFat);
      expect(restored.chest, original.chest);
      expect(restored.waist, original.waist);
      expect(restored.arms, original.arms);
      expect(restored.thighs, original.thighs);
      expect(restored.hips, original.hips);
      expect(restored.shoulders, original.shoulders);
      expect(restored.notes, original.notes);
    });

    test('createdAt defaults to now', () {
      final entry = ProgressEntry(
        id: 'p001',
        date: DateTime(2025, 6, 15),
        weight: 80.0,
      );
      final now = DateTime.now();
      expect(entry.createdAt.difference(now).inSeconds.abs(), lessThan(2));
    });
  });

  // ========================================
  // PROGRESS SERVICE TESTS
  // ========================================

  group('ProgressService', () {
    setUp(() {
      // Provide empty entries so reload() clears the singleton's internal list
      SharedPreferences.setMockInitialValues({'progress_entries': '[]'});
    });

    // Note: ProgressService is a singleton, so tests may share state.
    // We reset SharedPreferences before each test.

    test('initializes with empty entries', () async {
      final service = ProgressService();
      await service.reload();
      expect(service.entries, isEmpty);
    });

    test('addEntry adds and sorts by date', () async {
      final service = ProgressService();
      await service.reload();

      await service.addEntry(ProgressEntry(
        id: 'p2',
        date: DateTime(2025, 6, 20),
        weight: 81.0,
      ));
      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 15),
        weight: 82.0,
      ));

      expect(service.entries, hasLength(2));
      // Sorted ascending by date
      expect(service.entries.first.id, 'p1');
      expect(service.entries.last.id, 'p2');
    });

    test('addEntry updates user stats with latest weight', () async {
      final service = ProgressService();
      await service.reload();

      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 15),
        weight: 80.0,
        height: 180.0,
      ));

      expect(service.userStats.weight, 80.0);
      expect(service.userStats.height, 180.0);
    });

    test('updateEntry modifies existing entry', () async {
      final service = ProgressService();
      await service.reload();

      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 15),
        weight: 80.0,
      ));

      await service.updateEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 15),
        weight: 79.0,
      ));

      expect(service.entries.first.weight, 79.0);
    });

    test('deleteEntry removes by ID', () async {
      final service = ProgressService();
      await service.reload();

      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 15),
        weight: 80.0,
      ));
      await service.deleteEntry('p1');
      expect(service.entries, isEmpty);
    });

    test('getLatestEntry returns most recent', () async {
      final service = ProgressService();
      await service.reload();

      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 15),
        weight: 80.0,
      ));
      await service.addEntry(ProgressEntry(
        id: 'p2',
        date: DateTime(2025, 6, 20),
        weight: 78.0,
      ));

      final latest = service.getLatestEntry();
      expect(latest, isNotNull);
      expect(latest!.weight, 78.0);
    });

    test('getLatestEntry returns null when empty', () async {
      final service = ProgressService();
      await service.reload();
      expect(service.getLatestEntry(), isNull);
    });

    test('getWeightChange calculates difference', () async {
      final service = ProgressService();
      await service.reload();

      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 1),
        weight: 85.0,
      ));
      await service.addEntry(ProgressEntry(
        id: 'p2',
        date: DateTime(2025, 6, 30),
        weight: 82.0,
      ));

      expect(service.getWeightChange(), closeTo(-3.0, 0.01));
    });

    test('getWeightChange returns null with less than 2 entries', () async {
      final service = ProgressService();
      await service.reload();

      expect(service.getWeightChange(), isNull);

      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 15),
        weight: 80.0,
      ));
      expect(service.getWeightChange(), isNull);
    });

    test('getBodyFatChange calculates difference', () async {
      final service = ProgressService();
      await service.reload();

      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 1),
        weight: 85.0,
        bodyFat: 18.0,
      ));
      await service.addEntry(ProgressEntry(
        id: 'p2',
        date: DateTime(2025, 6, 30),
        weight: 82.0,
        bodyFat: 15.0,
      ));

      expect(service.getBodyFatChange(), closeTo(-3.0, 0.01));
    });

    test('getBodyFatChange returns null without body fat data', () async {
      final service = ProgressService();
      await service.reload();

      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 1),
        weight: 85.0,
      ));
      await service.addEntry(ProgressEntry(
        id: 'p2',
        date: DateTime(2025, 6, 30),
        weight: 82.0,
      ));

      expect(service.getBodyFatChange(), isNull);
    });

    test('getWeightHistory returns date-weight pairs', () async {
      final service = ProgressService();
      await service.reload();

      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 15),
        weight: 80.0,
      ));
      await service.addEntry(ProgressEntry(
        id: 'p2',
        date: DateTime(2025, 6, 20),
        weight: 79.0,
      ));

      final history = service.getWeightHistory();
      expect(history, hasLength(2));
      expect(history.first['weight'], 80.0);
      expect(history.last['weight'], 79.0);
    });

    test('getMeasurementHistory filters correctly', () async {
      final service = ProgressService();
      await service.reload();

      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 15),
        weight: 80.0,
        chest: 42.0,
      ));
      await service.addEntry(ProgressEntry(
        id: 'p2',
        date: DateTime(2025, 6, 20),
        weight: 79.0,
        // No chest measurement
      ));

      final chestHistory = service.getMeasurementHistory('chest');
      expect(chestHistory, hasLength(1));
      expect(chestHistory.first['value'], 42.0);
    });

    test('getEntriesForDate returns matching entries', () async {
      final service = ProgressService();
      await service.reload();

      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 15, 10, 0),
        weight: 80.0,
      ));
      await service.addEntry(ProgressEntry(
        id: 'p2',
        date: DateTime(2025, 6, 16, 10, 0),
        weight: 79.0,
      ));

      final entries = service.getEntriesForDate(DateTime(2025, 6, 15));
      expect(entries, hasLength(1));
      expect(entries.first.id, 'p1');
    });

    test('getEntriesByDate groups entries', () async {
      final service = ProgressService();
      await service.reload();

      await service.addEntry(ProgressEntry(
        id: 'p1',
        date: DateTime(2025, 6, 15, 8, 0),
        weight: 80.0,
      ));
      await service.addEntry(ProgressEntry(
        id: 'p2',
        date: DateTime(2025, 6, 15, 20, 0),
        weight: 80.5,
      ));

      final grouped = service.getEntriesByDate();
      final dateKey = DateTime(2025, 6, 15);
      expect(grouped[dateKey], hasLength(2));
    });

    test('updateUserStats updates stats correctly', () async {
      final service = ProgressService();
      await service.reload();

      await service.updateUserStats(
        age: 30,
        height: 180.0,
        weight: 85.0,
        targetWeight: 80.0,
        fitnessGoal: 'Build Muscle',
      );

      expect(service.userStats.age, 30);
      expect(service.userStats.height, 180.0);
      expect(service.userStats.weight, 85.0);
      expect(service.userStats.targetWeight, 80.0);
      expect(service.userStats.fitnessGoal, 'Build Muscle');
    });

    test('updateUserStats preserves unmodified fields', () async {
      final service = ProgressService();
      await service.reload();

      await service.updateUserStats(age: 30, height: 180.0);
      await service.updateUserStats(weight: 85.0);

      expect(service.userStats.age, 30);
      expect(service.userStats.height, 180.0);
      expect(service.userStats.weight, 85.0);
    });
  });
}
