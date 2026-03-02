import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/core/services/fcm_service.dart';
import 'package:flutter_app/data/services/api_service.dart';
import 'package:flutter_app/features/profile/models/profile_model.dart';
import 'package:flutter_app/features/favourite/services/favourite_badge_service.dart';

/// Result of profile operations
class ProfileResult {
  final bool success;
  final String? message;
  final ProfileModel? profile;

  const ProfileResult({
    required this.success,
    this.message,
    this.profile,
  });

  factory ProfileResult.success({ProfileModel? profile}) {
    return ProfileResult(
      success: true,
      message: 'Profile loaded successfully',
      profile: profile,
    );
  }

  factory ProfileResult.error(String message) {
    return ProfileResult(success: false, message: message);
  }
}

/// Service for handling profile operations
class ProfileService {
  final AuthService _authService;
  final ApiService _apiService;
  final CommonHelper _commonHelper;
  final BackendHelper _backendHelper;

  ProfileService({
    AuthService? authService,
    ApiService? apiService,
    CommonHelper? commonHelper,
    BackendHelper? backendHelper,
  })  : _authService = authService ?? AuthService(),
        _apiService = apiService ?? ApiService(),
        _commonHelper = commonHelper ?? CommonHelper(),
        _backendHelper = backendHelper ?? BackendHelper();

  /// Initialize API service with stored token
  Future<void> _initializeAuth() async {
    final accessToken = await _commonHelper.getAccessToken();
    if (accessToken != null) {
      _apiService.setAuthToken(accessToken);
      _authService.setAuthToken(accessToken);
    }
  }

  /// Get user profile from API
  Future<ProfileResult> getProfile() async {
    try {
      // Initialize auth with stored token
      await _initializeAuth();
      
      // Fetch user data from /api/auth/me/ using BackendHelper
      final userJson = await _backendHelper.getMe();
      final user = UserModel.fromJson(userJson);
      
      // Convert user data to ProfileModel
      // Priority for name display: fullName > displayName > firstName+lastName > username > email
      String name;
      if (user.fullName != null && user.fullName!.trim().isNotEmpty) {
        // Use full_name if available and not empty
        name = user.fullName!.trim();
      } else if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        // Use display_name if available and not empty
        name = user.displayName!.trim();
      } else if (user.firstName != null || user.lastName != null) {
        // Combine first_name and last_name if available
        name = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
      } else {
        // Final fallback: username or email
        name = user.username ?? user.email;
      }
      
      final profile = ProfileModel(
        id: user.id,
        name: name,
        profileImage: user.profileImage,
        identity: null, // Will be fetched separately if needed
        location: null, // Will be fetched separately if needed
        rating: 0.0, // Default - fetch from separate endpoint
        reviewCount: 0,
        isVerified: user.isVerified,
        kycStatus: user.kycStatus ?? (user.isVerified ? 'verified' : 'not_verified'),
        stats: const ProfileStats(
          animalsSold: 0,
          transactions: 0,
          memberYears: 0,
        ),
        memberSince: user.dateJoined,
      );
      
      return ProfileResult.success(profile: profile);
    } catch (e) {
      return ProfileResult.error('Failed to load profile. Please try again.');
    }
  }

  /// Update user profile
  Future<ProfileResult> updateProfile(ProfileModel profile) async {
    try {
      // TODO: Call API when backend is ready
      // final response = await _apiService.put('/api/users/profile/', data: profile.toJson());
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      return ProfileResult.success(profile: profile);
    } catch (e) {
      return ProfileResult.error('Failed to update profile.');
    }
  }

  /// Get profile menu counts
  Future<Map<String, int>> getMenuCounts() async {
    try {
      print('[ProfileService] 🔍 Getting menu counts...');
      
      // Fetch NEW favorites count (since last visit)
      final badgeService = FavouriteBadgeService();
      final newFavoritesCount = await badgeService.getNewFavoritesCount();
      
      print('[ProfileService] ✅ Badge count received: $newFavoritesCount');
      
      // TODO: Fetch actual counts from API for other items when backend is ready
      final counts = {
        'my_listings': 0,
        'saved_items': newFavoritesCount,
        'my_bookings': 0,
      };
      
      print('[ProfileService] 📊 Returning menu counts: $counts');
      return counts;
    } catch (e) {
      print('[ProfileService] ❌ ERROR getting menu counts: $e');
      return {};
    }
  }

  /// Upload profile image
  Future<ProfileResult> uploadProfileImage(String imagePath) async {
    try {
      // TODO: Call API when backend is ready
      // final response = await _apiService.uploadFile('/api/users/profile/image/', imagePath);
      
      await Future.delayed(const Duration(seconds: 1));
      
      return ProfileResult.success();
    } catch (e) {
      return ProfileResult.error('Failed to upload image.');
    }
  }

  /// Logout user
  /// Calls POST /api/auth/logout/ with refresh token in body
  Future<bool> logout() async {
    try {
      await _initializeAuth();
      
      // Get refresh token
      final refreshToken = await _commonHelper.getRefreshToken();
      
      // Call logout API if refresh token exists
      if (refreshToken != null) {
        await _backendHelper.postLogout({'refresh': refreshToken});
      }
      
      return true;
    } catch (e) {
      // Ignore logout errors
      return true;
    } finally {
      // Unregister FCM token before clearing auth
      await FCMService().unregisterToken();

      // Always clear tokens and auth state
      await _commonHelper.clearAll();
      _apiService.clearAuthToken();
      APIClient().clearAuthorization();
    }
  }
}

