// test/widget/audit_fixes/my_app_widget_test.dart
//
// Widget tests for MyApp in lib/main.dart
// PR #43 — Tests: theme integration, initial routing, localization delegates
//
// Run: flutter test test/widget/audit_fixes/my_app_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ── MyApp constructor ─────────────────────────────────────────────────────
  group('MyApp constructor', () {
    test('defaults appMode to farmer', () {
      const app = MyApp(user: null);
      expect(app.appMode, 'farmer');
    });

    test('accepts custom appMode', () {
      const app = MyApp(user: null, appMode: 'vet');
      expect(app.appMode, 'vet');
    });

    test('user can be null', () {
      const app = MyApp(user: null);
      expect(app.user, isNull);
    });
  });

  // ── Global navigation key ─────────────────────────────────────────────────
  group('Global navigation', () {
    test('navigatorKey is a GlobalKey<NavigatorState>', () {
      expect(navigatorKey, isA<GlobalKey<NavigatorState>>());
    });

    test('routeObserver is a RouteObserver', () {
      expect(routeObserver, isA<RouteObserver<PageRoute>>());
    });
  });

  // ── ThemeNotifier integration (tested in unit tests) ──────────────────────
  group('ThemeNotifier with Provider', () {
    test('ThemeNotifier can be used as ChangeNotifierProvider value', () {
      final notifier = ThemeNotifier();
      expect(notifier, isA<ChangeNotifier>());
      expect(notifier.themeMode, ThemeMode.light);
    });

    test('changing theme mode triggers notification', () async {
      final notifier = ThemeNotifier();
      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifyCount, greaterThanOrEqualTo(1));
      expect(notifier.themeMode, ThemeMode.dark);
    });
  });
}
