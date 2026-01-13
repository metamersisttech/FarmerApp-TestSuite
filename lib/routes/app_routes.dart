import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/auth/screens/email_login_page.dart';
import 'package:flutter_app/features/auth/screens/otp_verification_page.dart';
import 'package:flutter_app/features/auth/screens/register_page.dart';
import 'package:flutter_app/features/auth/screens/sendOtp_page.dart';
import 'package:flutter_app/features/editprofile/screens/edit_profile_page.dart';
import 'package:flutter_app/features/forgotPassword/screens/forgot_password_page.dart';
import 'package:flutter_app/features/home/screens/animal_detail_page.dart';
import 'package:flutter_app/features/home/screens/home_page.dart';
import 'package:flutter_app/features/profile/screens/profile_page.dart';
import 'package:flutter_app/features/resetPassword/screens/reset_password_page.dart';
import 'package:flutter_app/features/sell/screens/create_farm_page.dart';

/// App Routes
///
/// Centralized navigation configuration.
/// Usage:
///   Navigator.pushNamed(context, AppRoutes.login);
///   Navigator.pushNamed(context, AppRoutes.home);

class AppRoutes {
  // ============ Route Names ============
  static const String login = '/'; // Login is now the initial route
  static const String signup = '/signup'; // Alias for login
  // static const String phoneLogin = '/phone-login'; // Alias for login
  static const String welcome = '/';
  static const String phoneLogin = '/phone-login';
  static const String emailLogin = '/email-login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String createFarm = '/create-farm';
  static const String animalDetail = '/animal-detail';

  // ============ Route Generator ============
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
      case signup:
      case phoneLogin:
        // All these routes go to SendOtpPage (Login screen)
        return _buildRoute(const SendOtpPage(), settings);

      case emailLogin:
        return _buildRoute(const EmailLoginPage(), settings);

      case forgotPassword:
        return _buildRoute(const ForgotPasswordPage(), settings);

      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ResetPasswordPage(token: args?['token'] as String?),
          settings,
        );

      case register:
        return _buildRoute(const RegisterPage(), settings);

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
        // Get user from arguments if passed
        final args = settings.arguments;
        UserModel? user;
        if (args is Map<String, dynamic>) {
          user = args['user'] as UserModel?;
        }
        return _buildRoute(HomePage(user: user), settings);

      case profile:
        return _buildRoute(const ProfilePage(), settings);

      case editProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          EditProfilePage(
            initialFullName: args?['fullName'],
            initialDisplayName: args?['displayName'],
            initialDob: args?['dob'],
            initialAddress: args?['address'],
            initialState: args?['state'],
            initialDistrict: args?['district'],
            initialVillage: args?['village'],
            initialPincode: args?['pincode'],
            initialLatitude: args?['latitude'],
            initialLongitude: args?['longitude'],
            initialAbout: args?['about'],
            initialProfileImageUrl: args?['profileImageUrl'],
          ),
          settings,
        );

      case createFarm:
        return _buildRoute(const CreateFarmPage(), settings);

      case animalDetail:
        final listingId = settings.arguments as int?;
        if (listingId != null) {
          return _buildRoute(
            AnimalDetailPage(listingId: listingId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Listing ID required for animal detail')),
          ),
          settings,
        );

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
  static void navigateAndRemoveAll(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate to a route and replace current route
  static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
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
