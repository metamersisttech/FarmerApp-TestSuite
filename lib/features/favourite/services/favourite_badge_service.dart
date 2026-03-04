import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/features/favourite/services/favourite_listings_service.dart';

/// Service to manage favorite listings badge count
/// Shows count of NEW favorites since last visit
class FavouriteBadgeService {
  static const String _lastViewedKey = 'favourite_listings_last_viewed';
  
  final FavouriteListingsService _favouriteService;
  
  FavouriteBadgeService({
    FavouriteListingsService? favouriteService,
  }) : _favouriteService = favouriteService ?? FavouriteListingsService();

  /// Get the count of new favorites since last visit
  Future<int> getNewFavoritesCount() async {
    try {
      print('[FavouriteBadgeService] 🔍 Starting badge count calculation...');
      
      final prefs = await SharedPreferences.getInstance();
      final lastViewed = prefs.getString(_lastViewedKey);
      
      print('[FavouriteBadgeService] Last viewed timestamp: $lastViewed');
      
      // Fetch all favorites
      print('[FavouriteBadgeService] Fetching favorites from API...');
      final favorites = await _favouriteService.fetchFavorites();
      
      print('[FavouriteBadgeService] ✅ Fetched ${favorites.length} favorites');
      
      if (favorites.isEmpty) {
        print('[FavouriteBadgeService] No favorites found, returning 0');
        return 0;
      }
      
      // If never viewed, ALL favorites are new - show total count
      if (lastViewed == null) {
        print('[FavouriteBadgeService] 🆕 Never viewed before! Showing all ${favorites.length} favorites as new');
        return favorites.length;
      }
      
      // Parse last viewed timestamp
      final lastViewedDate = DateTime.parse(lastViewed);
      print('[FavouriteBadgeService] Last viewed date: $lastViewedDate');
      
      // Count favorites created after last viewed
      int newCount = 0;
      for (var favorite in favorites) {
        try {
          // Get the created_at timestamp from favorite
          final createdAt = favorite['created_at'] as String?;
          if (createdAt != null) {
            final favoriteDate = DateTime.parse(createdAt);
            if (favoriteDate.isAfter(lastViewedDate)) {
              newCount++;
              print('[FavouriteBadgeService] ✓ New favorite: created at $favoriteDate');
            } else {
              print('[FavouriteBadgeService] ✗ Old favorite: created at $favoriteDate');
            }
          }
        } catch (e) {
          print('[FavouriteBadgeService] ⚠️ Error parsing favorite date: $e');
          continue;
        }
      }
      
      print('[FavouriteBadgeService] 📊 Returning badge count: $newCount');
      return newCount;
    } catch (e) {
      print('[FavouriteBadgeService] ❌ ERROR in getNewFavoritesCount: $e');
      print('[FavouriteBadgeService] Stack trace: ${StackTrace.current}');
      return 0;
    }
  }

  /// Mark favorites as viewed (clear badge)
  Future<void> markAsViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastViewedKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Silently fail
    }
  }

  /// Reset last viewed timestamp (for testing)
  Future<void> resetLastViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastViewedKey);
    } catch (e) {
      // Silently fail
    }
  }
}
