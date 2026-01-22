import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/features/viewalllistings/controllers/viewalllistings_controller.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';

/// Mixin for view all listings page state management and business logic
mixin ViewAllListingsStateMixin<T extends StatefulWidget> on State<T> {
  late ViewAllListingsController controller;
  late TextEditingController searchController;

  /// Initialize controller
  void initializeController() {
    controller = ViewAllListingsController();
    searchController = TextEditingController();
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
    await controller.setSearchQuery(value);
    
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
    if (index == 0) {
      // Navigate back to home page
      Navigator.pop(context);
    } else {
      // Use the default handler from HomeStateMixin for other tabs
      defaultHandler(index);
    }
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
