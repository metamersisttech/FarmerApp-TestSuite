import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/home/controllers/home_controller.dart';
import 'package:flutter_app/features/notifications/controllers/notification_controller.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';

/// Mixin for reusable home page state coordination
/// 
/// Purpose: Share common state management patterns across home-related widgets
/// - Controller lifecycle management
/// - Listener setup and teardown
/// - State synchronization between controller and UI
/// - Notification polling
/// 
/// Does NOT contain business logic - only coordinates state
mixin HomeStateMixin<T extends StatefulWidget> on State<T> {
  late HomeController homeController;
  late NotificationController _notificationController;
  Timer? _notificationPollTimer;
  
  int currentBottomNavIndex = 0;
  String searchQuery = '';
  int notificationUnreadCount = 0;
  List<ListingModel> recentlyViewedListings = [];
  bool isLoadingRecentlyViewed = false;

  /// Initialize controllers and set up listeners
  void initializeHomeController({Function(int)? onNavigateToTab}) {
    homeController = HomeController();
    homeController.onNavigateToTab = onNavigateToTab;
    homeController.onShowComingSoon = _showComingSoonMessage;
    
    // Add listener to rebuild when controller state changes
    homeController.addListener(_onHomeControllerChanged);

    // Notification badge controller
    _notificationController = NotificationController();
    _notificationController.addListener(_onNotificationCountChanged);

    // Poll unread count every 60 seconds
    _notificationPollTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _notificationController.fetchUnreadCount(),
    );
  }

  /// Handle notification unread count changes
  void _onNotificationCountChanged() {
    if (mounted) {
      setState(() {
        notificationUnreadCount = _notificationController.unreadCount;
      });
    }
  }

  /// Handle home controller state changes (auto-rebuild UI)
  void _onHomeControllerChanged() {
    if (mounted) {
      setState(() {
        // Rebuild when controller state changes
      });

      // Show error if any (requires ToastMixin)
      if (homeController.errorMessage != null) {
        try {
          (this as dynamic).showErrorToast(homeController.errorMessage!);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(homeController.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        homeController.clearError();
      }
    }
  }

  /// Sync recently viewed listings from controller to local state
  Future<void> syncRecentlyViewedListings() async {
    setState(() {
      isLoadingRecentlyViewed = true;
    });

    try {
      await homeController.fetchRecentlyViewedListings();
      
      if (mounted) {
        setState(() {
          recentlyViewedListings = homeController.recentlyViewedListings;
          isLoadingRecentlyViewed = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingRecentlyViewed = false;
        });
      }
    }
  }

  /// Update search query state
  void updateSearchQuery(String query) {
    if (mounted) {
      setState(() => searchQuery = query);
    }
  }

  /// Set bottom navigation index
  void setBottomNavIndex(int index) {
    if (mounted) {
      setState(() => currentBottomNavIndex = index);
    }
  }

  /// Show coming soon message (private)
  void _showComingSoonMessage(String feature) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$feature feature coming soon!')),
      );
    }
  }

  /// Show coming soon message (public wrapper)
  void showComingSoonMessage(String feature) => _showComingSoonMessage(feature);

  /// Handle listing tap - navigate to detail and sync recently viewed
  void handleListingTap(dynamic listing) {
    if (listing is ListingModel) {
      homeController.navigateToListingDetail(context, listing);
      syncRecentlyViewedListings();
    }
  }

  /// Get current user from controller
  UserModel? get currentUser => homeController.currentUser;

  /// Dispose controllers and cleanup
  void disposeHomeController() {
    _notificationPollTimer?.cancel();
    homeController.removeListener(_onHomeControllerChanged);
    homeController.dispose();
    _notificationController.removeListener(_onNotificationCountChanged);
    _notificationController.dispose();
  }
}

