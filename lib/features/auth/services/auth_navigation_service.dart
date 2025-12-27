import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/auth/screens/otp_verification_page.dart';
import 'package:flutter_app/features/auth/screens/register_page.dart';
import 'package:flutter_app/features/auth/screens/sendOtp_page.dart';
import 'package:flutter_app/features/home/screens/home_page.dart';
import 'package:flutter_app/features/language/screens/choose_language_page.dart';

/// Service for handling auth-related navigation
class AuthNavigationService {
  /// Navigate to registration page
  static void toRegister(BuildContext context, {String? phoneNumber}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(phoneNumber: phoneNumber),
      ),
    );
  }

  /// Navigate to OTP verification page
  static void toOtpVerification(
    BuildContext context, {
    required String phoneNumber,
    bool isNewUser = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationPage(
          mobileNumber: phoneNumber,
          isNewUser: isNewUser,
        ),
      ),
    );
  }

  /// Navigate to send OTP page
  static void toSendOtp(
    BuildContext context, {
    bool isAfterRegistration = false,
    bool replace = false,
  }) {
    if (replace) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SendOtpPage(isAfterRegistration: isAfterRegistration),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SendOtpPage(isAfterRegistration: isAfterRegistration),
        ),
      );
    }
  }

  /// Navigate to home page (clear stack)
  static void toHome(BuildContext context, {UserModel? user}) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage(user: user)),
      (route) => false,
    );
  }

  /// Navigate to language selection
  static void toLanguageSelection(BuildContext context, {UserModel? user}) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ChooseLanguagePage(user: user)),
      (route) => false,
    );
  }
}

