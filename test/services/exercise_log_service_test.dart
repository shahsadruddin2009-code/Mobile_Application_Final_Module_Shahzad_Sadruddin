// ============================================================================
// MUSCLE POWER - Exercise Log Service Unit Tests
// ============================================================================
//
// Tests for ExerciseLogService and ExerciseLogEntry model.
// Uses SharedPreferences mock via setMockInitialValues.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodybuilding_app/services/exercise_log_service.dart';

void main() {
  // ========================================
  // EXERCISE LOG ENTRY MODEL TESTS
  // ========================================

  group('ExerciseLogEntry Model', () {
    test('creates entry with all required fields', () {
      final entry = ExerciseLogEntry(
        id: '1001',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 4,
        reps: 10,
        weight: 80.0,
      );
      expect(entry.id, '1001');
      expect(entry.exerciseName, 'Bench Press');
      expect(entry.muscleGroup, 'Chest');
      expect(entry.sets, 4);
      expect(entry.reps, 10);
      expect(entry.weight, 80.0);
      expect(entry.notes, ''); // default
    });

    test('creates entry with optional notes', () {
      final entry = ExerciseLogEntry(
        id: '1002',
        exerciseName: 'Squat',
        muscleGroup: 'Legs',
        date: DateTime(2025, 6, 15),
        sets: 3,
        reps: 8,
        weight: 100.0,
        notes: 'Felt heavy',
      );
      expect(entry.notes, 'Felt heavy');
    });

    test('dateKey uniquely identifies exercise+date', () {
      final entry = ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 3,
        reps: 10,
        weight: 80.0,
      );
      expect(entry.dateKey, 'Bench Press_2025-06-15');
    });

    test('dateKey pads month and day', () {
      final entry = ExerciseLogEntry(
        id: '1',
        exerciseName: 'Curl',
        muscleGroup: 'Arms',
        date: DateTime(2025, 1, 5),
        sets: 3,
        reps: 12,
        weight: 15.0,
      );
      expect(entry.dateKey, 'Curl_2025-01-05');
    });

    test('toJson produces valid JSON map', () {
      final date = DateTime(2025, 6, 15, 10, 30);
      final entry = ExerciseLogEntry(
        id: '1001',
        exerciseName: 'Deadlift',
        muscleGroup: 'Back',
        date: date,
        sets: 5,
        reps: 5,
        weight: 120.0,
        notes: 'PR attempt',
      );

      final json = entry.toJson();
      expect(json['id'], '1001');
      expect(json['exerciseName'], 'Deadlift');
      expect(json['muscleGroup'], 'Back');
      expect(json['sets'], 5);
      expect(json['reps'], 5);
      expect(json['weight'], 120.0);
      expect(json['notes'], 'PR attempt');
      expect(json['date'], contains('2025'));
    });

    test('fromJson reconstructs entry correctly', () {
      final json = {
        'id': '1001',
        'exerciseName': 'Squat',
        'muscleGroup': 'Legs',
        'date': '2025-06-15T10:30:00.000',
        'sets': 4,
        'reps': 8,
        'weight': 100.0,
        'notes': 'Deep squats',
      };

      final entry = ExerciseLogEntry.fromJson(json);
      expect(entry.id, '1001');
      expect(entry.exerciseName, 'Squat');
      expect(entry.muscleGroup, 'Legs');
      expect(entry.sets, 4);
      expect(entry.reps, 8);
      expect(entry.weight, 100.0);
      expect(entry.notes, 'Deep squats');
    });

    test('fromJson handles missing muscleGroup', () {
      final json = {
        'id': '1',
        'exerciseName': 'Unknown',
        'date': '2025-06-15T10:30:00.000',
        'sets': 3,
        'reps': 10,
        'weight': 50.0,
      };
      final entry = ExerciseLogEntry.fromJson(json);
      expect(entry.muscleGroup, 'Other');
    });

    test('fromJson handles missing notes', () {
      final json = {
        'id': '1',
        'exerciseName': 'Test',
        'muscleGroup': 'Chest',
        'date': '2025-06-15T10:30:00.000',
        'sets': 3,
        'reps': 10,
        'weight': 50.0,
      };
      final entry = ExerciseLogEntry.fromJson(json);
      expect(entry.notes, '');
    });

    test('fromJson handles integer weight as double', () {
      final json = {
        'id': '1',
        'exerciseName': 'Test',
        'muscleGroup': 'Chest',
        'date': '2025-06-15T10:30:00.000',
        'sets': 3,
        'reps': 10,
        'weight': 50, // int, not double
      };
      final entry = ExerciseLogEntry.fromJson(json);
      expect(entry.weight, 50.0);
      expect(entry.weight, isA<double>());
    });

    test('copyWith creates new entry with updated fields', () {
      final original = ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 3,
        reps: 10,
        weight: 80.0,
      );

      final updated = original.copyWith(weight: 85.0, reps: 8);
      expect(updated.weight, 85.0);
      expect(updated.reps, 8);
      expect(updated.exerciseName, 'Bench Press'); // unchanged
      expect(updated.sets, 3); // unchanged
    });

    test('toJson → fromJson round-trip preserves data', () {
      final original = ExerciseLogEntry(
        id: '1001',
        exerciseName: 'Overhead Press',
        muscleGroup: 'Shoulders',
        date: DateTime(2025, 6, 15, 14, 0),
        sets: 4,
        reps: 8,
        weight: 50.0,
        notes: 'Standing',
      );

      final restored = ExerciseLogEntry.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.exerciseName, original.exerciseName);
      expect(restored.muscleGroup, original.muscleGroup);
      expect(restored.sets, original.sets);
      expect(restored.reps, original.reps);
      expect(restored.weight, original.weight);
      expect(restored.notes, original.notes);
    });
  });

  // ========================================
  // EXERCISE LOG SERVICE TESTS
  // ========================================

  group('ExerciseLogService', () {
    late ExerciseLogService service;

    setUp(() {
      // Mock SharedPreferences with empty data
      SharedPreferences.setMockInitialValues({});
      // Create fresh instance (NOT singleton for test isolation)
      service = ExerciseLogService();
    });

    test('initializes with empty entries', () async {
      await service.init();
      expect(service.entries, isEmpty);
    });

    test('logs an exercise entry', () async {
      await service.init();

      final entry = ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 4,
        reps: 10,
        weight: 80.0,
      );

      await service.logExercise(entry);
      expect(service.entries, hasLength(1));
      expect(service.entries.first.exerciseName, 'Bench Press');
    });

    test('deduplicates entries by exercise+date', () async {
      await service.init();

      final entry1 = ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 3,
        reps: 10,
        weight: 70.0,
      );
      final entry2 = ExerciseLogEntry(
        id: '2',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 4,
        reps: 10,
        weight: 80.0,
      );

      await service.logExercise(entry1);
      await service.logExercise(entry2);

      // Should only have 1 entry (entry2 replaces entry1)
      expect(service.entries, hasLength(1));
      expect(service.entries.first.weight, 80.0);
    });

    test('allows same exercise on different dates', () async {
      await service.init();

      await service.logExercise(ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 4,
        reps: 10,
        weight: 80.0,
      ));
      await service.logExercise(ExerciseLogEntry(
        id: '2',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 16),
        sets: 4,
        reps: 10,
        weight: 82.5,
      ));

      expect(service.entries, hasLength(2));
    });

    test('getEntriesForExercise filters by name', () async {
      await service.init();

      await service.logExercise(ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 4,
        reps: 10,
        weight: 80.0,
      ));
      await service.logExercise(ExerciseLogEntry(
        id: '2',
        exerciseName: 'Squat',
        muscleGroup: 'Legs',
        date: DateTime(2025, 6, 15),
        sets: 3,
        reps: 8,
        weight: 100.0,
      ));

      final benchEntries = service.getEntriesForExercise('Bench Press');
      expect(benchEntries, hasLength(1));
      expect(benchEntries.first.exerciseName, 'Bench Press');

      final squatEntries = service.getEntriesForExercise('Squat');
      expect(squatEntries, hasLength(1));
    });

    test('getEntriesForDate filters by date', () async {
      await service.init();

      final date = DateTime(2025, 6, 15);
      await service.logExercise(ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: date,
        sets: 4,
        reps: 10,
        weight: 80.0,
      ));
      await service.logExercise(ExerciseLogEntry(
        id: '2',
        exerciseName: 'Squat',
        muscleGroup: 'Legs',
        date: DateTime(2025, 6, 16),
        sets: 3,
        reps: 8,
        weight: 100.0,
      ));

      final entries = service.getEntriesForDate(date);
      expect(entries, hasLength(1));
      expect(entries.first.exerciseName, 'Bench Press');
    });

    test('getLoggedExerciseNames returns unique names', () async {
      await service.init();

      await service.logExercise(ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 4,
        reps: 10,
        weight: 80.0,
      ));
      await service.logExercise(ExerciseLogEntry(
        id: '2',
        exerciseName: 'Squat',
        muscleGroup: 'Legs',
        date: DateTime(2025, 6, 15),
        sets: 3,
        reps: 8,
        weight: 100.0,
      ));
      await service.logExercise(ExerciseLogEntry(
        id: '3',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 16),
        sets: 4,
        reps: 10,
        weight: 82.5,
      ));

      final names = service.getLoggedExerciseNames();
      expect(names, hasLength(2));
      expect(names, contains('Bench Press'));
      expect(names, contains('Squat'));
    });

    test('getWeightHistory returns ascending date-sorted data', () async {
      await service.init();

      await service.logExercise(ExerciseLogEntry(
        id: '2',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 16),
        sets: 4,
        reps: 10,
        weight: 82.5,
      ));
      await service.logExercise(ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 4,
        reps: 10,
        weight: 80.0,
      ));

      final history = service.getWeightHistory('Bench Press');
      expect(history, hasLength(2));
      // Should be date-ascending
      expect((history[0]['date'] as DateTime).isBefore(history[1]['date'] as DateTime), isTrue);
      expect(history[0]['weight'], 80.0);
      expect(history[1]['weight'], 82.5);
    });

    test('getLatestEntry returns most recent entry', () async {
      await service.init();

      await service.logExercise(ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 4,
        reps: 10,
        weight: 80.0,
      ));
      await service.logExercise(ExerciseLogEntry(
        id: '2',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 20),
        sets: 4,
        reps: 10,
        weight: 85.0,
      ));

      final latest = service.getLatestEntry('Bench Press');
      expect(latest, isNotNull);
      expect(latest!.weight, 85.0);
    });

    test('getLatestEntry returns null for unknown exercise', () async {
      await service.init();
      expect(service.getLatestEntry('NonExistent'), isNull);
    });

    test('hasEntryForDate returns correct boolean', () async {
      await service.init();

      final date = DateTime(2025, 6, 15);
      await service.logExercise(ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: date,
        sets: 4,
        reps: 10,
        weight: 80.0,
      ));

      expect(service.hasEntryForDate('Bench Press', date), isTrue);
      expect(service.hasEntryForDate('Bench Press', DateTime(2025, 6, 16)), isFalse);
      expect(service.hasEntryForDate('Squat', date), isFalse);
    });

    test('deleteEntry removes by ID', () async {
      await service.init();

      await service.logExercise(ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 4,
        reps: 10,
        weight: 80.0,
      ));
      expect(service.entries, hasLength(1));

      await service.deleteEntry('1');
      expect(service.entries, isEmpty);
    });

    test('getStatistics returns correct aggregates', () async {
      await service.init();

      await service.logExercise(ExerciseLogEntry(
        id: '1',
        exerciseName: 'Bench Press',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 15),
        sets: 4,
        reps: 10,
        weight: 80.0,
      ));
      await service.logExercise(ExerciseLogEntry(
        id: '2',
        exerciseName: 'Squat',
        muscleGroup: 'Legs',
        date: DateTime(2025, 6, 15),
        sets: 3,
        reps: 8,
        weight: 120.0,
      ));

      final stats = service.getStatistics();
      expect(stats['totalWorkouts'], 2);
      expect(stats['uniqueExercises'], 2);
      expect(stats['totalSets'], 7); // 4 + 3
      expect(stats['maxWeight'], 120.0);
    });

    test('getStatistics returns zeros when empty', () async {
      await service.init();
      final stats = service.getStatistics();
      expect(stats['totalWorkouts'], 0);
      expect(stats['uniqueExercises'], 0);
      expect(stats['totalSets'], 0);
      expect(stats['maxWeight'], 0.0);
    });

    test('setWeeklyGoal persists goal value', () async {
      await service.init();
      await service.setWeeklyGoal(7);
      expect(service.weeklyGoal, 7);
    });

    test('setWeeklyGoal clamps to valid range', () async {
      await service.init();
      await service.setWeeklyGoal(0);
      expect(service.weeklyGoal, 1); // min 1

      await service.setWeeklyGoal(25);
      expect(service.weeklyGoal, 20); // max 20
    });

    test('entries are sorted by date descending', () async {
      await service.init();

      await service.logExercise(ExerciseLogEntry(
        id: '1',
        exerciseName: 'A',
        muscleGroup: 'Chest',
        date: DateTime(2025, 6, 10),
        sets: 3,
        reps: 10,
        weight: 50.0,
      ));
      await service.logExercise(ExerciseLogEntry(
        id: '2',
        exerciseName: 'B',
        muscleGroup: 'Back',
        date: DateTime(2025, 6, 20),
        sets: 3,
        reps: 10,
        weight: 60.0,
      ));
      await service.logExercise(ExerciseLogEntry(
        id: '3',
        exerciseName: 'C',
        muscleGroup: 'Legs',
        date: DateTime(2025, 6, 15),
        sets: 3,
        reps: 10,
        weight: 70.0,
      ));

      // Descending order: Jun 20, Jun 15, Jun 10
      expect(service.entries[0].exerciseName, 'B');
      expect(service.entries[1].exerciseName, 'C');
      expect(service.entries[2].exerciseName, 'A');
    });
  });
}
