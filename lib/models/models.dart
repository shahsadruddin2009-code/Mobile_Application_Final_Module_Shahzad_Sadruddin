// ============================================================================
// IRON FORGE - Data Models
// ============================================================================
// 
// File: models.dart
// Description: Core data models used throughout the application
// 
// This file defines the data structures for:
// - Exercise: Individual exercise information
// - Workout: Collection of exercises forming a workout routine
// - WorkoutLog: Record of completed workout sessions
// - UserProfile: User account and statistics
// - Meal & MealPlan: Nutrition tracking models
// - ProgressEntry: Weight and body measurement tracking
// 
// All models are immutable (using final fields) for data integrity.
// ============================================================================

// =============================================================================
// EXERCISE MODEL
// =============================================================================

// Represents a single exercise with all its details
// 
// Used in the exercise library and as part of workout routines.
// Contains information for proper exercise execution and tracking.
class Exercise {
  /// Unique identifier for the exercise
  final String id;
  
  /// Display name of the exercise (e.g., "Bench Press")
  final String name;
  
  /// Primary muscle group targeted (e.g., "Chest", "Back", "Legs")
  final String muscleGroup;
  
  /// Detailed description of how to perform the exercise
  final String description;
  
  /// URL or asset path to exercise demonstration image
  final String imageUrl;
  
  /// Recommended number of sets
  final int sets;
  
  /// Recommended repetitions per set
  final int reps;
  
  /// Rest period between sets (e.g., "60 seconds")
  final String restTime;
  
  /// Difficulty level: "Beginner", "Intermediate", "Advanced"
  final String difficulty;
  
  /// List of form tips for proper execution
  final List<String> tips;
  
  /// Required equipment (e.g., "Barbell", "Dumbbells", "None")
  final String equipment;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.description,
    required this.imageUrl,
    required this.sets,
    required this.reps,
    required this.restTime,
    required this.difficulty,
    required this.tips,
    required this.equipment,
  });
}

// =============================================================================
// WORKOUT MODELS
// =============================================================================

/// Represents a complete workout routine
/// 
/// A workout consists of multiple exercises performed in sequence,
/// targeting specific muscle groups with defined duration and intensity.
class Workout {
  /// Unique identifier for the workout
  final String id;
  
  /// Display name (e.g., "Push Day", "Full Body Blast")
  final String name;
  
  /// Brief overview of the workout
  final String description;
  
  /// Primary muscle group focus
  final String muscleGroup;
  
  /// Estimated duration (e.g., "45 min")
  final String duration;
  
  /// Difficulty level: "Beginner", "Intermediate", "Advanced"
  final String difficulty;
  
  /// Estimated calories burned during workout
  final int caloriesBurned;
  
  /// Ordered list of exercises in this workout
  final List<Exercise> exercises;
  
  /// Workout cover/thumbnail image
  final String imageUrl;
  
  /// All muscle groups worked in this workout
  final List<String> targetMuscles;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.duration,
    required this.difficulty,
    required this.caloriesBurned,
    required this.exercises,
    required this.imageUrl,
    required this.targetMuscles,
  });
}

/// Record of a completed workout session
/// 
/// Stores all details about a workout that was performed,
/// including timing, exercises completed, and user notes.
class WorkoutLog {
  /// Unique identifier for this log entry
  final String id;
  
  /// Date and time workout was performed
  final DateTime date;
  
  /// Reference to the workout template used
  final Workout workout;
  
  /// Actual duration in minutes
  final int duration;
  
  /// Calories burned (may differ from estimate)
  final int caloriesBurned;
  
  /// Detailed log of each exercise performed
  final List<ExerciseLog> exerciseLogs;
  
  /// User notes about the session
  final String notes;

  WorkoutLog({
    required this.id,
    required this.date,
    required this.workout,
    required this.duration,
    required this.caloriesBurned,
    required this.exerciseLogs,
    required this.notes,
  });
}

/// Log of a single exercise within a workout session
/// 
/// Tracks all sets performed for one exercise during a workout.
class ExerciseLog {
  /// The exercise that was performed
  final Exercise exercise;
  
  /// List of all sets completed
  final List<SetLog> sets;

  ExerciseLog({
    required this.exercise,
    required this.sets,
  });
}

/// Individual set performance data
/// 
/// Records the details of a single set within an exercise.
class SetLog {
  /// Set number within the exercise (1, 2, 3, etc.)
  final int setNumber;
  
  /// Number of repetitions completed
  final int reps;
  
  /// Weight used in kg or lbs (based on user preference)
  final double weight;
  
  /// Whether the set was completed successfully
  final bool completed;

  SetLog({
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.completed,
  });
}

// =============================================================================
// USER PROFILE MODEL
// =============================================================================

/// User account information and fitness statistics
/// 
/// Stores user preferences, goals, and accumulated workout statistics.
class UserProfile {
  /// User's display name
  final String name;
  
  /// User's age in years
  final int age;
  
  /// Height in cm or inches (based on preference)
  final double height;
  
  /// Current weight in kg or lbs
  final double weight;
  
  /// Goal weight for tracking progress
  final double targetWeight;
  
  /// Primary fitness goal (e.g., "Build Muscle", "Lose Weight")
  final String fitnessGoal;
  
  /// Experience level: "Beginner", "Intermediate", "Advanced"
  final String experienceLevel;
  
  /// Total number of workouts completed
  final int workoutsCompleted;
  
  /// Total workout time in minutes
  final int totalMinutes;
  
  /// Cumulative calories burned across all workouts
  final int totalCaloriesBurned;
  
  /// List of earned achievement badges
  final List<String> achievements;

  UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.targetWeight,
    required this.fitnessGoal,
    required this.experienceLevel,
    required this.workoutsCompleted,
    required this.totalMinutes,
    required this.totalCaloriesBurned,
    required this.achievements,
  });
}

// =============================================================================
// NUTRITION MODELS
// =============================================================================

/// Individual meal with nutritional information
/// 
/// Contains all details needed for meal planning and nutrition tracking.
class Meal {
  /// Unique identifier for the meal
  final String id;
  
  /// Meal name (e.g., "Grilled Chicken Salad")
  final String name;
  
  /// Type of meal: "Breakfast", "Lunch", "Dinner", "Snack"
  final String mealType;
  
  /// Total calories in the meal
  final int calories;
  
  /// Protein content in grams
  final double protein;
  
  /// Carbohydrate content in grams
  final double carbs;
  
  /// Fat content in grams
  final double fat;
  
  /// List of ingredients needed
  final List<String> ingredients;
  
  /// Meal photo or illustration
  final String imageUrl;
  
  /// Preparation time (e.g., "10 min")
  final String prepTime;
  
  /// Cooking time (e.g., "20 min")
  final String cookTime;
  
  /// Step-by-step cooking instructions
  final List<String> instructions;

  Meal({
    required this.id,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.imageUrl,
    required this.prepTime,
    required this.cookTime,
    required this.instructions,
  });
}

/// Daily meal plan with aggregated nutrition
/// 
/// Groups multiple meals together for a complete day's nutrition plan.
class MealPlan {
  /// Unique identifier for the meal plan
  final String id;
  
  /// Plan name (e.g., "High Protein Day")
  final String name;
  
  /// Description of the meal plan's purpose
  final String description;
  
  /// Sum of calories from all meals
  final int totalCalories;
  
  /// Sum of protein from all meals (grams)
  final double totalProtein;
  
  /// Sum of carbs from all meals (grams)
  final double totalCarbs;
  
  /// Sum of fat from all meals (grams)
  final double totalFat;
  
  /// All meals included in this plan
  final List<Meal> meals;

  MealPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.meals,
  });
}

// =============================================================================
// PROGRESS TRACKING MODEL
// =============================================================================

/// Progress entry for weight and body measurement tracking
/// 
/// Records a snapshot of the user's physical measurements at a point in time.
/// Used to track changes and visualize progress over time.
/// 
/// Note: This is the legacy model used by DataService.
/// See ProgressService for the newer persistence-enabled model.
class ProgressEntry {
  /// Date the measurements were taken
  final DateTime date;
  
  /// Body weight in kg or lbs
  final double weight;
  
  /// Body fat percentage
  final double bodyFat;
  
  /// Body measurements (chest, waist, arms, etc.) in inches/cm
  /// Keys: "chest", "waist", "arms", "thighs", etc.
  final Map<String, double> measurements;
  
  /// User notes about this entry
  final String notes;
  
  /// Optional progress photo URL
  final String? photoUrl;

  ProgressEntry({
    required this.date,
    required this.weight,
    required this.bodyFat,
    required this.measurements,
    required this.notes,
    this.photoUrl,
  });
}
