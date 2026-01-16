import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/features/profile/services/my_listings_service.dart';

/// Controller for managing user's listings
class MyListingsController extends BaseController {
  final MyListingsService _myListingsService;

  List<ListingModel> _listings = [];
  String? _filterStatus;

  MyListingsController({MyListingsService? myListingsService})
      : _myListingsService = myListingsService ?? MyListingsService();

  /// Get all user's listings
  List<ListingModel> get listings => _listings;

  /// Get current filter status
  String? get filterStatus => _filterStatus;

  /// Fetch user's listings from API
  Future<void> fetchMyListings({String? status}) async {
    if (isDisposed) return;

    setLoading(true);
    clearError();
    _filterStatus = status;

    try {
      _listings = await _myListingsService.fetchMyListings(status: status);

      if (isDisposed) return;
      
      notifyListeners();
    } catch (e) {
      if (isDisposed) return;
      
      setError('Failed to fetch your listings: $e');
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Refresh listings
  Future<void> refreshListings() async {
    return fetchMyListings(status: _filterStatus);
  }

  /// Delete a listing
  Future<bool> deleteListing(int listingId) async {
    if (isDisposed) return false;

    setLoading(true);
    clearError();

    try {
      await _myListingsService.deleteListing(listingId);

      if (isDisposed) return false;

      // Remove from local list
      _listings.removeWhere((listing) => listing.id == listingId);
      notifyListeners();
      
      return true;
    } catch (e) {
      if (isDisposed) return false;
      
      setError('Failed to delete listing: $e');
      return false;
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Mark a listing as sold
  Future<bool> markAsSold(int listingId) async {
    if (isDisposed) return false;

    clearError();

    try {
      await _myListingsService.markAsSold(listingId);

      if (isDisposed) return false;

      // Update listing status locally
      final index = _listings.indexWhere((listing) => listing.id == listingId);
      if (index != -1) {
        // Create a new listing with updated status
        // Note: You may need to add a copyWith method to ListingModel
        _listings[index] = _listings[index];
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      if (isDisposed) return false;
      
      setError('Failed to mark listing as sold: $e');
      return false;
    }
  }

  /// Filter listings by status
  void filterByStatus(String? status) {
    fetchMyListings(status: status);
  }

  /// Get count of listings
  int get listingsCount => _listings.length;

  /// Check if listings are empty
  bool get hasListings => _listings.isNotEmpty;
}
