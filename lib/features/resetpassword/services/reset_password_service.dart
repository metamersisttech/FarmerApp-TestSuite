import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/data/services/auth_service.dart';

/// Result of password reset operation
class ResetPasswordResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const ResetPasswordResult({
    required this.success,
    this.message,
    this.errorMessage,
  });

  factory ResetPasswordResult.success({String? message}) {
    return ResetPasswordResult(
      success: true,
      message: message ?? 'Password reset successfully.',
    );
  }

  factory ResetPasswordResult.error(String errorMessage) {
    return ResetPasswordResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Service for handling password reset operations
class ResetPasswordService {
  final AuthService _authService;

  ResetPasswordService(this._authService);

  /// Confirm password reset with token
  Future<ResetPasswordResult> confirmPasswordReset({
    required String token,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      final response = await _authService.confirmPasswordReset(
        token: token,
        newPassword: newPassword,
        newPasswordConfirm: newPasswordConfirm,
      );

      final message = response['message'] as String? ??
          'Password reset successfully.';

      return ResetPasswordResult.success(message: message);
    } on UnauthorizedException {
      return ResetPasswordResult.error(
        'Invalid or expired reset token. Please request a new one.',
      );
    } on BadRequestException catch (e) {
      // Handle password mismatch or validation errors
      if (e.message.toLowerCase().contains('password')) {
        return ResetPasswordResult.error(e.message);
      }
      return ResetPasswordResult.error(
        'Invalid request. Please check your input and try again.',
      );
    } on NetworkException {
      return ResetPasswordResult.error(
        'No internet connection. Please try again.',
      );
    } on ApiException catch (e) {
      // Check for specific error messages
      if (e.message.toLowerCase().contains('token') &&
          (e.message.toLowerCase().contains('invalid') ||
              e.message.toLowerCase().contains('expired'))) {
        return ResetPasswordResult.error(
          'Invalid or expired reset token. Please request a new one.',
        );
      }

      if (e.message.toLowerCase().contains('password') &&
          e.message.toLowerCase().contains('match')) {
        return ResetPasswordResult.error(
          'Passwords do not match. Please try again.',
        );
      }

      return ResetPasswordResult.error(e.message);
    } catch (e) {
      return ResetPasswordResult.error(
        'Failed to reset password. Please try again.',
      );
    }
  }
}

