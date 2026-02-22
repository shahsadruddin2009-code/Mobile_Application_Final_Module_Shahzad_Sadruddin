// ============================================================================
// MUSCLE POWER - Landing Screen
// ============================================================================
// 
// File: landing_screen.dart
// Description: App welcome/splash screen with branding and navigation
// 
// Purpose:
// This is the first screen users see when launching the app.
// It showcases the MUSCLE POWER brand with animations and provides
// navigation options for authentication or guest access.
// 
// Features:
// - Animated brand logo with gradient glow effect
// - Background image with gradient overlay
// - Feature highlights (workouts, meals, progress)
// - Sign In / Create Account buttons
// - Guest access option
// - Smooth entrance animations (fade + slide)
// 
// Navigation:
// - Sign In -> AuthScreen(isSignUp: false)
// - Create Account -> AuthScreen(isSignUp: true)
// - Guest -> /home route (main app)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_screen.dart';

/// Landing screen with branding and authentication options
/// 
/// Uses [TickerProviderStateMixin] for managing multiple animation controllers.
/// Displays animated logo, brand name, feature highlights, and auth buttons.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  // ========================================
  // ANIMATION CONTROLLERS
  // ========================================

  /// Controls fade-in animation for all content
  late AnimationController _fadeController;

  /// Controls slide-up animation for content entrance
  late AnimationController _slideController;

  /// Fade animation value (0.0 to 1.0)
  late Animation<double> _fadeAnimation;

  /// Slide animation offset (starts at 30% below, slides to normal position)
  late Animation<Offset> _slideAnimation;

  // ========================================
  // LIFECYCLE METHODS
  // ========================================

  @override
  void initState() {
    super.initState();
    
    // Initialize fade controller (1.5 seconds duration)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Initialize slide controller (1.2 seconds duration)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Configure fade animation with ease-in curve
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    // Configure slide animation (30% offset to zero)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start both animations immediately
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    // Clean up animation controllers to prevent memory leaks
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ========================================
  // NAVIGATION
  // ========================================

  /// Navigate to authentication screen with custom transition
  /// 
  /// [isSignUp] determines whether to show sign up or sign in form
  void _navigateToAuth(bool isSignUp) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AuthScreen(isSignUp: isSignUp),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Combine fade and slide transitions
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),  // Slide from right
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ========================================
  // BUILD METHOD
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Background Image
          Image.asset(
            'assets/images/Master_Image_file.jpg',
            fit: BoxFit.cover,
            // Fallback gradient if image fails to load
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D0D1A),
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Layer 2: Dark gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          
          // Layer 3: Animated content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      // Brand elements
                      _buildLogo(),
                      const SizedBox(height: 24),
                      _buildBrandName(),
                      const SizedBox(height: 16),
                      _buildTagline(),
                      const Spacer(flex: 2),
                      // Feature highlights
                      _buildFeatures(),
                      const Spacer(flex: 2),
                      // Auth buttons
                      _buildSignInButton(),
                      const SizedBox(height: 16),
                      _buildCreateAccountButton(),
                      const SizedBox(height: 24),
                      _buildGuestOption(),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // BRAND WIDGETS
  // ========================================

  /// Build the main logo with gradient background and glow effect
  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B35),  // Primary orange
            Color(0xFFFF8E53),  // Light orange
            Color(0xFFFFD700),  // Gold
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.fitness_center,
          size: 70,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build brand name with animated gradient shader
  Widget _buildBrandName() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFFF6B35),  // Orange
          Color(0xFFFFD700),  // Gold
          Color(0xFF00D9FF),  // Cyan
        ],
      ).createShader(bounds),
      child: Text(
        'MUSCLE FITNESS',
        style: GoogleFonts.orbitron(
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 4,
        ),
      ),
    );
  }

  /// Build tagline text
  Widget _buildTagline() {
    return Text(
      'FORGE YOUR LEGACY',
      style: GoogleFonts.rajdhani(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
        letterSpacing: 6,
      ),
    );
  }

  // ========================================
  // FEATURE HIGHLIGHTS
  // ========================================

  /// Build feature highlight row (3 icons with labels)
  Widget _buildFeatures() {
    final features = [
      {'icon': Icons.fitness_center, 'text': '+ Workouts'},
      {'icon': Icons.restaurant_menu, 'text': 'Meal Plans'},
      {'icon': Icons.trending_up, 'text': 'Track Progress'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: features.map((feature) {
        return Column(
          children: [
            // Feature icon container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: const Color(0xFFFF6B35),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            // Feature label
            Text(
              feature['text'] as String,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ========================================
  // AUTH BUTTONS
  // ========================================

  /// Build primary Sign In button
  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _navigateToAuth(false),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFFFF6B35).withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login, size: 24),
            const SizedBox(width: 12),
            Text(
              'SIGN IN',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build secondary Create Account button (outlined style)
  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: () => _navigateToAuth(true),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(
            color: Color(0xFF00D9FF),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.black.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add, size: 24, color: Color(0xFF00D9FF)),
            const SizedBox(width: 12),
            Text(
              'CREATE ACCOUNT',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: const Color(0xFF00D9FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build guest access text button
  Widget _buildGuestOption() {
    return TextButton(
      onPressed: () {
        // Navigate directly to home, bypassing authentication
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: Text(
        'Continue as Guest',
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 14,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
