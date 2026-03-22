// test/unit/user_model_test.dart
//
// Unit tests for lib/data/models/user_model.dart
// Run: flutter test test/unit/user_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/data/models/user_model.dart';

void main() {
  // ── UserModel.fromJson ────────────────────────────────────────────────────
  group('UserModel.fromJson', () {
    test('parses minimal required fields', () {
      final json = {
        'id': 1,
        'email': 'farmer@example.com',
      };
      final user = UserModel.fromJson(json);
      expect(user.id, 1);
      expect(user.email, 'farmer@example.com');
      expect(user.isActive, true);   // default
      expect(user.isVerified, false); // default
    });

    test('parses all flat top-level fields', () {
      final json = {
        'id': 42,
        'email': 'test@farm.in',
        'username': 'ramesh99',
        'first_name': 'Ramesh',
        'last_name': 'Patil',
        'phone': '9876543210',
        'is_active': true,
        'is_verified': true,
        'kyc_status': 'APPROVED',
        'date_joined': '2024-01-15T10:00:00Z',
        'last_login': '2024-03-10T08:30:00Z',
        'full_name': 'Ramesh Patil',
        'display_name': 'RameshFarmer',
        'about': 'Cattle farmer from Pune',
      };
      final user = UserModel.fromJson(json);
      expect(user.id, 42);
      expect(user.username, 'ramesh99');
      expect(user.firstName, 'Ramesh');
      expect(user.lastName, 'Patil');
      expect(user.phone, '9876543210');
      expect(user.isVerified, true);
      expect(user.kycStatus, 'APPROVED');
      expect(user.dateJoined, isNotNull);
      expect(user.fullName, 'Ramesh Patil');
      expect(user.displayName, 'RameshFarmer');
      expect(user.about, 'Cattle farmer from Pune');
    });

    test('parses new-format fields from nested profile object', () {
      final json = {
        'id': 5,
        'email': 'sita@example.com',
        'profile': {
          'full_name': 'Sita Devi',
          'display_name': 'SitaD',
          'address': 'Village Road, Maharashtra',
          'state': 'Maharashtra',
          'district': 'Pune',
          'village': 'Khed',
          'pincode': '410501',
          'latitude': '18.5204',
          'longitude': '73.8567',
          'about': 'Goat farmer',
        },
      };
      final user = UserModel.fromJson(json);
      expect(user.fullName, 'Sita Devi');
      expect(user.displayName, 'SitaD');
      expect(user.state, 'Maharashtra');
      expect(user.district, 'Pune');
      expect(user.pincode, '410501');
    });

    test('accepts string id (converts to int)', () {
      final json = {'id': '99', 'email': 'test@test.com'};
      final user = UserModel.fromJson(json);
      expect(user.id, 99);
    });

    test('handles null optional fields gracefully', () {
      final json = {'id': 1, 'email': 'a@b.com'};
      final user = UserModel.fromJson(json);
      expect(user.firstName, isNull);
      expect(user.phone, isNull);
      expect(user.profileImage, isNull);
    });
  });

  // ── UserModel getters ─────────────────────────────────────────────────────
  group('UserModel.fullNameDisplay', () {
    test('prefers fullName when set', () {
      final user = UserModel(id: 1, email: 'a@b.com',
        fullName: 'Full Name', firstName: 'First', lastName: 'Last');
      expect(user.fullNameDisplay, 'Full Name');
    });

    test('falls back to firstName + lastName', () {
      final user = UserModel(id: 1, email: 'a@b.com',
        firstName: 'Ramesh', lastName: 'Patil');
      expect(user.fullNameDisplay, 'Ramesh Patil');
    });

    test('falls back to email when nothing else available', () {
      final user = UserModel(id: 1, email: 'fallback@example.com');
      expect(user.fullNameDisplay, 'fallback@example.com');
    });
  });

  group('UserModel.displayNameOrUsername', () {
    test('prefers displayName', () {
      final user = UserModel(id: 1, email: 'a@b.com',
        displayName: 'MyDisplay', username: 'myuser');
      expect(user.displayNameOrUsername, 'MyDisplay');
    });

    test('falls back to username', () {
      final user = UserModel(id: 1, email: 'a@b.com', username: 'myuser');
      expect(user.displayNameOrUsername, 'myuser');
    });

    test('falls back to email prefix', () {
      final user = UserModel(id: 1, email: 'prefix@example.com');
      expect(user.displayNameOrUsername, 'prefix');
    });
  });

  // ── UserModel.toJson ──────────────────────────────────────────────────────
  group('UserModel.toJson', () {
    test('round-trips required fields', () {
      final user = UserModel(id: 7, email: 'round@trip.com');
      final json = user.toJson();
      expect(json['id'], 7);
      expect(json['email'], 'round@trip.com');
    });

    test('includes optional fields when set', () {
      final user = UserModel(
        id: 1, email: 'a@b.com',
        phone: '9876543210',
        fullName: 'Test User',
      );
      final json = user.toJson();
      expect(json['phone'], '9876543210');
      expect(json['full_name'], 'Test User');
    });

    test('excludes null optional fields', () {
      final user = UserModel(id: 1, email: 'a@b.com');
      final json = user.toJson();
      expect(json.containsKey('phone'), isFalse);
      expect(json.containsKey('full_name'), isFalse);
    });
  });

  // ── UserModel.copyWith ────────────────────────────────────────────────────
  group('UserModel.copyWith', () {
    test('copies unchanged fields', () {
      final original = UserModel(id: 1, email: 'orig@example.com',
        phone: '9876543210');
      final copy = original.copyWith(phone: '1234567890');
      expect(copy.id, 1);
      expect(copy.email, 'orig@example.com');
      expect(copy.phone, '1234567890');
    });

    test('does not mutate original', () {
      final original = UserModel(id: 1, email: 'a@b.com', phone: '111');
      original.copyWith(phone: '999');
      expect(original.phone, '111');
    });
  });

  // ── AuthResponse.fromJson ─────────────────────────────────────────────────
  group('AuthResponse.fromJson', () {
    final userJson = {'id': 1, 'email': 'auth@example.com'};

    test('parses nested tokens format', () {
      final json = {
        'tokens': {'access': 'acc_token', 'refresh': 'ref_token'},
        'user': userJson,
        'message': 'Login successful',
      };
      final response = AuthResponse.fromJson(json);
      expect(response.accessToken, 'acc_token');
      expect(response.refreshToken, 'ref_token');
      expect(response.user.email, 'auth@example.com');
      expect(response.message, 'Login successful');
    });

    test('parses flat token format', () {
      final json = {
        'access': 'flat_access',
        'refresh': 'flat_refresh',
        'user': userJson,
      };
      final response = AuthResponse.fromJson(json);
      expect(response.accessToken, 'flat_access');
      expect(response.refreshToken, 'flat_refresh');
    });

    test('parses access_token key variant', () {
      final json = {
        'access_token': 'token_variant',
        'user': userJson,
      };
      final response = AuthResponse.fromJson(json);
      expect(response.accessToken, 'token_variant');
    });
  });
}
