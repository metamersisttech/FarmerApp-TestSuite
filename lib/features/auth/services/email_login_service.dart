import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/services/auth_service.dart';

/// Result of email login operation
class EmailLoginResult {
  final bool success;
  final String? errorMessage;
  final bool isUserNotFound;
  final bool isInvalidCredentials;
  final UserModel? user;

  const EmailLoginResult({
    required this.success,
    this.errorMessage,
    this.isUserNotFound = false,
    this.isInvalidCredentials = false,
    this.user,
  });

  factory EmailLoginResult.success({required UserModel user}) {
    return EmailLoginResult(success: true, user: user);
  }

  factory EmailLoginResult.userNotFound() {
    return const EmailLoginResult(
      success: false,
      isUserNotFound: true,
      errorMessage: 'User not found. Please register first.',
    );
  }

  factory EmailLoginResult.invalidCredentials(String message) {
    return EmailLoginResult(
      success: false,
      isInvalidCredentials: true,
      errorMessage: message,
    );
  }

  factory EmailLoginResult.error(String message) {
    return EmailLoginResult(success: false, errorMessage: message);
  }
}

/// Service for handling email login operations
class EmailLoginService {
  final AuthService _authService;
  final BackendHelper _backendHelper;

  EmailLoginService(this._authService, {BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Login with email/username and password
  Future<EmailLoginResult> loginWithEmail({
    required String identifier,
    required String password,
  }) async {
    try {
      final authResponse = await _authService.loginWithEmail(
        identifier: identifier,
        password: password,
      );

      // Set auth token for subsequent API calls
      _authService.setAuthToken(authResponse.accessToken);
      APIClient().setAuthorization(authResponse.accessToken);

      // Fetch fresh user data from /api/auth/me/ to get latest profile updates
      final userJson = await _backendHelper.getMe();
      final freshUser = UserModel.fromJson(userJson);

      // Store tokens and fresh user data using CommonHelper
      final commonHelper = CommonHelper();
      await commonHelper.saveAuthData(
        user: freshUser,
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      // Return success with fresh user data
      return EmailLoginResult.success(user: freshUser);
    } on UnauthorizedException catch (e) {
      // 401 - Invalid password or email
      return EmailLoginResult.invalidCredentials(
        e.message.contains('password')
            ? 'Invalid password or email ID'
            : 'Invalid credentials',
      );
    } on NotFoundException {
      // 404 - User not found
      return EmailLoginResult.userNotFound();
    } on NetworkException {
      return EmailLoginResult.error('No internet connection. Please try again.');
    } on ApiException catch (e) {
      // Check if the error message indicates user not found
      if (e.message.toLowerCase().contains('not found') ||
          e.message.toLowerCase().contains('does not exist')) {
        return EmailLoginResult.userNotFound();
      }
      
      // Check if the error message indicates invalid credentials
      if (e.message.toLowerCase().contains('invalid') ||
          e.message.toLowerCase().contains('incorrect')) {
        return EmailLoginResult.invalidCredentials(
          'Invalid password or email ID',
        );
      }
      
      return EmailLoginResult.error(e.message);
    } catch (e) {
      return EmailLoginResult.error('Login failed. Please try again.');
    }
  }
}

