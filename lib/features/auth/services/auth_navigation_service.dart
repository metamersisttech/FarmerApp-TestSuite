import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/auth/screens/otp_verification_page.dart';
import 'package:flutter_app/features/auth/screens/register_page.dart';
import 'package:flutter_app/features/auth/screens/sendOtp_page.dart';
import 'package:flutter_app/features/vet_dashboard/screens/vet_home_page.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Service for handling auth-related navigation
class AuthNavigationService {
  /// Navigate to OTP verification page
  static void toOtpVerification(
    BuildContext context, {
    required String phoneNumber,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationPage(
          mobileNumber: phoneNumber,
        ),
      ),
    );
  }

  /// Navigate to login page (SendOtpPage)
  static void toLogin(BuildContext context, {bool replace = false}) async {
    // Clear user data
    final commonHelper = CommonHelper();
    await commonHelper.clearUser();

    // Clear API auth
    APIClient().clearAuthorization();

    if (replace) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SendOtpPage(),
        ),
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SendOtpPage()),
        (route) => false,
      );
    }
  }

  /// Navigate to send OTP page (alias for backwards compatibility)
  /// Note: isAfterRegistration is deprecated and ignored
  static void toSendOtp(
    BuildContext context, {
    bool isAfterRegistration = false, // Deprecated, ignored
    bool replace = false,
  }) {
    if (replace) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SendOtpPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SendOtpPage()),
      );
    }
  }

  /// Navigate to home page (clear stack)
  /// Checks stored app mode to route to farmer or vet dashboard.
  static void toHome(BuildContext context, {UserModel? user}) async {
    // If no user passed, try to get from CommonHelper
    final commonHelper = CommonHelper();
    UserModel? userToPass = user;
    userToPass ??= await commonHelper.getLoggedInUser();

    // Check if user was in vet mode
    final mode = await commonHelper.getAppMode();

    if (mode == 'vet') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const VetHomePage()),
        (route) => false,
      );
    } else {
      // Use named route to navigate to MainShellPage with bottom nav
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
        arguments: {'user': userToPass},
      );
    }
  }

  /// Navigate to register page
  static void toRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }
}
