import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/features/profile/services/my_listings_service.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';

/// Service to manage My Listings badge count
/// Shows count of NEW listings since last visit
class MyListingsBadgeService {
  static const String _lastViewedKey = 'my_listings_last_viewed';
  static const int _defaultRecentDays = 7;
  
  final MyListingsService _myListingsService;
  
  MyListingsBadgeService({
    MyListingsService? myListingsService,
  }) : _myListingsService = myListingsService ?? MyListingsService();

  /// Get the count of new listings since last visit
  Future<int> getNewListingsCount() async {
    try {
      _logInfo('Starting badge count calculation...');
      
      final lastViewed = await _getLastViewedTimestamp();
      final listings = await _fetchListings();
      
      if (_isListingsEmpty(listings)) {
        return 0;
      }
      
      // Debug: Log listing details
      for (var listing in listings) {
        _logInfo('Listing: "${listing.name}" | Status: ${listing.listingStatus} | Posted: ${listing.postedAt}');
      }
      
      final cutoffDate = _determineCutoffDate(lastViewed);
      _logInfo('Using cutoff date: $cutoffDate');
      
      final newCount = _countListingsAfter(listings, cutoffDate);
      
      _logInfo('Returning badge count: $newCount');
      return newCount;
    } catch (e) {
      _logError('ERROR in getNewListingsCount', e);
      return 0;
    }
  }

  /// Fetch last viewed timestamp from storage
  Future<DateTime?> _getLastViewedTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final lastViewedString = prefs.getString(_lastViewedKey);
    
    _logInfo('Last viewed timestamp: $lastViewedString');
    
    if (lastViewedString == null) {
      return null;
    }
    
    try {
      return DateTime.parse(lastViewedString);
    } catch (e) {
      _logWarning('Failed to parse last viewed timestamp: $e');
      return null;
    }
  }

  /// Fetch all listings from service
  Future<List<ListingModel>> _fetchListings() async {
    _logInfo('Fetching listings from API...');
    final listings = await _myListingsService.fetchMyListings();
    _logInfo('Fetched ${listings.length} listings');
    return listings;
  }

  /// Check if listings list is empty
  bool _isListingsEmpty(List<ListingModel> listings) {
    if (listings.isEmpty) {
      _logInfo('No listings found, returning 0');
      return true;
    }
    return false;
  }

  /// Determine the cutoff date based on last viewed timestamp
  /// Returns the last viewed date if available, otherwise returns date from N days ago
  DateTime _determineCutoffDate(DateTime? lastViewed) {
    if (lastViewed != null) {
      _logInfo('Last viewed date: $lastViewed');
      return lastViewed;
    }
    
    final cutoffDate = DateTime.now().subtract(Duration(days: _defaultRecentDays));
    _logInfo('Never viewed before! Using $cutoffDate as cutoff ($_defaultRecentDays days ago)');
    return cutoffDate;
  }

  /// Count listings created after the given cutoff date
  int _countListingsAfter(List<ListingModel> listings, DateTime cutoffDate) {
    return listings
        .where(_hasValidCreatedAt)
        .where((listing) => _isCreatedAfter(listing, cutoffDate))
        .length;
  }

  /// Check if listing has a valid posted_at timestamp
  /// For drafts without postedAt, treat them as new
  bool _hasValidCreatedAt(ListingModel listing) {
    // If no postedAt but is a draft, include it (treat as new)
    if (listing.postedAt == null) {
      if (listing.listingStatus.toUpperCase() == 'DRAFT') {
        _logInfo('✓ Draft listing without postedAt, treating as new: ${listing.name}');
        return true; // Include drafts even without timestamp
      }
      return false;
    }
    return true;
  }

  /// Check if listing was posted after the cutoff date
  bool _isCreatedAfter(ListingModel listing, DateTime cutoffDate) {
    // If draft without postedAt, treat as new (already filtered by _hasValidCreatedAt)
    if (listing.postedAt == null) {
      return true; // Assume new if no timestamp (for drafts)
    }
    
    final postedAt = listing.postedAt!;
    final isNew = postedAt.isAfter(cutoffDate);
    
    if (isNew) {
      _logInfo('✓ New listing: posted at $postedAt');
    }
    
    return isNew;
  }

  /// Logging helpers
  void _logInfo(String message) {
    print('[MyListingsBadgeService] 🔍 $message');
  }

  void _logWarning(String message) {
    print('[MyListingsBadgeService] ⚠️ $message');
  }

  void _logError(String message, Object error) {
    print('[MyListingsBadgeService] ❌ $message: $error');
    print('[MyListingsBadgeService] Stack trace: ${StackTrace.current}');
  }

  /// Mark listings as viewed (clear badge)
  Future<void> markAsViewed() async {
    try {
      print('[MyListingsBadgeService] Marking listings as viewed');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastViewedKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('[MyListingsBadgeService] ⚠️ Error marking as viewed: $e');
    }
  }

  /// Reset last viewed timestamp (for testing)
  Future<void> resetLastViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastViewedKey);
    } catch (e) {
      // Silently fail
    }
  }
}
