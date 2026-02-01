// ============================================================================
// IRON FORGE - Bodybuilding & Fitness Tracking Application
// ============================================================================
// 
// File: main.dart
// Description: Application entry point and main configuration
// 
// This file contains:
// - App initialization and startup logic
// - Theme configuration (colors, fonts, styling)
// - Route definitions for navigation
// - Main navigation screen with bottom navigation bar
// 
// Author: Iron Forge Development Team
// Version: 1.0.0
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/landing_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/workouts_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';

/// Main entry point for the application
/// 
/// Initializes Flutter bindings, authentication service, and validates
/// any existing user session before launching the app.
void main() async {
  // Ensure Flutter bindings are initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the authentication service singleton
  final authService = AuthService();
  await authService.init();

  // Validate existing session - check if stored user still exists in database
  bool isValidSession = false;
  if (authService.isLoggedIn) {
    isValidSession = await authService.verifySession();
    if (!isValidSession) {
      // Clear invalid session data
      await authService.signOut();
    }
  }

  // Launch app with appropriate initial route based on auth state
  runApp(BodybuildingApp(isLoggedIn: isValidSession));
}

/// Root widget of the application
/// 
/// Configures the MaterialApp with:
/// - Custom dark theme with orange/cyan accent colors
/// - Google Fonts (Poppins) for consistent typography
/// - Named routes for navigation
class BodybuildingApp extends StatelessWidget {
  /// Whether user has a valid authenticated session
  final bool isLoggedIn;

  const BodybuildingApp({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iron Man Muscle - Bodybuilding',
      debugShowCheckedModeBanner: false, // Hide debug banner
      
      // ========================================
      // THEME CONFIGURATION
      // ========================================
      theme: ThemeData(
        useMaterial3: true, // Enable Material 3 design system
        
        // Color scheme - Dark theme with vibrant accents
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B35),    // Orange - primary actions, buttons
          secondary: Color(0xFF00D9FF),   // Cyan - secondary elements
          tertiary: Color(0xFFFFD700),    // Gold - achievements, highlights
          surface: Color(0xFF1A1A2E),     // Dark purple - cards, surfaces
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
        
        // Background color for scaffolds
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        
        // Apply Poppins font throughout the app
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        
        // Transparent app bar with no elevation
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        
        // Card styling with rounded corners
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A2E),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        
        // Elevated button styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
          ),
        ),
      ),
      
      // ========================================
      // ROUTING CONFIGURATION
      // ========================================
      // Set initial route based on authentication status
      initialRoute: isLoggedIn ? '/home' : '/',
      
      // Named routes for navigation
      routes: {
        '/': (context) => const LandingScreen(),           // Welcome/landing page
        '/auth': (context) => const AuthScreen(),          // Sign in screen
        '/signup': (context) => const AuthScreen(isSignUp: true), // Sign up screen
        '/home': (context) => const MainNavigationScreen(), // Main app with tabs
      },
    );
  }
}

/// Main navigation screen with bottom navigation bar
/// 
/// This screen serves as the container for the main app content,
/// providing tab-based navigation between:
/// - Home (dashboard)
/// - Workouts (workout programs)
/// - Exercises (exercise library)
/// - Progress (weight & body tracking)
/// - Nutrition (meal planning)
/// - Profile (settings & account)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  /// Current selected tab index
  int _currentIndex = 0;
  
  /// Animation controller for page transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  /// List of screens for each tab
  final List<Widget> _screens = [
    const HomeScreen(),       // Tab 0: Dashboard
    const WorkoutsScreen(),   // Tab 1: Workout programs
    const ExercisesScreen(),  // Tab 2: Exercise library
    const ProgressScreen(),   // Tab 3: Progress tracking
    const NutritionScreen(),  // Tab 4: Nutrition/meals
    const ProfileScreen(),    // Tab 5: User profile
  ];

  @override
  void initState() {
    super.initState();
    // Initialize fade animation for smooth tab transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Handle tab selection
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Restart fade animation for new tab
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display current tab with fade animation
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _screens[_currentIndex],
      ),
      
      // Custom styled bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // Gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E).withValues(alpha: 0.8),
              const Color(0xFF1A1A2E),
            ],
          ),
          // Orange glow effect
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFFFF6B35),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Workouts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_gymnastics_outlined),
              activeIcon: Icon(Icons.sports_gymnastics),
              label: 'Exercises',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_outlined),
              activeIcon: Icon(Icons.trending_up),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              activeIcon: Icon(Icons.restaurant),
              label: 'Nutrition',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
