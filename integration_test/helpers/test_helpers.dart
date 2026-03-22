// integration_test/helpers/test_helpers.dart
// Shared utilities for Flutter integration tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps frames until [text] is visible or [timeout] elapses.
Future<void> waitForText(
  WidgetTester tester,
  String text, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (find.text(text).evaluate().isNotEmpty) return;
  }
  throw TestFailure('Text "$text" not found within $timeout');
}

/// Pumps until no CircularProgressIndicator is visible.
Future<void> waitForLoadingToFinish(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
}
