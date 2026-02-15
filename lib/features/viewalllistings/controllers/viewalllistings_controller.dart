import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/features/viewalllistings/services/viewalllistings_service.dart';
import 'package:flutter_app/core/services/firebase_cache_sync_service.dart';
import 'package:flutter_app/features/viewalllistings/services/lisiting_cache_service.dart';

/// Controller for view all listings page operations
/// 
/// Manages business logic and state for the marketplace listings page.
/// Uses ViewAllListingsService for data operations.
class ViewAllListingsController extends BaseController {
  final ViewAllListingsService _service;
  final ListingCacheService _cacheService = ListingCacheService();
  final FirebaseCacheSyncService _firebaseSync;

  List<ListingModel> _listings = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  
  // API sorting parameters
  String _apiSortBy = 'posted_at'; // price, posted_at, views
  String _apiOrder = 'desc'; // asc, desc
  
  // Available categories
  final List<String> _categories = [
    'All',
    'Cow',
    'Buffalo',
    'Goat',
    'Sheep',
    'Poultry',
  ];

  ViewAllListingsController(this._firebaseSync, {ViewAllListingsService? service})
    : _service = service ?? ViewAllListingsService();

  /// Initialize controller (call from initState)
  void init() {
  // Register for automatic refresh on cache invalidation
    _firebaseSync.addInvalidationListener('listings', _autoRefresh);
  
  // Load initial data
    fetchListings();
  }
  


  /// Get listings data
  List<ListingModel> get listings => _listings;

  /// Get listings count
  int get listingsCount => _listings.length;

  /// Check if there are listings
  bool get hasListings => _listings.isNotEmpty;

  /// Get available categories
  List<String> get categories => _categories;

  /// Get selected category
  String get selectedCategory => _selectedCategory;

  /// Get API sort by parameter
  String get apiSortBy => _apiSortBy;

  /// Get API order parameter
  String get apiOrder => _apiOrder;

  /// Get current search query
  String get searchQuery => _searchQuery;

  /// Fetch listings from service with sorting and all filters
  Future<void> fetchListings() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      if (kDebugMode) {
        print('[ViewAllListingsController] Starting to fetch listings...');
        print('[ViewAllListingsController] Sort by: $_apiSortBy, Order: $_apiOrder');
      }

      // Build params with all filters
      final params = <String, dynamic>{
        'sort_by': _apiSortBy,
        'order': _apiOrder,
      };

      // Add search query if not empty
      if (_searchQuery.isNotEmpty) {
        params['search'] = _searchQuery;
      }

      // Add category filter if not 'All'
      if (_selectedCategory != 'All') {
        params['species'] = _selectedCategory;
      }

      // OLD: _listings = await _service.fetchListings(params: params);
// NEW:
      _listings = await _cacheService.getListings(params: params);

      if (isDisposed) return;

      if (kDebugMode) {
        print('[ViewAllListingsController] Fetched ${_listings.length} listings');
        for (final listing in _listings) {
          print('[ViewAllListingsController] - ${listing.name}: ${listing.price}');
        }
      }

      notifyListeners();
    } catch (e) {
      if (!isDisposed) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        setError(errorMessage.isEmpty ? 'Failed to load listings' : errorMessage);
      }
      if (kDebugMode) {
        print('[ViewAllListingsController] Error fetching listings: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Set search query and refresh listings
  Future<void> setSearchQuery(String query) async {
    if (_searchQuery == query) return;
    
    _searchQuery = query;
    
    if (kDebugMode) {
      print('[ViewAllListingsController] Search query updated: $query');
    }
    
    // Fetch with updated search query
    return fetchListings();
  }

  /// Set selected category and filter listings
  Future<void> setSelectedCategory(String category) async {
    if (_selectedCategory == category) return;
    
    _selectedCategory = category;
    
    // Fetch with current sorting applied
    return fetchListings();
  }

  /// Set API sorting parameters and refresh listings
  Future<void> setApiSorting(String sortBy, String order) async {
    if (_apiSortBy == sortBy && _apiOrder == order) return;

    _apiSortBy = sortBy;
    _apiOrder = order;

    if (kDebugMode) {
      print('[ViewAllListingsController] Updated sort: $sortBy, order: $order');
    }

    // Fetch with new sorting
    return fetchListings();
  }

  /// Refresh listings
  Future<void> refreshListings() async {
    return fetchListings();
  }

/// Called automatically when Firebase invalidates cache
  Future<void> _autoRefresh() async {
    print('🔄 Auto-refreshing listings (Firebase trigger)...');
    await fetchListings();
  }
  @override
  void dispose() {
    _firebaseSync.removeInvalidationListener('listings', _autoRefresh);
    super.dispose();
  }


}
