// ============================================================================
// IRON FORGE - Nutrition Service
// ============================================================================
// 
// File: nutrition_service.dart
// Description: Manages meal logging and nutritional tracking
// 
// Features:
// - Log meals with full macronutrient breakdown
// - Track daily calorie intake
// - Monitor protein, carbs, and fat consumption
// - Filter meals by meal type (breakfast, lunch, dinner, snack)
// - Calculate daily nutrition totals
// - Current body weight tracking for calorie calculations
// 
// Storage:
// - Uses SharedPreferences for web compatibility
// - Meals stored as JSON array under 'mealLogs' key
// - Current weight stored separately under 'currentWeight' key
// 
// Macros Tracked:
// - Calories (kcal)
// - Protein (grams)
// - Carbohydrates (grams)
// - Fat (grams)
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Data model for a logged meal
/// 
/// Contains complete nutritional information for a single meal entry.
/// All values are required to ensure complete tracking.
class MealLog {
  // ========================================
  // PROPERTIES
  // ========================================

  /// Unique identifier (timestamp-based)
  final String id;

  /// Name/description of the meal
  final String name;

  /// Total calories in kcal
  final int calories;

  /// Protein content in grams
  final double protein;

  /// Carbohydrate content in grams
  final double carbs;

  /// Fat content in grams
  final double fat;

  /// Type of meal: 'breakfast', 'lunch', 'dinner', 'snack'
  final String mealType;

  /// When the meal was logged
  final DateTime loggedAt;

  // ========================================
  // CONSTRUCTOR
  // ========================================

  /// Create a new meal log entry
  /// 
  /// All fields are required for complete nutritional tracking.
  MealLog({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
    required this.loggedAt,
  });

  // ========================================
  // SERIALIZATION
  // ========================================

  /// Convert meal to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'mealType': mealType,
    'loggedAt': loggedAt.toIso8601String(),
  };

  /// Create meal from JSON
  /// 
  /// Handles type conversions for numeric values.
  factory MealLog.fromJson(Map<String, dynamic> json) => MealLog(
    id: json['id'],
    name: json['name'],
    calories: json['calories'],
    protein: (json['protein'] as num).toDouble(),
    carbs: (json['carbs'] as num).toDouble(),
    fat: (json['fat'] as num).toDouble(),
    mealType: json['mealType'],
    loggedAt: DateTime.parse(json['loggedAt']),
  );
}

/// Nutrition tracking service singleton
/// 
/// Manages meal logging and provides nutritional analytics.
/// Tracks current body weight for calorie goal calculations.
class NutritionService {
  // ========================================
  // SINGLETON PATTERN
  // ========================================

  /// Single instance of the service
  static final NutritionService _instance = NutritionService._internal();

  /// Factory constructor returns singleton
  factory NutritionService() => _instance;

  /// Private internal constructor
  NutritionService._internal();

  // ========================================
  // STATE
  // ========================================

  /// List of all logged meals
  final List<MealLog> _mealLogs = [];

  /// User's current body weight (for calorie calculations)
  double _currentWeight = 50.0;

  /// Today's water intake (glasses)
  int _waterIntake = 0;

  /// Daily water intake goal (glasses)
  int _waterGoal = 8;

  /// Last date water was tracked (to reset daily)
  String _lastWaterDate = '';

  /// Get read-only list of meal logs
  List<MealLog> get mealLogs => List.unmodifiable(_mealLogs);

  /// Get current body weight
  double get currentWeight => _currentWeight;

  /// Get today's water intake
  int get waterIntake => _waterIntake;

  /// Get water intake goal
  int get waterGoal => _waterGoal;

  // ========================================
  // COMPUTED PROPERTIES
  // ========================================

  /// Get all meals logged today
  /// 
  /// Filters by current date (year, month, day).
  List<MealLog> get todaysMeals {
    final now = DateTime.now();
    return _mealLogs.where((meal) =>
      meal.loggedAt.year == now.year &&
      meal.loggedAt.month == now.month &&
      meal.loggedAt.day == now.day
    ).toList();
  }

  /// Get aggregated nutrition totals for today
  /// 
  /// Returns map with 'calories', 'protein', 'carbs', 'fat' keys.
  Map<String, dynamic> get todaysTotals {
    final meals = todaysMeals;
    return {
      'calories': meals.fold<int>(0, (sum, m) => sum + m.calories),
      'protein': meals.fold<double>(0, (sum, m) => sum + m.protein),
      'carbs': meals.fold<double>(0, (sum, m) => sum + m.carbs),
      'fat': meals.fold<double>(0, (sum, m) => sum + m.fat),
    };
  }

  // ========================================
  // INITIALIZATION
  // ========================================

  /// Initialize service and load data from storage
  /// 
  /// Loads both meal logs and current weight.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved meals
      final mealsJson = prefs.getString('mealLogs');
      if (mealsJson != null) {
        final List<dynamic> mealsList = json.decode(mealsJson);
        _mealLogs.clear();
        _mealLogs.addAll(mealsList.map((m) => MealLog.fromJson(m)));
      }

      // Load saved weight (default 50kg if not set)
      _currentWeight = prefs.getDouble('currentWeight') ?? 50.0;

      // Load water intake
      _waterGoal = prefs.getInt('waterGoal') ?? 8;
      _lastWaterDate = prefs.getString('lastWaterDate') ?? '';
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Reset water intake if it's a new day
      if (_lastWaterDate == today) {
        _waterIntake = prefs.getInt('waterIntake') ?? 0;
      } else {
        _waterIntake = 0;
        _lastWaterDate = today;
        await _saveWaterIntake();
      }
    } catch (e) {
      // Silently handle load errors
    }
  }

  // ========================================
  // PERSISTENCE
  // ========================================

  /// Save meals to SharedPreferences
  Future<void> _saveMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = json.encode(_mealLogs.map((m) => m.toJson()).toList());
      await prefs.setString('mealLogs', mealsJson);
    } catch (e) {
      // Silently handle save errors
    }
  }

  /// Save current weight to SharedPreferences
  Future<void> _saveWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('currentWeight', _currentWeight);
    } catch (e) {
      // Silently handle save errors
    }
  }

  // ========================================
  // MEAL OPERATIONS
  // ========================================

  /// Add a new meal entry
  /// 
  /// Creates a MealLog with auto-generated ID and current timestamp.
  /// Default mealType is 'snack' if not specified.
  Future<void> addMeal({
    required String name,
    required int calories,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
    String mealType = 'snack',
  }) async {
    final meal = MealLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      mealType: mealType,
      loggedAt: DateTime.now(),
    );
    _mealLogs.add(meal);
    await _saveMeals();
  }

  /// Remove a meal by ID
  ///
  /// Removes the meal from both in-memory list and persistent storage.
  /// Does nothing if meal with given ID doesn't exist.
  ///
  /// [id] - The unique identifier of the meal to remove
  Future<void> removeMeal(String id) async {
    _mealLogs.removeWhere((m) => m.id == id);
    await _saveMeals();
  }

  // ========================================
  // WEIGHT OPERATIONS
  // ========================================

  /// Increase weight by 1 unit (kg)
  ///
  /// Used by increment buttons in the nutrition UI.
  /// Weight is used for calorie goal calculations.
  Future<void> incrementWeight() async {
    _currentWeight += 1;
    await _saveWeight();
  }

  /// Decrease weight by 1 unit (kg)
  ///
  /// Prevents going below 1 kg for safety.
  /// Weight is used for calorie goal calculations.
  Future<void> decrementWeight() async {
    if (_currentWeight > 1) {
      _currentWeight -= 1;
      await _saveWeight();
    }
  }

  /// Set weight to a specific value
  ///
  /// Used when user enters weight directly in the input field.
  /// No validation is performed - caller should validate.
  ///
  /// [weight] - The new weight value in kg
  Future<void> setWeight(double weight) async {
    _currentWeight = weight;
    await _saveWeight();
  }

  // ========================================
  // WATER INTAKE OPERATIONS
  // ========================================

  /// Save water intake to SharedPreferences
  Future<void> _saveWaterIntake() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('waterIntake', _waterIntake);
      await prefs.setInt('waterGoal', _waterGoal);
      await prefs.setString('lastWaterDate', _lastWaterDate);
    } catch (e) {
      // Silently handle save errors
    }
  }

  /// Add a glass of water
  Future<void> addWater() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Reset if new day
    if (_lastWaterDate != today) {
      _waterIntake = 0;
      _lastWaterDate = today;
    }
    
    _waterIntake++;
    await _saveWaterIntake();
  }

  /// Remove a glass of water
  Future<void> removeWater() async {
    if (_waterIntake > 0) {
      _waterIntake--;
      await _saveWaterIntake();
    }
  }

  /// Set water intake to a specific value
  Future<void> setWaterIntake(int glasses) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    _lastWaterDate = today;
    _waterIntake = glasses.clamp(0, 20);
    await _saveWaterIntake();
  }

  /// Set daily water goal
  Future<void> setWaterGoal(int glasses) async {
    _waterGoal = glasses.clamp(1, 20);
    await _saveWaterIntake();
  }
}
