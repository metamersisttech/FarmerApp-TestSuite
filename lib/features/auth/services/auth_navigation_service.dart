import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/auth/screens/otp_verification_page.dart';
import 'package:flutter_app/features/auth/screens/sendOtp_page.dart';
import 'package:flutter_app/features/home/screens/home_page.dart';

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
  static void toHome(BuildContext context, {UserModel? user}) async {
    // If no user passed, try to get from CommonHelper
    UserModel? userToPass = user;
    if (userToPass == null) {
      final commonHelper = CommonHelper();
      userToPass = await commonHelper.getLoggedInUser();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage(user: userToPass)),
      (route) => false,
    );
  }
}
