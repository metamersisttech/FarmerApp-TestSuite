import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';

/// ViewAllListings Service - Handles data operations for marketplace feature
/// 
/// This service layer provides listing data from the backend API.
class ViewAllListingsService {
  final BackendHelper _backendHelper;

  ViewAllListingsService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();
  /// Fetch all marketplace listings from API
  /// Returns a list of ListingModel objects
  Future<List<ListingModel>> fetchListings({Map<String, dynamic>? params}) async {
    try {
      if (kDebugMode) {
        print('[ViewAllListingsService] fetchListings called with params: $params');
      }

      // Call backend API
      final response = await _backendHelper.getListings(params: params);

      if (kDebugMode) {
        print('[ViewAllListingsService] API Response: $response');
      }

      // Parse response
      List<ListingModel> listings = [];
      
      if (response is Map) {
        // Paginated response format: { "count": 123, "results": [...] }
        final results = response['results'] as List?;
        if (results != null) {
          listings = results
              .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } else if (response is List) {
        // Direct list response
        listings = response
            .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (kDebugMode) {
        print('[ViewAllListingsService] Returning ${listings.length} listings');
      }

      return listings;
    } catch (e) {
      if (kDebugMode) {
        print('[ViewAllListingsService] Error fetching listings: $e');
      }
      throw Exception('Failed to fetch listings: ${e.toString()}');
    }
  }

  /// Bulk fetch listings by IDs (for delta sync)
  /// Used when Firebase notifies of changes - fetch only changed listings
  /// 
  /// TODO: Backend to implement /api/listings/bulk/ endpoint
  /// Current: Falls back to fetching all listings (will be optimized when backend ready)
  Future<List<ListingModel>> bulkFetchListings(List<int> ids) async {
    try {
      if (kDebugMode) {
        print('[ViewAllListingsService] bulkFetchListings called with ${ids.length} IDs: $ids');
      }

      if (ids.isEmpty) {
        return [];
      }

      try {
        // Try bulk API first (will fail until backend implements it)
        final response = await _backendHelper.getBulkListings(ids);

        if (kDebugMode) {
          print('[ViewAllListingsService] ✅ Bulk API Response: $response');
        }

        // Parse response (should be a list)
        List<ListingModel> listings = [];
        
        if (response is List) {
          listings = response
              .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        if (kDebugMode) {
          print('[ViewAllListingsService] Bulk fetch returned ${listings.length} listings');
        }

        return listings;
      } catch (bulkError) {
        // Fallback: If bulk API not implemented yet, fetch all and filter by IDs
        if (kDebugMode) {
          print('[ViewAllListingsService] ⚠️ Bulk API failed (expected until backend ready): $bulkError');
          print('[ViewAllListingsService] 🔄 Fallback: Fetching all listings and filtering by IDs');
        }
        
        // Fetch all listings
        final allListings = await fetchListings();
        
        // Filter by requested IDs
        final filteredListings = allListings.where((l) => ids.contains(l.id)).toList();
        
        if (kDebugMode) {
          print('[ViewAllListingsService] Fallback returned ${filteredListings.length} listings');
        }
        
        return filteredListings;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ViewAllListingsService] ❌ Error bulk fetching listings: $e');
      }
      throw Exception('Failed to bulk fetch listings: ${e.toString()}');
    }
  }
}
