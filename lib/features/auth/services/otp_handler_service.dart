import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/services/auth_service.dart';

/// Result of OTP operations
class OtpResult {
  final bool success;
  final String? otp;
  final String? userId;
  final String? errorMessage;
  final bool isUserNotFound;
  final UserModel? user;

  const OtpResult({
    required this.success,
    this.otp,
    this.userId,
    this.errorMessage,
    this.isUserNotFound = false,
    this.user,
  });

  factory OtpResult.success({String? otp, String? userId, UserModel? user}) {
    return OtpResult(success: true, otp: otp, userId: userId, user: user);
  }

  factory OtpResult.userNotFound() {
    return const OtpResult(
      success: false,
      isUserNotFound: true,
      errorMessage: 'Phone number not registered',
    );
  }

  factory OtpResult.error(String message) {
    return OtpResult(success: false, errorMessage: message);
  }
}

/// Service for handling OTP operations
class OtpHandlerService {
  final AuthService _authService;
  final BackendHelper _backendHelper;

  OtpHandlerService(this._authService, {BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Send OTP to phone number
  Future<OtpResult> sendOtp(String phoneNumber) async {
    try {
      final response = await _backendHelper.postSendLoginOtp({'phone': phoneNumber});
      
      // Handle both String and int types from API response
      final otp = response['otp']?.toString();
      final userId = response['user_id']?.toString();

      if (userId == null) {
        return OtpResult.userNotFound();
      }

      return OtpResult.success(otp: otp, userId: userId);
    } on BackendException catch (e) {
      // Handle user not found (404)
      if (e.isUserNotFound) {
        return OtpResult.userNotFound();
      }
      return OtpResult.error(e.message);
    } on NotFoundException {
      return OtpResult.userNotFound();
    } on NetworkException {
      return OtpResult.error('No internet connection. Please try again.');
    } on ApiException catch (e) {
      return OtpResult.error(e.message);
    } catch (e) {
      return OtpResult.error('Failed to send OTP. Please try again.');
    }
  }

  /// Verify OTP
  Future<OtpResult> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _backendHelper.postVerifyLoginOtp({
        'phone': phoneNumber,
        'otp': otp,
      });

      // Extract tokens and user from response
      final tokens = response['tokens'] as Map<String, dynamic>;
      final accessToken = tokens['access'] as String;
      final refreshToken = tokens['refresh'] as String?;

      // Set auth token for subsequent API calls
      _authService.setAuthToken(accessToken);
      APIClient().setAuthorization(accessToken);
      
      // Fetch fresh user data from /api/auth/me/ to get latest profile updates
      final userJson = await _backendHelper.getMe();
      final user = UserModel.fromJson(userJson);

      // Store user data and tokens in localStorage using CommonHelper
      final commonHelper = CommonHelper();
      await commonHelper.saveAuthData(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // Return success with fresh user data
      return OtpResult.success(user: user);
    } on BackendException catch (e) {
      // Handle unauthorized (invalid OTP)
      if (e.isUnauthorized) {
        return OtpResult.error('Invalid OTP. Please try again.');
      }
      return OtpResult.error(e.message);
    } on UnauthorizedException {
      return OtpResult.error('Invalid OTP. Please try again.');
    } on NetworkException {
      return OtpResult.error('No internet connection. Please try again.');
    } on ApiException catch (e) {
      return OtpResult.error(e.message);
    } catch (e) {
      return OtpResult.error('Verification failed. Please try again.');
    }
  }
}

