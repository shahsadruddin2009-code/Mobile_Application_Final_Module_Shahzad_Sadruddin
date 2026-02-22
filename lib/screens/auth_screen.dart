// ============================================================================
// MUSCLE POWER - Authentication Screen
// ============================================================================
//
// File: auth_screen.dart
// Description: User authentication UI for sign in and sign up flows
//
// Features:
// - Toggle between Sign In and Sign Up modes
// - Email/password validation with real-time feedback
// - Social login options (Google, Apple, Facebook - UI only)
// - Forgot password flow with password reset
// - Animated transitions between form states
// - Loading states and error handling
// - User count display for community stats
//
// Form Fields:
// - Email (required, validated format)
// - Password (required, min 6 characters)
// - Confirm Password (sign up only, must match)
// - First Name (sign up only)
// - Last Name (sign up only)
//
// Navigation:
// - Success: Navigate to /home route
// - Back: Return to previous screen
//
// Styling:
// - Dark theme with orange accent colors
// - Gradient backgrounds and glassmorphism effects
// - Custom input decorations with icons
// - Animated buttons and transitions
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

/// Authentication screen for user sign in and sign up
///
/// This widget provides a complete authentication flow with:
/// - Animated form switching between sign in/sign up modes
/// - Input validation with error messages
/// - Social login buttons (Google, Apple, Facebook)
/// - Forgot password functionality
///
/// The [isSignUp] parameter determines the initial form state.
/// Pass `true` to show sign up form initially, `false` for sign in.
class AuthScreen extends StatefulWidget {
  final bool isSignUp;

  const AuthScreen({super.key, this.isSignUp = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

/// State class for AuthScreen
///
/// Manages form state, validation, animations, and authentication logic.
/// Uses [SingleTickerProviderStateMixin] for fade animation controller.
class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  // ========================================
  // FORM STATE
  // ========================================

  /// Current form mode - true for sign up, false for sign in
  late bool _isSignUp;

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  // ========================================
  // TEXT CONTROLLERS
  // ========================================

  /// Controller for email input field
  final _emailController = TextEditingController();

  /// Controller for password input field
  final _passwordController = TextEditingController();

  /// Controller for confirm password field (sign up only)
  final _confirmPasswordController = TextEditingController();

  /// Controller for first name field (sign up only)
  final _firstNameController = TextEditingController();

  /// Controller for last name field (sign up only)
  final _lastNameController = TextEditingController();

  // ========================================
  // UI STATE
  // ========================================

  /// Loading state for async operations
  bool _isLoading = false;

  /// Password visibility toggle for main password field
  bool _obscurePassword = true;

  /// Password visibility toggle for confirm password field
  bool _obscureConfirmPassword = true;

  /// Error message to display (null if no error)
  String? _errorMessage;

  /// Count of registered users for community stats display
  int _registeredCount = 0;

  // ========================================
  // ANIMATION
  // ========================================

  /// Animation controller for form fade transitions
  late AnimationController _animController;

  /// Fade animation for smooth form state transitions
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isSignUp;

    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animController);
    _animController.forward();

    // Load registered users count
    _loadRegisteredCount();
  }

  Future<void> _loadRegisteredCount() async {
    final authService = AuthService();
    await authService.init();
    if (mounted) {
      setState(() {
        _registeredCount = authService.registeredUsersCount;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
    });
    _animController.reset();
    _animController.forward();
  }

  /// Validates email format using strict regex.
  ///
  /// Checks for:
  /// - Non-empty local part before @
  /// - Valid domain with at least one dot (e.g., domain.com)
  /// - No consecutive dots
  /// - Valid TLD (2+ chars)
  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.(?:[a-zA-Z]{2,})(?:\.[a-zA-Z]{2,})*$',
    );
    if (!emailRegex.hasMatch(email)) return false;
    final parts = email.split('@');
    if (parts.length != 2) return false;
    final local = parts[0];
    final domain = parts[1];
    if (local.contains('..') || domain.contains('..')) return false;
    if (local.length > 64) return false;
    if (domain.length > 253) return false;
    return true;
  }

  /// Returns a detailed error message for invalid emails.
  String? _getEmailError(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!email.contains('@')) return 'Email must contain @';
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return 'Enter text before @';
    if (parts[1].isEmpty) return 'Enter domain after @';
    if (!parts[1].contains('.')) return 'Domain must include a dot (e.g., gmail.com)';
    final tld = parts[1].split('.').last;
    if (tld.length < 2) return 'Invalid domain extension';
    if (!_isValidEmail(email)) return 'Please enter a valid email address';
    return null;
  }

  /// Validates password strength for sign-up.
  ///
  /// Requirements:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  /// - At least one special character
  String? _getPasswordStrengthError(String password) {
    if (password.isEmpty) return 'Password is required';
    final errors = <String>[];
    if (password.length < 8) errors.add('at least 8 characters');
    if (!RegExp(r'[A-Z]').hasMatch(password)) errors.add('an uppercase letter');
    if (!RegExp(r'[a-z]').hasMatch(password)) errors.add('a lowercase letter');
    if (!RegExp(r'[0-9]').hasMatch(password)) errors.add('a digit');
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) errors.add('a special character');
    if (errors.isEmpty) return null;
    return 'Password needs: ${errors.join(', ')}';
  }

  void _showForgotPasswordDialog() {
    final forgotEmailController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();
    String? dialogError;
    int step = 1;
    bool isLoading = false;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    step == 1 ? Icons.email_outlined : Icons.lock_reset,
                    color: const Color(0xFFFF6B35),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  step == 1 ? 'Find Account' : 'Reset Password',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (step == 1) ...[
                    Text(
                      'Enter your email address to reset your password.',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: forgotEmailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.poppins(color: Colors.white54),
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFFF6B35)),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF27AE60).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xFF27AE60), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Account found! Enter your new password.',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF27AE60),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: GoogleFonts.poppins(color: Colors.white54),
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: Colors.white54),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setDialogState(() => obscureNew = !obscureNew),
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white54,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFFF6B35)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmNewPasswordController,
                      obscureText: obscureConfirm,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        labelStyle: GoogleFonts.poppins(color: Colors.white54),
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: Colors.white54),
                        suffixIcon: IconButton(
                          onPressed: () => setDialogState(
                              () => obscureConfirm = !obscureConfirm),
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white54,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFFF6B35)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ' At least 6 characters',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (dialogError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dialogError!,
                              style: GoogleFonts.poppins(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.white54),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setDialogState(() {
                          isLoading = true;
                          dialogError = null;
                        });

                        final authService = AuthService();

                        if (step == 1) {
                          final email = forgotEmailController.text.trim();

                          if (email.isEmpty) {
                            setDialogState(() {
                              dialogError = 'Please enter your email';
                              isLoading = false;
                            });
                            return;
                          }

                          if (!_isValidEmail(email)) {
                            setDialogState(() {
                              dialogError =
                                  'Please enter a valid email address';
                              isLoading = false;
                            });
                            return;
                          }

                          final exists =
                              await authService.checkEmailExists(email);
                          if (exists) {
                            setDialogState(() {
                              step = 2;
                              isLoading = false;
                            });
                          } else {
                            setDialogState(() {
                              dialogError = 'No account found with this email';
                              isLoading = false;
                            });
                          }
                        } else {
                          final newPass = newPasswordController.text;
                          final confirmPass = confirmNewPasswordController.text;

                          if (newPass.isEmpty) {
                            setDialogState(() {
                              dialogError = 'Please enter a new password';
                              isLoading = false;
                            });
                            return;
                          }

                          if (newPass.length < 6) {
                            setDialogState(() {
                              dialogError =
                                  'Password must be at least 6 characters';
                              isLoading = false;
                            });
                            return;
                          }

                          if (newPass != confirmPass) {
                            setDialogState(() {
                              dialogError = 'Passwords do not match';
                              isLoading = false;
                            });
                            return;
                          }

                          final result = await authService.resetPassword(
                            email: forgotEmailController.text.trim(),
                            newPassword: newPass,
                          );

                          if (result['success'] == true) {
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.white),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Password reset successful! Please sign in.',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF27AE60),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          } else {
                            setDialogState(() {
                              dialogError = result['error'] as String?;
                              isLoading = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        step == 1 ? 'Find Account' : 'Reset Password',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = AuthService();
    Map<String, dynamic> result;

    if (_isSignUp) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Passwords do not match';
          _isLoading = false;
        });
        return;
      }

      result = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
    } else {
      result = await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() => _errorMessage = result['error'] as String?);
    }

    _loadRegisteredCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Main_image_body_builder.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.85),
                    const Color(0xFF0D0D1A).withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(),
                    const SizedBox(height: 24),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildForm(),
                    const SizedBox(height: 24),
                    if (_errorMessage != null) _buildErrorMessage(),
                    const SizedBox(height: 16),
                    _buildSubmitButton(),
                    const SizedBox(height: 24),
                    _buildToggleMode(),
                    const SizedBox(height: 32),
                    _buildSocialLogin(),
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Registered accounts: $_registeredCount',
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFFD700)],
          ).createShader(bounds),
          child: Text(
            _isSignUp ? 'Create Account' : 'Welcome Back',
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSignUp
              ? 'Start your fitness journey today'
              : 'Sign in to continue your journey',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_isSignUp) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              return _getEmailError(value?.trim() ?? '');
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white54,
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter your password';
              if (_isSignUp) {
                return _getPasswordStrengthError(value!);
              }
              return null;
            },
          ),
          if (_isSignUp) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password Requirements:',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildPasswordReq('At least 8 characters', _passwordController.text.length >= 8),
                  _buildPasswordReq('Uppercase letter (A-Z)', RegExp(r'[A-Z]').hasMatch(_passwordController.text)),
                  _buildPasswordReq('Lowercase letter (a-z)', RegExp(r'[a-z]').hasMatch(_passwordController.text)),
                  _buildPasswordReq('A digit (0-9)', RegExp(r'[0-9]').hasMatch(_passwordController.text)),
                  _buildPasswordReq('Special character (!@#\$...)', RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text)),
                ],
              ),
            ),
          ],
          if (_isSignUp) ...[
            const SizedBox(height: 20),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white54,
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please confirm your password';
                }
                return null;
              },
            ),
          ],
          if (!_isSignUp) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPasswordDialog(),
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF00D9FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: const Color(0xFFFF6B35).withOpacity(0.5),
          disabledBackgroundColor: const Color(0xFFFF6B35).withOpacity(0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                _isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
      ),
    );
  }

  Widget _buildToggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? 'Already have an account?' : "Don't have an account?",
          style: GoogleFonts.poppins(color: Colors.white60),
        ),
        TextButton(
          onPressed: _toggleMode,
          child: Text(
            _isSignUp ? 'Sign In' : 'Sign Up',
            style: GoogleFonts.poppins(
                color: const Color(0xFF00D9FF), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Or continue with',
                  style:
                      GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                onTap: _signInWithGoogle),
            const SizedBox(width: 20),
            _buildSocialButton(
                icon: Icons.apple, label: 'Apple', onTap: _signInWithApple),
            const SizedBox(width: 20),
            _buildSocialButton(
                icon: Icons.facebook,
                label: 'Facebook',
                onTap: _signInWithFacebook),
          ],
        ),
      ],
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final result = await authService.signInWithGoogle();

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${authService.userFullName}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Google sign-in failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Google sign-in error: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final result = await authService.signInWithApple();

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${authService.userFullName}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Apple sign-in failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Apple sign-in error: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final result = await authService.signInWithFacebook();

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${authService.userFullName}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Facebook sign-in failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Facebook sign-in error: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPasswordReq(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            color: met ? const Color(0xFF27AE60) : Colors.white30,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: met ? const Color(0xFF27AE60) : Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
