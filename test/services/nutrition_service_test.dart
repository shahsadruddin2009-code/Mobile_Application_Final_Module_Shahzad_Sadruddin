// ============================================================================
// MUSCLE POWER - Nutrition Service Unit Tests
// ============================================================================
//
// Tests for NutritionService and MealLog model.
// Uses SharedPreferences mock for test isolation.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodybuilding_app/services/nutrition_service.dart';

void main() {
  // ========================================
  // MEAL LOG MODEL TESTS
  // ========================================

  group('MealLog Model', () {
    test('creates meal log with all fields', () {
      final log = MealLog(
        id: '1001',
        name: 'Chicken Salad',
        calories: 450,
        protein: 42.0,
        carbs: 20.0,
        fat: 18.0,
        mealType: 'lunch',
        loggedAt: DateTime(2025, 6, 15, 12, 30),
      );

      expect(log.id, '1001');
      expect(log.name, 'Chicken Salad');
      expect(log.calories, 450);
      expect(log.protein, 42.0);
      expect(log.carbs, 20.0);
      expect(log.fat, 18.0);
      expect(log.mealType, 'lunch');
    });

    test('toJson produces valid map', () {
      final log = MealLog(
        id: '1001',
        name: 'Oatmeal',
        calories: 350,
        protein: 12.0,
        carbs: 55.0,
        fat: 8.0,
        mealType: 'breakfast',
        loggedAt: DateTime(2025, 6, 15, 8, 0),
      );

      final json = log.toJson();
      expect(json['id'], '1001');
      expect(json['name'], 'Oatmeal');
      expect(json['calories'], 350);
      expect(json['protein'], 12.0);
      expect(json['mealType'], 'breakfast');
    });

    test('fromJson reconstructs correctly', () {
      final json = {
        'id': '1001',
        'name': 'Steak',
        'calories': 600,
        'protein': 50.0,
        'carbs': 0.0,
        'fat': 35.0,
        'mealType': 'dinner',
        'loggedAt': '2025-06-15T19:00:00.000',
      };

      final log = MealLog.fromJson(json);
      expect(log.id, '1001');
      expect(log.name, 'Steak');
      expect(log.calories, 600);
      expect(log.protein, 50.0);
      expect(log.fat, 35.0);
    });

    test('fromJson handles integer protein as double', () {
      final json = {
        'id': '1',
        'name': 'Test',
        'calories': 100,
        'protein': 10, // int instead of double
        'carbs': 20,
        'fat': 5,
        'mealType': 'snack',
        'loggedAt': '2025-06-15T10:00:00.000',
      };

      final log = MealLog.fromJson(json);
      expect(log.protein, 10.0);
      expect(log.protein, isA<double>());
    });

    test('toJson → fromJson round-trip', () {
      final original = MealLog(
        id: '1001',
        name: 'Protein Shake',
        calories: 250,
        protein: 30.0,
        carbs: 15.0,
        fat: 5.0,
        mealType: 'snack',
        loggedAt: DateTime(2025, 6, 15, 16, 0),
      );

      final restored = MealLog.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.calories, original.calories);
      expect(restored.protein, original.protein);
      expect(restored.carbs, original.carbs);
      expect(restored.fat, original.fat);
      expect(restored.mealType, original.mealType);
    });
  });

  // ========================================
  // NUTRITION SERVICE TESTS
  // ========================================

  group('NutritionService', () {
    late NutritionService service;

    setUp(() async {
      // Provide empty mealLogs so init() clears the singleton's internal list
      SharedPreferences.setMockInitialValues({'mealLogs': '[]'});
      service = NutritionService();
      await service.init();
    });

    test('initializes with default values', () {
      expect(service.mealLogs, isEmpty);
      expect(service.currentWeight, 50.0);
      expect(service.waterIntake, 0);
      expect(service.waterGoal, 8);
    });

    test('addMeal adds meal to list', () async {
      await service.addMeal(
        name: 'Chicken Breast',
        calories: 300,
        protein: 45.0,
        carbs: 0.0,
        fat: 8.0,
        mealType: 'lunch',
      );

      expect(service.mealLogs, hasLength(1));
      expect(service.mealLogs.first.name, 'Chicken Breast');
      expect(service.mealLogs.first.calories, 300);
    });

    test('addMeal uses snack as default mealType', () async {
      await service.addMeal(
        name: 'Apple',
        calories: 95,
      );

      expect(service.mealLogs.first.mealType, 'snack');
    });

    test('addMeal defaults macros to zero', () async {
      await service.addMeal(
        name: 'Water',
        calories: 0,
      );

      expect(service.mealLogs.first.protein, 0.0);
      expect(service.mealLogs.first.carbs, 0.0);
      expect(service.mealLogs.first.fat, 0.0);
    });

    test('removeMeal removes by ID', () async {
      await service.addMeal(name: 'Meal A', calories: 100);
      // Small delay to ensure unique timestamp-based IDs
      await Future.delayed(const Duration(milliseconds: 10));
      await service.addMeal(name: 'Meal B', calories: 200);

      expect(service.mealLogs, hasLength(2));

      final idToRemove = service.mealLogs.first.id;
      await service.removeMeal(idToRemove);

      expect(service.mealLogs, hasLength(1));
      expect(service.mealLogs.first.name, 'Meal B');
    });

    test('removeMeal does nothing for unknown ID', () async {
      await service.addMeal(name: 'Test', calories: 100);

      await service.removeMeal('nonexistent_id');
      expect(service.mealLogs, hasLength(1));
    });

    test('todaysTotals aggregates correctly', () async {
      await service.addMeal(
        name: 'Breakfast',
        calories: 400,
        protein: 20.0,
        carbs: 50.0,
        fat: 10.0,
        mealType: 'breakfast',
      );
      await service.addMeal(
        name: 'Lunch',
        calories: 600,
        protein: 45.0,
        carbs: 40.0,
        fat: 20.0,
        mealType: 'lunch',
      );

      final totals = service.todaysTotals;
      expect(totals['calories'], 1000);
      expect(totals['protein'], 65.0);
      expect(totals['carbs'], 90.0);
      expect(totals['fat'], 30.0);
    });

    test('todaysTotals returns zeros when no meals', () async {
      final totals = service.todaysTotals;
      expect(totals['calories'], 0);
      expect(totals['protein'], 0.0);
      expect(totals['carbs'], 0.0);
      expect(totals['fat'], 0.0);
    });

    // ========================================
    // WEIGHT OPERATIONS
    // ========================================

    test('incrementWeight adds 1kg', () async {
      final before = service.currentWeight;
      await service.incrementWeight();
      expect(service.currentWeight, before + 1);
    });

    test('decrementWeight subtracts 1kg', () async {
      await service.setWeight(80.0);
      await service.decrementWeight();
      expect(service.currentWeight, 79.0);
    });

    test('decrementWeight does not go below 1', () async {
      await service.setWeight(1.0);
      await service.decrementWeight();
      expect(service.currentWeight, 1.0);
    });

    test('setWeight updates to exact value', () async {
      await service.setWeight(92.5);
      expect(service.currentWeight, 92.5);
    });

    // ========================================
    // WATER INTAKE OPERATIONS
    // ========================================

    test('addWater increments count', () async {
      await service.addWater();
      expect(service.waterIntake, 1);
      await service.addWater();
      expect(service.waterIntake, 2);
    });

    test('removeWater decrements count', () async {
      await service.addWater();
      await service.addWater();
      await service.removeWater();
      expect(service.waterIntake, 1);
    });

    test('removeWater does not go below 0', () async {
      await service.removeWater();
      expect(service.waterIntake, 0);
    });

    test('setWaterIntake sets exact value', () async {
      await service.setWaterIntake(5);
      expect(service.waterIntake, 5);
    });

    test('setWaterIntake clamps to valid range', () async {
      await service.setWaterIntake(-3);
      expect(service.waterIntake, 0);

      await service.setWaterIntake(25);
      expect(service.waterIntake, 20);
    });

    test('setWaterGoal updates goal', () async {
      await service.setWaterGoal(10);
      expect(service.waterGoal, 10);
    });

    test('setWaterGoal clamps to valid range', () async {
      await service.setWaterGoal(0);
      expect(service.waterGoal, 1);

      await service.setWaterGoal(25);
      expect(service.waterGoal, 20);
    });
  });
}
