import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/features/auth/services/email_login_service.dart';
/// Controller for email login operations
class EmailLoginController extends BaseController {
  final EmailLoginService _emailLoginService;

  EmailLoginController(AuthService authService)
    : _emailLoginService = EmailLoginService(authService);

  /// Login with email/username and password
  Future<EmailLoginResult> loginWithEmail({
    required String identifier,
    required String password,
  }) async {
    setLoading(true);
    clearError();

    final result = await _emailLoginService.loginWithEmail(
      identifier: identifier,
      password: password,
    );

    if (!result.success && result.errorMessage != null) {
      setError(result.errorMessage);
    }

    setLoading(false);
    return result;
  }
}
