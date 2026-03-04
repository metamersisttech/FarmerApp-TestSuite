import 'dart:collection';
import 'package:hive_flutter/hive_flutter.dart';
import 'cache_entry.dart';



/// Two-layer cache manager with LRU eviction
/// 
/// Architecture:
/// - L1: Memory cache (LinkedHashMap) - 50-100 items, instant access (1ms)
/// - L2: Disk cache (Hive) - 500-1000 items, fast access (10ms)
/// 
/// Lookup order: Memory → Disk → null (cache miss)
class CacheManager {
  // L1: Memory Cache Configuration
  static const int MAX_MEMORY_ITEMS = 100;
  static const int MAX_MEMORY_SIZE_MB = 50;
  
  // LRU implementation: LinkedHashMap maintains insertion order
  // Most recently accessed items are at the end
  final LinkedHashMap<String, CacheEntry> _memoryCache = LinkedHashMap();
  
  // L2: Disk Cache
  late Box _diskCache;
  
  // Singleton pattern - only one cache manager instance
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();
  
  /// Initialize Hive and open cache box
  /// Call this in main() before runApp()
  Future<void> initialize() async {
    await Hive.initFlutter();
    _diskCache = await Hive.openBox('app_cache');
    
    // Debug: Check what's in Hive on startup
    print('✅ CacheManager initialized');
    print('📊 Hive box has ${_diskCache.length} entries');
    
    // List all cache keys for debugging
    if (_diskCache.length > 0) {
      print('🔑 Cache keys in Hive:');
      for (final key in _diskCache.keys) {
        print('   - $key');
      }
    } else {
      print('⚠️ Hive cache is empty on startup');
    }
  }
  
  /// Get data with hierarchical lookup: Memory → Disk → null
  /// 
  /// Returns cached data if found and not expired, otherwise null.
  /// Automatically promotes disk data to memory for faster future access.
  Future<T?> get<T>(String key, T Function(dynamic) fromJson) async {
    // L1: Check memory cache (instant ~1ms)
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        _promoteToFront(key); // Mark as recently used (LRU)
        print('✅ Cache HIT (memory): $key');
        return entry.data as T;
      } else {
        _memoryCache.remove(key); // Remove expired
        print('⏰ Cache EXPIRED (memory): $key');
      }
    }
    
    // L2: Check disk cache (fast ~10ms)
    print('🔍 Checking disk cache for: $key');
    final diskData = _diskCache.get(key);
    
    if (diskData != null) {
      print('📦 Found data in disk for: $key');
      try {
        final entry = CacheEntry<T>.fromJson(diskData, fromJson);
        print('📅 Cache timestamp: ${entry.timestamp}');
        print('⏱️ Cache TTL: ${entry.ttl}');
        print('🔄 Is expired? ${entry.isExpired}');
        
        if (!entry.isExpired) {
          // Promote to memory for faster access next time
          await _setMemory(key, entry);
          print('✅ Cache HIT (disk): $key');
          return entry.data;
        } else {
          await _diskCache.delete(key); // Remove expired
          print('⏰ Cache EXPIRED (disk): $key - deleted');
        }
      } catch (e) {
        print('❌ Cache deserialization error for $key: $e');
        await _diskCache.delete(key);
      }
    } else {
      print('❌ No data in disk for: $key');
    }
    
    // L3: Cache miss - caller must fetch from API
    print('❌ Cache MISS: $key');
    return null;
  }
  
  /// Set data in both layers (memory + disk)
  /// 
  /// Writes to disk for persistence, then stores in memory for speed.
  /// Automatically evicts LRU items if memory is full.
  Future<void> set<T>(
    String key,
    T data,
    Duration ttl,
    dynamic Function(T) toJson,
  ) async {
    final entry = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
    );
    
    // Always write to disk first (persistence)
    await _diskCache.put(key, entry.toJson(toJson));
    print('💾 Cache SET: $key (TTL: ${ttl.inMinutes}min)');
    print('📊 Hive now has ${_diskCache.length} entries');
    
    // Then write to memory if space available
    await _setMemory(key, entry);
  }
  
  /// Invalidate specific cache key (called by Firebase sync)
  /// 
  /// Removes from both layers. Used when backend pushes change deltas.
  /// If invalidating main listings cache, also clears recently viewed history.
  Future<void> invalidate(String key) async {
    _memoryCache.remove(key);
    await _diskCache.delete(key);
    print('🗑️ Cache INVALIDATED: $key');
    
    // If invalidating main listings cache (not individual listings), clear recently viewed
    // Match keys like: listings:all, listings:species=Cow, etc.
    // Don't match: listing:123 (individual listing - singular 'listing:')
    if (key.startsWith('listings:')) {
      await clearRecentlyViewed();
      print('🗑️ Also cleared recently viewed history due to listings cache invalidation');
    }
  }
  
  /// Clear all caches (nuclear option)
  /// Also clears recently viewed history
  Future<void> clearAll() async {
    _memoryCache.clear();
    await _diskCache.clear();
    print('💣 Cache CLEARED (all, including recently viewed)');
  }
  
  // --- Internal Methods ---
  
  /// Add entry to memory cache with LRU eviction
  Future<void> _setMemory<T>(String key, CacheEntry<T> entry) async {
    // Evict oldest item if memory full
    if (_memoryCache.length >= MAX_MEMORY_ITEMS) {
      _evictLRU();
    }
    
    _memoryCache[key] = entry;
  }
  
  /// Evict least recently used item (first item in LinkedHashMap)
  void _evictLRU() {
    if (_memoryCache.isNotEmpty) {
      // LinkedHashMap: first item = least recently used
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
      print('🗑️ Evicted from memory: $oldestKey (kept on disk)');
    }
  }
  
  /// Promote item to front (most recently used) for LRU tracking
  void _promoteToFront(String key) {
    // LRU strategy: Move to end of LinkedHashMap
    final entry = _memoryCache.remove(key)!;
    _memoryCache[key] = entry;
  }

  // ============ Recently Viewed Tracking ============

  static const String _recentlyViewedKey = 'recently_viewed_listings';
  static const int _maxRecentlyViewed = 20;
  static const Duration _recentlyViewedTTL = Duration(days: 7); // Expire after 7 days

  /// Track a viewed listing with timestamp (most recent first)
  Future<void> trackViewedListing(int listingId) async {
    try {
      print('[CacheManager] 📝 Tracking viewed listing ID: $listingId');
      final viewedList = await _getRecentlyViewedWithTimestamps();
      print('[CacheManager] 📋 Current viewed list: ${viewedList.length} entries');
      
      // Remove if already exists to avoid duplicates
      viewedList.removeWhere((entry) => entry['id'] == listingId);
      
      // Add to front (most recent) with current timestamp
      viewedList.insert(0, {
        'id': listingId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      print('[CacheManager] ➕ Added $listingId to front with timestamp');
      
      // Limit to max items
      if (viewedList.length > _maxRecentlyViewed) {
        viewedList.removeRange(_maxRecentlyViewed, viewedList.length);
      }
      
      // Save to disk cache with timestamps
      await _diskCache.put(_recentlyViewedKey, viewedList);
      print('[CacheManager] ✅ Successfully saved to Hive: $listingId (Total: ${viewedList.length})');
    } catch (e) {
      print('❌ Error tracking viewed listing: $e');
    }
  }

  /// Get list of recently viewed listing IDs (most recent first)
  /// Only returns IDs viewed within the last 7 days
  Future<List<int>> getRecentlyViewedListings() async {
    try {
      final viewedList = await _getRecentlyViewedWithTimestamps();
      
      // Filter out entries older than TTL
      final now = DateTime.now().millisecondsSinceEpoch;
      final ttlMs = _recentlyViewedTTL.inMilliseconds;
      final validEntries = viewedList.where((entry) {
        final timestamp = entry['timestamp'] as int;
        final age = now - timestamp;
        return age <= ttlMs;
      }).toList();
      
      // Extract IDs
      final ids = validEntries.map((e) => e['id'] as int).toList();
      
      print('[CacheManager] 📖 Retrieved ${ids.length} recently viewed IDs (filtered from ${viewedList.length}): $ids');
      
      // If we filtered out expired entries, update storage
      if (validEntries.length < viewedList.length) {
        await _diskCache.put(_recentlyViewedKey, validEntries);
        print('[CacheManager] 🧹 Cleaned up ${viewedList.length - validEntries.length} expired entries');
      }
      
      return ids;
    } catch (e) {
      print('[CacheManager] ❌ Error getting recently viewed: $e');
    }
    return [];
  }

  /// Get recently viewed entries with timestamps (internal)
  Future<List<Map<String, dynamic>>> _getRecentlyViewedWithTimestamps() async {
    try {
      final data = _diskCache.get(_recentlyViewedKey);
      if (data != null && data is List) {
        // Handle migration from old format (just IDs) to new format (ID + timestamp)
        final entries = <Map<String, dynamic>>[];
        for (final item in data) {
          if (item is Map) {
            // New format: {id: X, timestamp: Y}
            entries.add(Map<String, dynamic>.from(item));
          } else if (item is int) {
            // Old format: just ID - add current timestamp for migration
            entries.add({
              'id': item,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });
          }
        }
        return entries;
      }
    } catch (e) {
      print('[CacheManager] ❌ Error getting recently viewed with timestamps: $e');
    }
    return [];
  }

  /// Clear recently viewed history
  Future<void> clearRecentlyViewed() async {
    await _diskCache.delete(_recentlyViewedKey);
    print('🗑️ Cleared recently viewed history');
  }

  // ============ Raw Data Access (for non-typed cache) ============

  /// Get raw data from disk cache without deserialization
  /// Used for simple data types like lists of strings or primitives
  Future<dynamic> getRaw(String key) async {
    try {
      return _diskCache.get(key);
    } catch (e) {
      print('[CacheManager] ❌ Error getting raw data for $key: $e');
      return null;
    }
  }

  /// Set raw data in disk cache
  /// Used for simple data types like lists of strings or primitives
  Future<void> setRaw(String key, dynamic data) async {
    try {
      await _diskCache.put(key, data);
      print('💾 Cache SET (raw): $key');
    } catch (e) {
      print('[CacheManager] ❌ Error setting raw data for $key: $e');
      rethrow;
    }
  }

  /// Delete raw data from disk cache
  Future<void> deleteRaw(String key) async {
    try {
      await _diskCache.delete(key);
      print('🗑️ Cache DELETE (raw): $key');
    } catch (e) {
      print('[CacheManager] ❌ Error deleting raw data for $key: $e');
      rethrow;
    }
  }
}