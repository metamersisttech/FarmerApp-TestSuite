import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/cache/cache_manager.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';
import 'package:flutter_app/features/viewalllistings/controllers/viewalllistings_controller.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/main.dart' show firebaseSync;

/// Mixin for view all listings page state management and business logic
mixin ViewAllListingsStateMixin<T extends StatefulWidget> on State<T> {
  late ViewAllListingsController controller;
  late TextEditingController searchController;

  /// Initialize controller with Firebase sync service
  void initializeController() {
    // Pass firebaseSync instance to controller for cache invalidation
    controller = ViewAllListingsController(firebaseSync);
    searchController = TextEditingController();
    // Add listener to rebuild UI when controller notifies changes
    controller.addListener(_onControllerUpdate);
    
    // Initialize controller (registers Firebase listener)
    controller.init();
  }

  /// Called when controller notifies changes
  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Fetch marketplace listings from service
  Future<void> fetchMarketplaceListings() async {
    if (kDebugMode) {
      print('[ViewAllListingsStateMixin] fetchMarketplaceListings called');
    }

    await controller.fetchListings();

    if (!mounted) return;

    setState(() {});

    if (kDebugMode) {
      print('[ViewAllListingsStateMixin] After fetch - hasListings: ${controller.hasListings}, count: ${controller.listingsCount}, isLoading: ${controller.isLoading}, error: ${controller.errorMessage}');
    }

    if (controller.errorMessage != null) {
      _showErrorMessage(controller.errorMessage!);
    }
  }

  /// Handle search input for marketplace listings
  Future<void> handleListingsSearch(String value) async {
    await controller.setSearchQuery(value);
    
    if (mounted) {
      setState(() {});
    }
  }

  /// Handle listing tap
  void handleListingTap(dynamic listing) {
    if (listing is ListingModel) {
      // Track this listing as viewed for "Recently Viewed Ads" section
      print('[ViewAllListings] 📝 Tracking view for listing ID: ${listing.id}');
      trackListingView(listing.id);
      
      // Navigate to detail page and reload favorites when returning
      Navigator.pushNamed(
        context, 
        AppRoutes.animalDetail, 
        arguments: listing.id,
      ).then((_) async {
        // Reload favorites when returning from detail page
        print('[ViewAllListings] 🔄 Returned from animal detail, reloading favorites...');
        await controller.loadFavorites();
        if (mounted) {
          setState(() {});
          print('[ViewAllListings] ✅ UI refreshed after loading favorites');
        }
      });
    }
  }
  
  /// Track a listing as viewed
  Future<void> trackListingView(int listingId) async {
    try {
      await CacheManager().trackViewedListing(listingId);
      print('[ViewAllListings] ✅ Tracked listing $listingId in recently viewed');
    } catch (e) {
      print('[ViewAllListings] ❌ Error tracking listing view: $e');
    }
  }

  /// Handle category selection
  Future<void> handleCategorySelected(String category) async {
    await controller.setSelectedCategory(category);
    
    if (mounted) {
      setState(() {});
    }
  }

  /// Handle refresh
  Future<void> handleRefresh() async {
    await controller.refreshListings();
    
    if (mounted) {
      setState(() {});
    }
  }

  /// Handle bottom navigation with custom logic for marketplace page
  void handleMarketplaceBottomNavigation(int index, Function(int) defaultHandler) {
    // For all navigation items, pop back to MainShellPage and let it handle the tab switching
    // Pass the target tab index as a result
    Navigator.pop(context, index);
  }

  /// Handle sort and filter apply
  Future<void> handleSortFilterApply(String sortBy, String order) async {
    await controller.setApiSorting(sortBy, order);
    
    if (mounted) {
      setState(() {});
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
