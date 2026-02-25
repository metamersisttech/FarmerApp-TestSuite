import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/search/controllers/search_controller.dart'
    as search;
import 'package:flutter_app/features/search/screens/search_results_page.dart';
import 'package:flutter_app/features/search/widgets/popular_categories_section.dart';
import 'package:flutter_app/features/search/widgets/recent_searches_section.dart';
import 'package:flutter_app/features/search/widgets/search_location_bar.dart';
import 'package:flutter_app/features/search/widgets/search_app_bar.dart';
import 'package:flutter_app/features/search/widgets/search_filters_sheet.dart';

/// Search Page
///
/// Full-screen search interface with:
/// - Search bar with back button and search icon
/// - Location selector
/// - Recent searches with clear all
/// - Popular categories (Cow, Sheep, Buffalo, Goat)
/// - Real-time search with debouncing
/// - Loading states
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final search.SearchController _controller = search.SearchController();
  
  Timer? _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    
    // Load recent searches
    _controller.loadRecentSearches();
    
    // Auto-focus search bar when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    
    // Add listener to controller for updates
    _controller.addListener(_onControllerUpdate);
    
    // Add listener to search field for debounced suggestions
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  /// Called when controller notifies changes
  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Called when search text changes (for debounced suggestions)
  void _onSearchTextChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Start new timer (300ms debounce)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        // Get suggestions
        _controller.getSuggestions(query);
      }
    });
  }

  /// Handle back button press
  void _handleBack() {
    Navigator.pop(context);
  }

  /// Handle search submission
  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    // Unfocus keyboard
    _searchFocusNode.unfocus();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
    
    // Perform search
    await _controller.search(query);
    
    // Close loading dialog
    if (mounted) {
      Navigator.pop(context);
      
      // Navigate to results page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(
            query: query,
            results: _controller.searchResults,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  /// Handle recent search tap
  void _handleRecentSearchTap(String query) {
    _searchController.text = query;
    _handleSearch(query);
  }

  /// Handle clear all recent searches
  Future<void> _handleClearAllSearches() async {
    await _controller.clearRecentSearches();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recent searches cleared')),
      );
    }
  }

  /// Handle location tap
  void _handleLocationTap() {
    // TODO: Navigate to location selection page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location selection - Coming soon!')),
    );
  }

  /// Handle category tap
  void _handleCategoryTap(String category) {
    _searchController.text = category;
    _controller.setCategory(category);
    _handleSearch(category);
  }

  /// Handle filter tap
  void _handleFilterTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SearchFiltersSheet(
          currentLocation: _controller.currentLocation,
          currentCategory: _controller.selectedCategory,
          onLocationChanged: (location) {
            if (location != null) {
              _controller.updateLocation(location);
            }
          },
          onCategoryChanged: (category) {
            _controller.setCategory(category);
          },
          onApply: () {
            // Rerun search with new filters if there's a query
            if (_searchController.text.isNotEmpty) {
              _handleSearch(_searchController.text);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Search App Bar (with back button and search icon)
          SearchAppBar(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onBack: _handleBack,
            onSearch: _handleSearch,
            onFilterTap: _handleFilterTap, // Add filter button
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Location Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SearchLocationBar(
                      location: _controller.currentLocation,
                      onTap: _handleLocationTap,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recent Searches Section
                  if (_controller.recentSearches.isNotEmpty)
                    RecentSearchesSection(
                      searches: _controller.recentSearches,
                      onSearchTap: _handleRecentSearchTap,
                      onClearAll: _handleClearAllSearches,
                    ),

                  const SizedBox(height: 24),

                  // Popular Categories Section
                  PopularCategoriesSection(
                    onCategoryTap: _handleCategoryTap,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
