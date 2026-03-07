import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';
import 'package:flutter_app/features/recentlyviewed/services/recentlyviewed_service.dart';

/// Controller for recently viewed listings page operations
/// 
/// Manages business logic and state for the recently viewed listings page.
/// Uses RecentlyViewedService for data operations.
class RecentlyViewedController extends BaseController {
  final RecentlyViewedService _service;
  final BackendHelper _backendHelper;

  List<ListingModel> _listings = [];
  String _searchQuery = '';
  Set<int> _favoriteListingIds = {};

  RecentlyViewedController({RecentlyViewedService? service, BackendHelper? backendHelper})
      : _service = service ?? RecentlyViewedService(),
        _backendHelper = backendHelper ?? BackendHelper();

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

  /// Load user's favorites
  Future<void> loadFavorites() async {
    try {
      print('[RecentlyViewedController] 🔍 Loading favorites...');
      final favorites = await _backendHelper.getFavorites();
      
      print('[RecentlyViewedController] 📦 Raw favorites response: $favorites');
      
      // Handle both List and paginated response
      List<dynamic> favoritesList = [];
      if (favorites is Map && favorites['results'] != null) {
        favoritesList = favorites['results'] as List<dynamic>;
        print('[RecentlyViewedController] 📋 Paginated response with ${favoritesList.length} items');
      } else if (favorites is List) {
        favoritesList = favorites;
        print('[RecentlyViewedController] 📋 Direct list response with ${favoritesList.length} items');
      }
      
      // Extract listing IDs from favorites
      _favoriteListingIds = favoritesList.map((fav) {
        if (fav is Map) {
          final listing = fav['listing'];
          if (listing is Map) {
            // Check for both 'listing_id' and 'id' fields in nested listing
            if (listing['listing_id'] != null) {
              final id = listing['listing_id'] as int;
              print('[RecentlyViewedController] ✅ Extracted listing ID from nested listing_id: $id');
              return id;
            }
            if (listing['id'] != null) {
              final id = listing['id'] as int;
              print('[RecentlyViewedController] ✅ Extracted listing ID from nested id: $id');
              return id;
            }
          }
          // Fallback to listing_id field at root level
          if (fav['listing_id'] != null) {
            final id = fav['listing_id'] as int;
            print('[RecentlyViewedController] ✅ Extracted listing ID from root field: $id');
            return id;
          }
        }
        print('[RecentlyViewedController] ❌ Could not extract listing ID from: $fav');
        return null;
      }).whereType<int>().toSet();
      
      print('[RecentlyViewedController] ✅ Loaded ${_favoriteListingIds.length} favorite IDs: $_favoriteListingIds');
      
      notifyListeners();
    } catch (e) {
      print('[RecentlyViewedController] ❌ Error loading favorites: $e');
      // Don't fail the whole page if favorites fail to load
    }
  }
  
  /// Check if a listing is favorited
  bool isListingFavorited(int listingId) {
    final isFavorited = _favoriteListingIds.contains(listingId);
    if (kDebugMode) {
      print('[RecentlyViewedController] 🔍 Checking if listing $listingId is favorited: $isFavorited (favorites: $_favoriteListingIds)');
    }
    return isFavorited;
  }

}
