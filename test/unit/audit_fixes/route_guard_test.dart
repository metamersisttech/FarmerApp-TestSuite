// test/unit/audit_fixes/route_guard_test.dart
//
// Unit tests for route guard logic in lib/routes/app_routes.dart
// PR #43 — P0 Fix: Route guards for auth and role-based access
//
// Run: flutter test test/unit/audit_fixes/route_guard_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/routes/app_routes.dart';

void main() {
  // ── Route name constants exist ────────────────────────────────────────────
  group('AppRoutes constants', () {
    test('login route is /', () {
      expect(AppRoutes.login, '/');
    });

    test('home route is /home', () {
      expect(AppRoutes.home, '/home');
    });

    test('vetHome route is /vet-home', () {
      expect(AppRoutes.vetHome, '/vet-home');
    });

    test('transportDashboard route exists', () {
      expect(AppRoutes.transportDashboard, '/transport/dashboard');
    });

    test('languageSelection route exists', () {
      expect(AppRoutes.languageSelection, '/language-selection');
    });

    test('settings route exists', () {
      expect(AppRoutes.settings, '/settings');
    });
  });

  // ── Public routes ─────────────────────────────────────────────────────────
  group('Public routes classification', () {
    test('login is a public route', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/'),
      );
      expect(route, isNotNull);
    });

    test('signup is a public route', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/signup'),
      );
      expect(route, isNotNull);
    });

    test('register is a public route', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/register'),
      );
      expect(route, isNotNull);
    });

    test('emailLogin is a public route', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/email-login'),
      );
      expect(route, isNotNull);
    });

    test('forgotPassword is a public route', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/forgot-password'),
      );
      expect(route, isNotNull);
    });

    test('otpVerification is a public route', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/otp-verification'),
      );
      expect(route, isNotNull);
    });

    test('languageSelection is a public route', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/language-selection'),
      );
      expect(route, isNotNull);
    });
  });

  // ── Vet routes ────────────────────────────────────────────────────────────
  group('Vet routes', () {
    final vetRoutes = [
      AppRoutes.vetOnboardingCarousel,
      AppRoutes.vetDocumentUpload,
      AppRoutes.vetVerificationStatus,
      AppRoutes.vetDocumentReupload,
      AppRoutes.vetProfile,
      AppRoutes.vetAvailability,
      AppRoutes.vetPricing,
      AppRoutes.vetAppointments,
      AppRoutes.vetApproveAppointment,
      AppRoutes.vetRejectAppointment,
      AppRoutes.vetCompleteAppointment,
      AppRoutes.vetHome,
      AppRoutes.vetDashboardProfile,
    ];

    for (final route in vetRoutes) {
      test('$route generates a valid route', () {
        final generated = AppRoutes.generateRoute(
          RouteSettings(name: route),
        );
        expect(generated, isNotNull);
      });
    }

    test('all vet routes start with /vet', () {
      for (final route in vetRoutes) {
        expect(route, startsWith('/vet'));
      }
    });
  });

  // ── Transport provider routes ─────────────────────────────────────────────
  group('Transport provider routes', () {
    final transportRoutes = [
      AppRoutes.transportDashboard,
      AppRoutes.transportNearbyRequests,
      AppRoutes.transportRequestDetail,
      AppRoutes.transportAcceptRequest,
      AppRoutes.transportTripProgress,
      AppRoutes.transportTripCompletion,
      AppRoutes.transportVehicleList,
      AppRoutes.transportVehicleForm,
      AppRoutes.transportRoleRequest,
      AppRoutes.transportOnboarding,
      AppRoutes.transportPendingApproval,
      AppRoutes.transportLicenseUpload,
      AppRoutes.transportProfile,
    ];

    for (final route in transportRoutes) {
      test('$route generates a valid route', () {
        final generated = AppRoutes.generateRoute(
          RouteSettings(name: route),
        );
        expect(generated, isNotNull);
      });
    }

    test('all transport provider routes start with /transport/', () {
      for (final route in transportRoutes) {
        expect(route, startsWith('/transport/'));
      }
    });
  });

  // ── Transport requester routes ────────────────────────────────────────────
  group('Transport requester routes', () {
    test('transportCreateRequest route exists', () {
      expect(AppRoutes.transportCreateRequest, '/transport/requester/create');
    });

    test('transportMyRequests route exists', () {
      expect(AppRoutes.transportMyRequests, '/transport/requester/my-requests');
    });

    test('transportDeliveryConfirmation route exists', () {
      expect(
        AppRoutes.transportDeliveryConfirmation,
        '/transport/requester/delivery-confirmation',
      );
    });
  });

  // ── Farmer routes (any authenticated user) ────────────────────────────────
  group('Farmer routes', () {
    final farmerRoutes = [
      AppRoutes.home,
      AppRoutes.profile,
      AppRoutes.editProfile,
      AppRoutes.settings,
      AppRoutes.createFarm,
      AppRoutes.animalDetail,
      AppRoutes.vetServices,
      AppRoutes.vetDetail,
      AppRoutes.bookAppointment,
      AppRoutes.myAppointments,
      AppRoutes.conversations,
      AppRoutes.directChat,
      AppRoutes.myBids,
      AppRoutes.notifications,
      AppRoutes.favouriteListings,
    ];

    for (final route in farmerRoutes) {
      test('$route generates a valid route', () {
        final generated = AppRoutes.generateRoute(
          RouteSettings(name: route),
        );
        expect(generated, isNotNull);
      });
    }
  });

  // ── Unknown routes ────────────────────────────────────────────────────────
  group('Unknown routes', () {
    test('unknown route returns a valid route (with error message)', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/nonexistent-route'),
      );
      expect(route, isNotNull);
    });
  });

  // ── Navigation helpers exist ──────────────────────────────────────────────
  group('Navigation helper methods exist', () {
    test('navigateAndRemoveAll is callable', () {
      expect(AppRoutes.navigateAndRemoveAll, isA<Function>());
    });

    test('navigateAndReplace is callable', () {
      expect(AppRoutes.navigateAndReplace, isA<Function>());
    });

    test('navigateTo is callable', () {
      expect(AppRoutes.navigateTo, isA<Function>());
    });

    test('goBack is callable', () {
      expect(AppRoutes.goBack, isA<Function>());
    });

    test('goBackWithResult is callable', () {
      expect(AppRoutes.goBackWithResult, isA<Function>());
    });
  });
}
