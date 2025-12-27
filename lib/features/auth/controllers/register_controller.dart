import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';

/// Result of registration operation
class RegisterResult {
  final bool success;
  final String? errorMessage;

  const RegisterResult({required this.success, this.errorMessage});

  factory RegisterResult.success() => const RegisterResult(success: true);
  
  factory RegisterResult.error(String message) {
    return RegisterResult(success: false, errorMessage: message);
  }
}

/// Controller for registration operations
class RegisterController extends BaseController {
  final AuthRepository _authRepository;

  RegisterController(this._authRepository);

  /// Register new user
  Future<RegisterResult> register({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  }) async {
    setLoading(true);
    clearError();

    try {
      await _authRepository.register(
        username: username,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
      );

      setLoading(false);
      return RegisterResult.success();
    } on NetworkException {
      final error = 'No internet connection. Please try again.';
      setError(error);
      setLoading(false);
      return RegisterResult.error(error);
    } on ApiException catch (e) {
      setError(e.message);
      setLoading(false);
      return RegisterResult.error(e.message);
    } catch (e) {
      final error = 'Registration failed. Please try again.';
      setError(error);
      setLoading(false);
      return RegisterResult.error(error);
    }
  }
}

