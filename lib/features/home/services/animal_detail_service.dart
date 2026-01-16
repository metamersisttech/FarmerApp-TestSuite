import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/data/models/animal_detail_model.dart';

/// Animal Detail Service - Handles data operations for animal detail feature
/// 
/// This service layer sits between the controller and backend helper.
/// It handles data fetching, transformation, and business rules.
class AnimalDetailService {
  final BackendHelper _backendHelper;

  AnimalDetailService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Fetch animal listing details by ID
  /// Returns AnimalDetailModel with complete listing information
  Future<AnimalDetailModel> fetchAnimalDetail(int listingId) async {
    try {
      print('[AnimalDetailService] Fetching listing $listingId...');
      
      final response = await _backendHelper.getListingById(listingId);
      
      print('[AnimalDetailService] Response received for listing $listingId');
      
      // Transform response to model
      final animalDetail = AnimalDetailModel.fromJson(response);
      
      print('[AnimalDetailService] Parsed: ${animalDetail.title}');
      
      return animalDetail;
    } catch (e) {
      print('[AnimalDetailService] Error fetching listing $listingId: $e');
      rethrow; // Let controller handle the error
    }
  }

  /// Add listing to favorites
  /// TODO: Implement when backend endpoint is ready
  Future<void> addToFavorites(int listingId) async {
    try {
      print('[AnimalDetailService] Adding listing $listingId to favorites');
      // await _backendHelper.postAddFavorite(listingId);
      throw UnimplementedError('Add to favorites not yet implemented');
    } catch (e) {
      print('[AnimalDetailService] Error adding to favorites: $e');
      rethrow;
    }
  }

  /// Remove listing from favorites
  /// TODO: Implement when backend endpoint is ready
  Future<void> removeFromFavorites(int listingId) async {
    try {
      print('[AnimalDetailService] Removing listing $listingId from favorites');
      // await _backendHelper.deleteRemoveFavorite(listingId);
      throw UnimplementedError('Remove from favorites not yet implemented');
    } catch (e) {
      print('[AnimalDetailService] Error removing from favorites: $e');
      rethrow;
    }
  }

  /// Check if listing is favorited
  /// TODO: Implement when backend endpoint is ready
  Future<bool> isFavorited(int listingId) async {
    try {
      print('[AnimalDetailService] Checking favorite status for listing $listingId');
      // final response = await _backendHelper.getFavoriteStatus(listingId);
      // return response['is_favorited'] ?? false;
      return false; // Placeholder
    } catch (e) {
      print('[AnimalDetailService] Error checking favorite status: $e');
      return false;
    }
  }

  /// Report a listing
  /// TODO: Implement when backend endpoint is ready
  Future<void> reportListing(int listingId, String reason) async {
    try {
      print('[AnimalDetailService] Reporting listing $listingId: $reason');
      // await _backendHelper.postReportListing(listingId, {'reason': reason});
      throw UnimplementedError('Report listing not yet implemented');
    } catch (e) {
      print('[AnimalDetailService] Error reporting listing: $e');
      rethrow;
    }
  }

  /// Contact seller
  /// TODO: Implement when backend endpoint is ready
  Future<void> contactSeller(int listingId, String message) async {
    try {
      print('[AnimalDetailService] Contacting seller for listing $listingId');
      // await _backendHelper.postContactSeller(listingId, {'message': message});
      throw UnimplementedError('Contact seller not yet implemented');
    } catch (e) {
      print('[AnimalDetailService] Error contacting seller: $e');
      rethrow;
    }
  }

  /// Get similar listings
  /// TODO: Implement when backend endpoint is ready
  Future<List<AnimalDetailModel>> getSimilarListings(int listingId) async {
    try {
      print('[AnimalDetailService] Fetching similar listings for $listingId');
      // final response = await _backendHelper.getSimilarListings(listingId);
      // return response.map((json) => AnimalDetailModel.fromJson(json)).toList();
      return []; // Placeholder
    } catch (e) {
      print('[AnimalDetailService] Error fetching similar listings: $e');
      rethrow;
    }
  }
}
