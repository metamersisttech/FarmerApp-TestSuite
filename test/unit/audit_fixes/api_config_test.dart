// test/unit/audit_fixes/api_config_test.dart
//
// Unit tests for lib/config/api_config.dart
// PR #43 — P0 Fix: Environment-based API configuration
//
// Run: flutter test test/unit/audit_fixes/api_config_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/config/api_config.dart';

void main() {
  // ── URL Constants ──────────────────────────────────────────────────────────
  group('ApiConfig URL constants', () {
    test('devBaseUrl points to Android emulator loopback', () {
      expect(ApiConfig.devBaseUrl, 'http://10.0.2.2:8000/api/');
    });

    test('devBaseUrlIOS points to localhost', () {
      expect(ApiConfig.devBaseUrlIOS, 'http://localhost:8000/api/');
    });

    test('stagingBaseUrl points to cloud server', () {
      expect(ApiConfig.stagingBaseUrl, 'http://34.72.231.118/api/');
    });

    test('prodBaseUrl uses HTTPS', () {
      expect(ApiConfig.prodBaseUrl, startsWith('https://'));
    });

    test('all URLs end with trailing slash', () {
      expect(ApiConfig.devBaseUrl, endsWith('/'));
      expect(ApiConfig.devBaseUrlIOS, endsWith('/'));
      expect(ApiConfig.stagingBaseUrl, endsWith('/'));
      expect(ApiConfig.prodBaseUrl, endsWith('/'));
    });

    test('all URLs include /api/ path', () {
      expect(ApiConfig.devBaseUrl, contains('/api/'));
      expect(ApiConfig.devBaseUrlIOS, contains('/api/'));
      expect(ApiConfig.stagingBaseUrl, contains('/api/'));
      expect(ApiConfig.prodBaseUrl, contains('/api/'));
    });
  });

  // ── Environment detection ─────────────────────────────────────────────────
  group('ApiConfig environment', () {
    test('env defaults to staging when no dart-define provided', () {
      // Without --dart-define=ENV=..., defaults to 'staging'
      expect(ApiConfig.env, equals('staging'));
    });

    test('baseUrl defaults to staging URL', () {
      // Default env is 'staging', so baseUrl should match stagingBaseUrl
      expect(ApiConfig.baseUrl, equals(ApiConfig.stagingBaseUrl));
    });

    test('isProduction is false by default (staging)', () {
      expect(ApiConfig.isProduction, isFalse);
    });
  });

  // ── Timeouts ──────────────────────────────────────────────────────────────
  group('ApiConfig timeouts', () {
    test('connectionTimeout is 30 seconds', () {
      expect(ApiConfig.connectionTimeout, 30000);
    });

    test('receiveTimeout is 30 seconds', () {
      expect(ApiConfig.receiveTimeout, 30000);
    });

    test('timeouts are positive', () {
      expect(ApiConfig.connectionTimeout, greaterThan(0));
      expect(ApiConfig.receiveTimeout, greaterThan(0));
    });
  });

  // ── API Version ───────────────────────────────────────────────────────────
  group('ApiConfig version', () {
    test('apiVersion is v1', () {
      expect(ApiConfig.apiVersion, 'v1');
    });
  });

  // ── baseUrl resolution logic ──────────────────────────────────────────────
  group('ApiConfig.baseUrl resolution', () {
    test('baseUrl returns a valid HTTP(S) URL', () {
      final url = ApiConfig.baseUrl;
      expect(url, anyOf(startsWith('http://'), startsWith('https://')));
    });

    test('baseUrl is not empty', () {
      expect(ApiConfig.baseUrl, isNotEmpty);
    });

    test('baseUrl ends with trailing slash', () {
      expect(ApiConfig.baseUrl, endsWith('/'));
    });
  });
}
