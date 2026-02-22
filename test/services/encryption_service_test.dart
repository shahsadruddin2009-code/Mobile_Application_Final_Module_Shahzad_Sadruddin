// ============================================================================
// MUSCLE POWER - Encryption Service Unit Tests
// ============================================================================
//
// Tests for EncryptionService: SHA-256 hashing, salt generation,
// XOR encryption/decryption, and password verification.
//
// These are pure Dart tests (no Flutter/SharedPreferences dependencies).
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:bodybuilding_app/services/encryption_service.dart';

void main() {
  late EncryptionService encryption;

  setUp(() {
    encryption = EncryptionService();
  });

  // ========================================
  // SINGLETON TESTS
  // ========================================

  group('Singleton Pattern', () {
    test('returns same instance', () {
      final a = EncryptionService();
      final b = EncryptionService();
      expect(identical(a, b), isTrue);
    });
  });

  // ========================================
  // SALT GENERATION TESTS
  // ========================================

  group('Salt Generation', () {
    test('generates non-empty salt', () {
      final salt = encryption.generateSalt();
      expect(salt, isNotEmpty);
    });

    test('generates base64-encoded salt', () {
      final salt = encryption.generateSalt();
      // Base64url encoded strings contain only [A-Za-z0-9_-=]
      expect(salt, matches(RegExp(r'^[A-Za-z0-9_\-=]+$')));
    });

    test('generates unique salts', () {
      final salts = List.generate(100, (_) => encryption.generateSalt());
      final unique = salts.toSet();
      // All 100 salts should be unique (cryptographically random)
      expect(unique.length, 100);
    });

    test('salt has sufficient length', () {
      final salt = encryption.generateSalt();
      // 32 bytes base64-encoded should be ~44 characters
      expect(salt.length, greaterThanOrEqualTo(40));
    });
  });

  // ========================================
  // PASSWORD HASHING TESTS
  // ========================================

  group('Password Hashing', () {
    test('produces non-empty hash', () {
      final hash = encryption.hashPassword('password123', 'test_salt');
      expect(hash, isNotEmpty);
    });

    test('produces consistent hash for same input', () {
      const password = 'MySecurePass!';
      const salt = 'fixed_salt_value';
      final hash1 = encryption.hashPassword(password, salt);
      final hash2 = encryption.hashPassword(password, salt);
      expect(hash1, equals(hash2));
    });

    test('produces different hash for different passwords', () {
      const salt = 'same_salt';
      final hash1 = encryption.hashPassword('password1', salt);
      final hash2 = encryption.hashPassword('password2', salt);
      expect(hash1, isNot(equals(hash2)));
    });

    test('produces different hash for different salts', () {
      const password = 'samePassword';
      final hash1 = encryption.hashPassword(password, 'salt1');
      final hash2 = encryption.hashPassword(password, 'salt2');
      expect(hash1, isNot(equals(hash2)));
    });

    test('hash is base64url encoded', () {
      final hash = encryption.hashPassword('test', 'salt');
      expect(hash, matches(RegExp(r'^[A-Za-z0-9_\-=]+$')));
    });

    test('hash has consistent length (SHA-256 = 32 bytes)', () {
      final hash1 = encryption.hashPassword('short', 'salt');
      final hash2 = encryption.hashPassword('a very long password with many characters!', 'salt');
      // SHA-256 always produces 32 bytes → 44 characters base64
      expect(hash1.length, equals(hash2.length));
    });

    test('handles special characters in password', () {
      final hash = encryption.hashPassword('P@ss\$w0rd!#%^&*()', 'salt');
      expect(hash, isNotEmpty);
    });

    test('handles unicode characters', () {
      final hash = encryption.hashPassword('パスワード', 'salt');
      expect(hash, isNotEmpty);
    });

    test('handles empty password', () {
      final hash = encryption.hashPassword('', 'salt');
      expect(hash, isNotEmpty);
    });
  });

  // ========================================
  // PASSWORD VERIFICATION TESTS
  // ========================================

  group('Password Verification', () {
    test('verifies correct password', () {
      const password = 'CorrectHorse!42';
      final salt = encryption.generateSalt();
      final hash = encryption.hashPassword(password, salt);

      expect(encryption.verifyPassword(password, salt, hash), isTrue);
    });

    test('rejects incorrect password', () {
      const password = 'CorrectHorse!42';
      final salt = encryption.generateSalt();
      final hash = encryption.hashPassword(password, salt);

      expect(encryption.verifyPassword('WrongPassword!42', salt, hash), isFalse);
    });
    test('rejects password without special characters against different hash', () {
      const password = 'ValidPassword123';
      const wrongPassword = 'ValidPassword456';
      final salt = encryption.generateSalt();
      final hash = encryption.hashPassword(wrongPassword, salt);

      // verifyPassword checks hash match, not password strength
      expect(encryption.verifyPassword(password, salt, hash), isFalse);
    });
    test('rejects wrong salt', () {
      const password = 'Test123!';
      final salt1 = encryption.generateSalt();
      final hash = encryption.hashPassword(password, salt1);
      final salt2 = encryption.generateSalt();

      expect(encryption.verifyPassword(password, salt2, hash), isFalse);
    });

    test('rejects tampered hash', () {
      const password = 'Test123!';
      final salt = encryption.generateSalt();
      final hash = encryption.hashPassword(password, salt);
      final tampered = '${hash}X';

      expect(encryption.verifyPassword(password, salt, tampered), isFalse);
    });

    test('handles empty password in verification', () {
      const password = '';
      final salt = encryption.generateSalt();
      final hash = encryption.hashPassword(password, salt);

      expect(encryption.verifyPassword(password, salt, hash), isTrue);
      expect(encryption.verifyPassword('notEmpty', salt, hash), isFalse);
    });
  });

  // ========================================
  // FIELD ENCRYPTION TESTS
  // ========================================

  group('Field Encryption', () {
    test('encrypts plain text with ENC: prefix', () {
      final encrypted = encryption.encrypt('Hello World');
      expect(encrypted, startsWith('ENC:'));
    });

    test('encrypted text differs from plain text', () {
      const plain = 'Sensitive Data';
      final encrypted = encryption.encrypt(plain);
      expect(encrypted, isNot(equals(plain)));
    });

    test('returns empty string for empty input', () {
      final encrypted = encryption.encrypt('');
      expect(encrypted, isEmpty);
    });

    test('produces consistent encryption for same input', () {
      const text = 'Same Input';
      final enc1 = encryption.encrypt(text);
      final enc2 = encryption.encrypt(text);
      expect(enc1, equals(enc2));
    });

    test('produces different encryption for different inputs', () {
      final enc1 = encryption.encrypt('Input A');
      final enc2 = encryption.encrypt('Input B');
      expect(enc1, isNot(equals(enc2)));
    });

    test('handles special characters', () {
      final encrypted = encryption.encrypt('user@email.com!#\$%^&*()');
      expect(encrypted, startsWith('ENC:'));
    });

    test('handles unicode text', () {
      final encrypted = encryption.encrypt('こんにちは世界');
      expect(encrypted, startsWith('ENC:'));
    });

    test('handles very long strings', () {
      final longText = 'A' * 10000;
      final encrypted = encryption.encrypt(longText);
      expect(encrypted, startsWith('ENC:'));
    });
  });

  // ========================================
  // FIELD DECRYPTION TESTS
  // ========================================

  group('Field Decryption', () {
    test('decrypts encrypted text back to original', () {
      const original = 'Hello World';
      final encrypted = encryption.encrypt(original);
      final decrypted = encryption.decrypt(encrypted);
      expect(decrypted, equals(original));
    });

    test('round-trip preserves special characters', () {
      const original = 'user@email.com!#\$%^&*()';
      final encrypted = encryption.encrypt(original);
      final decrypted = encryption.decrypt(encrypted);
      expect(decrypted, equals(original));
    });

    test('round-trip preserves unicode', () {
      const original = 'こんにちは世界 🏋️';
      final encrypted = encryption.encrypt(original);
      final decrypted = encryption.decrypt(encrypted);
      expect(decrypted, equals(original));
    });

    test('returns unencrypted text as-is', () {
      const plainText = 'Not encrypted';
      final result = encryption.decrypt(plainText);
      expect(result, equals(plainText));
    });

    test('returns empty string for empty input', () {
      expect(encryption.decrypt(''), equals(''));
    });

    test('handles corrupted encrypted data gracefully', () {
      // Should not throw — falls back to returning raw value
      final result = encryption.decrypt('ENC:not_valid_base64!!!');
      expect(result, isNotNull);
    });

    test('round-trip with email addresses', () {
      const email = 'john.doe@example.com';
      final encrypted = encryption.encrypt(email);
      final decrypted = encryption.decrypt(encrypted);
      expect(decrypted, equals(email));
    });

    test('round-trip with names', () {
      const name = "O'Brien-Smith Jr.";
      final encrypted = encryption.encrypt(name);
      final decrypted = encryption.decrypt(encrypted);
      expect(decrypted, equals(name));
    });
  });

  // ========================================
  // isEncrypted TESTS
  // ========================================

  group('isEncrypted', () {
    test('returns true for ENC: prefixed strings', () {
      expect(encryption.isEncrypted('ENC:abc123'), isTrue);
    });

    test('returns false for plain strings', () {
      expect(encryption.isEncrypted('plain text'), isFalse);
    });

    test('returns false for empty strings', () {
      expect(encryption.isEncrypted(''), isFalse);
    });

    test('returns false for partial prefix', () {
      expect(encryption.isEncrypted('ENC'), isFalse);
      expect(encryption.isEncrypted('EN:'), isFalse);
    });

    test('correctly identifies encrypted output', () {
      final encrypted = encryption.encrypt('test');
      expect(encryption.isEncrypted(encrypted), isTrue);
    });
  });

  // ========================================
  // encryptIfNeeded TESTS
  // ========================================

  group('encryptIfNeeded', () {
    test('encrypts plain text', () {
      final result = encryption.encryptIfNeeded('plain');
      expect(result, startsWith('ENC:'));
    });

    test('does not double-encrypt already encrypted text', () {
      final encrypted = encryption.encrypt('test');
      final result = encryption.encryptIfNeeded(encrypted);
      expect(result, equals(encrypted));
    });

    test('returns empty string for empty input', () {
      expect(encryption.encryptIfNeeded(''), isEmpty);
    });

    test('encrypted result is still decryptable', () {
      final encrypted = encryption.encryptIfNeeded('Hello');
      final decrypted = encryption.decrypt(encrypted);
      expect(decrypted, equals('Hello'));
    });
  });

  // ========================================
  // INTEGRATION / END-TO-END TESTS
  // ========================================

  group('End-to-End Scenarios', () {
    test('full user registration flow', () {
      // Simulate sign-up
      const password = 'SecureP@ss123';
      const firstName = 'John';
      const lastName = 'Doe';
      const email = 'john@example.com';

      // Generate salt and hash password
      final salt = encryption.generateSalt();
      final hashedPassword = encryption.hashPassword(password, salt);

      // Encrypt PII
      final encFirstName = encryption.encrypt(firstName);
      final encLastName = encryption.encrypt(lastName);
      final encEmail = encryption.encrypt(email);

      // Verify password during sign-in
      expect(encryption.verifyPassword(password, salt, hashedPassword), isTrue);
      expect(encryption.verifyPassword('wrong', salt, hashedPassword), isFalse);

      // Decrypt PII for display
      expect(encryption.decrypt(encFirstName), equals(firstName));
      expect(encryption.decrypt(encLastName), equals(lastName));
      expect(encryption.decrypt(encEmail), equals(email));
    });


    test('full user registration flow', () {
      // Simulate sign-up
      const password = 'SecureP@ss123';
      const firstName = 'John';
      const lastName = 'Doe';
      const email = 'john@example.com';

      for (var i = 0; i < email.length; i++) {
        if (email[i] == '@'|| email[i] == '.' || (email[i].codeUnitAt(0) >= 48 && email[i].codeUnitAt(0) <= 57) || (email[i].codeUnitAt(0) >= 65 && email[i].codeUnitAt(0) <= 90) || (email[i].codeUnitAt(0) >= 97 && email[i].codeUnitAt(0) <= 122)) {
          continue; // Skip valid email character
        }
        else {
          fail('Email contains invalid character: ${email[i]}'); // Fail the test if an invalid character is found
        }
      }

      // Generate salt and hash password
      final salt = encryption.generateSalt();
      final hashedPassword = encryption.hashPassword(password, salt);

      // Encrypt PII
      final encFirstName = encryption.encrypt(firstName);
      final encLastName = encryption.encrypt(lastName);
      final encEmail = encryption.encrypt(email);

      // Verify password during sign-in
      expect(encryption.verifyPassword(password, salt, hashedPassword), isTrue);
      expect(encryption.verifyPassword('wrong', salt, hashedPassword), isFalse);

      // Decrypt PII for display
      expect(encryption.decrypt(encFirstName), equals(firstName));
      expect(encryption.decrypt(encLastName), equals(lastName));
      expect(encryption.decrypt(encEmail), equals(email));
    });
    test('password reset flow', () {
      const oldPassword = 'OldP@ss123';
      const newPassword = 'NewP@ss456!';

      // Original registration
      final salt1 = encryption.generateSalt();
      final hash1 = encryption.hashPassword(oldPassword, salt1);

      // Password reset (new salt for extra security)
      final salt2 = encryption.generateSalt();
      final hash2 = encryption.hashPassword(newPassword, salt2);

      // Old password no longer works
      expect(encryption.verifyPassword(oldPassword, salt2, hash2), isFalse);

      // New password works
      expect(encryption.verifyPassword(newPassword, salt2, hash2), isTrue);

      // Original hash is different
      expect(hash1, isNot(equals(hash2)));
    });

    test('legacy migration flow', () {
      // Simulate legacy user with plain-text data
      const legacyFirstName = 'Jane';
      expect(encryption.isEncrypted(legacyFirstName), isFalse);

      // Migrate to encrypted format
      final migrated = encryption.encryptIfNeeded(legacyFirstName);
      expect(encryption.isEncrypted(migrated), isTrue);

      // Verify data integrity after migration
      expect(encryption.decrypt(migrated), equals(legacyFirstName));
    });
  });
}
