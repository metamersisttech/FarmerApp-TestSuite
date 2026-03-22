// test/unit/validators_test.dart
//
// Unit tests for lib/core/utils/validators.dart
// Run: flutter test test/unit/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/utils/validators.dart';

void main() {
  // ── Email ────────────────────────────────────────────────────────────────
  group('Validators.validateEmail', () {
    test('returns null for valid email', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('first.last+tag@sub.domain.org'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('returns error for missing @', () {
      expect(Validators.validateEmail('notanemail'), isNotNull);
    });

    test('returns error for missing domain', () {
      expect(Validators.validateEmail('user@'), isNotNull);
    });

    test('returns error for missing TLD', () {
      expect(Validators.validateEmail('user@example'), isNotNull);
    });
  });

  // ── Password ─────────────────────────────────────────────────────────────
  group('Validators.validatePassword', () {
    test('returns null for valid password', () {
      expect(Validators.validatePassword('Secure123'), isNull);
      expect(Validators.validatePassword('abcd1234'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.validatePassword(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validatePassword(''), isNotNull);
    });

    test('returns error for too short (< 8 chars)', () {
      expect(Validators.validatePassword('Abc1'), isNotNull);
    });

    test('returns error for digits only (no letters)', () {
      expect(Validators.validatePassword('12345678'), isNotNull);
    });

    test('returns error for letters only (no digits)', () {
      expect(Validators.validatePassword('abcdefgh'), isNotNull);
    });
  });

  // ── Phone ─────────────────────────────────────────────────────────────────
  group('Validators.validatePhone', () {
    test('returns null for valid 10-digit phone', () {
      expect(Validators.validatePhone('9876543210'), isNull);
    });

    test('returns null for phone with spaces (removes them)', () {
      expect(Validators.validatePhone('98 765 43210'), isNull);
    });

    test('returns null for phone with dashes', () {
      expect(Validators.validatePhone('98-7654-3210'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.validatePhone(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validatePhone(''), isNotNull);
    });

    test('returns error for < 10 digits', () {
      expect(Validators.validatePhone('123456'), isNotNull);
    });

    test('returns error for non-numeric', () {
      expect(Validators.validatePhone('phone-num'), isNotNull);
    });
  });

  // ── Required ─────────────────────────────────────────────────────────────
  group('Validators.validateRequired', () {
    test('returns null for non-empty value', () {
      expect(Validators.validateRequired('something'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.validateRequired(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validateRequired(''), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(Validators.validateRequired('   '), isNotNull);
    });

    test('includes fieldName in error message', () {
      final error = Validators.validateRequired('', fieldName: 'Farm Name');
      expect(error, contains('Farm Name'));
    });
  });

  // ── Name ──────────────────────────────────────────────────────────────────
  group('Validators.validateName', () {
    test('returns null for valid name', () {
      expect(Validators.validateName('Ramesh'), isNull);
      expect(Validators.validateName('Sita Devi'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.validateName(null), isNotNull);
    });

    test('returns error for single character', () {
      expect(Validators.validateName('A'), isNotNull);
    });

    test('returns error for digits in name', () {
      expect(Validators.validateName('Ram123'), isNotNull);
    });

    test('returns error for special characters', () {
      expect(Validators.validateName('Ram@#'), isNotNull);
    });

    test('uses custom fieldName in error', () {
      final error = Validators.validateName('', fieldName: 'Owner Name');
      expect(error, contains('Owner Name'));
    });
  });

  // ── OTP ───────────────────────────────────────────────────────────────────
  group('Validators.validateOtp', () {
    test('returns null for valid 6-digit OTP', () {
      expect(Validators.validateOtp('123456'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.validateOtp(null), isNotNull);
    });

    test('returns error for wrong length (< 6)', () {
      expect(Validators.validateOtp('12345'), isNotNull);
    });

    test('returns error for wrong length (> 6)', () {
      expect(Validators.validateOtp('1234567'), isNotNull);
    });

    test('returns error for non-digits', () {
      expect(Validators.validateOtp('12345a'), isNotNull);
    });

    test('respects custom length', () {
      expect(Validators.validateOtp('1234', length: 4), isNull);
      expect(Validators.validateOtp('123456', length: 4), isNotNull);
    });
  });

  // ── Confirm Password ──────────────────────────────────────────────────────
  group('Validators.validateConfirmPassword', () {
    test('returns null when passwords match', () {
      expect(Validators.validateConfirmPassword('Secure123', 'Secure123'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.validateConfirmPassword(null, 'Secure123'), isNotNull);
    });

    test('returns error when passwords do not match', () {
      expect(Validators.validateConfirmPassword('Different1', 'Secure123'), isNotNull);
    });

    test('returns error for empty value', () {
      expect(Validators.validateConfirmPassword('', 'Secure123'), isNotNull);
    });
  });
}
