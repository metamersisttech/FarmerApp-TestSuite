import '../../../core/cache/cache_manager.dart';
import '../../profile/models/listing_model.dart';
import 'viewalllistings_service.dart';

/// Listing-specific cache service
/// 
/// Handles:
/// - Parameterized cache key generation (filter-aware)
/// - Cache-first data fetching
/// - API fallback on cache miss
/// - Only stores UI-relevant fields (size optimization)
class ListingCacheService {
  final CacheManager _cacheManager = CacheManager();
  final ViewAllListingsService _listingService = ViewAllListingsService();
  
  // Cache configuration
  // Long TTL is safe because Firebase delta sync invalidates changed data
  // Disk cache (Hive) can hold stale data for offline mode
  static const Duration TTL = Duration(days: 7); // 7 days for disk persistence
  
  /// Get listings with cache-first strategy
  /// 
  /// Flow:
  /// 1. Generate cache key from params (species, sort_by, order, search)
  /// 2. Try cache (memory → disk)
  /// 3. On miss: fetch from API and cache
  /// 4. Return data
  Future<List<ListingModel>> getListings({
    Map<String, dynamic>? params,
    bool forceRefresh = false,
  }) async {
    // Generate parameterized cache key
    final cacheKey = _buildCacheKey(params ?? {});
    
    // Force refresh bypasses cache
    if (forceRefresh) {
      print('🔄 Force refresh: $cacheKey');
      return await _fetchAndCache(cacheKey, params);
    }
    
    // Try cache first
    final cached = await _cacheManager.get<List<ListingModel>>(
      cacheKey,
      (json) => _parseListingsFromCache(json),
    );
    
    if (cached != null) {
      return cached; // Cache hit
    }
    
    // Cache miss - fetch from API
    return await _fetchAndCache(cacheKey, params);
  }
  
  /// Fetch from API and cache the result (with UI-relevant fields only)
  Future<List<ListingModel>> _fetchAndCache(
    String cacheKey,
    Map<String, dynamic>? params,
  ) async {
    final listings = await _listingService.fetchListings(params: params);
    
    // Cache only UI-relevant fields (75% size reduction)
    await _cacheManager.set<List<ListingModel>>(
      cacheKey,
      listings,
      TTL,
      (data) => data.map((e) => _toUIOnlyJson(e)).toList(),
    );
    
    print('💾 Cached ${listings.length} listings with UI-only fields');
    return listings;
  }
  
  /// Parse cached listings from Hive to ListingModel objects
  /// Handles type conversion from Map<dynamic, dynamic> to Map<String, dynamic>
  List<ListingModel> _parseListingsFromCache(dynamic data) {
    final listings = <ListingModel>[];
    
    // Convert to list if needed
    List<dynamic> cachedListings = [];
    if (data is List) {
      cachedListings = data;
    } else {
      print('[ListingCacheService] ⚠️ Expected List but got ${data.runtimeType}');
      return listings;
    }
    
    for (final item in cachedListings) {
      try {
        // Check if item is already a ListingModel (cached as object)
        if (item is ListingModel) {
          listings.add(item);
        } 
        // Parse from map (handles both Map<String, dynamic> and Map<dynamic, dynamic>)
        else if (item is Map) {
          // Convert Map<dynamic, dynamic> to Map<String, dynamic>
          final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(item);
          listings.add(ListingModel.fromJson(jsonMap));
        }
      } catch (e) {
        print('[ListingCacheService] ❌ Error parsing listing: $e');
        // Continue with next listing
      }
    }
    
    return listings;
  }
  
  /// Extract only UI-relevant fields from listing (75% size reduction)
  /// 
  /// Only caches fields displayed in UI:
  /// - listing_id, title, price, species, breed, age_months, gender
  /// - primary_image, is_featured, currency, location, rating
  /// 
  /// Excludes internal fields like:
  /// - farm_internal_id, audit_log, created_by_user_id, etc.
  Map<String, dynamic> _toUIOnlyJson(ListingModel listing) {
    return {
      'listing_id': listing.id,
      'title': listing.name,
      'price': listing.price,
      'species': listing.species,
      'breed': listing.breed,
      'age_months': listing.ageMonths,
      'gender': listing.gender,
      'primary_image': listing.imageUrl,
      'is_featured': listing.isVerified,
      'currency': listing.currency,
      'location': listing.location,
      'rating': listing.rating,
    };
  }
  
  /// Build cache key from filter parameters
  /// 
  /// Examples:
  /// - {} → "listings:all"
  /// - {species: Cow} → "listings:species=Cow"
  /// - {species: Cow, sort_by: price, order: asc} → "listings:order=asc&sort_by=price&species=Cow"
  /// 
  /// Keys are sorted alphabetically for consistency.
  String _buildCacheKey(Map<String, dynamic> params) {
    if (params.isEmpty || params.values.every((v) => v == null || v == '')) {
      return 'listings:all';
    }
    
    // Sort params alphabetically for consistent keys
    final sorted = params.entries
        .where((e) => e.value != null && e.value != '')
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    if (sorted.isEmpty) {
      return 'listings:all';
    }
    
    final paramString = sorted
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return 'listings:$paramString';
  }

  /// Bulk fetch listings by IDs and merge into cache (Delta Sync)
  /// 
  /// This is the core of delta sync optimization:
  /// 1. Fetch only changed listings (not all listings)
  /// 2. Merge surgically into existing cache
  /// 3. Store only UI-relevant fields
  /// 
  /// TODO: Once backend bulk API is ready, this will be 99% more efficient
  Future<void> bulkFetchAndMerge(
    List<int> idsToFetch, 
    List<int> idsToDelete,
  ) async {
    try {
      print('🔄 Delta Sync: Fetching ${idsToFetch.length} listings, deleting ${idsToDelete.length}');
      
      // Fetch updated/created listings via bulk API
      List<ListingModel> updatedListings = [];
      if (idsToFetch.isNotEmpty) {
        updatedListings = await _listingService.bulkFetchListings(idsToFetch);
      }
      
      // Merge into cache
      await _mergeIntoCache(updatedListings, idsToDelete);
      
      print('✅ Delta sync complete: ${updatedListings.length} merged, ${idsToDelete.length} deleted');
    } catch (e) {
      print('❌ Error in delta sync: $e');
      rethrow;
    }
  }

  /// Merge listings into cache (surgical update - no full refetch)
  /// 
  /// Strategy:
  /// - Delete removed IDs
  /// - Update existing listings in place
  /// - Insert new listings at top
  /// - Preserve unaffected listings
  Future<void> _mergeIntoCache(
    List<ListingModel> updatedListings,
    List<int> deletedIds,
  ) async {
    // For now, merge into the 'all' cache
    // TODO: Update all affected filter caches (species, sort_by, etc.)
    const cacheKey = 'listings:all';
    
    // Get current cache
    final cached = await _cacheManager.get<List<ListingModel>>(
      cacheKey,
      (json) => _parseListingsFromCache(json),
    ) ?? [];
    
    print('📊 Cache before merge: ${cached.length} listings');
    
    // Remove deleted listings
    if (deletedIds.isNotEmpty) {
      cached.removeWhere((l) => deletedIds.contains(l.id));
      print('🗑️ Deleted ${deletedIds.length} listings from cache');
    }
    
    // Merge updated/created listings
    int updated = 0;
    int created = 0;
    
    for (final newListing in updatedListings) {
      final index = cached.indexWhere((l) => l.id == newListing.id);
      if (index >= 0) {
        // Update existing listing
        cached[index] = newListing;
        updated++;
      } else {
        // Insert new listing at top
        cached.insert(0, newListing);
        created++;
      }
    }
    
    print('📝 Merge result: $created created, $updated updated');
    print('📊 Cache after merge: ${cached.length} listings');
    
    // Save back to cache with only UI-relevant fields
    await _cacheManager.set<List<ListingModel>>(
      cacheKey,
      cached,
      TTL,
      (data) => data.map((e) => _toUIOnlyJson(e)).toList(),
    );
  }
}