import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/data/services/token_storage_service.dart';

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

  OtpHandlerService(this._authService);

  /// Send OTP to phone number
  Future<OtpResult> sendOtp(String phoneNumber) async {
    try {
      final response = await _authService.sendLoginOtp(phone: phoneNumber);
      
      // Handle both String and int types from API response
      final otp = response['otp']?.toString();
      final userId = response['user_id']?.toString();

      if (userId == null) {
        return OtpResult.userNotFound();
      }

      return OtpResult.success(otp: otp, userId: userId);
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
      final authResponse = await _authService.verifyLoginOtp(
        phone: phoneNumber,
        otp: otp,
      );
      
      // Store tokens securely
      final tokenStorage = TokenStorageService();
      await tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken ?? '',
      );
      
      // Set auth token for subsequent API calls
      _authService.setAuthToken(authResponse.accessToken);
      
      // Return success with user data from the response
      return OtpResult.success(user: authResponse.user);
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

