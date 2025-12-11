/// Authentication Repository
///
/// Business logic layer for authentication.
/// Combines AuthService with local storage and error handling.
/// 
/// TODO: Add 'flutter_secure_storage' package for secure token storage.
///       Run: flutter pub add flutter_secure_storage

import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  // TODO: Add secure storage
  // final FlutterSecureStorage _secureStorage;

  UserModel? _currentUser;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// Get current logged-in user
  UserModel? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Login with email and password
  /// 
  /// 1. Calls Django login API
  /// 2. Stores tokens securely
  /// 3. Returns user data
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      // Store tokens securely
      await _saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Set token for future requests
      _authService.setAuthToken(response.accessToken);

      // Cache user data
      _currentUser = response.user;

      return response.user;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      throw ApiException(message: 'Login failed. Please try again.');
    }
  }

  /// Register new user
  Future<UserModel> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? username,
    String? phone,
  }) async {
    try {
      final response = await _authService.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        username: username,
        phone: phone,
      );

      // Store tokens
      await _saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      _authService.setAuthToken(response.accessToken);
      _currentUser = response.user;

      return response.user;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Register error: $e');
      }
      throw ApiException(message: 'Registration failed. Please try again.');
    }
  }

  /// Login with phone OTP
  Future<UserModel> loginWithPhone({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _authService.verifyOtp(
        phone: phone,
        otp: otp,
      );

      await _saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      _authService.setAuthToken(response.accessToken);
      _currentUser = response.user;

      return response.user;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Phone login error: $e');
      }
      throw ApiException(message: 'Phone verification failed.');
    }
  }

  /// Send OTP to phone
  Future<bool> sendOtp({required String phone}) async {
    try {
      return await _authService.sendOtp(phone: phone);
    } catch (e) {
      if (kDebugMode) {
        print('Send OTP error: $e');
      }
      throw ApiException(message: 'Failed to send OTP.');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      if (kDebugMode) {
        print('Logout API error: $e');
      }
    } finally {
      // Always clear local data
      await _clearTokens();
      _currentUser = null;
    }
  }

  /// Check and restore session on app start
  Future<bool> checkAuthStatus() async {
    try {
      final token = await _getAccessToken();
      if (token == null) return false;

      _authService.setAuthToken(token);
      _currentUser = await _authService.getCurrentUser();

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Auth check error: $e');
      }
      await _clearTokens();
      return false;
    }
  }

  /// Request password reset
  Future<bool> forgotPassword({required String email}) async {
    return await _authService.forgotPassword(email: email);
  }

  // ============ Token Storage (Placeholder) ============
  // TODO: Implement with flutter_secure_storage

  Future<void> _saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    // TODO: Implement secure storage
    // await _secureStorage.write(key: 'access_token', value: accessToken);
    // if (refreshToken != null) {
    //   await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    // }
    if (kDebugMode) {
      print('TODO: Save tokens securely');
    }
  }

  Future<String?> _getAccessToken() async {
    // TODO: Implement secure storage
    // return await _secureStorage.read(key: 'access_token');
    return null;
  }

  Future<void> _clearTokens() async {
    // TODO: Implement secure storage
    // await _secureStorage.deleteAll();
    if (kDebugMode) {
      print('TODO: Clear tokens from secure storage');
    }
  }
}

