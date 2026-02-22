// ============================================================================
// MUSCLE POWER - Authentication Service
// ============================================================================
//
// File: auth_service.dart
// Description: Handles user authentication, registration, and session management
//
// Features:
// - User registration (sign up) with email/password
// - User authentication (sign in)
// - Social login (Google, Apple, Facebook)
// - Session persistence using SharedPreferences
// - Password reset functionality
// - Profile management
//
// Storage:
// - Uses SharedPreferences for cross-platform persistence (web, mobile, desktop)
// - User data stored as JSON with email as key
// - Session data stored separately for quick auth checks
//
// Security Notes:
// - Passwords are stored in plain text (for demo purposes)
// - Production apps should use proper hashing (bcrypt, argon2)
// - Consider Firebase Auth or similar for production
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:convert';
import 'encryption_service.dart';

/// Authentication service singleton
///
/// Manages user accounts, sessions, and authentication state.
/// Uses the singleton pattern to ensure consistent state across the app.
///
/// Usage:
/// ```dart
/// final auth = AuthService();
/// await auth.init();
/// if (auth.isLoggedIn) {
///   print('Welcome ${auth.userFullName}');
/// }
/// ```
class AuthService {
  // ========================================
  // SINGLETON PATTERN
  // ========================================

  /// Single instance of the service
  static final AuthService _instance = AuthService._internal();

  /// Currently logged in user data (null if not logged in)
  Map<String, dynamic>? _currentUser;

  /// Flag to prevent multiple initializations
  bool _initialized = false;

  /// In-memory user database
  /// Key: email (lowercase), Value: user data with hashed password & encrypted fields
  /// Works on all platforms including web (no SQLite needed)
  static final Map<String, Map<String, dynamic>> _users = {};

  /// Encryption service for securing sensitive data
  final EncryptionService _encryption = EncryptionService();

  /// Factory constructor returns the singleton instance
  factory AuthService() => _instance;

  /// Private internal constructor
  AuthService._internal();

  // ========================================
  // PUBLIC GETTERS
  // ========================================

  /// Get current user data (without password)
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Check if user is currently logged in
  bool get isLoggedIn => _currentUser != null;

  /// Get current user's ID (timestamp-based)
  int? get userId => _currentUser?['id'] as int?;

  // ========================================
  // INITIALIZATION
  // ========================================

  /// Initialize the auth service
  ///
  /// Loads persisted user data and session from SharedPreferences.
  /// Must be called before using any auth features.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load all registered users from storage
      final usersJson = prefs.getString('registered_users');
      if (usersJson != null && usersJson.isNotEmpty) {
        final savedUsers = json.decode(usersJson) as Map<String, dynamic>;
        _users.clear();
        savedUsers.forEach((key, value) {
          _users[key] = Map<String, dynamic>.from(value);
        });
      }

      // Restore current session if exists
      final userJson = prefs.getString('current_session');
      if (userJson != null && userJson.isNotEmpty) {
        final savedSession = json.decode(userJson) as Map<String, dynamic>;
        final email = savedSession['email'] as String?;

        // Validate session - user must still exist in database
        if (email != null && _users.containsKey(email)) {
          _currentUser = Map<String, dynamic>.from(savedSession);
        } else {
          // Invalid session, clear it
          await prefs.remove('current_session');
        }
      }
    } catch (e) {

      // Silently handle init errors - user will need to sign in again
      _users.clear();
    }
  }

  /// Force reload data from storage
  ///
  /// Useful after app restart or when data might be stale.
  Future<void> reloadFromStorage() async {
    _initialized = false;
    await init();
  }

  // ========================================
  // PRIVATE PERSISTENCE METHODS
  // ========================================

  /// Save all users to persistent storage
  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = json.encode(_users);
      await prefs.setString('registered_users', usersJson);
    } catch (e) {
      // Silently handle save errors
    }
  }

  /// Save current session to persistent storage
  Future<void> _saveCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString('current_session', json.encode(_currentUser));
      } else {
        await prefs.remove('current_session');
      }
    } catch (e) {
      // Silently handle save errors
    }
  }

  // ========================================
  // AUTHENTICATION METHODS
  // ========================================

  /// Register a new user account
  ///
  /// Creates a new user with the provided credentials and automatically
  /// signs them in upon successful registration.
  ///
  /// Returns: Map with 'success' boolean and either 'user' or 'error'
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    await init();

    // Input validation
    if (email.isEmpty || !email.contains('@')) {
      return {'success': false, 'error': 'Please enter a valid email'};
    }
    if (password.length < 6) {
      return {
        'success': false,
        'error': 'Password must be at least 6 characters'
      };
    }
    if (firstName.isEmpty || lastName.isEmpty) {
      return {'success': false, 'error': 'Please enter your full name'};
    }

    final emailLower = email.toLowerCase().trim();

    // Check for existing account
    if (_users.containsKey(emailLower)) {
      return {'success': false, 'error': 'Email already registered'};
    }

    // Generate salt and hash password (NEVER store plain text)
    final salt = _encryption.generateSalt();
    final hashedPassword = _encryption.hashPassword(password, salt);

    // Encrypt sensitive PII fields
    final encryptedFirstName = _encryption.encrypt(firstName.trim());
    final encryptedLastName = _encryption.encrypt(lastName.trim());
    final encryptedEmail = _encryption.encrypt(emailLower);

    // Create user record with encrypted data
    final newId = DateTime.now().millisecondsSinceEpoch;
    final newUser = {
      'id': newId,
      'email': emailLower,
      'emailEncrypted': encryptedEmail,
      'password': hashedPassword,
      'salt': salt,
      'firstName': encryptedFirstName,
      'lastName': encryptedLastName,
      'createdAt': DateTime.now().toIso8601String(),
      'lastLogin': DateTime.now().toIso8601String(),
      'securityVersion': 2,
    };

    // Store in database
    _users[emailLower] = newUser;

    // Create session (with decrypted names for display, no password)
    _currentUser = {
      'id': newId,
      'email': emailLower,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'createdAt': newUser['createdAt'],
      'lastLogin': newUser['lastLogin'],
    };

    // Persist changes
    await _saveUsers();
    await _saveCurrentUser();

    return {'success': true, 'user': _currentUser};
  }

  /// Sign in with existing account
  ///
  /// Authenticates user with email/password and creates a new session.
  ///
  /// Returns: Map with 'success' boolean and either 'user' or 'error'
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    await init();

    if (email.isEmpty || password.isEmpty) {
      return {'success': false, 'error': 'Please enter email and password'};
    }

    final emailLower = email.toLowerCase().trim();

    // Reload users to get latest data
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('registered_users');
    if (usersJson != null && usersJson.isNotEmpty) {
      final savedUsers = json.decode(usersJson) as Map<String, dynamic>;
      _users.clear();
      savedUsers.forEach((key, value) {
        _users[key] = Map<String, dynamic>.from(value);
      });
    }

    final user = _users[emailLower];

    // Validate credentials
    if (user == null) {
      return {'success': false, 'error': 'No account found with this email'};
    }

    // Verify password using hash comparison
    final salt = user['salt'] as String?;
    final storedHash = user['password'] as String?;
    if (salt != null && storedHash != null && _encryption.isEncrypted(user['firstName']?.toString() ?? '')) {
      // New encrypted format: verify via hash
      if (!_encryption.verifyPassword(password, salt, storedHash)) {
        return {'success': false, 'error': 'Incorrect password'};
      }
    } else {
      // Legacy plain-text format: direct comparison then migrate
      if (user['password'] != password) {
        return {'success': false, 'error': 'Incorrect password'};
      }
      // Migrate to encrypted format
      final newSalt = _encryption.generateSalt();
      user['salt'] = newSalt;
      user['password'] = _encryption.hashPassword(password, newSalt);
      user['firstName'] = _encryption.encryptIfNeeded(user['firstName'] ?? '');
      user['lastName'] = _encryption.encryptIfNeeded(user['lastName'] ?? '');
      user['emailEncrypted'] = _encryption.encrypt(emailLower);
      user['securityVersion'] = 2;
    }

    // Update last login timestamp
    user['lastLogin'] = DateTime.now().toIso8601String();
    _users[emailLower] = user;

    // Create session (with decrypted names, no password/salt)
    _currentUser = {
      'id': user['id'],
      'email': emailLower,
      'firstName': _encryption.isEncrypted(user['firstName']?.toString() ?? '')
          ? _encryption.decrypt(user['firstName']!)
          : user['firstName'] ?? '',
      'lastName': _encryption.isEncrypted(user['lastName']?.toString() ?? '')
          ? _encryption.decrypt(user['lastName']!)
          : user['lastName'] ?? '',
      'createdAt': user['createdAt'],
      'lastLogin': user['lastLogin'],
      'provider': user['provider'],
      'photoUrl': user['photoUrl'],
    };

    await _saveUsers();
    await _saveCurrentUser();

    return {'success': true, 'user': _currentUser};
  }

  /// Verify if current session is valid
  ///
  /// Checks that the logged-in user still exists in the database.
  /// Used during app startup to validate persisted sessions.
  Future<bool> verifySession() async {
    await init();

    if (_currentUser == null) return false;

    final email = _currentUser!['email'] as String?;
    if (email == null) return false;

    return _users.containsKey(email);
  }

  /// Sign out current user
  ///
  /// Clears the current session from memory and storage.
  Future<void> signOut() async {
    _currentUser = null;
    await _saveCurrentUser();

    // Also sign out from social providers
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint('AuthService: Google sign-out error — $e');
    }
    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      debugPrint('AuthService: Facebook sign-out error — $e');
    }
  }

  // ========================================
  // SOCIAL LOGIN METHODS
  // ========================================

  /// Sign in with Google
  ///
  /// Uses Google Sign-In to authenticate and create/update user account.
  /// Returns: Map with 'success' boolean and either 'user' or 'error'
  Future<Map<String, dynamic>> signInWithGoogle() async {
    await init();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return {'success': false, 'error': 'Google sign-in was cancelled'};
      }

      final email = googleUser.email.toLowerCase().trim();
      final displayName = googleUser.displayName ?? '';
      final nameParts = displayName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Check if user already exists
      if (_users.containsKey(email)) {
        // Update existing user and sign in
        final user = _users[email]!;
        user['lastLogin'] = DateTime.now().toIso8601String();
        user['provider'] = 'google';
        user['photoUrl'] = googleUser.photoUrl;
        _users[email] = user;

        _currentUser = {
          'id': user['id'],
          'email': email,
          'firstName': _encryption.isEncrypted(user['firstName']?.toString() ?? '')
              ? _encryption.decrypt(user['firstName']!)
              : user['firstName'] ?? '',
          'lastName': _encryption.isEncrypted(user['lastName']?.toString() ?? '')
              ? _encryption.decrypt(user['lastName']!)
              : user['lastName'] ?? '',
          'provider': 'google',
          'photoUrl': googleUser.photoUrl,
          'lastLogin': user['lastLogin'],
        };
      } else {
        // Create new user with encrypted data
        final newId = DateTime.now().millisecondsSinceEpoch;
        final newUser = {
          'id': newId,
          'email': email,
          'emailEncrypted': _encryption.encrypt(email),
          'firstName': _encryption.encrypt(firstName),
          'lastName': _encryption.encrypt(lastName),
          'provider': 'google',
          'photoUrl': googleUser.photoUrl,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLogin': DateTime.now().toIso8601String(),
          'securityVersion': 2,
        };

        _users[email] = newUser;
        _currentUser = {
          'id': newId,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'provider': 'google',
          'photoUrl': googleUser.photoUrl,
          'createdAt': newUser['createdAt'],
          'lastLogin': newUser['lastLogin'],
        };
      }

      await _saveUsers();
      await _saveCurrentUser();

      return {'success': true, 'user': _currentUser};
    } catch (e) {
      return {
        'success': false,
        'error': 'Google sign-in failed: ${e.toString()}'
      };
    }
  }

  /// Sign in with Apple
  ///
  /// Uses Apple Sign-In to authenticate and create/update user account.
  /// Returns: Map with 'success' boolean and either 'user' or 'error'
  Future<Map<String, dynamic>> signInWithApple() async {
    await init();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Apple may not return email on subsequent logins, so we need to handle that
      String? email = credential.email;
      String firstName = credential.givenName ?? '';
      String lastName = credential.familyName ?? '';

      // If email is null, try to find existing user by Apple user ID
      if (email == null) {
        // Look for existing user with this Apple user identifier (decrypt to compare)
        final targetId = credential.userIdentifier;
        for (final entry in _users.entries) {
          final storedId = entry.value['appleUserId']?.toString() ?? '';
          final decryptedId = _encryption.isEncrypted(storedId)
              ? _encryption.decrypt(storedId)
              : storedId;
          if (decryptedId == targetId) {
            email = entry.key;
            break;
          }
        }

        if (email == null) {
          return {
            'success': false,
            'error': 'Could not retrieve email from Apple. Please try again.'
          };
        }
      }

      email = email.toLowerCase().trim();

      // Check if user already exists
      if (_users.containsKey(email)) {
        final user = _users[email]!;
        user['lastLogin'] = DateTime.now().toIso8601String();
        user['provider'] = 'apple';
        user['appleUserId'] = _encryption.encrypt(credential.userIdentifier ?? '');
        _users[email] = user;

        _currentUser = {
          'id': user['id'],
          'email': email,
          'firstName': _encryption.isEncrypted(user['firstName']?.toString() ?? '')
              ? _encryption.decrypt(user['firstName']!)
              : user['firstName'] ?? '',
          'lastName': _encryption.isEncrypted(user['lastName']?.toString() ?? '')
              ? _encryption.decrypt(user['lastName']!)
              : user['lastName'] ?? '',
          'provider': 'apple',
          'lastLogin': user['lastLogin'],
        };
      } else {
        // Create new user with encrypted data
        final newId = DateTime.now().millisecondsSinceEpoch;
        final newUser = {
          'id': newId,
          'email': email,
          'emailEncrypted': _encryption.encrypt(email),
          'firstName': _encryption.encrypt(firstName.isNotEmpty ? firstName : 'Apple'),
          'lastName': _encryption.encrypt(lastName.isNotEmpty ? lastName : 'User'),
          'provider': 'apple',
          'appleUserId': _encryption.encrypt(credential.userIdentifier ?? ''),
          'createdAt': DateTime.now().toIso8601String(),
          'lastLogin': DateTime.now().toIso8601String(),
          'securityVersion': 2,
        };

        _users[email] = newUser;
        _currentUser = {
          'id': newId,
          'email': email,
          'firstName': firstName.isNotEmpty ? firstName : 'Apple',
          'lastName': lastName.isNotEmpty ? lastName : 'User',
          'provider': 'apple',
          'createdAt': newUser['createdAt'],
          'lastLogin': newUser['lastLogin'],
        };
      }

      await _saveUsers();
      await _saveCurrentUser();

      return {'success': true, 'user': _currentUser};
    } catch (e) {
      return {
        'success': false,
        'error': 'Apple sign-in failed: ${e.toString()}'
      };
    }
  }

  /// Sign in with Facebook
  ///
  /// Uses Facebook Login to authenticate and create/update user account.
  /// Returns: Map with 'success' boolean and either 'user' or 'error'
  Future<Map<String, dynamic>> signInWithFacebook() async {
    await init();

    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) {
        return {'success': false, 'error': 'Facebook sign-in was cancelled'};
      }

      if (result.status != LoginStatus.success) {
        return {
          'success': false,
          'error': 'Facebook sign-in failed: ${result.message}'
        };
      }

      // Get user data from Facebook
      final userData = await FacebookAuth.instance.getUserData(
        fields: 'name,email,picture.width(200)',
      );

      final email = (userData['email'] as String?)?.toLowerCase().trim();
      if (email == null || email.isEmpty) {
        return {
          'success': false,
          'error': 'Could not retrieve email from Facebook'
        };
      }

      final name = userData['name'] as String? ?? '';
      final nameParts = name.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'Facebook';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'User';
      final photoUrl = userData['picture']?['data']?['url'] as String?;

      // Check if user already exists
      if (_users.containsKey(email)) {
        final user = _users[email]!;
        user['lastLogin'] = DateTime.now().toIso8601String();
        user['provider'] = 'facebook';
        user['photoUrl'] = photoUrl;
        user['facebookId'] = _encryption.encrypt(userData['id']?.toString() ?? '');
        _users[email] = user;

        _currentUser = {
          'id': user['id'],
          'email': email,
          'firstName': _encryption.isEncrypted(user['firstName']?.toString() ?? '')
              ? _encryption.decrypt(user['firstName']!)
              : user['firstName'] ?? '',
          'lastName': _encryption.isEncrypted(user['lastName']?.toString() ?? '')
              ? _encryption.decrypt(user['lastName']!)
              : user['lastName'] ?? '',
          'provider': 'facebook',
          'photoUrl': photoUrl,
          'lastLogin': user['lastLogin'],
        };
      } else {
        // Create new user with encrypted data
        final newId = DateTime.now().millisecondsSinceEpoch;
        final newUser = {
          'id': newId,
          'email': email,
          'emailEncrypted': _encryption.encrypt(email),
          'firstName': _encryption.encrypt(firstName),
          'lastName': _encryption.encrypt(lastName),
          'provider': 'facebook',
          'photoUrl': photoUrl,
          'facebookId': _encryption.encrypt(userData['id']?.toString() ?? ''),
          'createdAt': DateTime.now().toIso8601String(),
          'lastLogin': DateTime.now().toIso8601String(),
          'securityVersion': 2,
        };

        _users[email] = newUser;
        _currentUser = {
          'id': newId,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'provider': 'facebook',
          'photoUrl': photoUrl,
          'createdAt': newUser['createdAt'],
          'lastLogin': newUser['lastLogin'],
        };
      }

      await _saveUsers();
      await _saveCurrentUser();

      return {'success': true, 'user': _currentUser};
    } catch (e) {
      return {
        'success': false,
        'error': 'Facebook sign-in failed: ${e.toString()}'
      };
    }
  }

  // ========================================
  // PROFILE MANAGEMENT
  // ========================================

  /// Update current user's profile data
  ///
  /// Merges provided data with existing user record.
  /// Encrypts sensitive fields (firstName, lastName) before storing.
  /// Does not allow changing email or password through this method.
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return false;

    final email = _currentUser!['email'] as String;
    final user = _users[email];

    if (user != null) {
      // Encrypt sensitive fields for storage
      final encryptedData = Map<String, dynamic>.from(data);
      if (encryptedData.containsKey('firstName')) {
        encryptedData['firstName'] =
            _encryption.encryptIfNeeded(encryptedData['firstName'] as String);
      }
      if (encryptedData.containsKey('lastName')) {
        encryptedData['lastName'] =
            _encryption.encryptIfNeeded(encryptedData['lastName'] as String);
      }

      user.addAll(encryptedData);
      _users[email] = user;

      // Session keeps decrypted values for display
      _currentUser!.addAll(data);

      await _saveUsers();
      await _saveCurrentUser();
      return true;
    }
    return false;
  }

  /// Get user's full name
  String get userFullName {
    if (_currentUser == null) return 'Guest';
    final fn = _currentUser!['firstName'] ?? '';
    final ln = _currentUser!['lastName'] ?? '';
    return '$fn $ln'.trim();
  }

  /// Get user's email address
  String get userEmail {
    return _currentUser?['email'] ?? '';
  }

  /// Get user's initials for avatar display
  String get userInitials {
    if (_currentUser == null) return 'G';
    final firstName = _currentUser!['firstName'] as String? ?? '';
    final lastName = _currentUser!['lastName'] as String? ?? '';
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  // ========================================
  // PASSWORD MANAGEMENT
  // ========================================

  /// Check if an email is already registered
  Future<bool> checkEmailExists(String email) async {
    await init();
    final emailLower = email.toLowerCase().trim();
    return _users.containsKey(emailLower);
  }

  /// Reset password for existing account
  ///
  /// In a real app, this would send a reset email.
  /// For demo purposes, it directly updates the password with proper hashing.
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await init();

    final emailLower = email.toLowerCase().trim();
    final user = _users[emailLower];

    if (user == null) {
      return {'success': false, 'error': 'No account found with this email'};
    }

    if (newPassword.length < 8) {
      return {
        'success': false,
        'error': 'Password must be at least 8 characters'
      };
    }

    // Hash the new password with a fresh salt
    final newSalt = _encryption.generateSalt();
    user['password'] = _encryption.hashPassword(newPassword, newSalt);
    user['salt'] = newSalt;
    user['passwordResetAt'] = DateTime.now().toIso8601String();
    user['securityVersion'] = 2;
    _users[emailLower] = user;

    await _saveUsers();

    return {'success': true};
  }

  // ========================================
  // DEBUG HELPERS
  // ========================================

  /// Get count of registered users (for debugging)
  int get registeredUsersCount => _users.length;
}
