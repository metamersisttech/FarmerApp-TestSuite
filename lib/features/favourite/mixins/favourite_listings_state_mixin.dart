import 'package:flutter/material.dart';
import 'package:flutter_app/features/favourite/controllers/favourite_listings_controller.dart';

/// Favourite Listings State Mixin
///
/// Manages UI state for favourite listings page
mixin FavouriteListingsStateMixin<T extends StatefulWidget> on State<T> {
  late FavouriteListingsController controller;

  @override
  void initState() {
    super.initState();
    controller = FavouriteListingsController();
    controller.addListener(_onControllerUpdate);
    
    // Fetch favorites after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchFavorites();
    });
  }

  /// Dispose controller
  void disposeController() {
    controller.removeListener(_onControllerUpdate);
    controller.dispose();
  }

  /// Called when controller notifies changes
  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Fetch favorites
  Future<void> fetchFavorites() async {
    await controller.fetchFavorites();
  }

  /// Handle refresh
  Future<void> handleRefresh() async {
    await controller.refresh();
  }

  /// Handle remove favorite
  Future<void> handleRemoveFavorite(int listingId) async {
    await controller.removeFavorite(listingId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handle listing tap - navigate to detail page
  void handleListingTap(Map<String, dynamic> listing) {
    // Check both listing_id and id fields
    final listingId = listing['listing_id'] ?? listing['id'];
    if (listingId != null) {
      Navigator.pushNamed(
        context,
        '/animal-detail',
        arguments: listingId, // Pass just the ID, not a map
      ).then((_) {
        // Refresh favorites when returning from detail page
        // in case favorite status changed
        fetchFavorites();
      });
    }
  }

  /// Show error message
  void showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
