import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/features/auth/services/otp_handler_service.dart';

/// Controller for OTP operations
class OtpController extends BaseController {
  final OtpHandlerService _otpService;

  OtpController(AuthService authService)
      : _otpService = OtpHandlerService(authService);

  /// Send OTP to phone number
  Future<OtpResult> sendOtp(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _otpService.sendOtp(phoneNumber);

    if (!result.success && result.errorMessage != null) {
      setError(result.errorMessage);
    }

    setLoading(false);
    return result;
  }

  /// Verify OTP
  Future<OtpResult> verifyOtp(String phoneNumber, String otp) async {
    setLoading(true);
    clearError();

    final result = await _otpService.verifyOtp(phoneNumber, otp);

    if (!result.success && result.errorMessage != null) {
      setError(result.errorMessage);
    }

    setLoading(false);
    return result;
  }
}

