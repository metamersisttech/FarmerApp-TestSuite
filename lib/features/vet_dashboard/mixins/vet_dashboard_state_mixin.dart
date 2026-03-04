import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/notifications/controllers/notification_controller.dart';
import 'package:flutter_app/features/vet_dashboard/controllers/vet_dashboard_controller.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Mixin for vet dashboard home page state management.
/// Follows the same pattern as HomeStateMixin.
mixin VetDashboardStateMixin<T extends StatefulWidget> on State<T> {
  late VetDashboardController dashboardController;
  late NotificationController _notificationController;
  Timer? _notificationPollTimer;
  UserModel? currentUser;
  int currentBottomNavIndex = 0;
  int notificationUnreadCount = 0;

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
