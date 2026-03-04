import 'package:flutter/material.dart';
import 'package:flutter_app/features/profile/models/profile_model.dart';
import 'package:flutter_app/features/vet/controllers/vet_profile_controller.dart';
import 'package:flutter_app/features/vet/models/vet_profile_model.dart';

/// Mixin for vet dashboard profile page state management.
/// Handles profile loading, menu navigation, and profile-specific actions.
mixin VetDashboardProfileMixin<T extends StatefulWidget> on State<T> {
  VetProfileController? _profileController;
  bool _isProfileLoading = true;
  bool _isSwitchingMode = false;

  VetProfileController get profileController =>
      _profileController ??= VetProfileController();

  bool get isProfileLoading => _isProfileLoading;
  bool get isSwitchingMode => _isSwitchingMode;
  VetProfileModel? get vetProfile => _profileController?.profile;

  /// Initialize profile controller
  void initializeProfileController() {
    _profileController = VetProfileController();
  }

  /// Load vet profile data
  Future<void> loadProfileData({
    required Function(String) showErrorToast,
  }) async {
    setProfileLoading(true);
    await profileController.loadProfile();

    if (!mounted) return;
    setProfileLoading(false);

    if (profileController.errorMessage != null) {
      showErrorToast(profileController.errorMessage!);
    }
  }

  /// Set profile loading state
  void setProfileLoading(bool loading) {
    if (mounted) {
      setState(() => _isProfileLoading = loading);
    }
  }

  /// Set mode switching state
  void setSwitchingMode(bool switching) {
    if (mounted) {
      setState(() => _isSwitchingMode = switching);
    }
  }

  /// Handle profile menu navigation
  void handleProfileMenuNavigation(
    BuildContext context,
    String menuId, {
    Function(String)? showSuccessToast,
  }) {
    switch (menuId) {
      case 'appointments':
        Navigator.pushNamed(context, '/vet-appointments');
        break;
      case 'availability':
        Navigator.pushNamed(context, '/vet-availability');
        break;
      case 'pricing':
        Navigator.pushNamed(context, '/vet-pricing');
        break;
      case 'vet_profile':
        Navigator.pushNamed(context, '/vet-profile');
        break;
      case 'reviews':
        showSuccessToast?.call('Reviews - Coming soon!');
        break;
      case 'notifications':
        showSuccessToast?.call('Notifications - Coming soon!');
        break;
      case 'help':
        showSuccessToast?.call('Help - Coming soon!');
        break;
      default:
        debugPrint('[VetDashboardProfileMixin] Unknown menu item: $menuId');
    }
  }

  /// Get profile menu items
  List<ProfileMenuItem> getProfileMenuItems(
    BuildContext context, {
    Function(String)? showSuccessToast,
  }) {
    return [
      ProfileMenuItem(
        id: 'appointments',
        title: 'My Appointments',
        icon: Icons.calendar_today,
        onTap: () => handleProfileMenuNavigation(
          context,
          'appointments',
          showSuccessToast: showSuccessToast,
        ),
      ),
      ProfileMenuItem(
        id: 'availability',
        title: 'Manage Availability',
        icon: Icons.schedule,
        onTap: () => handleProfileMenuNavigation(
          context,
          'availability',
          showSuccessToast: showSuccessToast,
        ),
      ),
      ProfileMenuItem(
        id: 'pricing',
        title: 'Manage Pricing',
        icon: Icons.payments,
        onTap: () => handleProfileMenuNavigation(
          context,
          'pricing',
          showSuccessToast: showSuccessToast,
        ),
      ),
      ProfileMenuItem(
        id: 'vet_profile',
        title: 'Vet Clinical Profile',
        icon: Icons.medical_information,
        onTap: () => handleProfileMenuNavigation(
          context,
          'vet_profile',
          showSuccessToast: showSuccessToast,
        ),
      ),
      ProfileMenuItem(
        id: 'reviews',
        title: 'Reviews & Ratings',
        icon: Icons.star_outline,
        onTap: () => handleProfileMenuNavigation(
          context,
          'reviews',
          showSuccessToast: showSuccessToast,
        ),
      ),
      ProfileMenuItem(
        id: 'notifications',
        title: 'Notifications',
        icon: Icons.notifications_outlined,
        onTap: () => handleProfileMenuNavigation(
          context,
          'notifications',
          showSuccessToast: showSuccessToast,
        ),
      ),
      ProfileMenuItem(
        id: 'help',
        title: 'Help & Support',
        icon: Icons.help_outline,
        onTap: () => handleProfileMenuNavigation(
          context,
          'help',
          showSuccessToast: showSuccessToast,
        ),
      ),
    ];
  }

  /// Dispose profile controller
  void disposeProfileController() {
    _profileController?.dispose();
    _profileController = null;
  }
}
