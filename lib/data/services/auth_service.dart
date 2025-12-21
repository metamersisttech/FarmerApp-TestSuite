// Authentication Service
//
// Handles all authentication-related API calls to Django backend.
// Methods for login, register, logout, OTP verification, etc.

import 'package:flutter_app/core/constants/api_endpoints.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/services/api_service.dart';

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
  /// Example Django endpoint: POST /api/auth/logout/
  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout);
    } catch (e) {
      // Ignore logout errors, just clear token
    } finally {
      _apiService.clearAuthToken();
    }
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

  /// Set auth token for authenticated requests
  void setAuthToken(String token) {
    _apiService.setAuthToken(token);
  }
}

