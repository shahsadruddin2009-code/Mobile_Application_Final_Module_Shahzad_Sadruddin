// ============================================================================
// MUSCLE POWER - Data Service Unit Tests
// ============================================================================
//
// Tests for DataService static data providers.
// Verifies data integrity, completeness, and structure.
// ============================================================================

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/data/data_service.dart';
import 'package:bodybuilding_app/models/models.dart';

void main() {
  // ========================================
  // EXERCISES DATA TESTS
  // ========================================

  group('DataService.getExercises()', () {
    late List<Exercise> exercises;

    setUp(() {
      exercises = DataService.getExercises();
    });

    test('returns non-empty exercise list', () {
      expect(exercises, isNotEmpty);
      expect(exercises.length, greaterThanOrEqualTo(20));
    });

    test('each exercise has unique ID', () {
      final ids = exercises.map((e) => e.id).toSet();
      expect(ids.length, exercises.length);
    });

    test('each exercise has required fields populated', () {
      for (final ex in exercises) {
        expect(ex.id, isNotEmpty, reason: '${ex.name} missing id');
        expect(ex.name, isNotEmpty, reason: '${ex.id} missing name');
        expect(ex.muscleGroup, isNotEmpty, reason: '${ex.name} missing muscleGroup');
        expect(ex.description, isNotEmpty, reason: '${ex.name} missing description');
        expect(ex.sets, greaterThan(0), reason: '${ex.name} has 0 sets');
        expect(ex.reps, greaterThan(0), reason: '${ex.name} has 0 reps');
        expect(ex.restTime, isNotEmpty, reason: '${ex.name} missing restTime');
        expect(ex.equipment, isNotEmpty, reason: '${ex.name} missing equipment');
      }
    });

    test('difficulty values are valid', () {
      final validDifficulties = {'Beginner', 'Intermediate', 'Advanced'};
      for (final ex in exercises) {
        expect(validDifficulties, contains(ex.difficulty),
            reason: '${ex.name} has invalid difficulty: ${ex.difficulty}');
      }
    });

    test('covers all major muscle groups', () {
      final muscleGroups = exercises.map((e) => e.muscleGroup).toSet();
      expect(muscleGroups, contains('Chest'));
      expect(muscleGroups, contains('Back'));
      expect(muscleGroups, contains('Legs'));
      expect(muscleGroups, contains('Shoulders'));
    });

    test('tips are lists (even if empty)', () {
      for (final ex in exercises) {
        expect(ex.tips, isA<List<String>>(),
            reason: '${ex.name} tips is not a list');
      }
    });
  });

  // ========================================
  // WORKOUTS DATA TESTS
  // ========================================

  group('DataService.getWorkouts()', () {
    late List<Workout> workouts;

    setUp(() {
      workouts = DataService.getWorkouts();
    });

    test('returns non-empty workout list', () {
      expect(workouts, isNotEmpty);
    });

    test('each workout has unique ID', () {
      final ids = workouts.map((w) => w.id).toSet();
      expect(ids.length, workouts.length);
    });

    test('each workout has exercises', () {
      for (final w in workouts) {
        expect(w.exercises, isNotEmpty,
            reason: '${w.name} has no exercises');
      }
    });

    test('each workout has valid fields', () {
      for (final w in workouts) {
        expect(w.name, isNotEmpty);
        expect(w.duration, isNotEmpty);
        expect(w.caloriesBurned, greaterThan(0));
        expect(w.difficulty, isNotEmpty);
        expect(w.targetMuscles, isNotEmpty);
      }
    });

    test('workout exercises are valid Exercise objects', () {
      for (final w in workouts) {
        for (final ex in w.exercises) {
          expect(ex.id, isNotEmpty);
          expect(ex.name, isNotEmpty);
        }
      }
    });
  });

  // ========================================
  // MEALS DATA TESTS
  // ========================================

  group('DataService.getMeals()', () {
    late List<Meal> meals;

    setUp(() {
      meals = DataService.getMeals();
    });

    test('returns non-empty meal list', () {
      expect(meals, isNotEmpty);
    });

    test('each meal has unique ID', () {
      final ids = meals.map((m) => m.id).toSet();
      expect(ids.length, meals.length);
    });

    test('each meal has valid nutritional data', () {
      for (final m in meals) {
        expect(m.name, isNotEmpty, reason: '${m.id} missing name');
        expect(m.calories, greaterThan(0), reason: '${m.name} has 0 calories');
        expect(m.protein, greaterThanOrEqualTo(0));
        expect(m.carbs, greaterThanOrEqualTo(0));
        expect(m.fat, greaterThanOrEqualTo(0));
      }
    });

    test('meal types are valid', () {
      final validTypes = {'Breakfast', 'Lunch', 'Dinner', 'Snack'};
      for (final m in meals) {
        expect(validTypes, contains(m.mealType),
            reason: '${m.name} has invalid mealType: ${m.mealType}');
      }
    });

    test('each meal has ingredients', () {
      for (final m in meals) {
        expect(m.ingredients, isNotEmpty,
            reason: '${m.name} has no ingredients');
      }
    });

    test('each meal has instructions', () {
      for (final m in meals) {
        expect(m.instructions, isNotEmpty,
            reason: '${m.name} has no instructions');
      }
    });
  });

  // ========================================
  // PROGRESS HISTORY DATA TESTS
  // ========================================

  group('DataService.getProgressHistory()', () {
    late List<ProgressEntry> history;

    setUp(() {
      history = DataService.getProgressHistory();
    });

    test('returns non-empty history', () {
      expect(history, isNotEmpty);
    });

    test('entries have valid weights', () {
      for (final entry in history) {
        expect(entry.weight, greaterThan(0));
      }
    });

    test('entries have valid body fat percentages', () {
      for (final entry in history) {
        expect(entry.bodyFat, greaterThan(0));
        expect(entry.bodyFat, lessThan(100));
      }
    });

    test('entries are in chronological order', () {
      for (int i = 1; i < history.length; i++) {
        expect(history[i].date.isAfter(history[i - 1].date) ||
               history[i].date.isAtSameMomentAs(history[i - 1].date),
            isTrue,
            reason: 'Entries not in chronological order at index $i');
      }
    });
  });

  // ========================================
  // USER PROFILE DATA TESTS
  // ========================================

  group('DataService.getUserProfile()', () {
    late UserProfile profile;

    setUp(() {
      profile = DataService.getUserProfile();
    });

    test('returns valid profile', () {
      expect(profile.name, isNotEmpty);
      expect(profile.age, greaterThan(0));
      expect(profile.height, greaterThan(0));
      expect(profile.weight, greaterThan(0));
    });

    test('profile has fitness goal', () {
      expect(profile.fitnessGoal, isNotEmpty);
    });

    test('profile has valid experience level', () {
      final validLevels = {'Beginner', 'Intermediate', 'Advanced'};
      expect(validLevels, contains(profile.experienceLevel));
    });

    test('profile stats are non-negative', () {
      expect(profile.workoutsCompleted, greaterThanOrEqualTo(0));
      expect(profile.totalMinutes, greaterThanOrEqualTo(0));
      expect(profile.totalCaloriesBurned, greaterThanOrEqualTo(0));
    });

    test('profile has achievements list', () {
      expect(profile.achievements, isA<List<String>>());
    });
  });

  // ========================================
  // DATABASE SERVICE - SQL INJECTION PROTECTION TESTS
  // ========================================
  //
  // These tests verify that DatabaseService uses parameterized queries
  // (whereArgs / ? placeholders) to prevent SQL injection attacks.
  // sqflite's parameterized query API separates SQL commands from user
  // data, making it impossible for malicious input to alter query logic.
  // ========================================

  group('DatabaseService - SQL Injection Protection', () {
    late String sourceCode;

    setUp(() {
      final file = File('lib/services/database_service.dart');
      sourceCode = file.readAsStringSync();
    });

    test('loginUser uses parameterized query for email and password', () {
      // SQL injection in login is critical — an attacker could bypass auth
      // with input like: ' OR '1'='1
      // Parameterized queries ensure this input is treated as literal data.
      expect(sourceCode, contains("where: 'email = ? AND password = ?'"));
      expect(sourceCode, contains('whereArgs: [email.toLowerCase(), password]'));
    });

    test('getUserById uses parameterized query', () {
      // Prevents injection via user ID parameter
      expect(sourceCode, contains("where: 'id = ?'"));
      expect(sourceCode, contains('whereArgs: [userId]'));
    });

    test('getUserByEmail uses parameterized query', () {
      // Prevents injection via email lookup
      expect(sourceCode, contains("where: 'email = ?'"));
      expect(sourceCode, contains('whereArgs: [email.toLowerCase()]'));
    });

    test('updateUser uses parameterized query', () {
      // Prevents injection via profile update operations
      final updatePattern = RegExp(r"db\.update\(\s*'users'[\s\S]*?whereArgs:\s*\[userId\]");
      expect(updatePattern.hasMatch(sourceCode), isTrue,
          reason: 'updateUser should use whereArgs with userId');
    });

    test('getWorkoutLogs uses parameterized query', () {
      // Prevents injection via workout history retrieval
      final workoutQueryPattern = RegExp(
        r"db\.query\(\s*'workout_logs'[\s\S]*?whereArgs:\s*\[userId\]"
      );
      expect(workoutQueryPattern.hasMatch(sourceCode), isTrue,
          reason: 'getWorkoutLogs should use whereArgs with userId');
    });

    test('getProgressEntries uses parameterized query', () {
      // Prevents injection via progress data retrieval
      final progressPattern = RegExp(
        r"db\.query\(\s*'progress_entries'[\s\S]*?whereArgs:\s*\[userId\]"
      );
      expect(progressPattern.hasMatch(sourceCode), isTrue,
          reason: 'getProgressEntries should use whereArgs with userId');
    });

    test('getMealLogs uses parameterized query', () {
      // Prevents injection via meal log retrieval
      final mealPattern = RegExp(
        r"db\.query\(\s*'meal_logs'[\s\S]*?whereArgs:\s*\[userId\]"
      );
      expect(mealPattern.hasMatch(sourceCode), isTrue,
          reason: 'getMealLogs should use whereArgs with userId');
    });

    test('getTodayNutrition rawQuery uses positional parameters', () {
      // rawQuery is higher risk — verify it uses ? placeholders with args list
      // Pattern: rawQuery('...WHERE userId = ? AND date LIKE ?', [userId, ...])
      expect(sourceCode, contains('WHERE userId = ? AND date LIKE ?'));
      final rawQueryWithArgs = RegExp(
        r'rawQuery\([\s\S]*?userId = \?[\s\S]*?\[userId'
      );
      expect(rawQueryWithArgs.hasMatch(sourceCode), isTrue,
          reason: 'getTodayNutrition should pass userId as a positional parameter');
    });

    test('getUserStats rawQueries use positional parameters', () {
      // All aggregate stat queries should use ? placeholders
      // Matches: rawQuery('SELECT ... WHERE userId = ?', [userId])
      final statsRawQueries = RegExp(
        r"rawQuery\(\s*'SELECT[^']*WHERE userId = \?'[\s,]*\[userId\]"
      );
      final matches = statsRawQueries.allMatches(sourceCode);
      expect(matches.length, greaterThanOrEqualTo(3),
          reason: 'getUserStats should have at least 3 parameterized rawQuery calls');
    });

    test('no string interpolation in SQL WHERE clauses', () {
      // SQL injection occurs when user input is interpolated directly into SQL.
      // Patterns like "WHERE email = '$email'" are vulnerable.
      // Only $today (derived from DateTime.now(), not user input) is safe.
      final lines = sourceCode.split('\n');
      for (final line in lines) {
        if (line.contains('where:') || line.toUpperCase().contains('WHERE')) {
          // Allow $today since it's derived from DateTime.now(), not user input
          final cleanedLine = line.replaceAll('\$today', '');
          expect(cleanedLine.contains(RegExp(r'\$[a-zA-Z]')), isFalse,
              reason: 'Found string interpolation in SQL clause: $line');
        }
      }
    });

    test('no user input interpolated in SQL query strings', () {
      // Verify that SQL query methods (db.query, db.rawQuery) never
      // embed user-supplied variables directly via string interpolation.
      // Column names like 'email' in DDL (CREATE TABLE) are safe schema
      // definitions — only runtime query strings must be parameterized.
      final queryLines = sourceCode.split('\n').where((line) =>
          line.contains('db.query(') ||
          line.contains('db.rawQuery(') ||
          line.contains('db.update(') ||
          line.contains('db.delete('));
      for (final line in queryLines) {
        final cleanedLine = line.replaceAll('\$today', '');
        expect(cleanedLine.contains(RegExp(r'\$[a-zA-Z]')), isFalse,
            reason: 'Found interpolation in query call: $line');
      }
    });

    test('invalid user input is not used in SQL strings', () {
      // Check for common SQL injection patterns in the source code
      final injectionPatterns = [
        r"' OR '1'='1",
        r"' OR '1'='1' --",
        r"' OR '1'='1' #",
        r"' OR '1'='1'/*",
        r"' OR 'x'='x",
        r"' OR 1=1--",
        r"' OR 1=1#",
        r"' OR 1=1/*",
      ];
      for (final pattern in injectionPatterns) {
        expect(sourceCode, isNot(contains(pattern)),
            reason: 'Source code should not contain SQL injection pattern: $pattern');
      }
    });
    test('Password missing special characters is not used in SQL strings', () {
      // Ensure no raw SQL strings contain 'ValidPassword123' directly, which would indicate
      // potential interpolation. All password references should be via parameterized queries.
       const password = 'ValidPassword123';
      for (final pass in password.split('')) {
        if (!pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
          expect(sourceCode, isNot(contains("'$pass'")),
              reason: 'Raw SQL should not contain any special character-free password directly');
        }
      }
      expect(sourceCode, isNot(contains("'ValidPassword123'")),
          reason: 'Raw SQL should not contain ValidPassword123 directly');
    });
    test('all CRUD operations use sqflite safe API methods', () {
      // sqflite's db.query(), db.insert(), db.update() with whereArgs
      // are inherently safe from SQL injection. Verify these are used
      // instead of manual SQL string building with db.execute().
      expect(sourceCode, contains('db.query('));
      expect(sourceCode, contains('db.insert('));
      expect(sourceCode, contains('db.update('));

      // Verify whereArgs is used consistently across the service
      final whereArgsCount = 'whereArgs:'.allMatches(sourceCode).length;
      expect(whereArgsCount, greaterThanOrEqualTo(8),
          reason: 'Expected at least 8 uses of whereArgs for parameterized queries');
    });

    test('user settings operations use parameterized queries', () {
      // Settings queries should also be protected
      final settingsQueryPattern = RegExp(
        r"db\.query\(\s*'user_settings'[\s\S]*?whereArgs:\s*\[userId\]"
      );
      expect(settingsQueryPattern.hasMatch(sourceCode), isTrue,
          reason: 'getUserSettings should use whereArgs');

      final settingsUpdatePattern = RegExp(
        r"db\.update\(\s*'user_settings'[\s\S]*?whereArgs:\s*\[userId\]"
      );
      expect(settingsUpdatePattern.hasMatch(sourceCode), isTrue,
          reason: 'updateUserSettings should use whereArgs');
    });
  });
}
