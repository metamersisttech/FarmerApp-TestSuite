import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/core/services/fcm_service.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/notifications/controllers/notification_controller.dart';
import 'package:flutter_app/features/vet/controllers/vet_profile_controller.dart';
import 'package:flutter_app/features/vet_dashboard/controllers/vet_dashboard_controller.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Mixin for vet dashboard home page state management.
/// Follows the same pattern as HomeStateMixin.
mixin VetDashboardStateMixin<T extends StatefulWidget> on State<T> {
  late VetDashboardController dashboardController;
  late NotificationController _notificationController;
  VetProfileController? vetProfileController;
  Timer? _notificationPollTimer;
  UserModel? currentUser;
  int currentBottomNavIndex = 0;
  int notificationUnreadCount = 0;
  bool isSwitchingMode = false;

  void initializeDashboardController() {
    dashboardController = VetDashboardController();
    _notificationController = NotificationController();
    _notificationController.addListener(_onNotificationCountChanged);

    // Poll unread count every 60 seconds
    _notificationPollTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => fetchNotificationUnreadCount(),
    );
  }

  void _onNotificationCountChanged() {
    if (mounted) {
      setState(() {
        notificationUnreadCount = _notificationController.unreadCount;
      });
    }
  }

  /// Fetch notification unread count for badge
  Future<void> fetchNotificationUnreadCount() async {
    await _notificationController.fetchUnreadCount();
  }

  /// Load user data from storage
  Future<void> loadUserFromStorage() async {
    try {
      final commonHelper = CommonHelper();
      final user = await commonHelper.getLoggedInUser();
      if (user != null && mounted) {
        setState(() {
          currentUser = user;
        });
      }
    } catch (e) {
      debugPrint('[VetDashboardStateMixin] Error loading user: $e');
    }
  }

  /// Fetch dashboard data
  Future<void> fetchDashboardData() async {
    await dashboardController.loadDashboard();
    if (!mounted) return;
    setState(() {});
  }

  /// Handle bottom navigation tap
  void handleBottomNavTap(int index) {
    if (mounted) {
      setState(() => currentBottomNavIndex = index);
    }

    switch (index) {
      case 0:
        // Already on vet home
        return;
      case 1:
      case 2:
      case 3:
        showComingSoonMessage('This feature');
        break;
    }
  }

  /// Handle profile tap — navigate to vet dashboard profile
  void handleProfileTap() {
    debugPrint('[VetDashboardStateMixin] Navigating to vet dashboard profile');
    Navigator.pushNamed(context, '/vet-dashboard-profile');
  }

  /// Handle notification tap
  void handleNotificationTap() {
    Navigator.pushNamed(context, AppRoutes.notifications);
  }

  /// Handle view all appointments
  void handleViewAllAppointments() {
    Navigator.pushNamed(context, '/vet-appointments');
  }

  /// Handle back button press with fallback navigation
  void handleBackPressed() {
    debugPrint('[VetDashboardStateMixin] Back arrow tapped');
    debugPrint('[VetDashboardStateMixin] Navigator can pop: ${Navigator.canPop(context)}');
    debugPrint('[VetDashboardStateMixin] Attempting to navigate back...');
    
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      debugPrint('[VetDashboardStateMixin] Pop executed');
    } else {
      debugPrint('[VetDashboardStateMixin] Cannot pop, navigating to /vet-home instead');
      Navigator.pushReplacementNamed(context, '/vet-home');
    }
  }

  /// Load vet profile data
  Future<void> loadVetProfileData({
    required VetProfileController controller,
    required Function(bool) setLoading,
    required Function(String) showErrorToast,
  }) async {
    setLoading(true);
    await controller.loadProfile();
    if (!mounted) return;
    setLoading(false);

    if (controller.errorMessage != null) {
      showErrorToast(controller.errorMessage!);
    }
  }

  /// Handle switch to farmer mode
  Future<void> handleSwitchToFarmer({
    required Function(bool) setSwitchingMode,
    required Function(String) showErrorToast,
  }) async {
    setSwitchingMode(true);

    try {
      await CommonHelper().setAppMode('farmer');
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setSwitchingMode(false);
      showErrorToast('Failed to switch mode');
    }
  }

  /// Handle logout with confirmation dialog
  void handleLogout({
    required Function(bool) setLoading,
    required Function(String) showSuccessToast,
    required Function(String) showErrorToast,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setLoading(true);

              try {
                // Unregister FCM token before clearing auth
                await FCMService().unregisterToken();

                await CommonHelper().clearAll();

                if (!mounted) return;
                setLoading(false);

                showSuccessToast('Logged out successfully');
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              } catch (e) {
                if (!mounted) return;
                setLoading(false);
                showErrorToast('Failed to logout');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Show feature coming soon message
  void showComingSoonMessage(String feature) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$feature coming soon!')),
      );
    }
  }

  /// Dispose controller
  void disposeDashboardController() {
    _notificationPollTimer?.cancel();
    dashboardController.dispose();
    _notificationController.removeListener(_onNotificationCountChanged);
    _notificationController.dispose();
  }
}
