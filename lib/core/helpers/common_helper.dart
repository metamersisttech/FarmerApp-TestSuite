/// Common Helper - localStorage user management
///
/// Handles storing/retrieving logged in user data.
/// Uses flutter_secure_storage for encrypted storage.
library;

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app/data/models/user_model.dart';

/// Common Helper
/// Singleton service for localStorage user management
class CommonHelper {
  static const String _userKey = 'logged_in_user';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _appModeKey = 'app_mode';

  final FlutterSecureStorage _storage;

  // Singleton
  static final CommonHelper _instance = CommonHelper._internal();
  factory CommonHelper() => _instance;

  CommonHelper._internal()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  // ============ User Management ============

  /// Get logged in user from localStorage
  /// Returns null if no user is stored
  Future<UserModel?> getLoggedInUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson == null || userJson.isEmpty) return null;
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Store logged in user in localStorage
  Future<void> setLoggedInUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
  }

  /// Clear stored user from localStorage
  Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Check if user is authenticated (has stored user data)
  Future<bool> isAuthenticated() async {
    final user = await getLoggedInUser();
    return user != null;
  }

  // ============ Token Management ============

  /// Store tokens
  Future<void> setTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Check if tokens exist
  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ============ Combined Operations ============

  /// Store user and tokens together (after login)
  Future<void> saveAuthData({
    required UserModel user,
    required String accessToken,
    String? refreshToken,
  }) async {
    await setLoggedInUser(user);
    await setTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  /// Clear all auth data (for logout)
  Future<void> clearAll() async {
    await clearUser();
    await _storage.delete(key: _appModeKey);
  }

  // ============ App Mode Management ============

  /// Get current app mode ('farmer' or 'vet'). Defaults to 'farmer'.
  Future<String> getAppMode() async {
    final mode = await _storage.read(key: _appModeKey);
    return mode ?? 'farmer';
  }

  /// Set app mode ('farmer' or 'vet')
  Future<void> setAppMode(String mode) async {
    await _storage.write(key: _appModeKey, value: mode);
  }

  /// Check if currently in vet mode
  Future<bool> isVetMode() async {
    return (await getAppMode()) == 'vet';
  }

  // ============ Image URL Helper ============

  /// GCS bucket base URL
  static const String _gcsBaseUrl = 'https://storage.googleapis.com/metamersisttest/';

  /// Convert GCS image key to full URL
  /// Takes a key like "users/3/listings/1e38bdfa0cbe4476866cba85e7283c73.png"
  /// Returns "https://storage.googleapis.com/metamersisttest/users/3/listings/1e38bdfa0cbe4476866cba85e7283c73.png"
  static String getImageUrl(String? key) {
    if (key == null || key.isEmpty) return '';
    // If already a full URL, return as-is
    if (key.startsWith('http://') || key.startsWith('https://')) {
      return key;
    }
    // Remove leading slash if present
    final cleanKey = key.startsWith('/') ? key.substring(1) : key;
    return '$_gcsBaseUrl$cleanKey';
  }

  // ============ Time-based Greeting ============

  /// Returns greeting based on current time of day
  /// Morning: 5:00 AM - 11:59 AM
  /// Afternoon: 12:00 PM - 4:59 PM
  /// Evening: 5:00 PM - 4:59 AM
  static String getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Hi, Good Morning 👋';
    } else if (hour >= 12 && hour < 17) {
      return 'Hi, Good Afternoon 👋';
    } else {
      return 'Hi, Good Evening 👋';
    }
  }
}
