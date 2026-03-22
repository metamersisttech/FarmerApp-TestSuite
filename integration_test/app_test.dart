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

    testWidgets('supportedLocales includes English', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      final MaterialApp materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      final locales = materialApp.supportedLocales;
      expect(locales, contains(const Locale('en')));
    });
  });

  // ── Group 4: Accessibility ────────────────────────────────────────────────
  group('Accessibility', () {
    testWidgets('no unbounded widget overflow on startup', (tester) async {
      final errors = <String>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('overflow') ||
            details.toString().contains('RenderFlex')) {
          errors.add(details.toString());
        }
        originalOnError?.call(details);
      };
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      FlutterError.onError = originalOnError;
      expect(errors, isEmpty, reason: 'Layout overflow detected on startup');
    });

    testWidgets('text widgets are not empty on language screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      // At minimum the language selection screen should have visible text
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsWidgets);
      // At least one Text widget should have non-empty content
      final texts = tester
          .widgetList<Text>(textWidgets)
          .where((t) => (t.data ?? '').isNotEmpty)
          .toList();
      expect(texts, isNotEmpty);
    });
  });

  // ── Group 5: Form Validation ──────────────────────────────────────────────
  group('Form Validation', () {
    testWidgets('TextField accepts input without crash', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      // Find first visible text field (phone input on login screen)
      final textFields = find.byType(TextField);
      if (tester.any(textFields)) {
        await tester.enterText(textFields.first, '9876543210');
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.byType(ErrorWidget), findsNothing);
      }
    });

    testWidgets('empty form submission shows validation, not crash', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      // Look for any ElevatedButton or TextButton to tap
      final buttons = find.byType(ElevatedButton);
      if (tester.any(buttons)) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(find.byType(ErrorWidget), findsNothing);
      }
    });
  });

  // ── Group 6: Scroll & List Integrity ─────────────────────────────────────
  group('Scroll & List', () {
    testWidgets('ListView does not throw on scroll', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      final listViews = find.byType(ListView);
      if (tester.any(listViews)) {
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.byType(ErrorWidget), findsNothing);
      }
    });

    testWidgets('SingleChildScrollView does not overflow', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      final scrollViews = find.byType(SingleChildScrollView);
      if (tester.any(scrollViews)) {
        await tester.drag(scrollViews.first, const Offset(0, -200));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.byType(ErrorWidget), findsNothing);
      }
    });
  });
}
