import 'package:flutter/foundation.dart';
import 'package:flutter_app/features/search/services/search_service.dart';
import 'package:flutter_app/features/search/services/search_history_service.dart';
import 'package:flutter_app/features/search/services/location_search_service.dart';
import 'package:flutter_app/data/models/location_search_model.dart';
import 'package:flutter_app/data/services/location_service.dart';

/// Search Controller
///
/// Manages search state and coordinates with search service
/// Extends ChangeNotifier for reactive state management
class SearchController extends ChangeNotifier {
  final SearchService _searchService = SearchService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final LocationSearchService _locationSearchService = LocationSearchService();
  final LocationService _locationService = LocationService();
  
  // State
  bool _isLoading = false;
  bool _isSuggestionsLoading = false;
  bool _isLocationSearchLoading = false;
  bool _isDetectingLocation = false;
  String? _errorMessage;
  List<String> _recentSearches = [];
  List<dynamic> _searchResults = [];
  List<String> _suggestions = [];
  List<LocationSearchModel> _locationSearchResults = [];
  String? _currentLocation; // Changed to nullable
  double? _currentLatitude;
  double? _currentLongitude;
  String? _selectedCategory;
  String _currentQuery = '';
  bool _locationPermissionDenied = false;
  bool _locationPermissionAsked = false;
  bool _locationServiceDisabled = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSuggestionsLoading => _isSuggestionsLoading;
  bool get isLocationSearchLoading => _isLocationSearchLoading;
  bool get isDetectingLocation => _isDetectingLocation;
  String? get errorMessage => _errorMessage;
  List<String> get recentSearches => _recentSearches;
  List<dynamic> get searchResults => _searchResults;
  List<String> get suggestions => _suggestions;
  List<LocationSearchModel> get locationSearchResults => _locationSearchResults;
  String? get currentLocation => _currentLocation;
  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;
  String? get selectedCategory => _selectedCategory;
  String get currentQuery => _currentQuery;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasSuggestions => _suggestions.isNotEmpty;
  bool get hasLocationResults => _locationSearchResults.isNotEmpty;
  bool get locationPermissionDenied => _locationPermissionDenied;
  bool get locationPermissionAsked => _locationPermissionAsked;
  bool get locationServiceDisabled => _locationServiceDisabled;
  bool get hasLocation => _currentLocation != null;

  /// Load recent searches from storage
  Future<void> loadRecentSearches() async {
    try {
      if (kDebugMode) {
        print('[SearchController] 📖 Loading recent searches from persistent storage...');
      }
      
      // Load from persistent cache (Hive)
      _recentSearches = await _searchHistoryService.getRecentSearches();
      
      if (kDebugMode) {
        print('[SearchController] ✅ Loaded ${_recentSearches.length} recent searches: $_recentSearches');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[SearchController] ❌ Failed to load recent searches: $e');
      }
      _recentSearches = []; // Fallback to empty list
      notifyListeners();
    }
  }

  /// Detect and set current location
  Future<bool> detectCurrentLocation() async {
    try {
      _isDetectingLocation = true;
      _locationPermissionAsked = true;
      notifyListeners();

      if (kDebugMode) {
        print('📍 [SearchController] Detecting current location...');
      }

      // Request location access first
      final accessResult = await _locationService.requestLocationAccess();
      
      if (!accessResult.success) {
        if (accessResult.permissionDenied) {
          _locationPermissionDenied = true;
          _locationServiceDisabled = false;
          _isDetectingLocation = false;
          
          if (kDebugMode) {
            print('❌ [SearchController] Location permission denied');
          }
          
          notifyListeners();
          return false;
        } else if (accessResult.serviceDisabled) {
          _locationServiceDisabled = true;
          _locationPermissionDenied = false;
          _isDetectingLocation = false;
          
          if (kDebugMode) {
            print('❌ [SearchController] Location service disabled');
          }
          
          notifyListeners();
          return false;
        }
        
        _isDetectingLocation = false;
        notifyListeners();
        return false;
      }

      // Get current location with address
      final result = await _locationService.getCurrentLocation(includeAddress: true);

      if (result.success && result.position != null) {
        // Store coordinates
        _currentLatitude = result.position!.latitude;
        _currentLongitude = result.position!.longitude;
        
        // Use the address from reverse geocoding, or fallback to 'Your location'
        _currentLocation = result.address ?? 'Your location';
        _locationPermissionDenied = false;
        _locationServiceDisabled = false;
        _isDetectingLocation = false;
        
        if (kDebugMode) {
          print('📍 [SearchController] Location detected: $_currentLocation ($_currentLatitude, $_currentLongitude)');
        }
        
        notifyListeners();
        return true;
      }

      _isDetectingLocation = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isDetectingLocation = false;
      
      if (kDebugMode) {
        print('❌ [SearchController] Location detection failed: $e');
      }
      
      notifyListeners();
      return false;
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    return await detectCurrentLocation();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Add search query to recent searches
  Future<void> addToRecentSearches(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final trimmedQuery = query.trim();
      
      // Save to persistent storage
      await _searchHistoryService.addSearchQuery(trimmedQuery);
      
      // Update in-memory list (case-insensitive removal)
      _recentSearches.removeWhere((s) => s.toLowerCase() == trimmedQuery.toLowerCase());
      _recentSearches.insert(0, trimmedQuery);
      
      // Keep only top 5 in memory
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
      
      if (kDebugMode) {
        print('[SearchController] ✅ Added "$trimmedQuery" to recent searches');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[SearchController] ❌ Failed to save search: $e');
      }
    }
  }

  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    try {
      // Clear from persistent storage
      await _searchHistoryService.clearAllSearches();
      
      // Clear in-memory list
      _recentSearches.clear();
      
      if (kDebugMode) {
        print('[SearchController] ✅ Cleared all recent searches');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[SearchController] ❌ Failed to clear searches: $e');
      }
    }
  }

  /// Perform search using the search service
  Future<void> search(String query) async {
    // Allow empty query if category filter is set
    if (query.trim().isEmpty && _selectedCategory == null) return;

    try {
      _currentQuery = query;
      _setLoading(true);
      _clearError();

      // Add to recent searches (only if query is not empty)
      if (query.trim().isNotEmpty) {
        await addToRecentSearches(query);
      }

      if (kDebugMode) {
        print('🔍 [SearchController] Searching with:');
        print('   Query: $query');
        print('   Location: ${_currentLocation ?? "No location"}');
        print('   Category: $_selectedCategory');
      }

      // Search animals using the service
      // Pass null location if not set (search without location filter)
      _searchResults = await _searchService.searchAnimals(
        query: query,
        location: _currentLocation,
        category: _selectedCategory,
      );

      _setLoading(false);
      
      if (kDebugMode) {
        print('🔍 Search completed: ${_searchResults.length} results found');
      }
    } catch (e) {
      _setError('Search failed: ${e.toString()}');
      _setLoading(false);
      
      if (kDebugMode) {
        print('❌ Search error: $e');
      }
    }
  }

  /// Get search suggestions with debouncing
  Future<void> getSuggestions(String query) async {
    if (query.trim().isEmpty) {
      _suggestions.clear();
      notifyListeners();
      return;
    }

    try {
      _isSuggestionsLoading = true;
      notifyListeners();

      // Get suggestions from service
      _suggestions = await _searchService.getSearchSuggestions(query);

      _isSuggestionsLoading = false;
      notifyListeners();
      
      if (kDebugMode) {
        print('💡 Suggestions: ${_suggestions.length} found');
      }
    } catch (e) {
      _isSuggestionsLoading = false;
      notifyListeners();
      
      if (kDebugMode) {
        print('⚠️ Suggestions error: $e');
      }
    }
  }

  /// Update current location
  void updateLocation(String location, {double? latitude, double? longitude}) {
    _currentLocation = location;
    _currentLatitude = latitude;
    _currentLongitude = longitude;
    notifyListeners();
  }

  /// Search locations
  Future<void> searchLocations(String query) async {
    if (query.trim().isEmpty) {
      _locationSearchResults.clear();
      notifyListeners();
      return;
    }

    try {
      _isLocationSearchLoading = true;
      notifyListeners();

      if (kDebugMode) {
        print('🌍 [SearchController] Searching locations for: $query');
      }

      // Get location results from service
      final response = await _locationSearchService.searchLocations(query);
      _locationSearchResults = response.results;

      _isLocationSearchLoading = false;
      notifyListeners();
      
      if (kDebugMode) {
        print('🌍 Location search completed: ${_locationSearchResults.length} results');
      }
    } catch (e) {
      _isLocationSearchLoading = false;
      notifyListeners();
      
      if (kDebugMode) {
        print('❌ Location search error: $e');
      }
    }
  }

  /// Clear location search results
  void clearLocationResults() {
    _locationSearchResults.clear();
    notifyListeners();
  }

  /// Set selected category filter
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _selectedCategory = null;
    notifyListeners();
  }

  /// Clear search results
  void clearResults() {
    _searchResults.clear();
    _currentQuery = '';
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Clear error (public method)
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
