import 'package:flutter_app/core/cache/cache_manager.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/data/models/listing_model.dart';

/// Home Service - Handles data operations for home feature
/// 
/// This service layer sits between the controller and backend helper.
/// It handles data fetching, transformation, and business rules.
class HomeService {
  final BackendHelper _backendHelper;
  final CacheManager _cacheManager;

  HomeService({BackendHelper? backendHelper, CacheManager? cacheManager})
      : _backendHelper = backendHelper ?? BackendHelper(),
        _cacheManager = cacheManager ?? CacheManager();

  /// Fetch all listings
  /// Returns a list of ListingModel objects
  Future<List<ListingModel>> fetchListings({Map<String, dynamic>? params}) async {
    try {
      final response = await _backendHelper.getListings(params: params);

      print('[HomeService] Response from getListings: $response');

      // Handle different response formats
      List<dynamic> rawListings = [];
      if (response is List) {
        rawListings = response;
      } else if (response is Map && response['results'] != null) {
        // Paginated response
        rawListings = response['results'] as List;
      } else if (response is Map && response['data'] != null) {
        // Alternative format
        rawListings = response['data'] as List;
      }

      // Transform to ListingModel objects
      final listings = rawListings
          .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
          .toList();

      print('[HomeService] Parsed ${listings.length} listings');
      
      return listings;
    } catch (e) {
      print('[HomeService] Error fetching listings: $e');
      rethrow; // Let controller handle the error
    }
  }

  /// Search listings by query
  Future<List<ListingModel>> searchListings(String query) async {
    if (query.isEmpty) {
      return fetchListings();
    }

    try {
      final response = await _backendHelper.getListings(
        params: {'search': query},
      );

      List<dynamic> rawListings = [];
      if (response is List) {
        rawListings = response;
      } else if (response is Map && response['results'] != null) {
        rawListings = response['results'] as List;
      }

      return rawListings
          .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[HomeService] Error searching listings: $e');
      rethrow;
    }
  }

  /// Filter listings by category/type
  Future<List<ListingModel>> filterListings({
    String? category,
    String? animalType,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final params = <String, dynamic>{};
      
      if (category != null) params['category'] = category;
      if (animalType != null) params['animal_type'] = animalType;
      if (minPrice != null) params['min_price'] = minPrice.toString();
      if (maxPrice != null) params['max_price'] = maxPrice.toString();

      return fetchListings(params: params);
    } catch (e) {
      print('[HomeService] Error filtering listings: $e');
      rethrow;
    }
  }

  /// Get featured/recommended listings
  Future<List<ListingModel>> getFeaturedListings() async {
    try {
      return fetchListings(params: {'featured': 'true'});
    } catch (e) {
      print('[HomeService] Error fetching featured listings: $e');
      rethrow;
    }
  }

  /// Track a viewed listing in cache
  Future<void> trackViewedListing(int listingId) async {
    try {
      await _cacheManager.trackViewedListing(listingId);
    } catch (e) {
      print('[HomeService] Error tracking viewed listing: $e');
      // Don't rethrow - tracking failures shouldn't break the app
    }
  }

  /// Get recently viewed listings from cache
  /// Shows cached listings that user has actually tapped/viewed
  Future<List<ListingModel>> getRecentlyViewedListings() async {
    try {
      print('[HomeService] 🔍 Fetching recently viewed from cache...');
      
      // Step 1: Get the list of tracked listing IDs (from Hive)
      final viewedIds = await _cacheManager.getRecentlyViewedListings();
      print('[HomeService] 📋 Found ${viewedIds.length} tracked viewed IDs: $viewedIds');
      
      if (viewedIds.isEmpty) {
        print('[HomeService] ⚠️ No listings have been tracked yet. User needs to tap on listings.');
        return [];
      }
      
      // Step 2: Try multiple cache keys to find cached listings
      // Users might have browsed with different sort orders/filters
      final cacheKeysToTry = [
        'listings:all',  // Try unfiltered first
        'listings:order=desc&sort_by=posted_at',  // Most common sort
        'listings:order=asc&sort_by=posted_at',
        'listings:order=desc&sort_by=price',
        'listings:order=asc&sort_by=price',
      ];
      
      List<ListingModel>? cachedListings;
      String? foundKey;
      
      for (final cacheKey in cacheKeysToTry) {
        print('[HomeService] 🔑 Trying cache key: $cacheKey');
        
        try {
          cachedListings = await _cacheManager.get<List<ListingModel>>(
            cacheKey,
            (data) => _parseListingsFromCache(data),
          );
          
          if (cachedListings != null) {
            print('[HomeService] 📦 Cache returned ${cachedListings.length} listings for key: $cacheKey');
          } else {
            print('[HomeService] ❌ Cache returned null for key: $cacheKey');
          }
          
          if (cachedListings != null && cachedListings.isNotEmpty) {
            foundKey = cacheKey;
            print('[HomeService] ✅ Found ${cachedListings.length} cached listings in $foundKey');
            break;
          }
        } catch (e) {
          print('[HomeService] ❌ Error reading cache key $cacheKey: $e');
        }
      }

      if (cachedListings == null || cachedListings.isEmpty) {
        print('[HomeService] ⚠️ No cached listings found in any cache key');
        print('[HomeService] 🌐 Recently viewed IDs are preserved but no listing data cached yet');
        print('[HomeService] 💡 User needs to browse listings page to populate cache');
        
        // DON'T clear recently viewed IDs - they should persist
        // User just needs to browse listings again to populate cache
        return [];
      }
      
      print('[HomeService] 🔄 Starting to filter ${cachedListings.length} listings by ${viewedIds.length} viewed IDs...');
      
      // Step 3: Filter to only show listings that were tracked
      final result = _filterAndSortByViewedIds(cachedListings, viewedIds);
      
      print('[HomeService] ✅ Returning ${result.length} recently viewed listings');
      return result;
    } catch (e) {
      print('[HomeService] ❌ Error getting recently viewed: $e');
      print('[HomeService] Stack trace: ${StackTrace.current}');
      return [];
    }
  }
  
  /// Filter listings by tracked IDs and sort by view order (most recent first)
  List<ListingModel> _filterAndSortByViewedIds(List<ListingModel> allListings, List<int> viewedIds) {
    print('[HomeService] 🔍 Filtering ${allListings.length} listings by ${viewedIds.length} viewed IDs');
    
    final recentlyViewed = <ListingModel>[];
    
    // Iterate through viewedIds in order (most recent first)
    for (final id in viewedIds) {
      // Find matching listing in cached data
      final listing = allListings.firstWhere(
        (l) => l.id == id,
        orElse: () => ListingModel(
          id: -1,
          name: '',
          age: '',
          price: '',
          location: '',
        ),
      );
      
      if (listing.id != -1) {
        recentlyViewed.add(listing);
        print('[HomeService] ✅ Found listing $id: ${listing.name}');
      } else {
        print('[HomeService] ⚠️ Listing $id not found in cache');
      }
    }
    
    print('[HomeService] 📊 Returning ${recentlyViewed.length} recently viewed listings');
    return recentlyViewed;
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
      print('[HomeService] ⚠️ Expected List but got ${data.runtimeType}');
      return listings;
    }
    
    for (final item in cachedListings) {
      try {
        // Check if item is already a ListingModel (cached as object)
        if (item is ListingModel) {
          print('[HomeService] ✅ Item is already ListingModel: ${item.id} - ${item.name}');
          listings.add(item);
        } 
        // Parse from map (handles both Map<String, dynamic> and Map<dynamic, dynamic>)
        else if (item is Map) {
          // Convert Map<dynamic, dynamic> to Map<String, dynamic>
          final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(item);
          print('[HomeService] 📝 Parsing from Map: ${jsonMap['listing_id'] ?? jsonMap['id']}');
          listings.add(ListingModel.fromJson(jsonMap));
        } else {
          print('[HomeService] ⚠️ Unknown item type: ${item.runtimeType}');
        }
      } catch (e) {
        print('[HomeService] ❌ Error parsing listing: $e');
        print('[HomeService] Item data: $item');
        // Continue with next listing
      }
    }

    print('[HomeService] ✅ Retrieved ${listings.length} listings from cache');
    
    return listings;
  }
}
