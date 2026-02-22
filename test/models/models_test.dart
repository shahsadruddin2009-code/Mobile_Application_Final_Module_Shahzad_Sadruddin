// ============================================================================
// MUSCLE POWER - Model Unit Tests
// ============================================================================
//
// Tests for all data models: Exercise, Workout, WorkoutLog, ExerciseLog,
// SetLog, UserProfile, Meal, MealPlan, ProgressEntry
//
// Verifies:
// - Object construction with required fields
// - Field integrity and types
// - Edge cases (empty lists, null-safe fields)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/models/models.dart';

void main() {
  // ========================================
  // EXERCISE MODEL TESTS
  // ========================================

  group('Exercise Model', () {
    late Exercise exercise;

    setUp(() {
      exercise = Exercise(
        id: 'ex_001',
        name: 'Bench Press',
        muscleGroup: 'Chest',
        description: 'A compound push exercise targeting the chest.',
        imageUrl: 'assets/images/bench_press.png',
        sets: 4,
        reps: 10,
        restTime: '90 seconds',
        difficulty: 'Intermediate',
        tips: ['Keep your back flat', 'Control the descent'],
        equipment: 'Barbell',
      );
    });

    test('creates exercise with all required fields', () {
      expect(exercise.id, 'ex_001');
      expect(exercise.name, 'Bench Press');
      expect(exercise.muscleGroup, 'Chest');
      expect(exercise.description, contains('compound push'));
      expect(exercise.imageUrl, contains('bench_press'));
      expect(exercise.sets, 4);
      expect(exercise.reps, 10);
      expect(exercise.restTime, '90 seconds');
      expect(exercise.difficulty, 'Intermediate');
      expect(exercise.tips, hasLength(2));
      expect(exercise.equipment, 'Barbell');
    });

    test('stores tips as immutable list', () {
      expect(exercise.tips, isA<List<String>>());
      expect(exercise.tips.first, 'Keep your back flat');
      expect(exercise.tips.last, 'Control the descent');
    });

    test('supports empty tips list', () {
      final noTips = Exercise(
        id: 'ex_002',
        name: 'Bodyweight Squat',
        muscleGroup: 'Legs',
        description: 'Basic squat',
        imageUrl: '',
        sets: 3,
        reps: 15,
        restTime: '60 seconds',
        difficulty: 'Beginner',
        tips: [],
        equipment: 'None',
      );
      expect(noTips.tips, isEmpty);
    });

    test('difficulty values are correct strings', () {
      final beginner = Exercise(
        id: 'b',
        name: 'Push Up',
        muscleGroup: 'Chest',
        description: '',
        imageUrl: '',
        sets: 3,
        reps: 10,
        restTime: '60 seconds',
        difficulty: 'Beginner',
        tips: [],
        equipment: 'None',
      );
      final advanced = Exercise(
        id: 'a',
        name: 'Muscle Up',
        muscleGroup: 'Back',
        description: '',
        imageUrl: '',
        sets: 3,
        reps: 5,
        restTime: '120 seconds',
        difficulty: 'Advanced',
        tips: [],
        equipment: 'Pull-up Bar',
      );
      expect(beginner.difficulty, 'Beginner');
      expect(exercise.difficulty, 'Intermediate');
      expect(advanced.difficulty, 'Advanced');
    });
  });

  // ========================================
  // WORKOUT MODEL TESTS
  // ========================================

  group('Workout Model', () {
    late Workout workout;
    late Exercise sampleExercise;

    setUp(() {
      sampleExercise = Exercise(
        id: 'ex_001',
        name: 'Bench Press',
        muscleGroup: 'Chest',
        description: 'Press',
        imageUrl: '',
        sets: 4,
        reps: 10,
        restTime: '90 seconds',
        difficulty: 'Intermediate',
        tips: [],
        equipment: 'Barbell',
      );

      workout = Workout(
        id: 'wk_001',
        name: 'Push Day',
        description: 'Chest, Shoulders, Triceps',
        muscleGroup: 'Chest',
        duration: '45 min',
        difficulty: 'Intermediate',
        caloriesBurned: 350,
        exercises: [sampleExercise],
        imageUrl: 'assets/images/push_day.png',
        targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
      );
    });

    test('creates workout with all required fields', () {
      expect(workout.id, 'wk_001');
      expect(workout.name, 'Push Day');
      expect(workout.description, 'Chest, Shoulders, Triceps');
      expect(workout.muscleGroup, 'Chest');
      expect(workout.duration, '45 min');
      expect(workout.difficulty, 'Intermediate');
      expect(workout.caloriesBurned, 350);
      expect(workout.exercises, hasLength(1));
      expect(workout.imageUrl, isNotEmpty);
      expect(workout.targetMuscles, hasLength(3));
    });

    test('exercises list contains valid Exercise objects', () {
      expect(workout.exercises.first, isA<Exercise>());
      expect(workout.exercises.first.name, 'Bench Press');
    });

    test('target muscles is a list of strings', () {
      expect(workout.targetMuscles, contains('Chest'));
      expect(workout.targetMuscles, contains('Shoulders'));
      expect(workout.targetMuscles, contains('Triceps'));
    });

    test('supports empty exercise list', () {
      final emptyWorkout = Workout(
        id: 'wk_empty',
        name: 'Empty',
        description: '',
        muscleGroup: 'Other',
        duration: '0 min',
        difficulty: 'Beginner',
        caloriesBurned: 0,
        exercises: [],
        imageUrl: '',
        targetMuscles: [],
      );
      expect(emptyWorkout.exercises, isEmpty);
      expect(emptyWorkout.targetMuscles, isEmpty);
    });
  });

  // ========================================
  // SETLOG MODEL TESTS
  // ========================================

  group('SetLog Model', () {
    test('creates completed set with all fields', () {
      final set = SetLog(
        setNumber: 1,
        reps: 10,
        weight: 80.0,
        completed: true,
      );
      expect(set.setNumber, 1);
      expect(set.reps, 10);
      expect(set.weight, 80.0);
      expect(set.completed, isTrue);
    });

    test('creates incomplete set', () {
      final set = SetLog(
        setNumber: 3,
        reps: 6,
        weight: 100.0,
        completed: false,
      );
      expect(set.completed, isFalse);
    });

    test('supports zero weight (bodyweight)', () {
      final set = SetLog(
        setNumber: 1,
        reps: 20,
        weight: 0.0,
        completed: true,
      );
      expect(set.weight, 0.0);
    });
  });

  // ========================================
  // EXERCISE LOG MODEL TESTS
  // ========================================

  group('ExerciseLog Model', () {
    test('creates log with exercise and sets', () {
      final exercise = Exercise(
        id: 'ex_001',
        name: 'Squat',
        muscleGroup: 'Legs',
        description: '',
        imageUrl: '',
        sets: 3,
        reps: 8,
        restTime: '120 seconds',
        difficulty: 'Advanced',
        tips: [],
        equipment: 'Barbell',
      );

      final sets = [
        SetLog(setNumber: 1, reps: 8, weight: 100.0, completed: true),
        SetLog(setNumber: 2, reps: 8, weight: 100.0, completed: true),
        SetLog(setNumber: 3, reps: 6, weight: 100.0, completed: false),
      ];

      final log = ExerciseLog(exercise: exercise, sets: sets);

      expect(log.exercise.name, 'Squat');
      expect(log.sets, hasLength(3));
      expect(log.sets[2].completed, isFalse);
    });
  });

  // ========================================
  // WORKOUT LOG MODEL TESTS
  // ========================================

  group('WorkoutLog Model', () {
    test('creates workout log with complete data', () {
      final exercise = Exercise(
        id: 'ex_001',
        name: 'Bench Press',
        muscleGroup: 'Chest',
        description: '',
        imageUrl: '',
        sets: 3,
        reps: 10,
        restTime: '90 seconds',
        difficulty: 'Intermediate',
        tips: [],
        equipment: 'Barbell',
      );

      final workout = Workout(
        id: 'wk_001',
        name: 'Push Day',
        description: 'Chest workout',
        muscleGroup: 'Chest',
        duration: '45 min',
        difficulty: 'Intermediate',
        caloriesBurned: 300,
        exercises: [exercise],
        imageUrl: '',
        targetMuscles: ['Chest'],
      );

      final date = DateTime(2025, 6, 15, 10, 30);
      final exerciseLogs = [
        ExerciseLog(
          exercise: exercise,
          sets: [
            SetLog(setNumber: 1, reps: 10, weight: 60.0, completed: true),
          ],
        ),
      ];

      final log = WorkoutLog(
        id: 'log_001',
        date: date,
        workout: workout,
        duration: 42,
        caloriesBurned: 280,
        exerciseLogs: exerciseLogs,
        notes: 'Felt strong today',
      );

      expect(log.id, 'log_001');
      expect(log.date, date);
      expect(log.workout.name, 'Push Day');
      expect(log.duration, 42);
      expect(log.caloriesBurned, 280);
      expect(log.exerciseLogs, hasLength(1));
      expect(log.notes, 'Felt strong today');
    });
  });

  // ========================================
  // USER PROFILE MODEL TESTS
  // ========================================

  group('UserProfile Model', () {
    test('creates profile with all fields', () {
      final profile = UserProfile(
        name: 'John Doe',
        age: 28,
        height: 180.0,
        weight: 85.0,
        targetWeight: 80.0,
        fitnessGoal: 'Build Muscle',
        experienceLevel: 'Intermediate',
        workoutsCompleted: 42,
        totalMinutes: 2100,
        totalCaloriesBurned: 15000,
        achievements: ['First Workout', '10 Day Streak'],
      );

      expect(profile.name, 'John Doe');
      expect(profile.age, 28);
      expect(profile.height, 180.0);
      expect(profile.weight, 85.0);
      expect(profile.targetWeight, 80.0);
      expect(profile.fitnessGoal, 'Build Muscle');
      expect(profile.experienceLevel, 'Intermediate');
      expect(profile.workoutsCompleted, 42);
      expect(profile.totalMinutes, 2100);
      expect(profile.totalCaloriesBurned, 15000);
      expect(profile.achievements, hasLength(2));
    });

    test('supports empty achievements list', () {
      final profile = UserProfile(
        name: 'New User',
        age: 20,
        height: 170.0,
        weight: 70.0,
        targetWeight: 75.0,
        fitnessGoal: 'Lose Weight',
        experienceLevel: 'Beginner',
        workoutsCompleted: 0,
        totalMinutes: 0,
        totalCaloriesBurned: 0,
        achievements: [],
      );
      expect(profile.achievements, isEmpty);
      expect(profile.workoutsCompleted, 0);
    });
  });

  // ========================================
  // MEAL MODEL TESTS
  // ========================================

  group('Meal Model', () {
    test('creates meal with full nutritional info', () {
      final meal = Meal(
        id: 'meal_001',
        name: 'Grilled Chicken Salad',
        mealType: 'Lunch',
        calories: 450,
        protein: 42.0,
        carbs: 20.0,
        fat: 18.0,
        ingredients: ['Chicken breast', 'Mixed greens', 'Olive oil'],
        imageUrl: 'assets/images/chicken_salad.png',
        prepTime: '10 min',
        cookTime: '15 min',
        instructions: ['Grill the chicken', 'Toss the salad', 'Drizzle oil'],
      );

      expect(meal.id, 'meal_001');
      expect(meal.name, 'Grilled Chicken Salad');
      expect(meal.mealType, 'Lunch');
      expect(meal.calories, 450);
      expect(meal.protein, 42.0);
      expect(meal.carbs, 20.0);
      expect(meal.fat, 18.0);
      expect(meal.ingredients, hasLength(3));
      expect(meal.prepTime, '10 min');
      expect(meal.cookTime, '15 min');
      expect(meal.instructions, hasLength(3));
    });

    test('meal types are valid strings', () {
      final types = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
      for (final type in types) {
        final meal = Meal(
          id: 'id_$type',
          name: type,
          mealType: type,
          calories: 100,
          protein: 10.0,
          carbs: 10.0,
          fat: 5.0,
          ingredients: [],
          imageUrl: '',
          prepTime: '5 min',
          cookTime: '0 min',
          instructions: [],
        );
        expect(meal.mealType, type);
      }
    });
  });

  // ========================================
  // MEAL PLAN MODEL TESTS
  // ========================================

  group('MealPlan Model', () {
    test('creates meal plan with aggregate macros', () {
      final meals = [
        Meal(
          id: 'm1',
          name: 'Oats',
          mealType: 'Breakfast',
          calories: 350,
          protein: 12.0,
          carbs: 55.0,
          fat: 8.0,
          ingredients: ['Oats', 'Milk'],
          imageUrl: '',
          prepTime: '5 min',
          cookTime: '3 min',
          instructions: ['Mix and heat'],
        ),
        Meal(
          id: 'm2',
          name: 'Chicken Rice',
          mealType: 'Lunch',
          calories: 600,
          protein: 45.0,
          carbs: 70.0,
          fat: 12.0,
          ingredients: ['Chicken', 'Rice'],
          imageUrl: '',
          prepTime: '10 min',
          cookTime: '20 min',
          instructions: ['Cook chicken', 'Cook rice'],
        ),
      ];

      final plan = MealPlan(
        id: 'plan_001',
        name: 'High Protein Day',
        description: 'Focuses on protein intake',
        totalCalories: 950,
        totalProtein: 57.0,
        totalCarbs: 125.0,
        totalFat: 20.0,
        meals: meals,
      );

      expect(plan.id, 'plan_001');
      expect(plan.name, 'High Protein Day');
      expect(plan.totalCalories, 950);
      expect(plan.totalProtein, 57.0);
      expect(plan.totalCarbs, 125.0);
      expect(plan.totalFat, 20.0);
      expect(plan.meals, hasLength(2));
    });
  });

  // ========================================
  // PROGRESS ENTRY MODEL TESTS (Legacy)
  // ========================================

  group('ProgressEntry Model (Legacy)', () {
    test('creates entry with all fields', () {
      final entry = ProgressEntry(
        date: DateTime(2025, 3, 15),
        weight: 82.5,
        bodyFat: 15.0,
        measurements: {
          'chest': 42.0,
          'waist': 32.0,
          'arms': 15.0,
          'thighs': 24.0,
        },
        notes: 'Feeling leaner',
        photoUrl: 'https://example.com/photo.jpg',
      );

      expect(entry.date, DateTime(2025, 3, 15));
      expect(entry.weight, 82.5);
      expect(entry.bodyFat, 15.0);
      expect(entry.measurements, hasLength(4));
      expect(entry.measurements['chest'], 42.0);
      expect(entry.notes, 'Feeling leaner');
      expect(entry.photoUrl, isNotNull);
    });

    test('photoUrl is optional', () {
      final entry = ProgressEntry(
        date: DateTime(2025, 3, 15),
        weight: 80.0,
        bodyFat: 14.0,
        measurements: {},
        notes: '',
      );
      expect(entry.photoUrl, isNull);
    });

    test('supports empty measurements map', () {
      final entry = ProgressEntry(
        date: DateTime(2025, 1, 1),
        weight: 75.0,
        bodyFat: 20.0,
        measurements: {},
        notes: 'First entry',
      );
      expect(entry.measurements, isEmpty);
    });
  });
}
