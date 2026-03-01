import 'package:flutter/foundation.dart';
import 'package:flutter_app/features/search/services/search_service.dart';

/// Search Controller
///
/// Manages search state and coordinates with search service
/// Extends ChangeNotifier for reactive state management
class SearchController extends ChangeNotifier {
  final SearchService _searchService = SearchService();
  
  // State
  bool _isLoading = false;
  bool _isSuggestionsLoading = false;
  String? _errorMessage;
  List<String> _recentSearches = [];
  List<dynamic> _searchResults = [];
  List<String> _suggestions = [];
  String _currentLocation = 'Bangalore, IN';
  String? _selectedCategory;
  String _currentQuery = '';

  // Getters
  bool get isLoading => _isLoading;
  bool get isSuggestionsLoading => _isSuggestionsLoading;
  String? get errorMessage => _errorMessage;
  List<String> get recentSearches => _recentSearches;
  List<dynamic> get searchResults => _searchResults;
  List<String> get suggestions => _suggestions;
  String get currentLocation => _currentLocation;
  String? get selectedCategory => _selectedCategory;
  String get currentQuery => _currentQuery;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasSuggestions => _suggestions.isNotEmpty;

  /// Load recent searches from storage
  Future<void> loadRecentSearches() async {
    try {
      _setLoading(true);
      
      // TODO: Load from cache/local storage
      // For now, use mock data
      await Future.delayed(const Duration(milliseconds: 300));
      _recentSearches = [
        'Jersey Cow',
        'Buffalo',
        'Goat breeds',
        'Sheep for sale',
      ];
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load recent searches: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// Add search query to recent searches
  Future<void> addToRecentSearches(String query) async {
    if (query.trim().isEmpty) return;

    try {
      // Remove if already exists
      _recentSearches.remove(query);
      
      // Add to beginning
      _recentSearches.insert(0, query);
      
      // Keep only last 10 searches
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }

      // TODO: Save to cache/local storage
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to save search: ${e.toString()}');
    }
  }

  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    try {
      _recentSearches.clear();
      
      // TODO: Clear from cache/local storage
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear searches: ${e.toString()}');
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
        print('   Location: $_currentLocation');
        print('   Category: $_selectedCategory');
      }

      // Search animals using the service
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
  void updateLocation(String location) {
    _currentLocation = location;
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

  @override
  void dispose() {
    super.dispose();
  }
}
