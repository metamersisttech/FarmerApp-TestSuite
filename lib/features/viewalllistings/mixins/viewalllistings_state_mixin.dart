import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/features/viewalllistings/controllers/viewalllistings_controller.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';

/// Mixin for view all listings page state management and business logic
mixin ViewAllListingsStateMixin<T extends StatefulWidget> on State<T> {
  late ViewAllListingsController controller;
  String searchQuery = '';

  /// Initialize controller
  void initializeController() {
    controller = ViewAllListingsController();
    // Add listener to rebuild UI when controller notifies changes
    controller.addListener(_onControllerUpdate);
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
    searchQuery = value;
    await controller.searchListings(value);
    
    if (mounted) {
      setState(() {});
    }
  }

  /// Handle listing tap
  void handleListingTap(dynamic listing) {
    if (listing is ListingModel) {
      HomeNavigationService.toAnimalDetail(context, listing.id);
    }
  }

  /// Handle sort change
  void handleSortChange(String sortBy) {
    controller.setSortBy(sortBy);
    
    if (mounted) {
      setState(() {});
    }
  }

  /// Handle filter apply
  Future<void> handleFilterApply({
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    await controller.filterListings(
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

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
    if (index == 0) {
      // Navigate back to home page
      Navigator.pop(context);
    } else {
      // Use the default handler from HomeStateMixin for other tabs
      defaultHandler(index);
    }
  }

  /// Show sort bottom sheet
  void showSortBottomSheet(BuildContext context, Widget sortBottomSheet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => sortBottomSheet,
    );
  }

  /// Show filter bottom sheet (placeholder)
  void showFilterBottomSheet() {
    showSuccessMessage('Filter feature coming soon!');
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
  }
}
