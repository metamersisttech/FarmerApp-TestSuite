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
      _logInfo('Starting badge count calculation...');
      
      final lastViewed = await _getLastViewedTimestamp();
      final favorites = await _fetchFavorites();
      
      if (_isFavoritesEmpty(favorites)) {
        return 0;
      }
      
      final cutoffDate = _determineCutoffDate(lastViewed, favorites);
      final newCount = _countFavoritesAfter(favorites, cutoffDate);
      
      _logInfo('Returning badge count: $newCount');
      return newCount;
    } catch (e) {
      _logError('ERROR in getNewFavoritesCount', e);
      return 0;
    }
  }

  /// Fetch last viewed timestamp from storage
  Future<DateTime?> _getLastViewedTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final lastViewedString = prefs.getString(_lastViewedKey);
    
    _logInfo('Last viewed timestamp: $lastViewedString');
    
    if (lastViewedString == null) {
      return null;
    }
    
    try {
      return DateTime.parse(lastViewedString);
    } catch (e) {
      _logWarning('Failed to parse last viewed timestamp: $e');
      return null;
    }
  }

  /// Fetch all favorites from service
  Future<List<dynamic>> _fetchFavorites() async {
    _logInfo('Fetching favorites from API...');
    final favorites = await _favouriteService.fetchFavorites();
    _logInfo('Fetched ${favorites.length} favorites');
    return favorites;
  }

  /// Check if favorites list is empty
  bool _isFavoritesEmpty(List<dynamic> favorites) {
    if (favorites.isEmpty) {
      _logInfo('No favorites found, returning 0');
      return true;
    }
    return false;
  }

  /// Determine the cutoff date based on last viewed timestamp
  /// For favorites: if never viewed, return epoch (shows all favorites)
  /// If viewed before, return last viewed date
  DateTime _determineCutoffDate(DateTime? lastViewed, List<dynamic> favorites) {
    if (lastViewed != null) {
      _logInfo('Last viewed date: $lastViewed');
      return lastViewed;
    }
    
    // Never viewed before - show all favorites as new
    _logInfo('Never viewed before! Showing all ${favorites.length} favorites as new');
    return DateTime.fromMillisecondsSinceEpoch(0); // Epoch - everything is newer
  }

  /// Count favorites created after the given cutoff date
  int _countFavoritesAfter(List<dynamic> favorites, DateTime cutoffDate) {
    return favorites
        .where(_hasValidCreatedAt)
        .where((favorite) => _isCreatedAfter(favorite, cutoffDate))
        .length;
  }

  /// Check if favorite has a valid created_at timestamp
  bool _hasValidCreatedAt(dynamic favorite) {
    if (favorite is! Map<String, dynamic>) {
      return false;
    }
    return favorite['created_at'] != null;
  }

  /// Check if favorite was created after the cutoff date
  bool _isCreatedAfter(dynamic favorite, DateTime cutoffDate) {
    try {
      final createdAtString = favorite['created_at'] as String;
      final createdAt = DateTime.parse(createdAtString);
      final isNew = createdAt.isAfter(cutoffDate);
      
      if (isNew) {
        _logInfo('✓ New favorite: created at $createdAt');
      }
      
      return isNew;
    } catch (e) {
      _logWarning('Error parsing favorite date: $e');
      return false;
    }
  }

  /// Logging helpers
  void _logInfo(String message) {
    print('[FavouriteBadgeService] 🔍 $message');
  }

  void _logWarning(String message) {
    print('[FavouriteBadgeService] ⚠️ $message');
  }

  void _logError(String message, Object error) {
    print('[FavouriteBadgeService] ❌ $message: $error');
    print('[FavouriteBadgeService] Stack trace: ${StackTrace.current}');
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
