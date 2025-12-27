import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/data/services/api_service.dart';
import 'package:flutter_app/data/services/token_storage_service.dart';
import 'package:flutter_app/features/profile/models/profile_model.dart';

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
  final TokenStorageService _tokenStorage;

  ProfileService({
    AuthService? authService,
    ApiService? apiService,
    TokenStorageService? tokenStorage,
  })  : _authService = authService ?? AuthService(),
        _apiService = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  /// Initialize API service with stored token
  Future<void> _initializeAuth() async {
    final accessToken = await _tokenStorage.getAccessToken();
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
      
      // Fetch user data from /api/auth/me/
      final user = await _authService.getMe();
      
      // Convert user data to ProfileModel
      final profile = ProfileModel(
        id: user.id,
        name: '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
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
      // TODO: Call API when backend is ready
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Return mock counts
      return {
        'my_listings': 5,
        'saved_items': 12,
        'my_bookings': 3,
      };
    } catch (e) {
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
      await _authService.logout();
      return true;
    } catch (e) {
      // Still clear tokens even if API call fails
      await _tokenStorage.clearTokens();
      _apiService.clearAuthToken();
      return true;
    }
  }
}

