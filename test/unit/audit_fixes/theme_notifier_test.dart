// test/unit/audit_fixes/theme_notifier_test.dart
//
// Unit tests for ThemeNotifier in lib/main.dart
// PR #43 — P2 Fix: Dark mode with persistence
//
// Run: flutter test test/unit/audit_fixes/theme_notifier_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/main.dart';

void main() {
  // ── Setup ─────────────────────────────────────────────────────────────────
  setUp(() {
    // Initialize SharedPreferences with empty values for each test
    SharedPreferences.setMockInitialValues({});
  });

  // ── Initial state ─────────────────────────────────────────────────────────
  group('ThemeNotifier initial state', () {
    test('defaults to ThemeMode.light', () {
      final notifier = ThemeNotifier();
      expect(notifier.themeMode, ThemeMode.light);
    });

    test('loads saved theme from SharedPreferences on creation', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final notifier = ThemeNotifier();

      // Wait for async _load() to complete
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier.themeMode, ThemeMode.dark);
    });

    test('loads system theme from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'system'});
      final notifier = ThemeNotifier();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier.themeMode, ThemeMode.system);
    });

    test('falls back to light for unknown stored value', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'garbage'});
      final notifier = ThemeNotifier();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier.themeMode, ThemeMode.light);
    });
  });

  // ── setThemeMode ──────────────────────────────────────────────────────────
  group('ThemeNotifier.setThemeMode', () {
    test('updates themeMode to dark', () async {
      final notifier = ThemeNotifier();
      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.themeMode, ThemeMode.dark);
    });

    test('updates themeMode to system', () async {
      final notifier = ThemeNotifier();
      await notifier.setThemeMode(ThemeMode.system);
      expect(notifier.themeMode, ThemeMode.system);
    });

    test('updates themeMode to light', () async {
      final notifier = ThemeNotifier();
      await notifier.setThemeMode(ThemeMode.dark);
      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.themeMode, ThemeMode.light);
    });

    test('notifies listeners on change', () async {
      final notifier = ThemeNotifier();
      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      await notifier.setThemeMode(ThemeMode.dark);
      // _load() also notifies, so notifyCount >= 1 from setThemeMode
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('persists to SharedPreferences', () async {
      final notifier = ThemeNotifier();
      await notifier.setThemeMode(ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('persists system mode to SharedPreferences', () async {
      final notifier = ThemeNotifier();
      await notifier.setThemeMode(ThemeMode.system);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'system');
    });

    test('persists light mode to SharedPreferences', () async {
      final notifier = ThemeNotifier();
      await notifier.setThemeMode(ThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'light');
    });
  });

  // ── toggleTheme ───────────────────────────────────────────────────────────
  group('ThemeNotifier.toggleTheme', () {
    test('cycles light -> dark', () async {
      final notifier = ThemeNotifier();
      // Starts as light
      notifier.toggleTheme();
      // Allow async setThemeMode to complete
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.themeMode, ThemeMode.dark);
    });

    test('cycles dark -> system', () async {
      final notifier = ThemeNotifier();
      await notifier.setThemeMode(ThemeMode.dark);
      notifier.toggleTheme();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.themeMode, ThemeMode.system);
    });

    test('cycles system -> light', () async {
      final notifier = ThemeNotifier();
      await notifier.setThemeMode(ThemeMode.system);
      notifier.toggleTheme();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.themeMode, ThemeMode.light);
    });

    test('full cycle: light -> dark -> system -> light', () async {
      final notifier = ThemeNotifier();
      expect(notifier.themeMode, ThemeMode.light);

      notifier.toggleTheme();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.themeMode, ThemeMode.dark);

      notifier.toggleTheme();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.themeMode, ThemeMode.system);

      notifier.toggleTheme();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.themeMode, ThemeMode.light);
    });
  });

  // ── ChangeNotifier contract ───────────────────────────────────────────────
  group('ThemeNotifier ChangeNotifier contract', () {
    test('extends ChangeNotifier', () {
      final notifier = ThemeNotifier();
      expect(notifier, isA<ChangeNotifier>());
    });

    test('can add and remove listeners', () {
      final notifier = ThemeNotifier();
      void listener() {}
      notifier.addListener(listener);
      notifier.removeListener(listener);
      // No exception means success
    });
  });
}
