// integration_test/app_test.dart
//
// Flutter Integration Tests — FarmerApp
// Run with: flutter test integration_test/app_test.dart --device-id=<device>
//
// These tests run ON a real device/emulator and have access to the full
// Flutter widget tree (unlike Maestro which uses accessibility APIs).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration — Startup', () {
    testWidgets('app initializes and renders root MaterialApp', (tester) async {
      app.main();
      // Give Firebase + EasyLocalization time to init
      await tester.pumpAndSettle(const Duration(seconds: 8));
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app does not show error widget on cold start', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // No ErrorWidget (red screen of death)
      expect(find.byType(ErrorWidget), findsNothing);
    });
  });
}
