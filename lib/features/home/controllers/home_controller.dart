import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/data/models/listing_model.dart';

/// Controller for home page operations
class HomeController extends BaseController {
  final BackendHelper _backendHelper;

  int _currentBottomNavIndex = 0;
  String _searchQuery = '';
  List<ListingModel> _listings = [];

  HomeController({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Get listings data
  List<ListingModel> get listings => _listings;

  /// Current bottom navigation bar index
  int get currentBottomNavIndex => _currentBottomNavIndex;

  /// Current search query
  String get searchQuery => _searchQuery;

  /// Set bottom navigation index
  void setBottomNavIndex(int index) {
    _currentBottomNavIndex = index;
    notifyListeners();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    // TODO: Implement search logic when backend is ready
  }

  /// Handle notification tap
  void onNotificationTap() {
    // TODO: Navigate to notifications screen
    setError('Notifications feature coming soon!');
  }

  /// Handle profile tap
  void onProfileTap() {
    // TODO: Navigate to profile screen
    setError('Profile feature coming soon!');
  }

  /// Handle wallet tap
  void onWalletTap() {
    // TODO: Navigate to wallet screen
    setError('Wallet feature coming soon!');
  }

  /// Fetch listings from API
  Future<void> fetchListings() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      final response = await _backendHelper.getListings();

      if (isDisposed) return;

      List<dynamic> rawListings = [];
      if (response is List) {
        rawListings = response;
      } else if (response is Map && response['results'] != null) {
        rawListings = response['results'] as List;
      }

      // Parse raw data into ListingModel objects
      _listings = rawListings
          .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        print('[HomeController] Fetched ${_listings.length} listings');
      }

      notifyListeners();
    } on BackendException catch (e) {
      if (!isDisposed) {
        setError(e.message);
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to load listings');
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
}

