import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/profile/models/profile_model.dart';
import 'package:flutter_app/features/profile/services/profile_service.dart';

/// Controller for profile operations
class ProfileController extends BaseController {
  final ProfileService _profileService;
  
  ProfileModel? _profile;
  Map<String, int> _menuCounts = {};

  ProfileController({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

  /// Current profile data
  ProfileModel? get profile => _profile;

  /// Menu badge counts
  Map<String, int> get menuCounts => _menuCounts;

  /// Check if profile is loaded
  bool get hasProfile => _profile != null;

  /// Get count for a specific menu item
  int getMenuCount(String menuId) => _menuCounts[menuId] ?? 0;

  /// Load profile data
  Future<ProfileResult> loadProfile() async {
    setLoading(true);
    clearError();

    try {
      final result = await _profileService.getProfile();
      
      if (result.success && result.profile != null) {
        _profile = result.profile;
        notifyListeners();
      } else if (result.message != null) {
        setError(result.message);
      }

      setLoading(false);
      return result;
    } catch (e) {
      setError('Failed to load profile. Please try again.');
      setLoading(false);
      return ProfileResult.error('Failed to load profile. Please try again.');
    }
  }

  /// Load menu counts
  Future<void> loadMenuCounts() async {
    try {
      _menuCounts = await _profileService.getMenuCounts();
      notifyListeners();
    } catch (e) {
      // Silently fail - counts are not critical
    }
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await Future.wait([
      loadProfile(),
      loadMenuCounts(),
    ]);
  }

  /// Update profile
  Future<ProfileResult> updateProfile(ProfileModel profile) async {
    setLoading(true);
    clearError();

    try {
      final result = await _profileService.updateProfile(profile);
      
      if (result.success) {
        _profile = result.profile ?? profile;
        notifyListeners();
      } else if (result.message != null) {
        setError(result.message);
      }

      setLoading(false);
      return result;
    } catch (e) {
      setError('Failed to update profile.');
      setLoading(false);
      return ProfileResult.error('Failed to update profile.');
    }
  }

  /// Upload profile image
  Future<ProfileResult> uploadProfileImage(String imagePath) async {
    setLoading(true);
    clearError();

    try {
      final result = await _profileService.uploadProfileImage(imagePath);
      
      if (result.success) {
        // Reload profile to get updated image URL
        await loadProfile();
      } else if (result.message != null) {
        setError(result.message);
      }

      setLoading(false);
      return result;
    } catch (e) {
      setError('Failed to upload image.');
      setLoading(false);
      return ProfileResult.error('Failed to upload image.');
    }
  }

  /// Reset controller
  void reset() {
    _profile = null;
    _menuCounts = {};
    clearError();
    notifyListeners();
  }

  /// Logout user
  Future<bool> logout() async {
    setLoading(true);
    clearError();

    try {
      final success = await _profileService.logout();
      reset();
      setLoading(false);
      return success;
    } catch (e) {
      setLoading(false);
      return false;
    }
  }
}

