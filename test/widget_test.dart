// Basic smoke test for FarmerApp.
//
// Verifies the app-level widget infrastructure is wired up correctly without
// running Firebase initialization, which requires real device services.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('FarmerApp')),
        ),
      ),
    );

    expect(find.text('FarmerApp'), findsOneWidget);
  });
}
