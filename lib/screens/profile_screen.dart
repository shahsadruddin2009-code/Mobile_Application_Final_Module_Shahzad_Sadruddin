// ============================================================================
// IRON FORGE - Profile Screen
// ============================================================================
//
// File: profile_screen.dart
// Description: User profile, settings, and account management
//
// Features:
// - Profile header with avatar and user info
// - Quick stats (workouts, hours, streak)
// - Weight goal tracking with progress bar
// - Body stats display (age, height, weight, BMI)
// - Edit body stats modal with form validation
// - Achievements showcase
// - App settings toggles (notifications, dark mode)
// - Settings menu (language, units, privacy)
// - Edit profile and sign out actions
//
// Body Stats:
// - Age, height, weight stored in ProgressService
// - BMI automatically calculated from height/weight
// - BMI category with color coding:
//   - Underweight: Blue
//   - Normal: Green
//   - Overweight: Orange
//   - Obese: Red
//
// Settings:
// - Notifications toggle (workout reminders)
// - Dark mode toggle (currently always dark)
// - Language selection (English default)
// - Units system (Metric: kg, cm)
// - Privacy settings
//
// Data Sources:
// - User profile from DataService.getUserProfile()
// - Body stats from ProgressService.userStats
// - Auth info from AuthService
//
// Actions:
// - Edit Profile: Opens profile editing modal
// - Edit Body Stats: Opens body measurement modal
// - Share Progress: Share achievements (placeholder)
// - Sign Out: Clear session and return to landing
// ============================================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';
import '../services/exercise_log_service.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../data/data_service.dart';

/// User profile and settings screen
///
/// Displays user information, fitness statistics, body measurements,
/// achievements, and app settings. Provides editing capabilities
/// for profile and body stats with real-time BMI calculation.
///
/// Integrates with multiple services:
/// - AuthService: User authentication and session
/// - ProgressService: Body stats and measurements
/// - ExerciseLogService: Exercise workout logs for dynamic stats
/// - DataService: Demo profile data
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = DataService.getUserProfile();
  final ProgressService _progressService = ProgressService();
  final ExerciseLogService _exerciseLogService = ExerciseLogService();
  bool _notificationsEnabled = true;
  bool _darkMode = true;
  bool _isLoading = true;

  // Dynamic stats from exercise logs
  int _totalWorkouts = 0;
  int _totalMinutes = 0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _progressService.init();
    await _exerciseLogService.init();

    // Calculate dynamic stats from exercise logs
    final entries = _exerciseLogService.entries;
    int totalMinutes = 0;

    // Calculate total workouts (unique dates with exercise logs)
    final workoutDates = <String>{};
    for (final entry in entries) {
      workoutDates
          .add('${entry.date.year}-${entry.date.month}-${entry.date.day}');
      // Estimate 3 minutes per set for workout duration
      totalMinutes += entry.sets * 3;
    }

    // Calculate current streak (consecutive days with workouts)
    int streak = 0;
    final today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    while (workoutDates
        .contains('${checkDate.year}-${checkDate.month}-${checkDate.day}')) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    if (mounted) {
      setState(() {
        _totalWorkouts = workoutDates.length;
        _totalMinutes = totalMinutes;
        _currentStreak = streak;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                              child: _buildProfileStatCard(
                                  'Workouts',
                                  '$_totalWorkouts',
                                  Icons.fitness_center,
                                  const Color(0xFFFF6B35))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildProfileStatCard(
                                  'Hours',
                                  (_totalMinutes / 60).toStringAsFixed(0),
                                  Icons.timer,
                                  const Color(0xFF00D9FF))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildProfileStatCard(
                                  'Streak',
                                  '$_currentStreak',
                                  Icons.local_fire_department,
                                  const Color(0xFFFFD700))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildGoalCard()),
                    const SizedBox(height: 24),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildBodyStatsCard()),
                    const SizedBox(height: 24),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildAchievementsSection()),
                    const SizedBox(height: 24),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSettingsSection()),
                    const SizedBox(height: 24),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildActionButtons()),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)]),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFFF6B35).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: const Center(
                    child: Text('A',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFF27AE60),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF0F0F1A), width: 3)),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(AuthService().userFullName,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)]),
                borderRadius: BorderRadius.circular(20)),
            child: Text(user.experienceLevel,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          const SizedBox(height: 8),
          Text('Goal: ${user.fitnessGoal}',
              style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProfileStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    final stats = _progressService.userStats;

    // Check if user has set their weight goals
    final hasWeightData = stats.weight != null && stats.targetWeight != null;

    if (!hasWeightData) {
      // Show prompt to set weight goals
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weight Goal',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 16),
            Text('Set your weight goals to track your progress!',
                style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showEditBodyStatsDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Set Weight Goals'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currentWeight = stats.weight!;
    final startWeight = stats.startingWeight ?? currentWeight;
    final targetWeight = stats.targetWeight!;

    // Calculate progress towards goal
    double progress = 0.0;
    if (startWeight != targetWeight) {
      progress = (startWeight - currentWeight) / (startWeight - targetWeight);
    }

    // Calculate difference from target
    final difference = (currentWeight - targetWeight).abs();
    final isGainingGoal = targetWeight > startWeight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weight Goal',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(isGainingGoal ? Icons.trending_up : Icons.trending_down,
                      color: const Color(0xFF27AE60), size: 14),
                  const SizedBox(width: 4),
                  Text('${difference.toStringAsFixed(1)} kg to go',
                      style: const TextStyle(
                          color: Color(0xFF27AE60),
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Current',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                Text('${currentWeight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text('Start',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                Text('${startWeight.toStringAsFixed(1)} kg',
                    style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('Target',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                Text('${targetWeight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                        color: Color(0xFFFF6B35),
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          LinearPercentIndicator(
              lineHeight: 10,
              percent: progress.clamp(0, 1).toDouble(),
              backgroundColor: Colors.grey[800],
              linearGradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFFD700)]),
              barRadius: const Radius.circular(10),
              animation: true,
              animationDuration: 1500),
          const SizedBox(height: 8),
          Text('${(progress.clamp(0, 1) * 100).toInt()}% achieved!',
              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBodyStatsCard() {
    final stats = _progressService.userStats;
    final bmi = stats.bmi;
    final bmiCategory = stats.bmiCategory;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Body Stats',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              IconButton(
                  onPressed: _showEditBodyStatsDialog,
                  icon: const Icon(Icons.edit,
                      color: Color(0xFFFF6B35), size: 20),
                  tooltip: 'Edit Body Stats'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBodyStatItem(
                  'Age', stats.age != null ? '${stats.age}' : '--', 'years'),
              _buildBodyStatItem(
                  'Height',
                  stats.height != null ? '${stats.height!.toInt()}' : '--',
                  'cm'),
              _buildBodyStatItem(
                  'Weight',
                  stats.weight != null
                      ? stats.weight!.toStringAsFixed(1)
                      : '--',
                  'kg'),
              _buildBodyStatItem('BMI',
                  bmi != null ? bmi.toStringAsFixed(1) : '--', bmiCategory,
                  valueColor: Color(stats.bmiCategoryColor)),
            ],
          ),
          if (stats.lastUpdated != null) ...[
            const SizedBox(height: 16),
            Center(
                child: Text('Last updated: ${_formatDate(stats.lastUpdated!)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11))),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  Widget _buildBodyStatItem(String label, String value, String unit,
      {Color? valueColor}) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold)),
      Text(unit,
          style: TextStyle(
              color: valueColor?.withOpacity(0.8) ?? Colors.grey[500],
              fontSize: 12)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
    ]);
  }

  void _showEditBodyStatsDialog() {
    final stats = _progressService.userStats;
    final ageController =
        TextEditingController(text: stats.age != null ? '${stats.age}' : '');
    final heightController = TextEditingController(
        text: stats.height != null ? '${stats.height!.toInt()}' : '');
    final weightController = TextEditingController(
        text: stats.weight != null ? stats.weight!.toStringAsFixed(1) : '');
    final startingWeightController = TextEditingController(
        text: stats.startingWeight != null
            ? stats.startingWeight!.toStringAsFixed(1)
            : '');
    final targetWeightController = TextEditingController(
        text: stats.targetWeight != null
            ? stats.targetWeight!.toStringAsFixed(1)
            : '');
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24),
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
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                const Text('Edit Body Stats',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text('These stats are synced with your Progress page',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                const SizedBox(height: 24),
                TextField(
                    controller: ageController,
                    decoration: InputDecoration(
                        labelText: 'Age',
                        hintText: 'Enter your age',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: const Color(0xFF0F0F1A),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                        prefixIcon:
                            const Icon(Icons.cake, color: Color(0xFFFF6B35)),
                        suffixText: 'years'),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: heightController,
                          decoration: InputDecoration(
                              labelText: 'Height',
                              hintText: 'Height',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: const Color(0xFF0F0F1A),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none),
                              prefixIcon: const Icon(Icons.height,
                                  color: Color(0xFF00D9FF)),
                              suffixText: 'cm'),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextField(
                          controller: weightController,
                          decoration: InputDecoration(
                              labelText: 'Current Weight',
                              hintText: 'Weight',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: const Color(0xFF0F0F1A),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none),
                              prefixIcon: const Icon(Icons.monitor_weight,
                                  color: Color(0xFFFFD700)),
                              suffixText: 'kg'),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true))),
                ]),
                const SizedBox(height: 16),
                const Text('Weight Goals',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text('Set your starting and target weight for goal tracking',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: startingWeightController,
                          decoration: InputDecoration(
                              labelText: 'Starting Weight',
                              hintText: 'Start',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: const Color(0xFF0F0F1A),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none),
                              prefixIcon: const Icon(Icons.flag,
                                  color: Color(0xFF9B59B6)),
                              suffixText: 'kg'),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextField(
                          controller: targetWeightController,
                          decoration: InputDecoration(
                              labelText: 'Target Weight',
                              hintText: 'Target',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: const Color(0xFF0F0F1A),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none),
                              prefixIcon: const Icon(Icons.emoji_events,
                                  color: Color(0xFF27AE60)),
                              suffixText: 'kg'),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true))),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final age = int.tryParse(ageController.text);
                      final nav = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final height = double.tryParse(heightController.text);
                      final weight = double.tryParse(weightController.text);
                      final startingWeight =
                          double.tryParse(startingWeightController.text);
                      final targetWeight =
                          double.tryParse(targetWeightController.text);
                      await _progressService.updateUserStats(
                          age: age,
                          height: height,
                          weight: weight,
                          startingWeight: startingWeight,
                          targetWeight: targetWeight);
                      if (mounted) {
                        setState(() {});
                        nav.pop();
                        messenger.showSnackBar(const SnackBar(
                            content: Text('Body stats updated successfully!'),
                            backgroundColor: Color(0xFF27AE60)));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Save Changes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Achievements',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text('${user.achievements.length} earned',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ]),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: user.achievements.map((achievement) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color(0xFFFFD700).withOpacity(0.3),
                      const Color(0xFFFFA500).withOpacity(0.2)
                    ]),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.4))),
                child: Text(achievement,
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Settings',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 16),
          _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Workout reminders & updates',
              trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeThumbColor: const Color(0xFFFF6B35))),
          _buildSettingItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'App appearance',
              trailing: Switch(
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
                  activeThumbColor: const Color(0xFFFF6B35))),
          _buildSettingItem(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English',
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: Colors.grey, size: 16),
              onTap: () {}),
          _buildSettingItem(
              icon: Icons.fitness_center_outlined,
              title: 'Units',
              subtitle: 'Metric (kg, cm)',
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: Colors.grey, size: 16),
              onTap: () {}),
          _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy',
              subtitle: 'Data & permissions',
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: Colors.grey, size: 16),
              onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Widget trailing,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFFFF6B35), size: 22)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12))
              ])),
          trailing,
        ]),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(children: [
      SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
              onPressed: () => _showEditProfileDialog(context),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(vertical: 16)))),
      const SizedBox(height: 12),
      SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share),
              label: const Text('Share Progress'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00D9FF),
                  side: const BorderSide(color: Color(0xFF00D9FF)),
                  padding: const EdgeInsets.symmetric(vertical: 16)))),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1A1A2E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: const Text('Sign Out',
                            style: TextStyle(color: Colors.white)),
                        content: const Text(
                            'Are you sure you want to sign out?',
                            style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Cancel',
                                  style: TextStyle(color: Colors.grey[400]))),
                          ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE74C3C)),
                              child: const Text('Sign Out'))
                        ]));
            if (confirmed == true) {
              await AuthService().signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              }
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
          style: TextButton.styleFrom(
              foregroundColor: Colors.grey[400],
              padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
      ),
    ]);
  }

  void _showEditProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24),
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
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text('Edit Profile',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 24),
              TextField(
                  decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFF0F0F1A),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none),
                      prefixIcon:
                          const Icon(Icons.person, color: Color(0xFFFF6B35))),
                  style: const TextStyle(color: Colors.white),
                  controller: TextEditingController(text: user.name)),
              const SizedBox(height: 16),
              TextField(
                  decoration: InputDecoration(
                      hintText: 'Target Weight (kg)',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFF0F0F1A),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none)),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                      text: '${user.targetWeight.toInt()}')),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Profile updated successfully!'),
                                backgroundColor: Color(0xFF27AE60)));
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)))),
            ],
          ),
        );
      },
    );
  }
}
