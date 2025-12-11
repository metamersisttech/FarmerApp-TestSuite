/// Authentication Service
///
/// Handles all authentication-related API calls to Django backend.
/// Methods for login, register, logout, OTP verification, etc.

// ignore: unused_import
import 'package:flutter_app/core/constants/api_endpoints.dart'; // Will be used when implementing HTTP calls
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
    // TODO: Implement with actual HTTP call
    // final response = await _apiService.post(ApiEndpoints.login, {
    //   'email': email,
    //   'password': password,
    // });
    // return AuthResponse.fromJson(response.data);
    
    throw UnimplementedError('Add dio package and implement HTTP call');
  }

  /// Register new user
  /// 
  /// Creates new account in Django backend.
  /// 
  /// Example Django endpoint: POST /api/auth/register/
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? username,
    String? phone,
  }) async {
    // TODO: Implement with actual HTTP call
    // final response = await _apiService.post(ApiEndpoints.register, {
    //   'email': email,
    //   'password': password,
    //   'password_confirm': confirmPassword,
    //   'username': username,
    //   'phone': phone,
    // });
    // return AuthResponse.fromJson(response.data);
    
    throw UnimplementedError('Add dio package and implement HTTP call');
  }

  /// Send OTP to phone number
  /// 
  /// Example Django endpoint: POST /api/auth/otp/send/
  Future<bool> sendOtp({required String phone}) async {
    // TODO: Implement with actual HTTP call
    // final response = await _apiService.post(ApiEndpoints.sendOtp, {
    //   'phone': phone,
    // });
    // return response.statusCode == 200;
    
    throw UnimplementedError('Add dio package and implement HTTP call');
  }

  /// Verify OTP code
  /// 
  /// Example Django endpoint: POST /api/auth/otp/verify/
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    // TODO: Implement with actual HTTP call
    // final response = await _apiService.post(ApiEndpoints.verifyOtp, {
    //   'phone': phone,
    //   'otp': otp,
    // });
    // return AuthResponse.fromJson(response.data);
    
    throw UnimplementedError('Add dio package and implement HTTP call');
  }

  /// Logout user
  /// 
  /// Example Django endpoint: POST /api/auth/logout/
  Future<void> logout() async {
    // TODO: Implement with actual HTTP call
    // await _apiService.post(ApiEndpoints.logout, {});
    _apiService.clearAuthToken();
  }

  /// Refresh access token
  /// 
  /// Example Django endpoint: POST /api/auth/token/refresh/
  Future<String> refreshToken({required String refreshToken}) async {
    // TODO: Implement with actual HTTP call
    // final response = await _apiService.post(ApiEndpoints.refreshToken, {
    //   'refresh': refreshToken,
    // });
    // return response.data['access'] as String;
    
    throw UnimplementedError('Add dio package and implement HTTP call');
  }

  /// Request password reset
  /// 
  /// Example Django endpoint: POST /api/auth/password/reset/
  Future<bool> forgotPassword({required String email}) async {
    // TODO: Implement with actual HTTP call
    // final response = await _apiService.post(ApiEndpoints.forgotPassword, {
    //   'email': email,
    // });
    // return response.statusCode == 200;
    
    throw UnimplementedError('Add dio package and implement HTTP call');
  }

  /// Get current user profile
  /// 
  /// Example Django endpoint: GET /api/users/profile/
  Future<UserModel> getCurrentUser() async {
    // TODO: Implement with actual HTTP call
    // final response = await _apiService.get(ApiEndpoints.userProfile);
    // return UserModel.fromJson(response.data);
    
    throw UnimplementedError('Add dio package and implement HTTP call');
  }

  /// Set auth token for authenticated requests
  void setAuthToken(String token) {
    _apiService.setAuthToken(token);
  }
}

