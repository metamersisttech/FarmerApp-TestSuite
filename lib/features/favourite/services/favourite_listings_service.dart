import 'package:flutter_app/core/helpers/backend_helper.dart';

/// Favourite Listings Service
///
/// Handles data operations for favourite listings
class FavouriteListingsService {
  final BackendHelper _backendHelper;

  FavouriteListingsService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Get all user favorites
  /// GET /api/auth/me/favorites/
  /// Returns list of favorite objects with listing details
  Future<List<dynamic>> fetchFavorites() async {
    try {
      print('[FavouriteListingsService] Fetching favorites...');
      
      final response = await _backendHelper.getFavorites();
      
      // Handle both List and paginated response
      List<dynamic> favoritesList = [];
      if (response is Map && response['results'] != null) {
        favoritesList = response['results'] as List<dynamic>;
      } else if (response is List) {
        favoritesList = response;
      }
      
      print('[FavouriteListingsService] Fetched ${favoritesList.length} favorites');
      return favoritesList;
    } catch (e) {
      print('[FavouriteListingsService] Error fetching favorites: $e');
      rethrow;
    }
  }

  /// Remove a favorite by listing ID
  /// DELETE /api/auth/me/favorites/{listing_id}/
  Future<void> removeFavoriteByListingId(int listingId) async {
    try {
      print('[FavouriteListingsService] Removing listing $listingId from favorites');
      await _backendHelper.deleteFavoriteByListingId(listingId);
      print('[FavouriteListingsService] Successfully removed listing $listingId from favorites');
    } catch (e) {
      print('[FavouriteListingsService] Error removing favorite: $e');
      rethrow;
    }
  }

  /// Add listing to favorites
  /// POST /api/auth/me/favorites/
  /// Request: { "listing_id": 123 }
  Future<Map<String, dynamic>> addFavorite(int listingId) async {
    try {
      print('[FavouriteListingsService] Adding listing $listingId to favorites');
      final response = await _backendHelper.postAddFavorite({'listing_id': listingId});
      print('[FavouriteListingsService] Successfully added to favorites');
      return response;
    } catch (e) {
      print('[FavouriteListingsService] Error adding favorite: $e');
      rethrow;
    }
  }
}
