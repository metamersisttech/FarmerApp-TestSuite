import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/data/models/listing_model.dart';

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
}
