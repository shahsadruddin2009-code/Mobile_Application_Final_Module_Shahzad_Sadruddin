// ============================================================================
// IRON FORGE - Database Service
// ============================================================================
// 
// File: database_service.dart
// Description: SQLite database operations for persistent data storage
// 
// Features:
// - User account management (CRUD operations)
// - Workout logging and history tracking
// - Progress entry storage (weight, measurements)
// - Meal/nutrition logging
// - User settings and preferences
// - Aggregate statistics calculation
// 
// Platform Notes:
// - SQLite works on mobile (iOS/Android) and desktop
// - Does NOT work on web - use SharedPreferences-based services for web
// - Database file: 'ironforge.db' in app documents directory
// 
// Tables:
// - users: User accounts with profile information
// - workout_logs: Completed workout records
// - exercise_logs: Individual exercise sets within workouts
// - progress_entries: Body measurements and weight over time
// - meal_logs: Nutrition/food logging
// - user_settings: App preferences per user
// ============================================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

/// Database service singleton for SQLite operations
/// 
/// Provides persistent storage for all app data on mobile/desktop platforms.
/// Uses lazy initialization to create database on first access.
/// 
/// Note: For web compatibility, use AuthService and ProgressService
/// which use SharedPreferences instead.
class DatabaseService {
  // ========================================
  // SINGLETON PATTERN
  // ========================================

  /// Single instance of the database service
  static final DatabaseService _instance = DatabaseService._internal();

  /// Cached database reference
  static Database? _database;

  /// Factory constructor returns singleton instance
  factory DatabaseService() => _instance;

  /// Private internal constructor
  DatabaseService._internal();

  // ========================================
  // DATABASE INITIALIZATION
  // ========================================

  /// Get database instance (creates if doesn't exist)
  /// 
  /// Uses lazy initialization pattern - database is only created
  /// when first accessed, not when service is instantiated.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the SQLite database
  /// 
  /// Creates database file in app documents directory.
  /// Calls _onCreate to set up table schema on first run.
  Future<Database> _initDatabase() async {
    // Get platform-appropriate database path
    String path = join(await getDatabasesPath(), 'ironforge.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create all database tables
  /// 
  /// Called once when database is first created.
  /// Sets up complete schema for all app features.
  Future<void> _onCreate(Database db, int version) async {
    // ----------------------------------------
    // USERS TABLE
    // Stores user account and profile data
    // ----------------------------------------
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        profileImage TEXT,
        height REAL,
        weight REAL,
        age INTEGER,
        fitnessGoal TEXT,
        experienceLevel TEXT,
        createdAt TEXT NOT NULL,
        lastLogin TEXT
      )
    ''');

    // ----------------------------------------
    // WORKOUT LOGS TABLE
    // Stores completed workout sessions
    // ----------------------------------------
    await db.execute('''
      CREATE TABLE workout_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        odId INTEGER NOT NULL,
        workoutName TEXT NOT NULL,
        duration INTEGER NOT NULL,
        caloriesBurned INTEGER,
        date TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // ----------------------------------------
    // EXERCISE LOGS TABLE
    // Individual exercises within a workout
    // Linked to workout_logs via workoutLogId
    // ----------------------------------------
    await db.execute('''
      CREATE TABLE exercise_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutLogId INTEGER NOT NULL,
        exerciseName TEXT NOT NULL,
        sets INTEGER,
        reps INTEGER,
        weight REAL,
        duration INTEGER,
        FOREIGN KEY (workoutLogId) REFERENCES workout_logs (id)
      )
    ''');

    // ----------------------------------------
    // PROGRESS ENTRIES TABLE
    // Body measurements and weight tracking
    // ----------------------------------------
    await db.execute('''
      CREATE TABLE progress_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        date TEXT NOT NULL,
        weight REAL,
        bodyFat REAL,
        muscleMass REAL,
        chest REAL,
        waist REAL,
        hips REAL,
        biceps REAL,
        thighs REAL,
        notes TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // ----------------------------------------
    // MEAL LOGS TABLE
    // Nutrition and food tracking
    // ----------------------------------------
    await db.execute('''
      CREATE TABLE meal_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        mealName TEXT NOT NULL,
        calories INTEGER,
        protein REAL,
        carbs REAL,
        fat REAL,
        date TEXT NOT NULL,
        mealType TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // ----------------------------------------
    // USER SETTINGS TABLE
    // App preferences (one row per user)
    // ----------------------------------------
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER UNIQUE NOT NULL,
        darkMode INTEGER DEFAULT 1,
        notifications INTEGER DEFAULT 1,
        reminderTime TEXT,
        unitSystem TEXT DEFAULT 'metric',
        language TEXT DEFAULT 'en',
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  // ========================================
  // USER OPERATIONS
  // ========================================

  /// Create a new user account
  /// 
  /// Returns: The auto-generated user ID
  /// Warning: Password is stored in plain text - use hashing in production!
  Future<int> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final db = await database;
    return await db.insert('users', {
      'email': email.toLowerCase(),
      'password': password, // In production, hash this!
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Authenticate user with email and password
  /// 
  /// Returns: User data map if credentials valid, null otherwise
  /// Also updates lastLogin timestamp on successful login.
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.toLowerCase(), password],
    );
    
    if (results.isNotEmpty) {
      // Update last login timestamp
      await db.update(
        'users',
        {'lastLogin': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [results.first['id']],
      );
      return results.first;
    }
    return null;
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get user by email address
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Update user profile data
  /// 
  /// Pass any fields to update in the data map.
  /// Returns: Number of rows affected (should be 1)
  Future<int> updateUser(int userId, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'users',
      data,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ========================================
  // WORKOUT LOG OPERATIONS
  // ========================================

  /// Log a completed workout session
  /// 
  /// Returns: The auto-generated workout log ID
  Future<int> logWorkout({
    required int userId,
    required String workoutName,
    required int duration,
    int? caloriesBurned,
    String? notes,
  }) async {
    final db = await database;
    return await db.insert('workout_logs', {
      'userId': userId,
      'workoutName': workoutName,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'date': DateTime.now().toIso8601String(),
      'notes': notes,
    });
  }

  /// Get workout history for a user
  /// 
  /// Returns workouts ordered by date (most recent first).
  /// Use limit parameter to control number of results.
  Future<List<Map<String, dynamic>>> getWorkoutLogs(int userId, {int limit = 50}) async {
    final db = await database;
    return await db.query(
      'workout_logs',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
  }

  // ========================================
  // PROGRESS TRACKING OPERATIONS
  // ========================================

  /// Log a progress entry with body measurements
  /// 
  /// All measurements are optional - only provide what was measured.
  /// Returns: The auto-generated progress entry ID
  Future<int> logProgress({
    required int userId,
    double? weight,
    double? bodyFat,
    double? muscleMass,
    double? chest,
    double? waist,
    double? hips,
    double? biceps,
    double? thighs,
    String? notes,
  }) async {
    final db = await database;
    return await db.insert('progress_entries', {
      'userId': userId,
      'date': DateTime.now().toIso8601String(),
      'weight': weight,
      'bodyFat': bodyFat,
      'muscleMass': muscleMass,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'biceps': biceps,
      'thighs': thighs,
      'notes': notes,
    });
  }

  /// Get progress history for a user
  /// 
  /// Returns entries ordered by date (most recent first).
  Future<List<Map<String, dynamic>>> getProgressEntries(int userId, {int limit = 100}) async {
    final db = await database;
    return await db.query(
      'progress_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
  }

  // ========================================
  // MEAL/NUTRITION OPERATIONS
  // ========================================

  /// Log a meal with nutritional information
  /// 
  /// mealType should be: 'breakfast', 'lunch', 'dinner', 'snack'
  /// Returns: The auto-generated meal log ID
  Future<int> logMeal({
    required int userId,
    required String mealName,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? mealType,
  }) async {
    final db = await database;
    return await db.insert('meal_logs', {
      'userId': userId,
      'mealName': mealName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'date': DateTime.now().toIso8601String(),
      'mealType': mealType,
    });
  }

  /// Get meal history for a user
  Future<List<Map<String, dynamic>>> getMealLogs(int userId, {int limit = 50}) async {
    final db = await database;
    return await db.query(
      'meal_logs',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
  }

  /// Get aggregated nutrition totals for today
  /// 
  /// Returns sum of calories, protein, carbs, and fat for current day.
  Future<Map<String, dynamic>> getTodayNutrition(int userId) async {
    final db = await database;
    // Get today's date in ISO format (just the date part)
    final today = DateTime.now().toIso8601String().split('T')[0];
    final results = await db.rawQuery('''
      SELECT
        SUM(calories) as totalCalories,
        SUM(protein) as totalProtein,
        SUM(carbs) as totalCarbs,
        SUM(fat) as totalFat
      FROM meal_logs
      WHERE userId = ? AND date LIKE ?
    ''', [userId, '$today%']);

    return results.isNotEmpty ? results.first : {};
  }

  // ========================================
  // USER SETTINGS OPERATIONS
  // ========================================

  /// Initialize default settings for a new user
  /// 
  /// Uses ConflictAlgorithm.ignore to avoid duplicates.
  Future<void> initUserSettings(int userId) async {
    final db = await database;
    await db.insert('user_settings', {
      'userId': userId,
      'darkMode': 1,        // Dark mode on by default
      'notifications': 1,   // Notifications on by default
      'unitSystem': 'metric',
      'language': 'en',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Get user's settings
  Future<Map<String, dynamic>?> getUserSettings(int userId) async {
    final db = await database;
    final results = await db.query(
      'user_settings',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Update user settings
  /// 
  /// Pass only the settings you want to change.
  Future<int> updateUserSettings(int userId, Map<String, dynamic> settings) async {
    final db = await database;
    return await db.update(
      'user_settings',
      settings,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // ========================================
  // STATISTICS & AGGREGATES
  // ========================================

  /// Get aggregate statistics for a user
  /// 
  /// Returns:
  /// - totalWorkouts: All-time workout count
  /// - totalMinutes: All-time exercise minutes
  /// - totalCaloriesBurned: All-time calories burned
  /// - thisWeekWorkouts: Workouts in last 7 days
  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final db = await database;
    
    // Total workout count
    final workoutCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM workout_logs WHERE userId = ?', [userId]
    )) ?? 0;

    // Total exercise minutes
    final totalMinutes = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT SUM(duration) FROM workout_logs WHERE userId = ?', [userId]
    )) ?? 0;

    // Total calories burned
    final totalCalories = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT SUM(caloriesBurned) FROM workout_logs WHERE userId = ?', [userId]
    )) ?? 0;

    // Workouts in the last 7 days
    final thisWeekWorkouts = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) FROM workout_logs 
      WHERE userId = ? AND date >= date('now', '-7 days')
    ''', [userId])) ?? 0;

    return {
      'totalWorkouts': workoutCount,
      'totalMinutes': totalMinutes,
      'totalCaloriesBurned': totalCalories,
      'thisWeekWorkouts': thisWeekWorkouts,
    };
  }
}
