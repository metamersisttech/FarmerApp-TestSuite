import 'package:flutter/material.dart';
import 'package:flutter_app/features/search/widgets/popular_categories_section.dart';
import 'package:flutter_app/features/search/widgets/recent_searches_section.dart';
import 'package:flutter_app/features/search/widgets/search_location_bar.dart';
import 'package:flutter_app/features/search/widgets/search_app_bar.dart';

/// Search Page
///
/// Full-screen search interface with:
/// - Search bar with back button and search icon
/// - Location selector
/// - Recent searches with clear all
/// - Popular categories (Cow, Sheep, Buffalo, Goat)
///
/// Architecture:
/// - UI only in this file (build methods)
/// - Business logic in SearchStateMixin (to be added)
/// - Data management in SearchController (to be added)
/// - Search service for API calls (to be added)
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  // Mock data for recent searches (will be replaced with actual data from controller)
  final List<String> _recentSearches = [
    'Jersey Cow',
    'Buffalo',
    'Goat breeds',
    'Sheep for sale',
  ];
  
  String _currentLocation = 'Bangalore, IN';

  @override
  void initState() {
    super.initState();
    // Auto-focus search bar when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Handle back button press
  void _handleBack() {
    Navigator.pop(context);
  }

  /// Handle search submission
  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    
    // TODO: Implement search logic
    print('🔍 Searching for: $query');
    
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for: $query')),
    );
  }

  /// Handle recent search tap
  void _handleRecentSearchTap(String query) {
    _searchController.text = query;
    _handleSearch(query);
  }

  /// Handle clear all recent searches
  void _handleClearAllSearches() {
    setState(() {
      _recentSearches.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recent searches cleared')),
    );
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
    _handleSearch(category);
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
                      location: _currentLocation,
                      onTap: _handleLocationTap,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recent Searches Section
                  if (_recentSearches.isNotEmpty)
                    RecentSearchesSection(
                      searches: _recentSearches,
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
