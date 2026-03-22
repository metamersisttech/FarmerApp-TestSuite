// integration_test/app_test.dart
//
// Flutter Integration Tests — FarmerApp
// =======================================
// Run on device/emulator:
//   flutter test integration_test/app_test.dart --device-id=<id>
//
// These tests have full widget tree access unlike Maestro (accessibility API).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── Group 1: Startup ──────────────────────────────────────────────────────
  group('App Startup', () {
    testWidgets('renders root MaterialApp without crash', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('no ErrorWidget (red screen) on cold start', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('Scaffold is present after init', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  // ── Group 2: Navigation ───────────────────────────────────────────────────
  group('Navigation Infrastructure', () {
    testWidgets('Navigator is present in widget tree', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      expect(find.byType(Navigator), findsWidgets);
    });

    testWidgets('back button does not crash app', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      // Simulate back button press
      final dynamic widgetsBinding = tester.binding;
      await widgetsBinding.handlePopRoute();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  // ── Group 3: Theme ────────────────────────────────────────────────────────
  group('Theme & Localisation', () {
    testWidgets('light theme is applied', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      final MaterialApp materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(materialApp.themeMode, equals(ThemeMode.light));
    });
  });
}
