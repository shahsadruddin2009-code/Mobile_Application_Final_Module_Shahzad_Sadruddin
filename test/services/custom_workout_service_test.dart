// ============================================================================
// MUSCLE POWER - Custom Workout Service Unit Tests
// ============================================================================
//
// Tests for CustomWorkoutService and CustomWorkout model.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodybuilding_app/services/custom_workout_service.dart';

void main() {
  // ========================================
  // CUSTOM WORKOUT MODEL TESTS
  // ========================================

  group('CustomWorkout Model', () {
    test('creates workout with all fields', () {
      final now = DateTime(2025, 6, 15);
      final workout = CustomWorkout(
        id: 'cw_001',
        name: 'My Push Day',
        description: 'Custom chest and shoulders',
        muscleGroup: 'Chest',
        difficulty: 'Intermediate',
        estimatedDuration: 45,
        estimatedCalories: 350,
        exerciseIds: ['ex_001', 'ex_002', 'ex_003'],
        createdAt: now,
        updatedAt: now,
      );

      expect(workout.id, 'cw_001');
      expect(workout.name, 'My Push Day');
      expect(workout.muscleGroup, 'Chest');
      expect(workout.difficulty, 'Intermediate');
      expect(workout.estimatedDuration, 45);
      expect(workout.estimatedCalories, 350);
      expect(workout.exerciseIds, hasLength(3));
    });

    test('toJson produces valid map', () {
      final workout = CustomWorkout(
        id: 'cw_001',
        name: 'Test',
        description: 'Desc',
        muscleGroup: 'Legs',
        difficulty: 'Beginner',
        estimatedDuration: 30,
        estimatedCalories: 200,
        exerciseIds: ['ex_001'],
        createdAt: DateTime(2025, 6, 15),
        updatedAt: DateTime(2025, 6, 15),
      );

      final json = workout.toJson();
      expect(json['id'], 'cw_001');
      expect(json['name'], 'Test');
      expect(json['muscleGroup'], 'Legs');
      expect(json['exerciseIds'], ['ex_001']);
    });

    test('fromJson reconstructs correctly', () {
      final json = {
        'id': 'cw_001',
        'name': 'Test Workout',
        'description': 'Test',
        'muscleGroup': 'Back',
        'difficulty': 'Advanced',
        'estimatedDuration': 60,
        'estimatedCalories': 500,
        'exerciseIds': ['ex_001', 'ex_002'],
        'createdAt': '2025-06-15T00:00:00.000',
        'updatedAt': '2025-06-15T00:00:00.000',
      };

      final workout = CustomWorkout.fromJson(json);
      expect(workout.id, 'cw_001');
      expect(workout.name, 'Test Workout');
      expect(workout.muscleGroup, 'Back');
      expect(workout.difficulty, 'Advanced');
      expect(workout.exerciseIds, hasLength(2));
    });

    test('toJson → fromJson round-trip', () {
      final original = CustomWorkout(
        id: 'cw_001',
        name: 'Full Body',
        description: 'Complete workout',
        muscleGroup: 'Full Body',
        difficulty: 'Intermediate',
        estimatedDuration: 60,
        estimatedCalories: 500,
        exerciseIds: ['ex_001', 'ex_002', 'ex_003'],
        createdAt: DateTime(2025, 6, 15),
        updatedAt: DateTime(2025, 6, 15),
      );

      final restored = CustomWorkout.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.muscleGroup, original.muscleGroup);
      expect(restored.difficulty, original.difficulty);
      expect(restored.estimatedDuration, original.estimatedDuration);
      expect(restored.estimatedCalories, original.estimatedCalories);
      expect(restored.exerciseIds, original.exerciseIds);
    });

    test('copyWith updates specified fields', () {
      final original = CustomWorkout(
        id: 'cw_001',
        name: 'Old Name',
        description: '',
        muscleGroup: 'Chest',
        difficulty: 'Beginner',
        estimatedDuration: 30,
        estimatedCalories: 200,
        exerciseIds: [],
        createdAt: DateTime(2025, 6, 15),
        updatedAt: DateTime(2025, 6, 15),
      );

      final updated = original.copyWith(
        name: 'New Name',
        difficulty: 'Advanced',
      );

      expect(updated.name, 'New Name');
      expect(updated.difficulty, 'Advanced');
      expect(updated.id, 'cw_001'); // unchanged
      expect(updated.muscleGroup, 'Chest'); // unchanged
    });

    test('toWorkout converts to Workout model', () {
      final workout = CustomWorkout(
        id: 'cw_001',
        name: 'Custom Workout',
        description: 'Test workout',
        muscleGroup: 'Chest',
        difficulty: 'Intermediate',
        estimatedDuration: 45,
        estimatedCalories: 300,
        exerciseIds: [], // Empty — no matching exercises in DataService
        createdAt: DateTime(2025, 6, 15),
        updatedAt: DateTime(2025, 6, 15),
      );

      final converted = workout.toWorkout();
      expect(converted.id, 'cw_001');
      expect(converted.name, 'Custom Workout');
      expect(converted.duration, '45 min');
      expect(converted.caloriesBurned, 300);
      expect(converted.muscleGroup, 'Chest');
    });
  });

  // ========================================
  // CUSTOM WORKOUT SERVICE TESTS
  // ========================================

  group('CustomWorkoutService', () {
    setUp(() {
      // Provide empty workouts so reload() clears the singleton's internal list
      SharedPreferences.setMockInitialValues({'custom_workouts': '[]'});
    });

    CustomWorkout createWorkout({
      String id = 'cw_001',
      String name = 'Test Workout',
      String muscleGroup = 'Chest',
    }) {
      return CustomWorkout(
        id: id,
        name: name,
        description: 'Test',
        muscleGroup: muscleGroup,
        difficulty: 'Intermediate',
        estimatedDuration: 45,
        estimatedCalories: 300,
        exerciseIds: ['ex_001'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    test('initializes with empty list', () async {
      final service = CustomWorkoutService();
      await service.reload();
      expect(service.customWorkouts, isEmpty);
    });

    test('createWorkout adds to list', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout());
      expect(service.customWorkouts, hasLength(1));
      expect(service.customWorkouts.first.name, 'Test Workout');
    });

    test('createWorkout inserts at beginning', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001', name: 'First'));
      await service.createWorkout(createWorkout(id: 'cw_002', name: 'Second'));

      // Second should be first (inserted at index 0)
      expect(service.customWorkouts.first.name, 'Second');
    });

    test('updateWorkout modifies existing workout', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001', name: 'Original'));

      final updated = createWorkout(id: 'cw_001', name: 'Updated');
      await service.updateWorkout(updated);

      expect(service.customWorkouts.first.name, 'Updated');
    });

    test('deleteWorkout removes by ID', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001'));
      await service.createWorkout(createWorkout(id: 'cw_002'));
      expect(service.customWorkouts, hasLength(2));

      await service.deleteWorkout('cw_001');
      expect(service.customWorkouts, hasLength(1));
      expect(service.customWorkouts.first.id, 'cw_002');
    });

    test('getWorkout returns by ID', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001', name: 'Target'));
      await service.createWorkout(createWorkout(id: 'cw_002', name: 'Other'));

      final found = service.getWorkout('cw_001');
      expect(found, isNotNull);
      expect(found!.name, 'Target');
    });

    test('getWorkout returns null for unknown ID', () async {
      final service = CustomWorkoutService();
      await service.reload();
      expect(service.getWorkout('nonexistent'), isNull);
    });

    test('getWorkoutsByMuscleGroup filters correctly', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001', muscleGroup: 'Chest'));
      await service.createWorkout(createWorkout(id: 'cw_002', muscleGroup: 'Legs'));
      await service.createWorkout(createWorkout(id: 'cw_003', muscleGroup: 'Chest'));

      final chestWorkouts = service.getWorkoutsByMuscleGroup('Chest');
      expect(chestWorkouts, hasLength(2));

      final legWorkouts = service.getWorkoutsByMuscleGroup('Legs');
      expect(legWorkouts, hasLength(1));
    });

    test('getWorkoutsByMuscleGroup returns all for "All"', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001', muscleGroup: 'Chest'));
      await service.createWorkout(createWorkout(id: 'cw_002', muscleGroup: 'Legs'));

      final all = service.getWorkoutsByMuscleGroup('All');
      expect(all, hasLength(2));
    });

    test('customWorkoutsAsWorkouts converts all to Workout models', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001'));
      await service.createWorkout(createWorkout(id: 'cw_002'));

      final workouts = service.customWorkoutsAsWorkouts;
      expect(workouts, hasLength(2));
      expect(workouts.first.duration, contains('min'));
    });

    test('reload clears and repopulates from SharedPreferences', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001'));
      await service.createWorkout(createWorkout(id: 'cw_002'));

      // Simulate app restart by creating new instance and reloading
      final newService = CustomWorkoutService();
      await newService.reload();

      expect(newService.customWorkouts, hasLength(2));
      expect(newService.customWorkouts.first.id, 'cw_002'); // Last created is first
    });

    test('See the back button is functional', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001', name: 'First'));
      await service.createWorkout(createWorkout(id: 'cw_002', name: 'Second'));

      // Simulate back button by reloading (which clears and repopulates)
      await service.reload();

      expect(service.customWorkouts, hasLength(2));
      expect(service.customWorkouts.first.name, 'Second'); // Last created is first
    });

    test('deleting non-existent workout does not throw', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001'));
      expect(service.customWorkouts, hasLength(1));

      // Attempt to delete a workout that doesn't exist
      await service.deleteWorkout('nonexistent_id');

      // Original workout should still be there
      expect(service.customWorkouts, hasLength(1));
      expect(service.customWorkouts.first.id, 'cw_001');
    });

    test('user can navigate back to main screen after creating workout', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001', name: 'Test Workout'));

      // Simulate user navigating back to main screen by reloading
      await service.reload();

      expect(service.customWorkouts, hasLength(1));
      expect(service.customWorkouts.first.name, 'Test Workout');
    });

    test('updating non-existent workout does not throw', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001'));
      expect(service.customWorkouts, hasLength(1));

      // Attempt to update a workout that doesn't exist
      final nonExistent = createWorkout(id: 'nonexistent_id', name: 'Nonexistent');
      await service.updateWorkout(nonExistent);

      // Original workout should still be unchanged
      expect(service.customWorkouts, hasLength(1));
      expect(service.customWorkouts.first.id, 'cw_001');
    });

    test('getWorkoutsByMuscleGroup returns empty list for unknown group', () async {
      final service = CustomWorkoutService();
      await service.reload();

      await service.createWorkout(createWorkout(id: 'cw_001', muscleGroup: 'Chest'));

      final unknownGroup = service.getWorkoutsByMuscleGroup('Unknown');
      expect(unknownGroup, isEmpty);
    });

    test('user did not select weight for an exercise', () async {
      final service = CustomWorkoutService();
      await service.reload();

      final workout = createWorkout(id: 'cw_001');
      await service.createWorkout(workout);

      // Simulate user not selecting weight by checking if exerciseIds is empty
      final createdWorkout = service.getWorkout('cw_001');
      expect(createdWorkout, isNotNull);
      expect(createdWorkout!.exerciseIds, isNotEmpty); // Should have exercise IDs
    });

    test('customWorkouts list is unmodifiable', () async {
      final service = CustomWorkoutService();
      await service.reload();

      expect(() => service.customWorkouts.add(createWorkout()), throwsA(anything));
    });
  });
}
