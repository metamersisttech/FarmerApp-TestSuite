// Authentication Service
//
// Handles all authentication-related API calls to Django backend.
// Methods for login, register, logout, OTP verification, etc.

import 'package:flutter_app/core/constants/api_endpoints.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/services/api_service.dart';
import 'package:flutter_app/data/services/token_storage_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  // ============ Authentication Methods ============

  /// Login with email and password
  /// 
  /// Sends credentials to Django's login endpoint.
  /// Returns AuthResponse with tokens and user data.
  /// 
  /// Example Django endpoint: POST /api/auth/login/
  /// Request body: { "email": "...", "password": "..." }
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  /// Register new user
  /// 
  /// Creates new account in Django backend.
  /// 
  /// Example Django endpoint: POST /api/auth/register/
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.register,
      data: {
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirm': confirmPassword,
        'first_name': firstName,
        'last_name': lastName,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  /// Send Login OTP to phone number (for existing users)
  /// 
  /// Django endpoint: POST /api/auth/send-login-otp/
  /// Request body: { "phone": "+91XXXXXXXXXX" }
  /// Response: { "message": "OTP sent successfully", "otp": "123456", "user_id": 1 }
  /// Throws ApiException with 404 if user not found
  Future<Map<String, dynamic>> sendLoginOtp({
    required String phone,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.sendLoginOtp,
      data: {
        'phone': phone,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Send OTP to phone number
  /// 
  /// Django endpoint: POST /api/auth/otp/send/
  /// Request body: { "phone": "+91XXXXXXXXXX" }
  /// Response: { "success": true, "message": "OTP sent successfully" }
  Future<bool> sendOtp({
    required String phone,
    String? email,
    String? username,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.sendOtp,
      data: {
        'phone': phone,
        if (email != null) 'email': email,
        if (username != null) 'username': username,
      },
    );
    
    // Check if response indicates success
    final data = response.data;
    if (data is Map) {
      return data['success'] == true || response.statusCode == 200;
    }
    return response.statusCode == 200;
  }

  /// Verify OTP code for login
  /// 
  /// Django endpoint: POST /api/auth/login/
  /// Request body: { "phone": "7406996114", "otp": "123456" }
  /// Response: { "message": "Login successful.", "user": {...}, "tokens": {...} }
  Future<AuthResponse> verifyLoginOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.verifyLoginOtp,
      data: {
        'phone': phone,
        'otp': otp,
      },
    );
    
    // Transform response to match AuthResponse format
    final data = response.data as Map<String, dynamic>;
    return AuthResponse.fromJson({
      'access': data['tokens']['access'],
      'refresh': data['tokens']['refresh'],
      'user': data['user'],
    });
  }

  /// Verify OTP code
  /// 
  /// Django endpoint: POST /api/auth/otp/verify/
  /// Request body: { "phone": "+91XXXXXXXXXX", "otp": "123456" }
  /// Response: { "access": "...", "refresh": "...", "user": {...} }
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
    String? email,
    String? username,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.verifyOtp,
      data: {
        'phone': phone,
        'otp': otp,
        if (email != null) 'email': email,
        if (username != null) 'username': username,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  /// Logout user
  /// 
  /// Django endpoint: POST /api/auth/logout/
  /// Request body: { "refresh": "..." }
  /// Authorization: Bearer access_token
  Future<void> logout() async {
    final tokenStorage = TokenStorageService();
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _apiService.post(
          ApiEndpoints.logout,
          data: {
            'refresh': refreshToken,
          },
        );
      }
    } catch (e) {
      // Ignore logout errors, just clear tokens
    } finally {
      _apiService.clearAuthToken();
      await tokenStorage.clearTokens();
    }
  }

  /// Get current authenticated user
  /// 
  /// Django endpoint: GET /api/auth/me/
  /// Authorization: Bearer access_token
  /// Response: { "id": 1, "email": "...", "first_name": "...", "last_name": "...", ... }
  Future<UserModel> getMe() async {
    final response = await _apiService.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data);
  }

  /// Refresh access token
  /// 
  /// Django endpoint: POST /api/auth/token/refresh/
  /// Request body: { "refresh": "..." }
  /// Response: { "access": "..." }
  Future<String> refreshToken({required String refreshToken}) async {
    final response = await _apiService.post(
      ApiEndpoints.refreshToken,
      data: {
        'refresh': refreshToken,
      },
    );
    return response.data['access'] as String;
  }

  /// Request password reset
  /// 
  /// Django endpoint: POST /api/auth/password/reset/
  /// Request body: { "email": "..." }
  Future<bool> forgotPassword({required String email}) async {
    final response = await _apiService.post(
      ApiEndpoints.forgotPassword,
      data: {
        'email': email,
      },
    );
    return response.statusCode == 200;
  }

  /// Get current user profile
  /// 
  /// Django endpoint: GET /api/users/profile/
  Future<UserModel> getCurrentUser() async {
    final response = await _apiService.get(ApiEndpoints.userProfile);
    return UserModel.fromJson(response.data);
  }

  /// Update current user profile
  /// 
  /// Django endpoint: PATCH /api/auth/me/
  /// Request body: { "username": "...", "email": "...", "first_name": "...", "last_name": "...", "phone": "..." }
  /// Response: Updated UserModel
  Future<UserModel> updateMe({
    String? username,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.me,
      data: {
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
      },
    );
    return UserModel.fromJson(response.data);
  }

  /// Login with email/username and password
  /// 
  /// Django endpoint: POST /api/auth/login-email/
  /// Request body: { "identifier": "string", "password": "string" }
  /// Response: { "message": "...", "user": {...}, "tokens": { "access": "...", "refresh": "..." } }
  Future<AuthResponse> loginWithEmail({
    required String identifier,
    required String password,
  }) async {
    final response = await _apiService.post(
      'auth/login-email/',
      data: {
        'identifier': identifier,
        'password': password,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  /// Request password reset
  /// 
  /// Django endpoint: POST /api/auth/password/reset/
  /// Request body: { "email": "string" }
  /// Response: { "message": "...", "token": "..." } (token only in mock mode)
  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.forgotPassword,
      data: {
        'email': email,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Confirm password reset with token
  /// 
  /// Django endpoint: POST /api/auth/password/reset/confirm/
  /// Request body: { "token": "string", "new_password": "string", "new_password_confirm": "string" }
  /// Response: { "message": "Password reset successfully." }
  Future<Map<String, dynamic>> confirmPasswordReset({
    required String token,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'new_password': newPassword,
        'new_password_confirm': newPasswordConfirm,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Set auth token for authenticated requests
  void setAuthToken(String token) {
    _apiService.setAuthToken(token);
  }
}

