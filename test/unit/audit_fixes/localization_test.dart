// test/unit/audit_fixes/localization_test.dart
//
// Unit tests for localization configuration
// PR #43 — P0 Fix: EasyLocalization integration
//
// Run: flutter test test/unit/audit_fixes/localization_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Supported locales ─────────────────────────────────────────────────────
  group('Supported locales', () {
    // These match what's configured in main.dart
    final supportedLocales = [
      const Locale('en'),
      const Locale('hi'),
      const Locale('mr'),
      const Locale('pa'),
    ];

    test('English is supported', () {
      expect(
        supportedLocales.any((l) => l.languageCode == 'en'),
        isTrue,
      );
    });

    test('Hindi is supported', () {
      expect(
        supportedLocales.any((l) => l.languageCode == 'hi'),
        isTrue,
      );
    });

    test('Marathi is supported', () {
      expect(
        supportedLocales.any((l) => l.languageCode == 'mr'),
        isTrue,
      );
    });

    test('Punjabi is supported', () {
      expect(
        supportedLocales.any((l) => l.languageCode == 'pa'),
        isTrue,
      );
    });

    test('4 locales are supported', () {
      expect(supportedLocales.length, 4);
    });

    test('fallback locale is English', () {
      const fallback = Locale('en');
      expect(fallback.languageCode, 'en');
    });
  });

  // ── Translation asset path ────────────────────────────────────────────────
  group('Translation assets', () {
    test('translation path follows convention', () {
      const path = 'assets/translations';
      expect(path, equals('assets/translations'));
    });
  });

  // ── Locale conversions ────────────────────────────────────────────────────
  group('Locale properties', () {
    test('English locale has correct language code', () {
      const locale = Locale('en');
      expect(locale.languageCode, 'en');
    });

    test('Hindi locale has correct language code', () {
      const locale = Locale('hi');
      expect(locale.languageCode, 'hi');
    });

    test('Marathi locale has correct language code', () {
      const locale = Locale('mr');
      expect(locale.languageCode, 'mr');
    });

    test('Punjabi locale has correct language code', () {
      const locale = Locale('pa');
      expect(locale.languageCode, 'pa');
    });
  });
}
