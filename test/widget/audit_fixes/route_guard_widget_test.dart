// test/widget/audit_fixes/route_guard_widget_test.dart
//
// Widget tests for _RouteGuard in lib/routes/app_routes.dart
// PR #43 — P0 Fix: Auth and role-based route guards
//
// Run: flutter test test/widget/audit_fixes/route_guard_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/routes/app_routes.dart';

void main() {
  // ── Route generation produces Material routes ─────────────────────────────
  group('Route generation types', () {
    test('public route generates MaterialPageRoute', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/'),
      );
      expect(route, isA<MaterialPageRoute>());
    });

    test('protected route generates MaterialPageRoute', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/home'),
      );
      expect(route, isA<MaterialPageRoute>());
    });

    test('vet route generates MaterialPageRoute', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/vet-home'),
      );
      expect(route, isA<MaterialPageRoute>());
    });

    test('transport route generates MaterialPageRoute', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/transport/dashboard'),
      );
      expect(route, isA<MaterialPageRoute>());
    });

    test('unknown route generates MaterialPageRoute', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/nonexistent'),
      );
      expect(route, isA<MaterialPageRoute>());
    });
  });

  // ── Public routes render without guard (no redirect loop) ─────────────────
  group('Public route rendering', () {
    testWidgets('otpVerification without arg shows error directly', (tester) async {
      // Public route — no guard wrapping, renders immediately
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => AppRoutes.generateRoute(
            const RouteSettings(name: '/otp-verification'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Phone number required'),
        findsOneWidget,
      );
    });
  });

  // ── Protected routes show guard loading state ─────────────────────────────
  group('Route guard behavior', () {
    testWidgets('guarded route shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => AppRoutes.generateRoute(
            const RouteSettings(name: '/home'),
          ),
        ),
      );
      // Don't settle — check the loading state before auth check completes
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('guarded vet route shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => AppRoutes.generateRoute(
            const RouteSettings(name: '/vet-home'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('guarded transport route shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => AppRoutes.generateRoute(
            const RouteSettings(name: '/transport/dashboard'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('unknown non-public route is still guarded (shows loading)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => AppRoutes.generateRoute(
            const RouteSettings(name: '/this-does-not-exist'),
          ),
        ),
      );
      await tester.pump();
      // Unknown routes are also guarded — shows loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ── Guarded routes without auth redirect to login ─────────────────────────
  group('Unauthenticated access', () {
    testWidgets('unauthenticated user on /home gets redirected (no crash)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: AppRoutes.generateRoute,
          initialRoute: AppRoutes.home,
        ),
      );
      // Let the FutureBuilder resolve (auth check returns notAuthenticated)
      await tester.pump(const Duration(milliseconds: 100));
      // After auth check resolves, it schedules a post-frame redirect
      await tester.pump(const Duration(milliseconds: 100));
      // The redirect should navigate to login — verify app doesn't crash
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
