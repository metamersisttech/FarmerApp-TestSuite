import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/data/models/listing_model.dart';

/// Home Service - Handles data operations for home feature
/// 
/// This service layer sits between the controller and backend helper.
/// It handles data fetching, transformation, and business rules.
class HomeService {
  final BackendHelper _backendHelper;

  HomeService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

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
}
