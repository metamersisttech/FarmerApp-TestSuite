import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/cache/cache_manager.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';

/// RecentlyViewed Service - Handles data operations for recently viewed feature
/// 
/// This service layer provides recently viewed listing data.
class RecentlyViewedService {
  final BackendHelper _backendHelper;
  final CacheManager _cacheManager;

  RecentlyViewedService({
    BackendHelper? backendHelper,
    CacheManager? cacheManager,
  })  : _backendHelper = backendHelper ?? BackendHelper(),
        _cacheManager = cacheManager ?? CacheManager();

  /// Fetch recently viewed listings from cache and API
  /// Returns a list of ListingModel objects in the order they were viewed
  Future<List<ListingModel>> fetchRecentlyViewedListings() async {
    try {
      if (kDebugMode) {
        print('[RecentlyViewedService] fetchRecentlyViewedListings called');
      }

      // Get recently viewed IDs from cache (most recent first)
      final viewedIds = await _cacheManager.getRecentlyViewedListings();
      
      if (viewedIds.isEmpty) {
        if (kDebugMode) {
          print('[RecentlyViewedService] No recently viewed listings found');
        }
        return [];
      }

      if (kDebugMode) {
        print('[RecentlyViewedService] Found ${viewedIds.length} recently viewed IDs: $viewedIds');
      }

      // Fetch listing details for these IDs
      final listings = await _fetchListingsByIds(viewedIds);

      if (kDebugMode) {
        print('[RecentlyViewedService] Returning ${listings.length} recently viewed listings');
      }

      return listings;
    } catch (e) {
      if (kDebugMode) {
        print('[RecentlyViewedService] Error fetching recently viewed listings: $e');
      }
      throw Exception('Failed to fetch recently viewed listings: ${e.toString()}');
    }
  }

  /// Fetch multiple listings by their IDs, maintaining order
  Future<List<ListingModel>> _fetchListingsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    try {
      // Fetch all listings - we'll filter by IDs
      final response = await _backendHelper.getListings();

      List<ListingModel> allListings = [];
      
      if (response is Map) {
        // Paginated response format: { "count": 123, "results": [...] }
        final results = response['results'] as List?;
        if (results != null) {
          allListings = results
              .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } else if (response is List) {
        // Direct list response
        allListings = response
            .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Filter to only requested IDs and maintain original order
      final orderedListings = <ListingModel>[];
      for (final id in ids) {
        try {
          final listing = allListings.firstWhere((l) => l.id == id);
          orderedListings.add(listing);
        } catch (e) {
          // Listing not found in results (might have been deleted)
          if (kDebugMode) {
            print('[RecentlyViewedService] Listing $id not found in results (possibly deleted)');
          }
        }
      }

      return orderedListings;
    } catch (e) {
      if (kDebugMode) {
        print('[RecentlyViewedService] Error fetching listings by IDs: $e');
      }
      throw Exception('Failed to fetch listings: ${e.toString()}');
    }
  }
}
