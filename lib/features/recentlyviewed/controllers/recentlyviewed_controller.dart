import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/features/recentlyviewed/services/recentlyviewed_service.dart';

/// Controller for recently viewed listings page operations
/// 
/// Manages business logic and state for the recently viewed listings page.
/// Uses RecentlyViewedService for data operations.
class RecentlyViewedController extends BaseController {
  final RecentlyViewedService _service;

  List<ListingModel> _listings = [];
  String _searchQuery = '';

  RecentlyViewedController({RecentlyViewedService? service})
      : _service = service ?? RecentlyViewedService();

  /// Initialize controller (call from initState)
  void init() {
    // Load initial data
    fetchListings();
  }

  /// Get listings data
  List<ListingModel> get listings => _listings;

  /// Get listings count
  int get listingsCount => _listings.length;

  /// Check if there are listings
  bool get hasListings => _listings.isNotEmpty;

  /// Get current search query
  String get searchQuery => _searchQuery;

  /// Fetch recently viewed listings from service
  Future<void> fetchListings() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      if (kDebugMode) {
        print('[RecentlyViewedController] Starting to fetch recently viewed listings...');
      }

      _listings = await _service.fetchRecentlyViewedListings();

      if (isDisposed) return;

      if (kDebugMode) {
        print('[RecentlyViewedController] Fetched ${_listings.length} recently viewed listings');
      }

      notifyListeners();
    } catch (e) {
      if (!isDisposed) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        setError(errorMessage.isEmpty ? 'Failed to load recently viewed listings' : errorMessage);
      }
      if (kDebugMode) {
        print('[RecentlyViewedController] Error fetching recently viewed listings: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Set search query and filter listings locally
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    
    _searchQuery = query.toLowerCase();
    
    if (kDebugMode) {
      print('[RecentlyViewedController] Search query updated: $query');
    }
    
    // Notify listeners to rebuild UI with filtered results
    notifyListeners();
  }

  /// Get filtered listings based on search query
  List<ListingModel> getFilteredListings() {
    if (_searchQuery.isEmpty) {
      return _listings;
    }
    
    return _listings.where((listing) {
      final name = listing.name.toLowerCase();
      final breed = listing.breed?.toLowerCase() ?? '';
      final location = listing.location.toLowerCase();
      
      return name.contains(_searchQuery) ||
             breed.contains(_searchQuery) ||
             location.contains(_searchQuery);
    }).toList();
  }

  /// Refresh listings
  Future<void> refreshListings() async {
    return fetchListings();
  }

}
