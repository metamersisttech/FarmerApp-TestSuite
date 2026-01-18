import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/features/viewalllistings/services/viewalllistings_service.dart';

/// Controller for view all listings page operations
/// 
/// Manages business logic and state for the marketplace listings page.
/// Uses ViewAllListingsService for data operations.
class ViewAllListingsController extends BaseController {
  final ViewAllListingsService _service;

  List<ListingModel> _listings = [];
  String _sortBy = 'relevance'; // relevance, price_low, price_high, newest

  ViewAllListingsController({ViewAllListingsService? service})
      : _service = service ?? ViewAllListingsService();

  /// Get listings data
  List<ListingModel> get listings => _listings;

  /// Get listings count
  int get listingsCount => _listings.length;

  /// Check if there are listings
  bool get hasListings => _listings.isNotEmpty;

  /// Current sort option
  String get sortBy => _sortBy;

  /// Fetch listings from service
  Future<void> fetchListings() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      if (kDebugMode) {
        print('[ViewAllListingsController] Starting to fetch listings...');
      }

      _listings = await _service.fetchListings();

      if (isDisposed) return;

      if (kDebugMode) {
        print('[ViewAllListingsController] Fetched ${_listings.length} listings');
        for (final listing in _listings) {
          print('[ViewAllListingsController] - ${listing.name}: ${listing.price}');
        }
      }

      _applySorting();
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

  /// Search listings
  Future<void> searchListings(String query) async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      _listings = await _service.searchListings(query);

      if (isDisposed) return;

      if (kDebugMode) {
        print('[ViewAllListingsController] Search found ${_listings.length} listings');
      }

      _applySorting();
      notifyListeners();
    } catch (e) {
      if (!isDisposed) {
        setError('Search failed');
      }
      if (kDebugMode) {
        print('[ViewAllListingsController] Error searching listings: $e');
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
      _listings = await _service.filterListings(
        category: category,
        animalType: animalType,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      if (isDisposed) return;

      _applySorting();
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

  /// Change sort order
  void setSortBy(String sortBy) {
    if (_sortBy == sortBy) return;
    
    _sortBy = sortBy;
    _applySorting();
    notifyListeners();
  }

  /// Apply sorting to listings
  void _applySorting() {
    switch (_sortBy) {
      case 'price_low':
        _listings.sort((a, b) {
          final priceA = _extractPrice(a.price);
          final priceB = _extractPrice(b.price);
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_high':
        _listings.sort((a, b) {
          final priceA = _extractPrice(a.price);
          final priceB = _extractPrice(b.price);
          return priceB.compareTo(priceA);
        });
        break;
      case 'newest':
        // In real implementation, sort by creation date
        _listings.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'relevance':
      default:
        // Keep original order or sort by rating
        _listings.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
  }

  /// Extract numeric price from formatted string
  double _extractPrice(String priceString) {
    final cleaned = priceString.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  /// Refresh listings
  Future<void> refreshListings() async {
    return fetchListings();
  }
}
