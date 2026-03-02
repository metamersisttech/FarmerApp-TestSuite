import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/features/recentlyviewed/controllers/recentlyviewed_controller.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';

/// Mixin for recently viewed listings page state management and business logic
mixin RecentlyViewedStateMixin<T extends StatefulWidget> on State<T> {
  late RecentlyViewedController controller;
  late TextEditingController searchController;

  /// Initialize controller
  void initializeController() {
    controller = RecentlyViewedController();
    searchController = TextEditingController();
    // Add listener to rebuild UI when controller notifies changes
    controller.addListener(_onControllerUpdate);
    
    // Initialize controller
    controller.init();
  }

  /// Called when controller notifies changes
  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Fetch recently viewed listings from service
  Future<void> fetchRecentlyViewedListings() async {
    if (kDebugMode) {
      print('[RecentlyViewedStateMixin] fetchRecentlyViewedListings called');
    }

    await controller.fetchListings();

    if (!mounted) return;

    setState(() {});

    if (kDebugMode) {
      print('[RecentlyViewedStateMixin] After fetch - hasListings: ${controller.hasListings}, count: ${controller.listingsCount}, isLoading: ${controller.isLoading}, error: ${controller.errorMessage}');
    }

    if (controller.errorMessage != null) {
      _showErrorMessage(controller.errorMessage!);
    }
  }

  /// Handle search input for recently viewed listings
  void handleListingsSearch(String value) {
    controller.setSearchQuery(value);
    
    if (mounted) {
      setState(() {});
    }
  }

  /// Handle listing tap
  void handleListingTap(dynamic listing) {
    if (listing is ListingModel) {
      // Navigate to detail page
      HomeNavigationService.toAnimalDetail(context, listing.id);
    }
  }

  /// Handle refresh
  Future<void> handleRefresh() async {
    await controller.refreshListings();
    
    if (mounted) {
      setState(() {});
    }
  }

  /// Handle bottom navigation with custom logic for recently viewed page
  void handleRecentlyViewedBottomNavigation(int index, Function(int) defaultHandler) {
    if (index == 0) {
      // Navigate back to home page
      Navigator.pop(context);
    } else {
      // Use the default handler from HomeStateMixin for other tabs
      defaultHandler(index);
    }
  }

  /// Show error message
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show success message
  void showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Dispose controller
  void disposeController() {
    controller.removeListener(_onControllerUpdate);
    controller.dispose();
    searchController.dispose();
  }
}
