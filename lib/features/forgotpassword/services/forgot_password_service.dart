import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';

/// Result of forgot password operation
class ForgotPasswordResult {
  final bool success;
  final String? message;
  final String? token; // Only in mock mode
  final String? errorMessage;

  const ForgotPasswordResult({
    required this.success,
    this.message,
    this.token,
    this.errorMessage,
  });

  factory ForgotPasswordResult.success({
    required String message,
    String? token,
  }) {
    return ForgotPasswordResult(
      success: true,
      message: message,
      token: token,
    );
  }

  factory ForgotPasswordResult.error(String errorMessage) {
    return ForgotPasswordResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Service for handling forgot password operations
class ForgotPasswordService {
  final BackendHelper _backendHelper;

  ForgotPasswordService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Request password reset email
  Future<ForgotPasswordResult> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await _backendHelper.postRequestPasswordReset({
        'email': email,
      });

      final message = response['message'] as String? ??
          'Password reset email sent successfully.';
      final token = response['token'] as String?; // Only in mock mode

      return ForgotPasswordResult.success(
        message: message,
        token: token,
      );
    } on BackendException catch (e) {
      // Handle not found (404) - email doesn't exist
      if (e.isUserNotFound) {
        return ForgotPasswordResult.error(
          'Email not found. Please check and try again.',
        );
      }
      return ForgotPasswordResult.error(e.message);
    } on NotFoundException {
      return ForgotPasswordResult.error(
        'Email not found. Please check and try again.',
      );
    } on NetworkException {
      return ForgotPasswordResult.error(
        'No internet connection. Please try again.',
      );
    } on ApiException catch (e) {
      // Check if the error message indicates email not found
      if (e.message.toLowerCase().contains('not found') ||
          e.message.toLowerCase().contains('does not exist')) {
        return ForgotPasswordResult.error(
          'Email not found. Please check and try again.',
        );
      }

      return ForgotPasswordResult.error(e.message);
    } catch (e) {
      return ForgotPasswordResult.error(
        'Failed to send reset email. Please try again.',
      );
    }
  }
}

