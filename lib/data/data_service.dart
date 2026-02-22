// ============================================================================
// MUSCLE POWER - Data Service (Sample Data Provider)
// ============================================================================
// 
// File: data_service.dart
// Description: Provides sample/demo data for the application
// 
// Purpose:
// This service provides static sample data for demonstration purposes.
// In a production app, this data would come from:
// - A backend API (REST, GraphQL)
// - Local database (SQLite, Hive)
// - Firebase/Firestore
// - User-generated content
// 
// Data Provided:
// - Exercises: Complete exercise library with 30+ exercises
// - Workouts: Pre-built workout programs (8 workouts)
// - Meals: Sample meal plans with nutritional info (8 meals)
// - Progress: Sample progress history for charts
// - User Profile: Demo user profile data
// 
// Muscle Groups Covered:
// - Chest (6 exercises)
// - Back (5 exercises)
// - Shoulders (4 exercises)
// - Arms (5 exercises)
// - Legs (6 exercises)
// - Core (4 exercises)
// ============================================================================

import '../models/models.dart';

/// Static data provider for sample/demo content
/// 
/// All methods are static - no instance needed.
/// Data is generated fresh on each call (not cached).
/// 
/// Usage:
/// ```dart
/// final exercises = DataService.getExercises();
/// final workouts = DataService.getWorkouts();
/// ```
class DataService {
  // ========================================
  // EXERCISE LIBRARY
  // ========================================

  /// Get complete exercise library
  /// 
  /// Returns 30+ exercises covering all major muscle groups.
  /// Each exercise includes:
  /// - Name and description
  /// - Target muscle group
  /// - Sets, reps, and rest time recommendations
  /// - Difficulty level (Beginner/Intermediate/Advanced)
  /// - Form tips and equipment needed
  static List<Exercise> getExercises() {
    return [
      // ----------------------------------------
      // CHEST EXERCISES (6 exercises)
      // Primary: Pectoralis Major/Minor
      // Secondary: Anterior Deltoid, Triceps
      // ----------------------------------------
      Exercise(
        id: 'chest_1',
        name: 'Barbell Bench Press',
        muscleGroup: 'Chest',
        description: 'The king of chest exercises. Lie on a flat bench and press a barbell from chest level to arm extension.',
        imageUrl: 'assets/exercises/bench_press.png',
        sets: 4,
        reps: 10,
        restTime: '90 sec',
        difficulty: 'Intermediate',
        tips: [
          'Keep your feet flat on the floor',
          'Maintain a slight arch in your lower back',
          'Lower the bar to mid-chest level',
          'Drive through your heels as you press'
        ],
        equipment: 'Barbell, Bench',
      ),
      Exercise(
        id: 'chest_2',
        name: 'Incline Dumbbell Press',
        muscleGroup: 'Chest',
        description: 'Targets the upper chest. Perform on an incline bench set to 30-45 degrees.',
        imageUrl: 'assets/exercises/incline_press.png',
        sets: 4,
        reps: 12,
        restTime: '60 sec',
        difficulty: 'Intermediate',
        tips: [
          'Keep dumbbells in line with upper chest',
          'Control the descent slowly',
          'Squeeze chest at the top'
        ],
        equipment: 'Dumbbells, Incline Bench',
      ),
      Exercise(
        id: 'chest_3',
        name: 'Cable Flyes',
        muscleGroup: 'Chest',
        description: 'Isolation exercise for chest development. Maintain a slight bend in elbows throughout.',
        imageUrl: 'assets/exercises/cable_flyes.png',
        sets: 3,
        reps: 15,
        restTime: '45 sec',
        difficulty: 'Beginner',
        tips: [
          'Focus on squeezing the chest',
          'Keep movement controlled',
          'Maintain slight elbow bend'
        ],
        equipment: 'Cable Machine',
      ),
      Exercise(
        id: 'chest_4',
        name: 'Push-Ups',
        muscleGroup: 'Chest',
        description: 'Classic bodyweight chest exercise. Great for endurance and muscle definition.',
        imageUrl: 'assets/exercises/pushups.png',
        sets: 3,
        reps: 20,
        restTime: '45 sec',
        difficulty: 'Beginner',
        tips: [
          'Keep core tight',
          'Full range of motion',
          'Hands shoulder-width apart'
        ],
        equipment: 'None',
      ),
      Exercise(
        id: 'chest_5',
        name: 'Dips',
        muscleGroup: 'Chest',
        description: 'Compound movement targeting lower chest. Lean forward to emphasize chest activation.',
        imageUrl: 'assets/exercises/dips.png',
        sets: 3,
        reps: 12,
        restTime: '60 sec',
        difficulty: 'Intermediate',
        tips: [
          'Lean forward for chest focus',
          'Go deep for full stretch',
          'Control the negative'
        ],
        equipment: 'Dip Bars',
      ),
      Exercise(
        id: 'chest_6',
        name: 'Incline Cable Fly',
        muscleGroup: 'Chest',
        description: 'An isolation exercise performed on an incline bench using a cable machine. Targets the upper chest with constant tension throughout the range of motion.',
        imageUrl: 'assets/exercises/incline_cable_fly.png',
        sets: 3,
        reps: 12,
        restTime: '60 sec',
        difficulty: 'Intermediate',
        tips: [
          'Set the bench to a 30-45 degree incline',
          'Keep a slight bend in your elbows throughout',
          'Bring hands together above your upper chest',
          'Control the stretch at the bottom, squeeze at the top',
          'Use low cable pulleys for proper line of resistance'
        ],
        equipment: 'Cable Machine, Incline Bench',
      ),

      // ----------------------------------------
      // BACK EXERCISES (5 exercises)
      // Primary: Latissimus Dorsi, Rhomboids, Traps
      // Secondary: Biceps, Rear Delts
      // ----------------------------------------
      Exercise(
        id: 'back_1',
        name: 'Deadlift',
        muscleGroup: 'Back',
        description: 'The ultimate compound exercise. Works the entire posterior chain.',
        imageUrl: 'assets/exercises/deadlift.png',
        sets: 4,
        reps: 6,
        restTime: '120 sec',
        difficulty: 'Advanced',
        tips: [
          'Keep back straight throughout',
          'Drive through heels',
          'Lock out at the top',
          'Keep bar close to body'
        ],
        equipment: 'Barbell',
      ),
      Exercise(
        id: 'back_2',
        name: 'Pull-Ups',
        muscleGroup: 'Back',
        description: 'Classic back builder targeting lats. Use various grips for different emphasis.',
        imageUrl: 'assets/exercises/pullups.png',
        sets: 4,
        reps: 10,
        restTime: '90 sec',
        difficulty: 'Intermediate',
        tips: [
          'Full extension at bottom',
          'Pull with elbows, not hands',
          'Chin over bar at top'
        ],
        equipment: 'Pull-Up Bar',
      ),
      Exercise(
        id: 'back_3',
        name: 'Barbell Rows',
        muscleGroup: 'Back',
        description: 'Bent over rowing movement for thick back development.',
        imageUrl: 'assets/exercises/barbell_rows.png',
        sets: 4,
        reps: 10,
        restTime: '90 sec',
        difficulty: 'Intermediate',
        tips: [
          'Keep back parallel to floor',
          'Pull to lower chest',
          'Squeeze shoulder blades'
        ],
        equipment: 'Barbell',
      ),
      Exercise(
        id: 'back_4',
        name: 'Lat Pulldown',
        muscleGroup: 'Back',
        description: 'Machine exercise for lat width. Great for beginners and advanced alike.',
        imageUrl: 'assets/exercises/lat_pulldown.png',
        sets: 3,
        reps: 12,
        restTime: '60 sec',
        difficulty: 'Beginner',
        tips: [
          'Pull to upper chest',
          'Lean back slightly',
          'Control the weight up'
        ],
        equipment: 'Cable Machine',
      ),
      Exercise(
        id: 'back_5',
        name: 'Seated Cable Rows',
        muscleGroup: 'Back',
        description: 'Isolation exercise for mid-back thickness.',
        imageUrl: 'assets/exercises/seated_rows.png',
        sets: 3,
        reps: 12,
        restTime: '60 sec',
        difficulty: 'Beginner',
        tips: [
          'Keep torso stationary',
          'Pull to lower ribcage',
          'Pause and squeeze'
        ],
        equipment: 'Cable Machine',
      ),

      // ----------------------------------------
      // SHOULDER EXERCISES (4 exercises)
      // Primary: Deltoids (anterior, lateral, posterior)
      // Secondary: Traps, Rotator Cuff
      // ----------------------------------------
      Exercise(
        id: 'shoulder_1',
        name: 'Overhead Press',
        muscleGroup: 'Shoulders',
        description: 'Primary shoulder mass builder. Press barbell from shoulders to overhead.',
        imageUrl: 'assets/exercises/overhead_press.png',
        sets: 4,
        reps: 10,
        restTime: '90 sec',
        difficulty: 'Intermediate',
        tips: [
          'Keep core braced',
          'Full lockout at top',
          'Control the descent'
        ],
        equipment: 'Barbell',
      ),
      Exercise(
        id: 'shoulder_2',
        name: 'Lateral Raises',
        muscleGroup: 'Shoulders',
        description: 'Isolation exercise for side delts. Creates the wide shoulder look.',
        imageUrl: 'assets/exercises/lateral_raises.png',
        sets: 4,
        reps: 15,
        restTime: '45 sec',
        difficulty: 'Beginner',
        tips: [
          'Lead with elbows',
          'Slight bend in elbows',
          'Control the negative'
        ],
        equipment: 'Dumbbells',
      ),
      Exercise(
        id: 'shoulder_3',
        name: 'Face Pulls',
        muscleGroup: 'Shoulders',
        description: 'Targets rear delts and rotator cuff. Essential for shoulder health.',
        imageUrl: 'assets/exercises/face_pulls.png',
        sets: 3,
        reps: 15,
        restTime: '45 sec',
        difficulty: 'Beginner',
        tips: [
          'Pull to face level',
          'External rotation at end',
          'Squeeze rear delts'
        ],
        equipment: 'Cable Machine',
      ),
      Exercise(
        id: 'shoulder_4',
        name: 'Arnold Press',
        muscleGroup: 'Shoulders',
        description: 'Rotating dumbbell press hitting all three deltoid heads.',
        imageUrl: 'assets/exercises/arnold_press.png',
        sets: 3,
        reps: 12,
        restTime: '60 sec',
        difficulty: 'Intermediate',
        tips: [
          'Rotate palms as you press',
          'Full range of motion',
          'Control throughout'
        ],
        equipment: 'Dumbbells',
      ),

      // ----------------------------------------
      // ARM EXERCISES (5 exercises)
      // Biceps: Biceps Brachii, Brachialis
      // Triceps: All three heads
      // ----------------------------------------
      Exercise(
        id: 'arms_1',
        name: 'Barbell Curls',
        muscleGroup: 'Arms',
        description: 'Classic bicep builder. Strict form is essential.',
        imageUrl: 'assets/exercises/barbell_curls.png',
        sets: 4,
        reps: 12,
        restTime: '60 sec',
        difficulty: 'Beginner',
        tips: [
          'Keep elbows stationary',
          'Full contraction at top',
          'Control the negative'
        ],
        equipment: 'Barbell',
      ),
      Exercise(
        id: 'arms_2',
        name: 'Tricep Pushdowns',
        muscleGroup: 'Arms',
        description: 'Cable exercise for tricep development. Various attachments work.',
        imageUrl: 'assets/exercises/tricep_pushdowns.png',
        sets: 4,
        reps: 15,
        restTime: '45 sec',
        difficulty: 'Beginner',
        tips: [
          'Keep elbows at sides',
          'Full extension at bottom',
          'Squeeze triceps hard'
        ],
        equipment: 'Cable Machine',
      ),
      Exercise(
        id: 'arms_3',
        name: 'Hammer Curls',
        muscleGroup: 'Arms',
        description: 'Targets brachialis and brachioradialis for arm thickness.',
        imageUrl: 'assets/exercises/hammer_curls.png',
        sets: 3,
        reps: 12,
        restTime: '45 sec',
        difficulty: 'Beginner',
        tips: [
          'Neutral grip throughout',
          'Alternating or together',
          'Control the weight'
        ],
        equipment: 'Dumbbells',
      ),
      Exercise(
        id: 'arms_4',
        name: 'Skull Crushers',
        muscleGroup: 'Arms',
        description: 'Lying tricep extension for long head development.',
        imageUrl: 'assets/exercises/skull_crushers.png',
        sets: 3,
        reps: 12,
        restTime: '60 sec',
        difficulty: 'Intermediate',
        tips: [
          'Lower to forehead',
          'Keep upper arms vertical',
          'Full extension at top'
        ],
        equipment: 'EZ Bar, Bench',
      ),
      Exercise(
        id: 'arms_5',
        name: 'Preacher Curls',
        muscleGroup: 'Arms',
        description: 'Isolation bicep exercise eliminating momentum.',
        imageUrl: 'assets/exercises/preacher_curls.png',
        sets: 3,
        reps: 12,
        restTime: '45 sec',
        difficulty: 'Beginner',
        tips: [
          'Full stretch at bottom',
          'Squeeze at top',
          'Slow controlled reps'
        ],
        equipment: 'Preacher Bench, EZ Bar',
      ),

      // ----------------------------------------
      // LEG EXERCISES (6 exercises)
      // Quads, Hamstrings, Glutes, Calves
      // ----------------------------------------
      Exercise(
        id: 'legs_1',
        name: 'Barbell Squats',
        muscleGroup: 'Legs',
        description: 'The king of leg exercises. Builds overall leg mass and strength.',
        imageUrl: 'assets/exercises/squats.png',
        sets: 4,
        reps: 8,
        restTime: '120 sec',
        difficulty: 'Intermediate',
        tips: [
          'Depth below parallel',
          'Keep chest up',
          'Drive through heels',
          'Knees track over toes'
        ],
        equipment: 'Barbell, Squat Rack',
      ),
      Exercise(
        id: 'legs_2',
        name: 'Romanian Deadlift',
        muscleGroup: 'Legs',
        description: 'Targets hamstrings and glutes. Essential for posterior chain.',
        imageUrl: 'assets/exercises/rdl.png',
        sets: 4,
        reps: 10,
        restTime: '90 sec',
        difficulty: 'Intermediate',
        tips: [
          'Hinge at hips',
          'Keep bar close',
          'Feel hamstring stretch',
          'Slight knee bend'
        ],
        equipment: 'Barbell',
      ),
      Exercise(
        id: 'legs_3',
        name: 'Leg Press',
        muscleGroup: 'Legs',
        description: 'Machine compound movement for leg development.',
        imageUrl: 'assets/exercises/leg_press.png',
        sets: 4,
        reps: 12,
        restTime: '90 sec',
        difficulty: 'Beginner',
        tips: [
          'Full range of motion',
          'Dont lock knees',
          'Control the descent'
        ],
        equipment: 'Leg Press Machine',
      ),
      Exercise(
        id: 'legs_4',
        name: 'Leg Curls',
        muscleGroup: 'Legs',
        description: 'Isolation exercise for hamstring development.',
        imageUrl: 'assets/exercises/leg_curls.png',
        sets: 3,
        reps: 15,
        restTime: '45 sec',
        difficulty: 'Beginner',
        tips: [
          'Full contraction',
          'Slow negative',
          'Dont use momentum'
        ],
        equipment: 'Leg Curl Machine',
      ),
      Exercise(
        id: 'legs_5',
        name: 'Calf Raises',
        muscleGroup: 'Legs',
        description: 'Builds calf muscle size and definition.',
        imageUrl: 'assets/exercises/calf_raises.png',
        sets: 4,
        reps: 20,
        restTime: '30 sec',
        difficulty: 'Beginner',
        tips: [
          'Full stretch at bottom',
          'Pause at top',
          'High rep ranges work best'
        ],
        equipment: 'Calf Raise Machine',
      ),
      Exercise(
        id: 'legs_6',
        name: 'Lunges',
        muscleGroup: 'Legs',
        description: 'Unilateral leg exercise for balance and development.',
        imageUrl: 'assets/exercises/lunges.png',
        sets: 3,
        reps: 12,
        restTime: '60 sec',
        difficulty: 'Beginner',
        tips: [
          'Knee doesnt pass toes',
          'Upright torso',
          'Step far enough'
        ],
        equipment: 'Dumbbells',
      ),

      // ----------------------------------------
      // CORE EXERCISES (4 exercises)
      // Rectus Abdominis, Obliques, Transverse
      // ----------------------------------------
      Exercise(
        id: 'core_1',
        name: 'Planks',
        muscleGroup: 'Core',
        description: 'Isometric core exercise for stability and endurance.',
        imageUrl: 'assets/exercises/planks.png',
        sets: 3,
        reps: 60,  // 60 seconds hold
        restTime: '45 sec',
        difficulty: 'Beginner',
        tips: [
          'Keep body straight',
          'Engage core tight',
          'Dont let hips sag'
        ],
        equipment: 'None',
      ),
      Exercise(
        id: 'core_2',
        name: 'Cable Crunches',
        muscleGroup: 'Core',
        description: 'Weighted ab exercise for building thick abs.',
        imageUrl: 'assets/exercises/cable_crunches.png',
        sets: 4,
        reps: 15,
        restTime: '45 sec',
        difficulty: 'Intermediate',
        tips: [
          'Crunch ribs to hips',
          'Hold contraction',
          'Controlled movement'
        ],
        equipment: 'Cable Machine',
      ),
      Exercise(
        id: 'core_3',
        name: 'Hanging Leg Raises',
        muscleGroup: 'Core',
        description: 'Advanced ab exercise targeting lower abs.',
        imageUrl: 'assets/exercises/leg_raises.png',
        sets: 3,
        reps: 12,
        restTime: '60 sec',
        difficulty: 'Advanced',
        tips: [
          'Minimize swinging',
          'Lift legs with abs',
          'Control the descent'
        ],
        equipment: 'Pull-Up Bar',
      ),
      Exercise(
        id: 'core_4',
        name: 'Russian Twists',
        muscleGroup: 'Core',
        description: 'Rotational exercise for obliques.',
        imageUrl: 'assets/exercises/russian_twists.png',
        sets: 3,
        reps: 20,  // 20 per side
        restTime: '45 sec',
        difficulty: 'Beginner',
        tips: [
          'Keep feet elevated',
          'Rotate from core',
          'Touch weight to ground'
        ],
        equipment: 'Medicine Ball',
      ),
    ];
  }

  // ========================================
  // WORKOUT PROGRAMS
  // ========================================

  /// Get pre-built workout programs
  /// 
  /// Returns 8 complete workout routines:
  /// - Single muscle group workouts (Chest, Back, Shoulders, Arms, Legs, Core)
  /// - Split workouts (Push Day, Pull Day)
  /// 
  /// Each workout includes:
  /// - Curated exercise selection
  /// - Estimated duration and calories
  /// - Target muscle list
  static List<Workout> getWorkouts() {
    // Get exercises to reference in workouts
    final exercises = getExercises();

    return [
      // Single muscle group workouts
      Workout(
        id: 'workout_1',
        name: 'Chest Destroyer',
        description: 'Intense chest workout for maximum pump and growth',
        muscleGroup: 'Chest',
        duration: '45 min',
        difficulty: 'Intermediate',
        caloriesBurned: 350,
        exercises: exercises.where((e) => e.muscleGroup == 'Chest').toList(),
        imageUrl: 'assets/images/Chest_Workout_Image.jpg',
        targetMuscles: ['Pectoralis Major', 'Pectoralis Minor', 'Anterior Deltoid'],
      ),
      Workout(
        id: 'workout_2',
        name: 'Back Attack',
        description: 'Build a wide and thick back with this routine',
        muscleGroup: 'Back',
        duration: '50 min',
        difficulty: 'Intermediate',
        caloriesBurned: 400,
        exercises: exercises.where((e) => e.muscleGroup == 'Back').toList(),
        imageUrl: 'assets/images/Back_Workout_Image.jpg',
        targetMuscles: ['Latissimus Dorsi', 'Rhomboids', 'Trapezius', 'Erector Spinae'],
      ),
      Workout(
        id: 'workout_3',
        name: 'Boulder Shoulders',
        description: 'Sculpt cannonball delts with this comprehensive workout',
        muscleGroup: 'Shoulders',
        duration: '40 min',
        difficulty: 'Intermediate',
        caloriesBurned: 280,
        exercises: exercises.where((e) => e.muscleGroup == 'Shoulders').toList(),
        imageUrl: 'assets/images/Shoulder_Workout_Image.jpg',
        targetMuscles: ['Anterior Deltoid', 'Lateral Deltoid', 'Posterior Deltoid'],
      ),
      Workout(
        id: 'workout_4',
        name: 'Arm Annihilator',
        description: 'Build sleeve-busting arms with biceps and triceps focus',
        muscleGroup: 'Arms',
        duration: '40 min',
        difficulty: 'Beginner',
        caloriesBurned: 250,
        exercises: exercises.where((e) => e.muscleGroup == 'Arms').toList(),
        imageUrl: 'assets/images/Arm_Workout_Images.jpg',
        targetMuscles: ['Biceps Brachii', 'Triceps Brachii', 'Brachialis', 'Forearms'],
      ),
      Workout(
        id: 'workout_5',
        name: 'Leg Day Legends',
        description: 'Brutal leg workout for massive quad and hamstring development',
        muscleGroup: 'Legs',
        duration: '60 min',
        difficulty: 'Advanced',
        caloriesBurned: 500,
        exercises: exercises.where((e) => e.muscleGroup == 'Legs').toList(),
        imageUrl: 'assets/images/Legs_workout_Image.jpg',
        targetMuscles: ['Quadriceps', 'Hamstrings', 'Glutes', 'Calves'],
      ),
      Workout(
        id: 'workout_6',
        name: 'Core Crusher',
        description: 'Build a rock-solid core with this ab-focused routine',
        muscleGroup: 'Core',
        duration: '30 min',
        difficulty: 'Intermediate',
        caloriesBurned: 200,
        exercises: exercises.where((e) => e.muscleGroup == 'Core').toList(),
        imageUrl: 'assets/images/Core_Cursher_Images.jpg',
        targetMuscles: ['Rectus Abdominis', 'Obliques', 'Transverse Abdominis'],
      ),
      // Push/Pull split workouts
      Workout(
        id: 'workout_7',
        name: 'Push Day Power',
        description: 'Complete push workout: Chest, Shoulders, Triceps',
        muscleGroup: 'Push',
        duration: '60 min',
        difficulty: 'Intermediate',
        caloriesBurned: 450,
        exercises: exercises.where((e) =>
          e.muscleGroup == 'Chest' ||
          e.muscleGroup == 'Shoulders' ||
          e.name.contains('Tricep') ||
          e.name.contains('Skull')
        ).take(8).toList(),
        imageUrl: 'assets/images/Push_Day_Power_Images.jpg',
        targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
      ),
      Workout(
        id: 'workout_8',
        name: 'Pull Day Pump',
        description: 'Complete pull workout: Back and Biceps',
        muscleGroup: 'Pull',
        duration: '55 min',
        difficulty: 'Intermediate',
        caloriesBurned: 420,
        exercises: exercises.where((e) =>
          e.muscleGroup == 'Back' ||
          e.name.contains('Curl')
        ).take(8).toList(),
        imageUrl: 'assets/images/Pull_Day_Pump_Images.jpg',
        targetMuscles: ['Back', 'Biceps', 'Rear Delts'],
      ),
    ];
  }

  // ========================================
  // MEAL PLANS
  // ========================================

  /// Get sample meal plans
  /// 
  /// Returns 8 meals covering all meal types:
  /// - Breakfast (2 meals)
  /// - Lunch (2 meals)
  /// - Dinner (2 meals)
  /// - Snacks/Shakes (2 meals)
  /// 
  /// Each meal includes:
  /// - Complete macronutrient breakdown
  /// - Ingredient list
  /// - Prep and cook times
  /// - Step-by-step instructions
  static List<Meal> getMeals() {
    return [
      // Breakfast options
      Meal(
        id: 'meal_1',
        name: 'Protein Power Breakfast',
        mealType: 'Breakfast',
        calories: 550,
        protein: 45,
        carbs: 40,
        fat: 20,
        ingredients: [
          '4 egg whites + 2 whole eggs',
          '1 cup oatmeal',
          '1 banana',
          '1 tbsp peanut butter',
          'Cinnamon to taste'
        ],
        imageUrl: 'assets/meals/breakfast.png',
        prepTime: '5 min',
        cookTime: '10 min',
        instructions: [
          'Cook oatmeal according to package directions',
          'Scramble eggs in a non-stick pan',
          'Slice banana over oatmeal',
          'Add peanut butter and cinnamon',
          'Serve eggs on the side'
        ],
      ),
      Meal(
        id: 'meal_8',
        name: 'Greek Yogurt Parfait',
        mealType: 'Breakfast',
        calories: 380,
        protein: 28,
        carbs: 45,
        fat: 10,
        ingredients: [
          '1.5 cups Greek yogurt',
          '1/2 cup granola',
          '1 cup mixed berries',
          '1 tbsp honey',
          'Chia seeds'
        ],
        imageUrl: 'assets/meals/parfait.png',
        prepTime: '5 min',
        cookTime: '0 min',
        instructions: [
          'Layer yogurt in a glass or bowl',
          'Add granola layer',
          'Top with mixed berries',
          'Drizzle with honey',
          'Sprinkle chia seeds on top'
        ],
      ),
      // Lunch options
      Meal(
        id: 'meal_2',
        name: 'Chicken & Rice Bowl',
        mealType: 'Lunch',
        calories: 650,
        protein: 55,
        carbs: 60,
        fat: 15,
        ingredients: [
          '8 oz chicken breast',
          '1.5 cups brown rice',
          '1 cup broccoli',
          '1 tbsp olive oil',
          'Garlic and herbs'
        ],
        imageUrl: 'assets/meals/chicken_rice.png',
        prepTime: '10 min',
        cookTime: '25 min',
        instructions: [
          'Season chicken breast with herbs and garlic',
          'Grill or bake chicken until cooked through',
          'Cook brown rice according to package',
          'Steam broccoli until tender',
          'Combine in a bowl, drizzle with olive oil'
        ],
      ),
      Meal(
        id: 'meal_7',
        name: 'Turkey Avocado Wrap',
        mealType: 'Lunch',
        calories: 480,
        protein: 38,
        carbs: 35,
        fat: 22,
        ingredients: [
          '6 oz turkey breast',
          '1 whole wheat wrap',
          '1/2 avocado',
          'Lettuce, tomato, onion',
          'Mustard'
        ],
        imageUrl: 'assets/meals/wrap.png',
        prepTime: '10 min',
        cookTime: '0 min',
        instructions: [
          'Lay wrap flat and spread mustard',
          'Layer turkey, avocado slices, and vegetables',
          'Roll tightly and cut in half',
          'Serve with side salad'
        ],
      ),
      // Dinner options
      Meal(
        id: 'meal_3',
        name: 'Salmon Power Plate',
        mealType: 'Dinner',
        calories: 580,
        protein: 42,
        carbs: 35,
        fat: 28,
        ingredients: [
          '6 oz salmon fillet',
          '1 cup sweet potato',
          '1 cup asparagus',
          '1 tbsp butter',
          'Lemon and dill'
        ],
        imageUrl: 'assets/meals/salmon.png',
        prepTime: '10 min',
        cookTime: '20 min',
        instructions: [
          'Season salmon with lemon, dill, salt and pepper',
          'Bake at 400F for 12-15 minutes',
          'Cube and roast sweet potato',
          'Saute asparagus in butter',
          'Plate and serve hot'
        ],
      ),
      Meal(
        id: 'meal_6',
        name: 'Lean Beef Stir Fry',
        mealType: 'Dinner',
        calories: 550,
        protein: 48,
        carbs: 40,
        fat: 18,
        ingredients: [
          '7 oz lean beef strips',
          '2 cups mixed vegetables',
          '1 cup jasmine rice',
          '2 tbsp soy sauce',
          'Ginger and garlic'
        ],
        imageUrl: 'assets/meals/stir_fry.png',
        prepTime: '15 min',
        cookTime: '15 min',
        instructions: [
          'Slice beef into thin strips',
          'Stir fry beef in hot wok with garlic and ginger',
          'Add vegetables and soy sauce',
          'Cook until vegetables are tender-crisp',
          'Serve over jasmine rice'
        ],
      ),
      // Snacks and shakes
      Meal(
        id: 'meal_4',
        name: 'Pre-Workout Shake',
        mealType: 'Snack',
        calories: 350,
        protein: 30,
        carbs: 45,
        fat: 8,
        ingredients: [
          '1 scoop whey protein',
          '1 banana',
          '1 cup oat milk',
          '1 tbsp honey',
          'Ice cubes'
        ],
        imageUrl: 'assets/meals/shake.png',
        prepTime: '5 min',
        cookTime: '0 min',
        instructions: [
          'Add all ingredients to blender',
          'Blend until smooth',
          'Drink 30-45 minutes before workout'
        ],
      ),
      Meal(
        id: 'meal_5',
        name: 'Post-Workout Recovery',
        mealType: 'Snack',
        calories: 400,
        protein: 40,
        carbs: 50,
        fat: 5,
        ingredients: [
          '1.5 scoops whey protein',
          '1 cup rice cakes',
          '1 tbsp honey',
          'Greek yogurt',
          'Berries'
        ],
        imageUrl: 'assets/meals/recovery.png',
        prepTime: '5 min',
        cookTime: '0 min',
        instructions: [
          'Mix protein with water',
          'Top rice cakes with Greek yogurt',
          'Add honey and berries',
          'Consume within 30 minutes of workout'
        ],
      ),
    ];
  }

  // ========================================
  // PROGRESS DATA
  // ========================================

  /// Get sample progress history for charts
  /// 
  /// Returns 5 progress entries spanning 60 days.
  /// Shows realistic weight loss and measurement changes.
  /// Used for demo charts and graphs.
  static List<ProgressEntry> getProgressHistory() {
    final now = DateTime.now();
    return [
      // 60 days ago - Starting point
      ProgressEntry(
        date: now.subtract(const Duration(days: 60)),
        weight: 185,
        bodyFat: 18,
        measurements: {
          'chest': 42,
          'waist': 34,
          'arms': 15,
          'thighs': 24,
        },
        notes: 'Starting my transformation journey!',
      ),
      // 45 days ago - First milestone
      ProgressEntry(
        date: now.subtract(const Duration(days: 45)),
        weight: 182,
        bodyFat: 17,
        measurements: {
          'chest': 42.5,
          'waist': 33.5,
          'arms': 15.2,
          'thighs': 24.2,
        },
        notes: 'Feeling stronger, diet is on point.',
      ),
      // 30 days ago - Halfway point
      ProgressEntry(
        date: now.subtract(const Duration(days: 30)),
        weight: 180,
        bodyFat: 16,
        measurements: {
          'chest': 43,
          'waist': 33,
          'arms': 15.5,
          'thighs': 24.5,
        },
        notes: 'Great progress! Abs starting to show.',
      ),
      // 14 days ago - Recent progress
      ProgressEntry(
        date: now.subtract(const Duration(days: 14)),
        weight: 178,
        bodyFat: 15,
        measurements: {
          'chest': 43.5,
          'waist': 32.5,
          'arms': 15.8,
          'thighs': 25,
        },
        notes: 'Hit new PR on bench press!',
      ),
      // Current
      ProgressEntry(
        date: now,
        weight: 176,
        bodyFat: 14,
        measurements: {
          'chest': 44,
          'waist': 32,
          'arms': 16,
          'thighs': 25.5,
        },
        notes: 'Feeling amazing! Best shape of my life.',
      ),
    ];
  }

  // ========================================
  // USER PROFILE
  // ========================================

  /// Get sample user profile for demo
  /// 
  /// Returns a pre-populated user profile with:
  /// - Basic info (name, age, height, weight)
  /// - Fitness goals and experience level
  /// - Workout statistics
  /// - Achievement badges
  static UserProfile getUserProfile() {
    return UserProfile(
      name: 'Shahzad Sadruddin',
      age: 28,
      height: 180,  // cm
      weight: 176,  // lbs (current)
      targetWeight: 175,  // lbs (goal)
      fitnessGoal: 'Build Muscle',
      experienceLevel: 'Intermediate',
      workoutsCompleted: 48,
      totalMinutes: 2160,  // 36 hours
      totalCaloriesBurned: 18500,
      achievements: [
        'First Workout Complete',
        '7-Day Streak',
        '30 Workouts Milestone',
        '100 Hours Training',
        'Hit Goal Weight',
        'Consistency Champion',
      ],
    );
  }
}
