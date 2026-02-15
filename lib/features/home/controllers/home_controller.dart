import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/features/home/services/home_service.dart';

/// Controller for home page operations
/// 
/// Manages business logic and state for the home page.
/// Uses HomeService for data operations.
class HomeController extends BaseController {
  final HomeService _homeService;

  List<ListingModel> _listings = [];
  List<ListingModel> _recentlyViewedListings = [];

  HomeController({HomeService? homeService})
      : _homeService = homeService ?? HomeService();

  /// Get listings data
  List<ListingModel> get listings => _listings;

  /// Get recently viewed listings
  List<ListingModel> get recentlyViewedListings => _recentlyViewedListings;

  /// Get listings count
  int get listingsCount => _listings.length;

  /// Check if there are listings
  bool get hasListings => _listings.isNotEmpty;

  /// Fetch listings from API
  Future<void> fetchListings() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      _listings = await _homeService.fetchListings();

      if (isDisposed) return;

      if (kDebugMode) {
        print('[HomeController] Fetched ${_listings.length} listings');
        for (final listing in _listings) {
          print('[HomeController] Listing: ${listing.name}, imageUrl: ${listing.imageUrl}');
        }
      }

      notifyListeners();
    } catch (e) {
      if (!isDisposed) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        setError(errorMessage.isEmpty ? 'Failed to load listings' : errorMessage);
      }
      if (kDebugMode) {
        print('[HomeController] Error fetching listings: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Search listings
  Future<void> searchListings(String query) async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      _listings = await _homeService.searchListings(query);

      if (isDisposed) return;

      if (kDebugMode) {
        print('[HomeController] Search found ${_listings.length} listings');
      }

      notifyListeners();
    } catch (e) {
      if (!isDisposed) {
        setError('Search failed');
      }
      if (kDebugMode) {
        print('[HomeController] Error searching listings: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Filter listings
  Future<void> filterListings({
    String? category,
    String? animalType,
    double? minPrice,
    double? maxPrice,
  }) async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      _listings = await _homeService.filterListings(
        category: category,
        animalType: animalType,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      if (isDisposed) return;

      notifyListeners();
    } catch (e) {
      if (!isDisposed) {
        setError('Filter failed');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Get featured listings
  Future<void> fetchFeaturedListings() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      _listings = await _homeService.getFeaturedListings();

      if (isDisposed) return;

      notifyListeners();
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to load featured listings');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Refresh listings
  Future<void> refreshListings() async {
    return fetchListings();
  }

  /// Fetch recently viewed listings from cache
  Future<void> fetchRecentlyViewedListings() async {
    if (isDisposed) return;

    try {
      _recentlyViewedListings = await _homeService.getRecentlyViewedListings();

      if (isDisposed) return;

      if (kDebugMode) {
        print('[HomeController] Fetched ${_recentlyViewedListings.length} recently viewed listings');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[HomeController] Error fetching recently viewed: $e');
      }
    }
  }

  /// Track a viewed listing
  Future<void> trackViewedListing(int listingId) async {
    if (isDisposed) return;

    try {
      await _homeService.trackViewedListing(listingId);

      if (kDebugMode) {
        print('[HomeController] Tracked viewed listing: $listingId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[HomeController] Error tracking viewed listing: $e');
      }
    }
  }
}

