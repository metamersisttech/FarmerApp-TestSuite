// test/unit/base_controller_test.dart
//
// Unit tests for lib/core/base/base_controller.dart
// Run: flutter test test/unit/base_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/base/base_controller.dart';

/// Concrete subclass for testing
class _TestController extends BaseController {}

void main() {
  late _TestController controller;

  setUp(() {
    controller = _TestController();
  });

  tearDown(() {
    if (!controller.isDisposed) controller.dispose();
  });

  // ── Initial state ─────────────────────────────────────────────────────────
  group('Initial state', () {
    test('isLoading defaults to false', () {
      expect(controller.isLoading, isFalse);
    });

    test('errorMessage defaults to null', () {
      expect(controller.errorMessage, isNull);
    });

    test('isDisposed defaults to false', () {
      expect(controller.isDisposed, isFalse);
    });
  });

  // ── setLoading ────────────────────────────────────────────────────────────
  group('setLoading', () {
    test('updates isLoading to true', () {
      controller.setLoading(true);
      expect(controller.isLoading, isTrue);
    });

    test('updates isLoading back to false', () {
      controller.setLoading(true);
      controller.setLoading(false);
      expect(controller.isLoading, isFalse);
    });

    test('notifies listeners on change', () {
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);
      controller.setLoading(true);
      expect(notifyCount, 1);
    });

    test('does nothing when disposed', () {
      controller.dispose();
      // Should not throw
      controller.setLoading(true);
      expect(controller.isLoading, isFalse);
    });
  });

  // ── setError / clearError ─────────────────────────────────────────────────
  group('setError / clearError', () {
    test('setError stores message', () {
      controller.setError('Something went wrong');
      expect(controller.errorMessage, 'Something went wrong');
    });

    test('clearError removes message', () {
      controller.setError('Error');
      controller.clearError();
      expect(controller.errorMessage, isNull);
    });

    test('setError notifies listeners', () {
      int count = 0;
      controller.addListener(() => count++);
      controller.setError('err');
      expect(count, 1);
    });

    test('does nothing when disposed', () {
      controller.dispose();
      controller.setError('late error');
      expect(controller.errorMessage, isNull);
    });
  });

  // ── executeAsync ──────────────────────────────────────────────────────────
  group('executeAsync', () {
    test('sets loading true while running, false after', () async {
      final loadingStates = <bool>[];
      controller.addListener(() => loadingStates.add(controller.isLoading));

      await controller.executeAsync(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'done';
      });

      expect(loadingStates, containsAllInOrder([true, false]));
    });

    test('returns operation result', () async {
      final result = await controller.executeAsync(() async => 42);
      expect(result, 42);
    });

    test('returns null and sets error on exception', () async {
      final result = await controller.executeAsync<int>(
        () async => throw Exception('oops'),
        errorMessage: 'Custom error',
      );
      expect(result, isNull);
      expect(controller.errorMessage, 'Custom error');
    });

    test('clears previous error before running', () async {
      controller.setError('old error');
      await controller.executeAsync(() async => 'ok');
      expect(controller.errorMessage, isNull);
    });

    test('returns null when disposed', () async {
      controller.dispose();
      final result = await controller.executeAsync(() async => 'value');
      expect(result, isNull);
    });
  });

  // ── dispose ───────────────────────────────────────────────────────────────
  group('dispose', () {
    test('sets isDisposed to true', () {
      controller.dispose();
      expect(controller.isDisposed, isTrue);
    });
  });
}
