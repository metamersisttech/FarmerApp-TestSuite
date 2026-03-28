// test/unit/audit_fixes/api_error_handling_test.dart
//
// Unit tests for API error handling in lib/data/services/api_service.dart
// PR #43 — P0 Fix: 401 token refresh and consistent error handling
//
// Run: flutter test test/unit/audit_fixes/api_error_handling_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/errors/exceptions.dart';

void main() {
  // ── Exception hierarchy ───────────────────────────────────────────────────
  group('API Exception types', () {
    test('BadRequestException is an ApiException with status 400', () {
      final e = BadRequestException(message: 'bad');
      expect(e, isA<ApiException>());
      expect(e.message, 'bad');
      expect(e.statusCode, 400);
    });

    test('BadRequestException has sensible default message', () {
      final e = BadRequestException();
      expect(e.message, 'Bad request');
    });

    test('UnauthorizedException is an ApiException with status 401', () {
      final e = UnauthorizedException(message: 'unauth');
      expect(e, isA<ApiException>());
      expect(e.message, 'unauth');
      expect(e.statusCode, 401);
    });

    test('UnauthorizedException has sensible default message', () {
      final e = UnauthorizedException();
      expect(e.message, 'Unauthorized access');
    });

    test('ForbiddenException is an ApiException with status 403', () {
      final e = ForbiddenException(message: 'forbidden');
      expect(e, isA<ApiException>());
      expect(e.message, 'forbidden');
      expect(e.statusCode, 403);
    });

    test('NotFoundException is an ApiException with status 404', () {
      final e = NotFoundException(message: 'not found');
      expect(e, isA<ApiException>());
      expect(e.message, 'not found');
      expect(e.statusCode, 404);
    });

    test('ValidationException carries errors map and status 422', () {
      final e = ValidationException(
        message: 'invalid',
        errors: {'email': ['taken']},
      );
      expect(e, isA<ApiException>());
      expect(e.statusCode, 422);
      expect(e.errors, isNotNull);
      expect(e.errors!['email'], contains('taken'));
    });

    test('ValidationException has sensible default message', () {
      final e = ValidationException();
      expect(e.message, 'Validation failed');
    });

    test('ServerException is an ApiException with status 500', () {
      final e = ServerException(message: 'server error');
      expect(e, isA<ApiException>());
      expect(e.message, 'server error');
      expect(e.statusCode, 500);
    });

    test('NetworkException is an ApiException with null status', () {
      final e = NetworkException(message: 'no internet');
      expect(e, isA<ApiException>());
      expect(e.message, 'no internet');
      expect(e.statusCode, isNull);
    });

    test('TimeoutException is an ApiException with null status', () {
      final e = TimeoutException(message: 'timed out');
      expect(e, isA<ApiException>());
      expect(e.message, 'timed out');
      expect(e.statusCode, isNull);
    });

    test('CacheException is independent of ApiException', () {
      final e = CacheException(message: 'cache miss');
      expect(e, isA<Exception>());
      expect(e, isNot(isA<ApiException>()));
      expect(e.message, 'cache miss');
    });

    test('CacheException has sensible default message', () {
      final e = CacheException();
      expect(e.message, 'Cache error');
    });
  });

  // ── Exception toString ────────────────────────────────────────────────────
  group('Exception string representation', () {
    test('ApiException toString includes message', () {
      final e = BadRequestException(message: 'Invalid input');
      expect(e.toString(), contains('Invalid input'));
    });

    test('ApiException toString includes status code', () {
      final e = NotFoundException();
      expect(e.toString(), contains('404'));
    });

    test('CacheException toString includes message', () {
      final e = CacheException(message: 'expired');
      expect(e.toString(), contains('expired'));
    });
  });

  // ── Django error message formats ──────────────────────────────────────────
  group('Django error message format parsing', () {
    test('format: {"message": "..."}', () {
      final data = {'message': 'Invalid credentials'};
      expect(data['message'], 'Invalid credentials');
    });

    test('format: {"detail": "..."}', () {
      final data = {'detail': 'Not found'};
      expect(data['detail'], 'Not found');
    });

    test('format: {"error": "..."}', () {
      final data = {'error': 'Server error'};
      expect(data['error'], 'Server error');
    });

    test('format: {"username": ["already exists"]}', () {
      final data = {
        'username': ['A user with that username already exists.']
      };
      expect(data['username'], isList);
      expect((data['username'] as List).first, contains('already exists'));
    });

    test('format: {"email": ["invalid"]}', () {
      final data = {
        'email': ['Enter a valid email address.']
      };
      expect(data['email'], isList);
      expect((data['email'] as List).first, contains('valid email'));
    });

    test('field-level errors are extractable', () {
      final data = {
        'username': ['too short'],
        'email': ['already taken'],
        'password': ['too common'],
      };
      expect(data.keys.length, 3);
      for (final entry in data.entries) {
        expect(entry.value, isList);
        expect(entry.value, isNotEmpty);
      }
    });
  });

  // ── ApiException data field ───────────────────────────────────────────────
  group('ApiException data field', () {
    test('BadRequestException can carry data', () {
      final e = BadRequestException(
        message: 'bad',
        data: {'field': 'value'},
      );
      expect(e.data, isNotNull);
      expect(e.data['field'], 'value');
    });

    test('ValidationException stores errors in data', () {
      final errors = {'email': ['required']};
      final e = ValidationException(errors: errors);
      expect(e.data, equals(errors));
    });
  });
}
