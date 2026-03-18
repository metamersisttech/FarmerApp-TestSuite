/// Transport Profile Controller
///
/// Manages transport provider profile state.
library;

import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/transport_provider_model.dart';
import 'package:flutter_app/features/transport/services/transport_profile_service.dart';

class TransportProfileController extends BaseController {
  final TransportProfileService _profileService;

  TransportProviderModel? _profile;

  TransportProviderModel? get profile => _profile;
  bool get hasProfile => _profile != null;

  TransportProfileController({
    TransportProfileService? profileService,
  }) : _profileService = profileService ?? TransportProfileService();

  /// Load profile
  Future<void> loadProfile() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      final result = await _profileService.getMyProfile();

      if (isDisposed) return;

      if (result.success) {
        _profile = result.profile;
        notifyListeners();
      } else {
        setError(result.errorMessage ?? 'Failed to load profile');
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to load profile: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Update profile
  Future<bool> updateProfile({
    String? businessName,
    String? bio,
    int? serviceRadiusKm,
  }) async {
    if (isDisposed) return false;

    setLoading(true);
    clearError();

    try {
      final result = await _profileService.updateProfile(
        businessName: businessName,
        bio: bio,
        serviceRadiusKm: serviceRadiusKm,
      );

      if (isDisposed) return false;

      if (result.success) {
        _profile = result.profile;
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to update profile: $e');
      }
      return false;
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Refresh profile
  Future<void> refreshProfile() async {
    await loadProfile();
  }

  /// Reset state
  void reset() {
    _profile = null;
    clearError();
    notifyListeners();
  }
}
