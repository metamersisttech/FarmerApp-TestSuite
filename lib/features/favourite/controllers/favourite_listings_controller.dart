import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/favourite/services/favourite_listings_service.dart';

/// Favourite Listings Controller
///
/// Manages the state and business logic for favourite listings
class FavouriteListingsController extends BaseController {
  final FavouriteListingsService _service;

  List<dynamic> _favorites = [];

  /// List of favorite items
  List<dynamic> get favorites => _favorites;

  /// Whether there are any favorites
  bool get hasFavorites => _favorites.isNotEmpty;

  /// Count of favorites
  int get favoritesCount => _favorites.length;

  FavouriteListingsController({FavouriteListingsService? service})
      : _service = service ?? FavouriteListingsService();

  /// Fetch all favorites from the API
  Future<void> fetchFavorites() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      debugPrint('[FavouriteListingsController] Fetching favorites...');

      _favorites = await _service.fetchFavorites();

      if (isDisposed) return;

      debugPrint('[FavouriteListingsController] ✅ Loaded ${_favorites.length} favorites');
      debugPrint('[FavouriteListingsController] hasFavorites: $hasFavorites');
      debugPrint('[FavouriteListingsController] favoritesCount: $favoritesCount');
      debugPrint('[FavouriteListingsController] _favorites list: $_favorites');
      
      // Debug: Print each favorite's structure
      if (_favorites.isNotEmpty && kDebugMode) {
        for (var i = 0; i < _favorites.length; i++) {
          debugPrint('[FavouriteListingsController] 📦 Favorite $i: ${_favorites[i]}');
          final listing = getListingFromFavorite(_favorites[i]);
          debugPrint('[FavouriteListingsController] 📄 Listing $i data: $listing');
          final listingId = getListingId(_favorites[i]);
          debugPrint('[FavouriteListingsController] 🆔 Listing $i ID: $listingId');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('[FavouriteListingsController] ❌ Error: $e');
      if (!isDisposed) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        setError(errorMessage.isEmpty ? 'Failed to load favorites' : errorMessage);
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Remove a favorite by listing ID
  Future<void> removeFavorite(int listingId) async {
    if (isDisposed) return;

    try {
      debugPrint('[FavouriteListingsController] Removing listing $listingId from favorites');

      // Optimistic update - remove from list immediately
      _favorites.removeWhere((fav) {
        final listing = fav['listing'];
        if (listing is Map) {
          // Check both listing_id and id fields
          return listing['listing_id'] == listingId || listing['id'] == listingId;
        }
        return fav['listing_id'] == listingId;
      });
      notifyListeners();

      // Make API call with listing ID
      await _service.removeFavoriteByListingId(listingId);

      debugPrint('[FavouriteListingsController] Successfully removed listing $listingId from favorites');
    } catch (e) {
      debugPrint('[FavouriteListingsController] Error removing favorite: $e');
      
      // Revert on error
      if (!isDisposed) {
        await fetchFavorites(); // Refresh to get accurate state
        setError('Failed to remove favorite');
      }
    }
  }

  /// Refresh favorites
  Future<void> refresh() async {
    await fetchFavorites();
  }

  /// Get listing from favorite object
  Map<String, dynamic>? getListingFromFavorite(dynamic favorite) {
    if (favorite is Map) {
      return favorite['listing'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// Get listing ID from favorite object
  int? getListingId(dynamic favorite) {
    if (favorite is Map) {
      final listing = favorite['listing'];
      if (listing is Map) {
        // Check both listing_id and id fields
        if (listing['listing_id'] != null) {
          return listing['listing_id'] as int?;
        }
        if (listing['id'] != null) {
          return listing['id'] as int?;
        }
      }
      // Fallback to listing_id at root level if listing object not available
      return favorite['listing_id'] as int?;
    }
    return null;
  }
}
