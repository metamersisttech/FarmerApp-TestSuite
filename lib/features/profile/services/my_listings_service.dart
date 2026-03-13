import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';

/// Service for fetching user's listings
class MyListingsService {
  final BackendHelper _backendHelper;

  MyListingsService({BackendHelper? backendHelper})
    : _backendHelper = backendHelper ?? BackendHelper();

  /// Fetch user's own listings
  /// Optionally filter by status (draft, sold, published, etc.)
  Future<List<ListingModel>> fetchMyListings({String? status}) async {
    try {
      // Build query params if status is provided and not 'all'
      final params = (status != null && status != 'all') ? {'status': status} : null;

      final response = await _backendHelper.getMyListings(params: params);

      // Handle different response formats
      List<dynamic> rawListings = [];

      if (response is List) {
        rawListings = response;
      } else if (response is Map && response['results'] != null) {
        // Paginated response
        rawListings = response['results'] as List;
      } else if (response is Map && response['data'] != null) {
        rawListings = response['data'] as List;
      }

      // Convert to ListingModel objects
      final listings = rawListings
          .map((json) => ListingModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return listings;
    } catch (e) {
      print('[MyListingsService] Error fetching listings: $e');
      rethrow;
    }
  }

  /// Delete a listing by ID
  Future<void> deleteListing(int listingId) async {
    try {
      // TODO: Add delete endpoint when backend is ready
      // await _backendHelper.deleteListing(listingId);
      throw UnimplementedError('Delete listing not yet implemented');
    } catch (e) {
      print('[MyListingsService] Error deleting listing: $e');
      rethrow;
    }
  }

  /// Publish a listing
  Future<void> publishListing(int listingId) async {
    try {
      await _backendHelper.postPublishListing(listingId);
    } catch (e) {
      print('[MyListingsService] Error publishing listing: $e');
      rethrow;
    }
  }

  /// Unpublish a listing
  Future<void> unpublishListing(int listingId) async {
    try {
      await _backendHelper.postUnpublishListing(listingId);
    } catch (e) {
      print('[MyListingsService] Error unpublishing listing: $e');
      rethrow;
    }
  }

  /// Mark a listing as sold
  Future<void> markAsSold(int listingId) async {
    try {
      await _backendHelper.postMarkListingSold(listingId);
    } catch (e) {
      print('[MyListingsService] Error marking listing as sold: $e');
      rethrow;
    }
  }
}
