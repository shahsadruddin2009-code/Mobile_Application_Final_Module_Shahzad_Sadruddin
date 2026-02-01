// ============================================================================
// IRON FORGE - Nutrition Screen
// ============================================================================
//
// File: nutrition_screen.dart
// Description: Nutrition tracking and meal planning interface
//
// Features:
// - Daily calorie tracking with visual progress indicator
// - Macronutrient breakdown (protein, carbs, fat)
// - Water intake tracker with glass visualization
// - Today's meals log with time and calorie info
// - Meal plan library with recipe cards
// - Filter meals by type (breakfast, lunch, dinner, snack)
// - Log custom meals with nutritional data
//
// Tabs:
// 1. Today Tab:
//    - Calorie progress card with circular indicator
//    - Macro cards showing protein/carbs/fat vs targets
//    - Water intake tracker (8 glasses goal)
//    - Today's logged meals list
//
// 2. Meal Plans Tab:
//    - Meal type filter chips
//    - Recipe cards with nutritional info
//    - Prep/cook time indicators
//    - Calorie and macro summaries
//
// Data Sources:
// - Meal data from DataService.getMeals()
// - Logged meals from NutritionService
// - User's daily totals calculated in real-time
//
// Daily Targets (configurable):
// - Calories: 2500 kcal
// - Protein: 180g
// - Carbs: 280g
// - Fat: 80g
// - Water: 8 glasses
// ============================================================================

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../data/data_service.dart';
import '../models/models.dart';
import '../services/nutrition_service.dart';

/// Nutrition tracking and meal planning screen
///
/// Provides comprehensive nutrition management with two main views:
/// - Today: Track daily calorie intake and macros
/// - Meal Plans: Browse and select from meal library
///
/// Integrates with NutritionService for persistent meal logging
/// and real-time calculation of daily nutritional totals.
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final meals = DataService.getMeals();
  String _selectedMealType = 'All';
  final NutritionService _nutritionService = NutritionService();

  // Daily nutrition targets
  final int targetCalories = 2500;
  final double targetProtein = 180;
  final double targetCarbs = 280;
  final double targetFat = 80;

  // Controllers for meal dialog
  final _mealNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  int get currentCalories => _nutritionService.todaysTotals['calories'] as int;
  double get currentProtein => _nutritionService.todaysTotals['protein'] as double;
  double get currentCarbs => _nutritionService.todaysTotals['carbs'] as double;
  double get currentFat => _nutritionService.todaysTotals['fat'] as double;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initNutritionService();
  }

  Future<void> _initNutritionService() async {
    await _nutritionService.init();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mealNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  List<Meal> get filteredMeals {
    if (_selectedMealType == 'All') return meals;
    return meals.where((m) => m.mealType == _selectedMealType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutrition',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Fuel your gains 🥗',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      onPressed: () => _showLogMealDialog(context),
                      icon: const Icon(Icons.add),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Today'),
                  Tab(text: 'Meal Plans'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTodayTab(),
                  _buildMealPlansTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calories Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27AE60).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calories Today',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$currentCalories',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ $targetCalories',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${targetCalories - currentCalories} calories remaining',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                CircularPercentIndicator(
                  radius: 55,
                  lineWidth: 10,
                  percent: currentCalories / targetCalories,
                  center: Text(
                    '${((currentCalories / targetCalories) * 100).toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  progressColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 1500,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Macros Section
          const Text(
            'Macronutrients',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMacroCard(
                  'Protein',
                  currentProtein,
                  targetProtein,
                  'g',
                  const Color(0xFFE74C3C),
                  Icons.egg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroCard(
                  'Carbs',
                  currentCarbs,
                  targetCarbs,
                  'g',
                  const Color(0xFFFFD700),
                  Icons.bakery_dining,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroCard(
                  'Fat',
                  currentFat,
                  targetFat,
                  'g',
                  const Color(0xFF3498DB),
                  Icons.water_drop,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Water Intake
          _buildWaterIntakeCard(),

          const SizedBox(height: 24),

          // Today's Meals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Meals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showLogMealDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF27AE60),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Show logged meals from service
          if (_nutritionService.todaysMeals.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey[800]!,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No meals logged today',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to log your first meal',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._nutritionService.todaysMeals.map((meal) => _buildMealLogItemFromLog(meal)),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMealPlansTab() {
    final mealTypes = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snack'];

    return Column(
      children: [
        // Meal Type Filter
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mealTypes.length,
            itemBuilder: (context, index) {
              final type = mealTypes[index];
              final isSelected = _selectedMealType == type;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMealType = type;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                          )
                        : null,
                    color: isSelected ? null : const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : const Color(0xFF27AE60).withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[400],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Meals List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: filteredMeals.length,
            itemBuilder: (context, index) {
              return _buildMealCard(filteredMeals[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard(
    String name,
    double current,
    double target,
    String unit,
    Color color,
    IconData icon,
  ) {
    final percent = current / target;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 35,
            lineWidth: 6,
            percent: percent.clamp(0, 1),
            center: Icon(icon, color: color, size: 20),
            progressColor: color,
            backgroundColor: color.withOpacity(0.2),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${current.toInt()}$unit',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '/ ${target.toInt()}$unit',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterIntakeCard() {
    final currentWater = _nutritionService.waterIntake;
    final targetWater = _nutritionService.waterGoal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D9FF).withOpacity(0.2),
            const Color(0xFF00B4D8).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D9FF).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D9FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Color(0xFF00D9FF),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Water Intake',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentWater of $targetWater glasses',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick add button
              ElevatedButton(
                onPressed: () async {
                  await _nutritionService.addWater();
                  setState(() {});
                  if (mounted && _nutritionService.waterIntake >= _nutritionService.waterGoal) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 Daily water goal reached!'),
                        backgroundColor: Color(0xFF00D9FF),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9FF),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Water glasses visualization
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              targetWater,
              (index) => GestureDetector(
                onTap: () async {
                  // Tap to set water intake to this glass number
                  await _nutritionService.setWaterIntake(index + 1);
                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 40,
                  decoration: BoxDecoration(
                    color: index < currentWater
                        ? const Color(0xFF00D9FF)
                        : const Color(0xFF00D9FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: index < currentWater
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00D9FF).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.water_drop,
                    size: 18,
                    color: index < currentWater
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (currentWater / targetWater).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFF00D9FF).withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
            ),
          ),
          const SizedBox(height: 12),
          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remove water button
              TextButton.icon(
                onPressed: currentWater > 0
                    ? () async {
                        await _nutritionService.removeWater();
                        setState(() {});
                      }
                    : null,
                icon: const Icon(Icons.remove, size: 16),
                label: const Text('Remove'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[400],
                ),
              ),
              // Set goal button
              TextButton.icon(
                onPressed: () => _showWaterGoalDialog(context),
                icon: const Icon(Icons.settings, size: 16),
                label: const Text('Set Goal'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00D9FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWaterGoalDialog(BuildContext context) {
    int selectedGoal = _nutritionService.waterGoal;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Daily Water Goal',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set your daily water intake goal',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: selectedGoal > 1
                            ? () => setDialogState(() => selectedGoal--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 40,
                        color: const Color(0xFF00D9FF),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          Text(
                            '$selectedGoal',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00D9FF),
                            ),
                          ),
                          const Text(
                            'glasses',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: selectedGoal < 20
                            ? () => setDialogState(() => selectedGoal++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 40,
                        color: const Color(0xFF00D9FF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '≈ ${selectedGoal * 250}ml',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await _nutritionService.setWaterGoal(selectedGoal);
                        if (mounted) {
                          navigator.pop();
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D9FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Save Goal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMealLogItemFromLog(MealLog meal) {
    final timeStr = '${meal.loggedAt.hour.toString().padLeft(2, '0')}:${meal.loggedAt.minute.toString().padLeft(2, '0')}';
    
    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          color: Colors.red,
        ),
      ),
      onDismissed: (direction) async {
        await _nutritionService.removeMeal(meal.id);
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${meal.name} removed'),
              backgroundColor: Colors.red[400],
              action: SnackBarAction(
                label: 'Undo',
                textColor: Colors.white,
                onPressed: () async {
                  await _nutritionService.addMeal(
                    name: meal.name,
                    calories: meal.calories,
                    protein: meal.protein,
                    carbs: meal.carbs,
                    fat: meal.fat,
                    mealType: meal.mealType,
                  );
                  setState(() {});
                },
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMealTypeIcon(meal.mealType),
                color: const Color(0xFF27AE60),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.mealType.isNotEmpty 
                        ? meal.mealType[0].toUpperCase() + meal.mealType.substring(1)
                        : 'Meal',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    meal.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (meal.protein > 0 || meal.carbs > 0 || meal.fat > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          if (meal.protein > 0)
                            _buildMiniMacro('P', meal.protein, const Color(0xFFE74C3C)),
                          if (meal.carbs > 0)
                            _buildMiniMacro('C', meal.carbs, const Color(0xFFFFD700)),
                          if (meal.fat > 0)
                            _buildMiniMacro('F', meal.fat, const Color(0xFF3498DB)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${meal.calories} cal',
                  style: const TextStyle(
                    color: Color(0xFF27AE60),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  timeStr,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMacro(String label, double value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: ${value.toInt()}g',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildMealCard(Meal meal) {
    return GestureDetector(
      onTap: () => _showMealDetails(context, meal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF27AE60).withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Image Placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF27AE60).withOpacity(0.3),
                    const Color(0xFF2ECC71).withOpacity(0.2),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 48,
                  color: const Color(0xFF27AE60).withOpacity(0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27AE60).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          meal.mealType,
                          style: const TextStyle(
                            color: Color(0xFF27AE60),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.timer,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        meal.prepTime,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    meal.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMacroInfo('Cal', '${meal.calories}', const Color(0xFF27AE60)),
                      _buildMacroInfo('P', '${meal.protein.toInt()}g', const Color(0xFFE74C3C)),
                      _buildMacroInfo('C', '${meal.carbs.toInt()}g', const Color(0xFFFFD700)),
                      _buildMacroInfo('F', '${meal.fat.toInt()}g', const Color(0xFF3498DB)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showMealDetails(BuildContext context, Meal meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        meal.mealType,
                        style: const TextStyle(
                          color: Color(0xFF27AE60),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Macros
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailMacro('Calories', '${meal.calories}', const Color(0xFF27AE60)),
                        _buildDetailMacro('Protein', '${meal.protein.toInt()}g', const Color(0xFFE74C3C)),
                        _buildDetailMacro('Carbs', '${meal.carbs.toInt()}g', const Color(0xFFFFD700)),
                        _buildDetailMacro('Fat', '${meal.fat.toInt()}g', const Color(0xFF3498DB)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Ingredients
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...meal.ingredients.map((ing) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF27AE60),
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                ing,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 24),

                    // Instructions
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...meal.instructions.asMap().entries.map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B35).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: Color(0xFFFF6B35),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Meal added to today!'),
                              backgroundColor: Color(0xFF27AE60),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Add to Today',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailMacro(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showLogMealDialog(BuildContext context) {
    _mealNameController.clear();
    _caloriesController.clear();
    _proteinController.clear();
    _carbsController.clear();
    _fatController.clear();
    String selectedMealType = 'Breakfast';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Log Meal',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your nutrition intake',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Meal Type Selection
                    const Text(
                      'Meal Type',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((type) {
                        final isSelected = selectedMealType == type;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedMealType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                                    )
                                  : null,
                              color: isSelected ? null : const Color(0xFF0F0F1A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? Colors.transparent 
                                    : Colors.grey[700]!,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getMealTypeIcon(type),
                                  size: 16,
                                  color: isSelected ? Colors.white : Colors.grey[400],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  type,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[400],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Meal Name
                    TextField(
                      controller: _mealNameController,
                      decoration: InputDecoration(
                        hintText: 'Meal Name (e.g., Grilled Chicken Salad)',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: const Color(0xFF0F0F1A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.restaurant,
                          color: Color(0xFF27AE60),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    
                    // Calories
                    TextField(
                      controller: _caloriesController,
                      decoration: InputDecoration(
                        hintText: 'Calories',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: const Color(0xFF0F0F1A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.local_fire_department,
                          color: Color(0xFF27AE60),
                        ),
                        suffixText: 'kcal',
                        suffixStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    // Macros Row
                    const Text(
                      'Macronutrients (optional)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _proteinController,
                            decoration: InputDecoration(
                              hintText: 'Protein',
                              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                              filled: true,
                              fillColor: const Color(0xFF0F0F1A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              suffixText: 'g',
                              suffixStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _carbsController,
                            decoration: InputDecoration(
                              hintText: 'Carbs',
                              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                              filled: true,
                              fillColor: const Color(0xFF0F0F1A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              suffixText: 'g',
                              suffixStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _fatController,
                            decoration: InputDecoration(
                              hintText: 'Fat',
                              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                              filled: true,
                              fillColor: const Color(0xFF0F0F1A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              suffixText: 'g',
                              suffixStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = _mealNameController.text.trim();
                          final calories = int.tryParse(_caloriesController.text) ?? 0;
                          final protein = double.tryParse(_proteinController.text) ?? 0;
                          final carbs = double.tryParse(_carbsController.text) ?? 0;
                          final fat = double.tryParse(_fatController.text) ?? 0;
                          
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a meal name'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          await _nutritionService.addMeal(
                            name: name,
                            calories: calories,
                            protein: protein,
                            carbs: carbs,
                            fat: fat,
                            mealType: selectedMealType.toLowerCase(),
                          );

                          navigator.pop();
                          setState(() {});
                          messenger.showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text('$name logged successfully!'),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF27AE60),
                              ),
                            );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Log Meal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
