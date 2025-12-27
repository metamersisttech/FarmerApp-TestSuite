import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/screens/otp_verification_page.dart';
import 'package:flutter_app/features/auth/screens/register_page.dart';
import 'package:flutter_app/features/auth/screens/sendOtp_page.dart';
import 'package:flutter_app/features/home/screens/home_page.dart';
import 'package:flutter_app/features/welcome/screens/welcome_page.dart';

/// App Routes
///
/// Centralized navigation configuration.
/// Usage:
///   Navigator.pushNamed(context, AppRoutes.login);
///   Navigator.pushNamed(context, AppRoutes.home);

class AppRoutes {
  // ============ Route Names ============
  static const String welcome = '/';
  static const String signup = '/signup'; // Alias for SendOtpPage (phone entry)
  static const String phoneLogin = '/phone-login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // ============ Route Generator ============
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return _buildRoute(const WelcomePage(), settings);

      case signup:
        return _buildRoute(const SendOtpPage(), settings);

      case phoneLogin:
        // Alias for signup - both go to SendOtpPage
        return _buildRoute(const SendOtpPage(), settings);

      case register:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          RegisterPage(phoneNumber: args?['phoneNumber']),
          settings,
        );

      case otpVerification:
        // Extract phone number from arguments
        final args = settings.arguments;
        if (args is String) {
          return _buildRoute(
            OtpVerificationPage(mobileNumber: args),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Phone number required for OTP verification')),
          ),
          settings,
        );

      case home:
        return _buildRoute(const HomePage(), settings);

      // Add more routes as needed
      // case profile:
      //   return _buildRoute(const ProfilePage(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  /// Build a MaterialPageRoute with given widget
  static MaterialPageRoute _buildRoute(Widget widget, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => widget, settings: settings);
  }

  // ============ Navigation Helpers ============

  /// Navigate to a route and remove all previous routes
  static void navigateAndRemoveAll(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  /// Navigate to a route and replace current route
  static void navigateAndReplace(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  /// Navigate to a route
  static void navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// Go back to previous route
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// Go back to previous route with result
  static void goBackWithResult<T>(BuildContext context, T result) {
    Navigator.pop(context, result);
  }
}
