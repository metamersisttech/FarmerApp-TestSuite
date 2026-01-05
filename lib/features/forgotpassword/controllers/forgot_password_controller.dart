import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/features/forgotPassword/services/forgot_password_service.dart';

/// Controller for forgot password operations
class ForgotPasswordController extends BaseController {
  final ForgotPasswordService _forgotPasswordService;

  ForgotPasswordController(AuthService authService)
      : _forgotPasswordService = ForgotPasswordService(authService);

  /// Request password reset email
  Future<ForgotPasswordResult> requestPasswordReset({
    required String email,
  }) async {
    setLoading(true);
    clearError();

    final result = await _forgotPasswordService.requestPasswordReset(
      email: email,
    );

    if (!result.success && result.errorMessage != null) {
      setError(result.errorMessage);
    }

    setLoading(false);
    return result;
  }
}

