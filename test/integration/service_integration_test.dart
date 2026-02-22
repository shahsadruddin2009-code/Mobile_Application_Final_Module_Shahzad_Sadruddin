// ============================================================================
// MUSCLE POWER - Service Integration Tests
// ============================================================================
//
// Tests service interactions end-to-end:
// 1. Auth + Encryption integration
// 2. Workout logging with ExerciseLogService
// 3. Nutrition tracking with NutritionService
// 4. Progress tracking with ProgressService
// 5. Custom workout creation and conversion
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodybuilding_app/services/encryption_service.dart';
import 'package:bodybuilding_app/services/exercise_log_service.dart';
import 'package:bodybuilding_app/services/nutrition_service.dart';
import 'package:bodybuilding_app/services/progress_service.dart';
import 'package:bodybuilding_app/services/custom_workout_service.dart';
import 'package:bodybuilding_app/data/data_service.dart';

void main() {
  // ========================================
  // AUTH + ENCRYPTION INTEGRATION
  // ========================================

  group('Auth + Encryption Integration', () {
    late EncryptionService encryption;

    setUp(() {
      encryption = EncryptionService();
    });

    test('complete signup flow: salt → hash → verify', () {
      final salt = encryption.generateSalt();
      final hash = encryption.hashPassword('MyStr0ng!Pass', salt);

      expect(encryption.verifyPassword('MyStr0ng!Pass', salt, hash), isTrue);
      expect(encryption.verifyPassword('WrongPassword', salt, hash), isFalse);
    });

    test('complete profile encryption: encrypt → store → decrypt', () {
      const plainName = 'John Doe';
      final encrypted = encryption.encryptIfNeeded(plainName);

      expect(encryption.isEncrypted(encrypted), isTrue);
      expect(encryption.decrypt(encrypted), plainName);
    });

    test('password reset flow: new salt + new hash replaces old', () {
      final salt1 = encryption.generateSalt();
      final hash1 = encryption.hashPassword('Original123!', salt1);

      final salt2 = encryption.generateSalt();
      final hash2 = encryption.hashPassword('NewPass456!', salt2);

      expect(encryption.verifyPassword('Original123!', salt2, hash2), isFalse);
      expect(encryption.verifyPassword('NewPass456!', salt2, hash2), isTrue);
      expect(encryption.verifyPassword('Original123!', salt1, hash1), isTrue);
    });

    test('multiple users with different salts have different hashes', () {
      const password = 'SamePassword1!';
      final salt1 = encryption.generateSalt();
      final salt2 = encryption.generateSalt();

      final hash1 = encryption.hashPassword(password, salt1);
      final hash2 = encryption.hashPassword(password, salt2);

      expect(hash1, isNot(equals(hash2)));
      expect(encryption.verifyPassword(password, salt1, hash1), isTrue);
      expect(encryption.verifyPassword(password, salt2, hash2), isTrue);
    });

    test('encrypted data round-trip for all profile fields', () {
      final fields = {
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
        'phone': '+1234567890',
      };

      final encrypted = <String, String>{};
      for (final entry in fields.entries) {
        encrypted[entry.key] = encryption.encryptIfNeeded(entry.value);
      }

      for (final entry in encrypted.entries) {
        expect(encryption.isEncrypted(entry.value), isTrue);
      }

      for (final entry in encrypted.entries) {
        expect(encryption.decrypt(entry.value), fields[entry.key]);
      }
    });
  });

  // ========================================
  // EXERCISE LOG SERVICE INTEGRATION
  // ========================================

  group('Exercise Log Service Integration', () {
    late ExerciseLogService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = ExerciseLogService();
    });

    test('complete workout logging flow', () async {
      await service.init();
      final exercises = DataService.getExercises();
      final exercise = exercises.first;

      final entry = ExerciseLogEntry(
        id: 'log_1',
        exerciseName: exercise.name,
        muscleGroup: exercise.muscleGroup,
        date: DateTime.now(),
        sets: 4,
        reps: 10,
        weight: 80.0,
        notes: 'Felt strong today',
      );

      await service.logExercise(entry);

      final entries = service.entries;
      expect(entries.length, 1);
      expect(entries.first.exerciseName, exercise.name);
      expect(entries.first.sets, 4);
    });

    test('weekly workout tracking across multiple days', () async {
      await service.init();
      final now = DateTime.now();

      for (int i = 0; i < 3; i++) {
        final date = now.subtract(Duration(days: i));
        await service.logExercise(ExerciseLogEntry(
          id: 'log_day_$i',
          exerciseName: 'Bench Press',
          muscleGroup: 'Chest',
          date: date,
          sets: 3,
          reps: 10,
          weight: 60.0,
        ));
      }

      final count = service.weeklyWorkoutCount;
      expect(count, greaterThanOrEqualTo(3));
    });

    test('exercise statistics reflect logged data', () async {
      await service.init();
      final dates = [
        DateTime.now().subtract(const Duration(days: 6)),
        DateTime.now().subtract(const Duration(days: 3)),
        DateTime.now(),
      ];

      for (int i = 0; i < dates.length; i++) {
        await service.logExercise(ExerciseLogEntry(
          id: 'stat_$i',
          exerciseName: 'Squat',
          muscleGroup: 'Legs',
          date: dates[i],
          sets: 3,
          reps: 10,
          weight: 80.0 + (i * 5),
        ));
      }

      final stats = service.getStatistics();
      expect(stats['totalWorkouts'], 3);
      expect(stats['totalSets'], 9); // 3 entries × 3 sets
    });

    test('weight history for exercise tracks progression', () async {
      await service.init();
      final base = DateTime.now().subtract(const Duration(days: 10));

      for (int i = 0; i < 5; i++) {
        await service.logExercise(ExerciseLogEntry(
          id: 'weight_$i',
          exerciseName: 'Deadlift',
          muscleGroup: 'Back',
          date: base.add(Duration(days: i * 2)),
          sets: 3,
          reps: 5,
          weight: 100.0 + (i * 5),
        ));
      }

      final history = service.getWeightHistory('Deadlift');
      expect(history.length, 5);
      expect(history.last['weight'], greaterThan(history.first['weight']));
    });
  });

  // ========================================
  // NUTRITION SERVICE INTEGRATION
  // ========================================

  group('Nutrition Service Integration', () {
    late NutritionService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'mealLogs': '[]'});
      service = NutritionService();
      await service.init();
    });

    test('full day meal tracking flow', () async {
      // Log breakfast
      await service.addMeal(
        name: 'Oatmeal with Berries',
        calories: 350,
        protein: 12,
        carbs: 55,
        fat: 8,
        mealType: 'Breakfast',
      );
      await Future.delayed(const Duration(milliseconds: 10));

      // Log lunch
      await service.addMeal(
        name: 'Grilled Chicken Salad',
        calories: 450,
        protein: 40,
        carbs: 20,
        fat: 15,
        mealType: 'Lunch',
      );
      await Future.delayed(const Duration(milliseconds: 10));

      // Log dinner
      await service.addMeal(
        name: 'Salmon with Rice',
        calories: 550,
        protein: 35,
        carbs: 45,
        fat: 18,
        mealType: 'Dinner',
      );

      // Check today's totals
      final totals = service.todaysTotals;
      expect(totals['calories'], 1350);
      expect(totals['protein'], closeTo(87, 0.1));
      expect(totals['carbs'], closeTo(120, 0.1));
      expect(totals['fat'], closeTo(41, 0.1));
    });

    test('water intake tracking throughout day', () async {
      // Add 3 glasses of water
      await service.addWater();
      expect(service.waterIntake, 1);

      await service.addWater();
      expect(service.waterIntake, 2);

      await service.addWater();
      expect(service.waterIntake, 3);
    });

    test('remove meal updates totals correctly', () async {
      await service.addMeal(
        name: 'Protein Shake',
        calories: 200,
        protein: 30,
        carbs: 10,
        fat: 5,
        mealType: 'Snack',
      );
      await Future.delayed(const Duration(milliseconds: 10));

      await service.addMeal(
        name: 'Banana',
        calories: 100,
        protein: 1,
        carbs: 25,
        fat: 0,
        mealType: 'Snack',
      );

      expect(service.todaysTotals['calories'], 300);

      // Remove the first meal using its ID
      final firstMealId = service.mealLogs.first.id;
      await service.removeMeal(firstMealId);
      expect(service.todaysTotals['calories'], 100);
    });

    test('weight set and retrieval', () async {
      await service.setWeight(85.0);
      expect(service.currentWeight, 85.0);

      await service.incrementWeight();
      expect(service.currentWeight, 86.0);

      await service.decrementWeight();
      expect(service.currentWeight, 85.0);
    });
  });

  // ========================================
  // PROGRESS SERVICE INTEGRATION
  // ========================================

  group('Progress Service Integration', () {
    late ProgressService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'progress_entries': '[]'});
      service = ProgressService();
      await service.reload();
    });

    test('BMI tracking with weight changes', () {
      final stats1 = UserBodyStats(weight: 80, height: 175);
      expect(stats1.bmi, closeTo(26.1, 0.1));
      expect(stats1.bmiCategory, 'Overweight');

      final stats2 = UserBodyStats(weight: 73, height: 175);
      expect(stats2.bmi, closeTo(23.8, 0.1));
      expect(stats2.bmiCategory, 'Normal');
    });

    test('BMI category changes with different weight values', () {
      final stats1 = UserBodyStats(weight: 95, height: 175);
      expect(stats1.bmiCategory, 'Obese');

      final stats2 = UserBodyStats(weight: 80, height: 175);
      expect(stats2.bmiCategory, 'Overweight');

      final stats3 = UserBodyStats(weight: 70, height: 175);
      expect(stats3.bmiCategory, 'Normal');
    });
    test('track progress entry changes over time', () async {
      final entry1 = ProgressEntry(
        id: 'entry1',
        date: DateTime.now().subtract(const Duration(days: 30)),
        weight: 85.0,
        bodyFat: 20.0,
        chest: 100,
        waist: 90,
        hips: 100,
        arms: 35,
        thighs: 60,
      );
      await service.addEntry(entry1);

      final entry2 = ProgressEntry(
        id: 'entry2',
        date: DateTime.now(),
        weight: 80.0,
        bodyFat: 18.0,
        chest: 102,
        waist: 85,
        hips: 98,
        arms: 36,
        thighs: 59,
      );
      await service.addEntry(entry2);

      expect(service.getWeightChange(), closeTo(-5.0, 0.01));
      expect(service.getBodyFatChange(), closeTo(-2.0, 0.01));
    });
    test('complete progress entry logging flow', () async {
      // Week 1
      final entry1 = ProgressEntry(
        id: 'week1',
        date: DateTime.now().subtract(const Duration(days: 7)),
        weight: 82.0,
        bodyFat: 18.0,
        chest: 100,
        waist: 85,
        hips: 95,
        arms: 35,
        thighs: 58,
      );
      await service.addEntry(entry1);

      // Week 2
      final entry2 = ProgressEntry(
        id: 'week2',
        date: DateTime.now(),
        weight: 81.0,
        bodyFat: 17.5,
        chest: 101,
        waist: 84,
        hips: 95,
        arms: 35.5,
        thighs: 58.5,
      );
      await service.addEntry(entry2);

      // Check changes
      expect(service.getWeightChange(), closeTo(-1.0, 0.01));
      expect(service.getBodyFatChange(), closeTo(-0.5, 0.01));
    });

    test('progress entry editing updates correctly', () async {
      final entry = ProgressEntry(
        id: 'edit_test',
        date: DateTime.now(),
        weight: 80.0,
        bodyFat: 18.0,
        chest: 100,
        waist: 85,
        hips: 95,
        arms: 35,
        thighs: 58,
      );
      await service.addEntry(entry);

      final updated = ProgressEntry(
        id: 'edit_test',
        date: entry.date,
        weight: 78.0,
        bodyFat: 17.0,
        chest: 100,
        waist: 85,
        hips: 95,
        arms: 35,
        thighs: 58,
      );
      await service.updateEntry(updated);

      final result = service.entries.firstWhere((e) => e.id == 'edit_test');
      expect(result.weight, 78.0);
      expect(result.bodyFat, 17.0);
    });
    test('measurement history tracks trends over time', () async {
      final dates = List.generate(
        5,
        (i) => DateTime.now().subtract(Duration(days: (4 - i) * 7)),
      );

      for (int i = 0; i < 5; i++) {
        await service.addEntry(ProgressEntry(
          id: 'trend_$i',
          date: dates[i],
          weight: 85.0 - i,
          bodyFat: 20.0 - (i * 0.5),
          chest: 100.0 + i,
          waist: 88.0 - i,
          hips: 96,
          arms: 34.0 + (i * 0.5),
          thighs: 57.0 + (i * 0.3),
        ));
      }

      final entries = service.entries;
      expect(entries.length, 5);

      // Weight should be trending down — use getWeightHistory()
      final weightHistory = service.getWeightHistory();
      expect(
        weightHistory.first['weight'],
        greaterThan(weightHistory.last['weight']),
      );
    });
  });

  // ========================================
  // CUSTOM WORKOUT SERVICE INTEGRATION
  // ========================================

  group('Custom Workout Integration', () {
    late CustomWorkoutService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'custom_workouts': '[]'});
      service = CustomWorkoutService();
      await service.reload();
    });

    test('create custom workout from exercises and convert to Workout',
        () async {
      final exercises = DataService.getExercises();
      final chestExercises = exercises
          .where((e) => e.muscleGroup.toLowerCase() == 'chest')
          .take(3)
          .toList();

      final now = DateTime.now();
      final custom = CustomWorkout(
        id: 'custom_chest',
        name: 'Chest Destroyer',
        description: 'Intense chest workout',
        muscleGroup: 'Chest',
        difficulty: 'Advanced',
        estimatedDuration: 45,
        estimatedCalories: 350,
        exerciseIds: chestExercises.map((e) => e.id).toList(),
        createdAt: now,
        updatedAt: now,
      );

      await service.createWorkout(custom);

      final workouts = service.customWorkouts;
      expect(workouts.length, 1);

      final workout = custom.toWorkout();
      expect(workout.name, 'Chest Destroyer');
      expect(workout.exercises.length, chestExercises.length);
    });

    test('filter custom workouts by muscle group', () async {
      final groups = ['Chest', 'Back', 'Legs', 'Chest'];
      for (int i = 0; i < groups.length; i++) {
        final now = DateTime.now();
        await service.createWorkout(CustomWorkout(
          id: 'filter_$i',
          name: '${groups[i]} Workout $i',
          description: 'Test',
          muscleGroup: groups[i],
          difficulty: 'Intermediate',
          estimatedDuration: 30,
          estimatedCalories: 200,
          exerciseIds: ['ex1', 'ex2'],
          createdAt: now,
          updatedAt: now,
        ));
      }

      final chestWorkouts = service.getWorkoutsByMuscleGroup('Chest');
      expect(chestWorkouts.length, 2);

      final legWorkouts = service.getWorkoutsByMuscleGroup('Legs');
      expect(legWorkouts.length, 1);
    });
    test('ensure timestamps update on workout edit', () async {
      final now = DateTime.now();
      final custom = CustomWorkout(
        id: 'timestamp_test',
        name: 'Timestamp Test',
        description: 'Testing timestamps',
        muscleGroup: 'Full Body',
        difficulty: 'Beginner',
        estimatedDuration: 30,
        estimatedCalories: 250,
        exerciseIds: ['ex1', 'ex2'],
        createdAt: now,
        updatedAt: now,
      );
      await service.createWorkout(custom);

      final originalUpdatedAt = service.customWorkouts
          .firstWhere((w) => w.id == 'timestamp_test')
          .updatedAt;

      // Wait a bit to ensure timestamp difference
      await Future.delayed(const Duration(seconds: 1));

      final updated = custom.copyWith(name: 'Updated Timestamp Test');
      await service.updateWorkout(updated);

      final newUpdatedAt = service.customWorkouts
          .firstWhere((w) => w.id == 'timestamp_test')
          .updatedAt;

      expect(newUpdatedAt.isAfter(originalUpdatedAt), isTrue);
    });
    test('edit custom workout preserves ID', () async {
      final now = DateTime.now();
      final original = CustomWorkout(
        id: 'edit_test',
        name: 'Original Name',
        description: 'Original desc',
        muscleGroup: 'Back',
        difficulty: 'Beginner',
        estimatedDuration: 20,
        estimatedCalories: 150,
        exerciseIds: ['ex_pullups'],
        createdAt: now,
        updatedAt: now,
      );
      await service.createWorkout(original);

      final updated = original.copyWith(
        name: 'Updated Name',
        exerciseIds: ['ex_pullups', 'ex_rows', 'ex_lat'],
        estimatedDuration: 40,
      );
      await service.updateWorkout(updated);

      final result = service.customWorkouts.firstWhere((w) => w.id == 'edit_test');
      expect(result.name, 'Updated Name');
      expect(result.exerciseIds.length, 3);
      expect(result.estimatedDuration, 40);
    });

    test('delete custom workout removes it completely', () async {
      final now = DateTime.now();
      await service.createWorkout(CustomWorkout(
        id: 'delete_me',
        name: 'To Delete',
        description: 'Will be deleted',
        muscleGroup: 'Arms',
        difficulty: 'Beginner',
        estimatedDuration: 15,
        estimatedCalories: 100,
        exerciseIds: ['ex_curls'],
        createdAt: now,
        updatedAt: now,
      ));

      expect(service.customWorkouts.length, 1);
      await service.deleteWorkout('delete_me');
      expect(service.customWorkouts.length, 0);
    });
  });

  // ========================================
  // DATA SERVICE INTEGRATION
  // ========================================

  group('Data Service Integration', () {
    test('exercises cover all major muscle groups', () {
      final exercises = DataService.getExercises();
      final muscles = exercises.map((e) => e.muscleGroup).toSet();

      expect(muscles, containsAll(['Chest', 'Back', 'Legs']));
      expect(muscles.length, greaterThanOrEqualTo(5));
    });

    test('workouts reference valid exercises', () {
      final exercises = DataService.getExercises();
      final exerciseNames = exercises.map((e) => e.name).toSet();
      final workouts = DataService.getWorkouts();

      for (final workout in workouts) {
        for (final exercise in workout.exercises) {
          expect(
            exerciseNames.contains(exercise.name),
            isTrue,
            reason:
                'Workout "${workout.name}" references unknown exercise "${exercise.name}"',
          );
        }
      }
    });

    test('meals have valid nutritional data', () {
      final meals = DataService.getMeals();
      for (final meal in meals) {
        expect(meal.calories, greaterThan(0));
        expect(meal.protein, greaterThanOrEqualTo(0));
        expect(meal.carbs, greaterThanOrEqualTo(0));
        expect(meal.fat, greaterThanOrEqualTo(0));
      }
    });
  });
}
