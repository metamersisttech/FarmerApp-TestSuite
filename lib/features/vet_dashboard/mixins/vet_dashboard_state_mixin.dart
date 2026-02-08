import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/vet_dashboard/controllers/vet_dashboard_controller.dart';

/// Mixin for vet dashboard home page state management.
/// Follows the same pattern as HomeStateMixin.
mixin VetDashboardStateMixin<T extends StatefulWidget> on State<T> {
  late VetDashboardController dashboardController;
  UserModel? currentUser;
  int currentBottomNavIndex = 0;

  void initializeDashboardController() {
    dashboardController = VetDashboardController();
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
    showComingSoonMessage('Notifications');
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
    dashboardController.dispose();
  }
}
