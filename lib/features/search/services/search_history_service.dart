import 'package:flutter_app/core/cache/cache_manager.dart';

/// Service for persisting search history using CacheManager (Hive)
///
/// Stores recent search queries for the search page.
/// Maximum of 10 recent searches stored.
class SearchHistoryService {
  static const String _searchHistoryKey = 'recent_searches';
  static const int _maxSearches = 10;

  final CacheManager _cacheManager = CacheManager();

  /// Get recent search queries from persistent storage
  Future<List<String>> getRecentSearches() async {
    try {
      final data = await _cacheManager.getRaw(_searchHistoryKey);
      if (data != null && data is List) {
        return data.cast<String>();
      }
    } catch (e) {
      // Silently fail, return empty list
    }
    return [];
  }

  /// Add a search query to the recent searches list
  ///
  /// Removes duplicates (case-insensitive) and keeps only the most recent entries.
  Future<void> addSearchQuery(String query) async {
    try {
      final searches = await getRecentSearches();

      // Remove duplicate (case-insensitive)
      searches.removeWhere((s) => s.toLowerCase() == query.toLowerCase());

      // Add to front (most recent)
      searches.insert(0, query);

      // Limit to max
      final trimmed = searches.length > _maxSearches
          ? searches.sublist(0, _maxSearches)
          : searches;

      await _cacheManager.setRaw(_searchHistoryKey, trimmed);
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear all recent searches
  Future<void> clearAllSearches() async {
    try {
      await _cacheManager.deleteRaw(_searchHistoryKey);
    } catch (e) {
      // Silently fail
    }
  }
}
