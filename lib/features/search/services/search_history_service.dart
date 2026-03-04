import 'package:flutter_app/core/cache/cache_manager.dart';

/// Search History Service
///
/// Manages persistent storage of user's recent search queries using Hive cache.
/// Search history persists across app restarts and user logouts.
/// 
/// Storage: Hive disk cache (same pattern as recently viewed listings)
/// TTL: 30 days (searches older than 30 days are automatically removed)
/// Limit: Top 5 most recent searches
class SearchHistoryService {
  final CacheManager _cacheManager = CacheManager();
  
  static const String _searchHistoryKey = 'recent_search_queries';
  static const int _maxRecentSearches = 5; // Only keep top 5
  static const Duration _searchHistoryTTL = Duration(days: 30); // 30 days persistence

  /// Get recent search queries (most recent first)
  /// Returns only searches performed within the last 30 days
  Future<List<String>> getRecentSearches() async {
    try {
      print('[SearchHistoryService] 📖 Loading recent searches from cache...');
      
      final searchList = await _getRecentSearchesWithTimestamps();
      
      // Filter out entries older than TTL
      final now = DateTime.now().millisecondsSinceEpoch;
      final ttlMs = _searchHistoryTTL.inMilliseconds;
      final validEntries = searchList.where((entry) {
        final timestamp = entry['timestamp'] as int;
        final age = now - timestamp;
        return age <= ttlMs;
      }).toList();
      
      // Extract queries
      final queries = validEntries
          .map((e) => e['query'] as String)
          .toList();
      
      print('[SearchHistoryService] ✅ Retrieved ${queries.length} recent searches (filtered from ${searchList.length}): $queries');
      
      // If we filtered out expired entries, update storage
      if (validEntries.length < searchList.length) {
        await _saveSearchHistory(validEntries);
        print('[SearchHistoryService] 🧹 Cleaned up ${searchList.length - validEntries.length} expired entries');
      }
      
      return queries;
    } catch (e) {
      print('[SearchHistoryService] ❌ Error loading recent searches: $e');
      return [];
    }
  }

  /// Add search query to recent searches
  /// 
  /// - Removes duplicates (case-insensitive)
  /// - Adds to front (most recent)
  /// - Limits to top 5 searches
  /// - Persists to disk cache
  Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final trimmedQuery = query.trim();
      print('[SearchHistoryService] 📝 Adding search query: "$trimmedQuery"');
      
      final searchList = await _getRecentSearchesWithTimestamps();
      print('[SearchHistoryService] 📋 Current history: ${searchList.length} entries');
      
      // Remove if already exists (case-insensitive comparison)
      searchList.removeWhere((entry) => 
        (entry['query'] as String).toLowerCase() == trimmedQuery.toLowerCase()
      );
      
      // Add to front (most recent) with current timestamp
      searchList.insert(0, {
        'query': trimmedQuery,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      print('[SearchHistoryService] ➕ Added "$trimmedQuery" to front with timestamp');
      
      // Limit to max searches (top 5)
      if (searchList.length > _maxRecentSearches) {
        final removed = searchList.length - _maxRecentSearches;
        searchList.removeRange(_maxRecentSearches, searchList.length);
        print('[SearchHistoryService] ✂️ Trimmed to top $_maxRecentSearches (removed $removed old searches)');
      }
      
      // Save to disk cache
      await _saveSearchHistory(searchList);
      print('[SearchHistoryService] ✅ Saved to cache (Total: ${searchList.length})');
    } catch (e) {
      print('[SearchHistoryService] ❌ Error adding search query: $e');
    }
  }

  /// Clear all recent searches
  Future<void> clearAllSearches() async {
    try {
      print('[SearchHistoryService] 🗑️ Clearing all recent searches...');
      await _cacheManager.deleteRaw(_searchHistoryKey);
      print('[SearchHistoryService] ✅ Recent searches cleared');
    } catch (e) {
      print('[SearchHistoryService] ❌ Error clearing searches: $e');
    }
  }

  /// Get recent searches with timestamps (internal method)
  /// Returns list of {query: String, timestamp: int} maps
  Future<List<Map<String, dynamic>>> _getRecentSearchesWithTimestamps() async {
    try {
      final data = await _cacheManager.getRaw(_searchHistoryKey);
      if (data != null && data is List) {
        final entries = <Map<String, dynamic>>[];
        for (final item in data) {
          if (item is Map) {
            // Format: {query: "Jersey Cow", timestamp: 1234567890}
            entries.add(Map<String, dynamic>.from(item));
          } else if (item is String) {
            // Old format migration: just string query - add current timestamp
            entries.add({
              'query': item,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });
          }
        }
        return entries;
      }
    } catch (e) {
      print('[SearchHistoryService] ❌ Error getting search history: $e');
    }
    return [];
  }

  /// Save search history to disk cache (internal method)
  Future<void> _saveSearchHistory(List<Map<String, dynamic>> searchList) async {
    try {
      await _cacheManager.setRaw(_searchHistoryKey, searchList);
      print('[SearchHistoryService] 💾 Saved ${searchList.length} search queries to Hive');
    } catch (e) {
      print('[SearchHistoryService] ❌ Error saving search history: $e');
      rethrow;
    }
  }
}

