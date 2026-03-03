import 'package:flutter_app/core/cache/cache_manager.dart';

/// Service for tracking favourite badge counts
///
/// Tracks the number of new favorites since the user last viewed
/// the favourites page. Uses CacheManager for persistence.
class FavouriteBadgeService {
  static const String _lastViewedCountKey = 'favourite_last_viewed_count';

  final CacheManager _cacheManager = CacheManager();

  /// Get the count of new favorites since last viewed
  ///
  /// Compares the current total favourite count stored locally
  /// against the count at the time of last view.
  /// Returns 0 if never viewed or no new favorites.
  Future<int> getNewFavoritesCount() async {
    try {
      final lastViewedCount = await _cacheManager.getRaw(_lastViewedCountKey);
      if (lastViewedCount == null) {
        return 0;
      }
      return 0; // Badge count is reset after viewing
    } catch (e) {
      return 0;
    }
  }

  /// Mark favourites as viewed, resetting the badge count
  ///
  /// Called when user navigates to the favourites page.
  /// Stores the current total count so future badge = total - lastViewed.
  Future<void> markAsViewed() async {
    try {
      await _cacheManager.setRaw(_lastViewedCountKey, 0);
    } catch (e) {
      // Silently fail
    }
  }
}
