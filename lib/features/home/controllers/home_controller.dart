import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';
import 'package:flutter_app/features/home/services/home_service.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';
import 'package:flutter_app/features/home/widgets/scrolling_templates.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Controller for home page operations
/// 
/// Manages business logic and state for the home page.
/// Uses HomeService for data operations.
/// Handles all business decisions and navigation logic.
class HomeController extends BaseController {
  final HomeService _homeService;
  final BackendHelper _backendHelper;
  final CommonHelper _commonHelper;
  
  // Navigation callback
  Function(int)? onNavigateToTab;
  
  // Coming soon callback
  Function(String)? onShowComingSoon;

  List<ListingModel> _listings = [];
  List<ListingModel> _recentlyViewedListings = [];
  Set<int> _favoriteListingIds = {};
  UserModel? _currentUser;

  HomeController({
    HomeService? homeService,
    BackendHelper? backendHelper,
    CommonHelper? commonHelper,
  })  : _homeService = homeService ?? HomeService(),
        _backendHelper = backendHelper ?? BackendHelper(),
        _commonHelper = commonHelper ?? CommonHelper();

  /// Get listings data
  List<ListingModel> get listings => _listings;

  /// Get recently viewed listings
  List<ListingModel> get recentlyViewedListings => _recentlyViewedListings;

  /// Get current user
  UserModel? get currentUser => _currentUser;

  /// Get listings count
  int get listingsCount => _listings.length;

  /// Check if there are listings
  bool get hasListings => _listings.isNotEmpty;

  /// Load user data from storage
  Future<void> loadUserFromStorage() async {
    try {
      _currentUser = await _commonHelper.getLoggedInUser();
      if (kDebugMode) {
        print('[HomeController] User loaded: ${_currentUser?.username}');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[HomeController] Error loading user: $e');
      }
    }
  }

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

  /// Load user's favorites
  Future<void> loadFavorites() async {
    try {
      print('[HomeController] 🔍 Loading favorites...');
      final favorites = await _backendHelper.getFavorites();
      
      print('[HomeController] 📦 Raw favorites response: $favorites');
      
      // Handle both List and paginated response
      List<dynamic> favoritesList = [];
      if (favorites is Map && favorites['results'] != null) {
        favoritesList = favorites['results'] as List<dynamic>;
        print('[HomeController] 📋 Paginated response with ${favoritesList.length} items');
      } else if (favorites is List) {
        favoritesList = favorites;
        print('[HomeController] 📋 Direct list response with ${favoritesList.length} items');
      }
      
      // Extract listing IDs from favorites
      _favoriteListingIds = favoritesList.map((fav) {
        if (fav is Map) {
          final listing = fav['listing'];
          if (listing is Map) {
            // Check for both 'listing_id' and 'id' fields in nested listing
            if (listing['listing_id'] != null) {
              final id = listing['listing_id'] as int;
              print('[HomeController] ✅ Extracted listing ID from nested listing_id: $id');
              return id;
            }
            if (listing['id'] != null) {
              final id = listing['id'] as int;
              print('[HomeController] ✅ Extracted listing ID from nested id: $id');
              return id;
            }
          }
          // Fallback to listing_id field at root level
          if (fav['listing_id'] != null) {
            final id = fav['listing_id'] as int;
            print('[HomeController] ✅ Extracted listing ID from root field: $id');
            return id;
          }
        }
        print('[HomeController] ❌ Could not extract listing ID from: $fav');
        return null;
      }).whereType<int>().toSet();
      
      print('[HomeController] ✅ Loaded ${_favoriteListingIds.length} favorite IDs: $_favoriteListingIds');
      
      notifyListeners();
    } catch (e) {
      print('[HomeController] ❌ Error loading favorites: $e');
      // Don't fail the whole page if favorites fail to load
    }
  }
  
  /// Check if a listing is favorited
  bool isListingFavorited(int listingId) {
    final isFavorited = _favoriteListingIds.contains(listingId);
    if (kDebugMode) {
      print('[HomeController] 🔍 Checking if listing $listingId is favorited: $isFavorited (favorites: $_favoriteListingIds)');
    }
    return isFavorited;
  }

  /// Navigate to listing detail and track view
  Future<void> navigateToListingDetail(
    BuildContext context,
    ListingModel listing,
  ) async {
    // Track the view (don't await to avoid delaying navigation)
    trackViewedListing(listing.id);
    
    // Navigate to details
    HomeNavigationService.toAnimalDetail(context, listing.id);
  }

  /// Handle marketplace navigation
  Future<void> navigateToMarketplace(BuildContext context) async {
    final result = await HomeNavigationService.toViewAllListings(context);
    
    if (result.success && result.selectedTab != null && onNavigateToTab != null) {
      onNavigateToTab!(result.selectedTab!);
    }
  }

  /// Handle vet services navigation
  void navigateToVetServices(BuildContext context) {
    HomeNavigationService.toVetServices(context);
  }

  /// Handle view all recently viewed
  void navigateToRecentlyViewed(BuildContext context) {
    HomeNavigationService.toRecentlyViewed(context);
  }

  /// Handle view all fresh listings
  Future<void> navigateToFreshListings(BuildContext context) async {
    final result = await HomeNavigationService.toViewAllListings(context);
    
    if (result.success && result.selectedTab != null && onNavigateToTab != null) {
      onNavigateToTab!(result.selectedTab!);
    }
  }

  /// Handle notification tap
  void navigateToNotifications(BuildContext context) {
    final result = HomeNavigationService.toNotifications(context);
    if (!result.success && result.message != null && onShowComingSoon != null) {
      onShowComingSoon!(result.message!.replaceAll(' feature coming soon!', ''));
    }
  }

  /// Handle profile navigation
  Future<void> navigateToProfile(BuildContext context) async {
    final result = HomeNavigationService.toProfile(context);
    
    if (result.success) {
      await loadUserFromStorage();
    } else if (result.message != null && onShowComingSoon != null) {
      onShowComingSoon!(result.message!.replaceAll(' feature coming soon!', ''));
    }
  }

  /// Get template card data for scrolling templates section
  List<TemplateCardData> getTemplateCards() {
    return [
      TemplateCardData(
        title: 'New Listings',
        subtitle: 'Check out latest animals',
        icon: Icons.fiber_new,
        backgroundColor: AppTheme.authPrimaryColor,
        buttonText: 'View Now',
        onPressed: () {
          if (onShowComingSoon != null) {
            onShowComingSoon!('New Listings');
          }
        },
      ),
      TemplateCardData(
        title: 'Vet Discount',
        subtitle: 'Special offers for you',
        icon: Icons.local_hospital,
        backgroundColor: Colors.orange,
        buttonText: 'View Now',
        onPressed: () {
          if (onShowComingSoon != null) {
            onShowComingSoon!('Vet Discount');
          }
        },
      ),
      TemplateCardData(
        title: 'Premium Feed',
        subtitle: 'Quality feed at best price',
        icon: Icons.grass,
        backgroundColor: Colors.green,
        buttonText: 'Shop Now',
        onPressed: () {
          if (onShowComingSoon != null) {
            onShowComingSoon!('Premium Feed');
          }
        },
      ),
      TemplateCardData(
        title: 'Transportation',
        subtitle: 'Book transport services',
        icon: Icons.local_shipping,
        backgroundColor: Colors.deepPurple,
        buttonText: 'Book Now',
        onPressed: () {
          if (onShowComingSoon != null) {
            onShowComingSoon!('Transportation');
          }
        },
      ),
    ];
  }
}

