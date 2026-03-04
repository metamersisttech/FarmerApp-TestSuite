import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/home/controllers/home_controller.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';
import 'package:flutter_app/features/notifications/controllers/notification_controller.dart';

/// Mixin for common home page state management and business logic coordination
/// Requires ToastMixin to be mixed in the using class
mixin HomeStateMixin<T extends StatefulWidget> on State<T> {
  late HomeController homeController;
  late NotificationController _notificationController;
  Timer? _notificationPollTimer;
  UserModel? currentUser;
  int currentBottomNavIndex = 0;
  String searchQuery = '';
  bool _isLoadingUserData = false;
  int notificationUnreadCount = 0;

  // Recently viewed listings
  List<ListingModel> recentlyViewedListings = [];
  bool isLoadingRecentlyViewed = false;

  /// Initialize home controller
  void initializeHomeController() {
    homeController = HomeController();
    // Add listener to rebuild when controller state changes
    homeController.addListener(_onHomeControllerChanged);

    // Notification badge controller
    _notificationController = NotificationController();
    _notificationController.addListener(_onNotificationCountChanged);

    // Poll unread count every 60 seconds
    _notificationPollTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => fetchNotificationUnreadCount(),
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

  /// Fetch notification unread count for badge
  Future<void> fetchNotificationUnreadCount() async {
    await _notificationController.fetchUnreadCount();
  }

  /// Handle home controller state changes
  void _onHomeControllerChanged() {
    if (mounted) {
      setState(() {
        // Rebuild when controller state changes
      });

      // Show error if any (and clear it after showing)
      if (homeController.errorMessage != null) {
        // Use showErrorToast from ToastMixin if available
        try {
          // This requires ToastMixin to be mixed in the using class
          (this as dynamic).showErrorToast(homeController.errorMessage!);
        } catch (e) {
          // Fallback to SnackBar if ToastMixin not available
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

  /// Load user data from storage
  Future<void> loadUserFromStorage() async {
    if (_isLoadingUserData) return;
    
    _isLoadingUserData = true;
    
    try {
      final commonHelper = CommonHelper();
      final user = await commonHelper.getLoggedInUser();
      if (user != null && mounted) {
        setState(() {
          currentUser = user;
        });
      }
    } catch (e) {
      print('[HomeStateMixin] Error loading user: $e');
    } finally {
      _isLoadingUserData = false;
    }
  }

  /// Fetch listings from API
  Future<void> fetchListings() async {
    await homeController.fetchListings();
    // No need for setState - listener handles it
  }

  /// Handle listing tap
  void handleListingTap(dynamic listing) {
    if (listing is ListingModel) {
      // Track the view (don't await to avoid delaying navigation)
      trackListingView(listing.id);
      
      // Navigate to details
      HomeNavigationService.toAnimalDetail(context, listing.id);
    }
  }

  /// Set bottom navigation index
  void setBottomNavIndex(int index) {
    if (mounted) {
      setState(() => currentBottomNavIndex = index);
    }
  }

  /// Reset to home tab
  void resetToHomeTab() {
    setBottomNavIndex(0);
  }

  /// Update search query
  void updateSearchQuery(String query) {
    if (mounted) {
      setState(() => searchQuery = query);
    }
  }

  /// Clear search
  void clearSearch() {
    if (mounted) {
      setState(() => searchQuery = '');
    }
  }

  /// Handle search input
  void handleSearch(String value) {
    updateSearchQuery(value);
    homeController.searchListings(value);
  }

  /// Handle bottom navigation tap
  void handleBottomNavTap(int index) {
    setBottomNavIndex(index);

    NavigationResult result;
    switch (index) {
      case 0:
        // Home - refresh recently viewed when returning to home
        print('[HomeStateMixin] 🏠 Returned to home, refreshing recently viewed...');
        fetchRecentlyViewedListings();
        return;
      case 1:
        // Favorite/Saved
        handleFavoriteTap();
        return;
      case 2:
        // Community
        result = HomeNavigationService.toMyAds(context);
        break;
      case 3:
        // Profile
        handleProfileTap();
        return;
      default:
        return;
    }

    if (!result.success && result.message != null) {
      showComingSoonMessage(result.message!.replaceAll(' feature coming soon!', ''));
    }
  }

  /// Handle add button tap
  void handleAddTap() {
    HomeNavigationService.toSell(
      context,
      onReturn: onReturnFromSell,
    );
  }

  /// Callback when returning from Sell page
  void onReturnFromSell() {
    resetToHomeTab();
    fetchListings();
  }

  /// Handle notification tap
  void handleNotificationTap() {
    final result = HomeNavigationService.toNotifications(context);
    if (!result.success && result.message != null) {
      showComingSoonMessage(result.message!.replaceAll(' feature coming soon!', ''));
    }
  }

  /// Handle profile tap
  Future<void> handleProfileTap() async {
    final result = HomeNavigationService.toProfile(context);
    
    if (result.success) {
      await loadUserFromStorage();
    } else if (result.message != null) {
      showComingSoonMessage(result.message!.replaceAll(' feature coming soon!', ''));
    }
  }

  /// Handle wallet tap
  void handleWalletTap() {
    final result = HomeNavigationService.toWallet(context);
    if (!result.success && result.message != null) {
      showComingSoonMessage(result.message!.replaceAll(' feature coming soon!', ''));
    }
  }

  /// Handle favorite icon tap
  void handleFavoriteTap() {
    final result = HomeNavigationService.toSaved(context);
    if (!result.success && result.message != null) {
      showComingSoonMessage(result.message!.replaceAll(' feature coming soon!', ''));
    }
  }

  /// Fetch recently viewed listings from cache
  Future<void> fetchRecentlyViewedListings() async {
    print('[HomeStateMixin] 🔍 Starting to fetch recently viewed listings...');
    
    setState(() {
      isLoadingRecentlyViewed = true;
    });

    try {
      await homeController.fetchRecentlyViewedListings();
      
      print('[HomeStateMixin] 📊 Controller has ${homeController.recentlyViewedListings.length} listings');
      
      if (mounted) {
        setState(() {
          recentlyViewedListings = homeController.recentlyViewedListings;
          isLoadingRecentlyViewed = false;
        });
        
        print('[HomeStateMixin] ✅ State updated with ${recentlyViewedListings.length} recently viewed listings');
      }
    } catch (e) {
      print('[HomeStateMixin] ❌ Error fetching recently viewed: $e');
      if (mounted) {
        setState(() {
          isLoadingRecentlyViewed = false;
        });
      }
    }
  }

  /// Track viewed listing and refresh recently viewed
  Future<void> trackListingView(int listingId) async {
    await homeController.trackViewedListing(listingId);
    // Optionally refresh the recently viewed list
    await fetchRecentlyViewedListings();
  }

  /// Show feature coming soon message
  void showComingSoonMessage(String feature) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$feature feature coming soon!')),
      );
    }
  }

  /// Dispose controller
  void disposeHomeController() {
    _notificationPollTimer?.cancel();
    homeController.removeListener(_onHomeControllerChanged);
    homeController.dispose();
    _notificationController.removeListener(_onNotificationCountChanged);
    _notificationController.dispose();
  }
}

