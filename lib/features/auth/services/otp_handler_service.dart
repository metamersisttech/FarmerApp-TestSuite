import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/data/services/auth_service.dart';

/// Result of OTP operations
class OtpResult {
  final bool success;
  final String? otp;
  final String? userId;
  final String? errorMessage;
  final bool isUserNotFound;

  const OtpResult({
    required this.success,
    this.otp,
    this.userId,
    this.errorMessage,
    this.isUserNotFound = false,
  });

  factory OtpResult.success({String? otp, String? userId}) {
    return OtpResult(success: true, otp: otp, userId: userId);
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
      await _authService.verifyLoginOtp(
        phone: phoneNumber,
        otp: otp,
      );
      
      return OtpResult.success();
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

