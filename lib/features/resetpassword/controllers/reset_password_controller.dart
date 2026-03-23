import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/features/resetpassword/services/reset_password_service.dart';

/// Controller for password reset operations
class ResetPasswordController extends BaseController {
  final ResetPasswordService _resetPasswordService;

  ResetPasswordController(AuthService authService)
      : _resetPasswordService = ResetPasswordService(authService);

  /// Confirm password reset with token
  Future<ResetPasswordResult> confirmPasswordReset({
    required String token,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    setLoading(true);
    clearError();

    final result = await _resetPasswordService.confirmPasswordReset(
      token: token,
      newPassword: newPassword,
      newPasswordConfirm: newPasswordConfirm,
    );

    if (!result.success && result.errorMessage != null) {
      setError(result.errorMessage);
    }

    setLoading(false);
    return result;
  }
}

