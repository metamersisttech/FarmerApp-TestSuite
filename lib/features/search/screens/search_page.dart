import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/search/controllers/search_controller.dart'
    as search;
import 'package:flutter_app/features/search/screens/search_results_page.dart';
import 'package:flutter_app/features/search/screens/location_search_page.dart';
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

class _SearchPageState extends State<SearchPage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final search.SearchController _controller = search.SearchController();
  
  Timer? _debounceTimer;
  bool _returnedFromSettings = false;
  
  @override
  void initState() {
    super.initState();
    
    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    // Load recent searches
    _controller.loadRecentSearches();
    
    // Add listener to controller for updates
    _controller.addListener(_onControllerUpdate);
    
    // Add listener to search field for debounced suggestions
    _searchController.addListener(_onSearchTextChanged);
    
    // Defer actions that might trigger navigation to after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto-focus search bar when page opens
      _searchFocusNode.requestFocus();
      
      // Try to detect current location (moved here to avoid Navigator lock)
      _detectLocationOnInit();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // When app resumes from settings
    if (state == AppLifecycleState.resumed && _returnedFromSettings) {
      _returnedFromSettings = false;
      
      // Try to detect location again after returning from settings
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (mounted) {
          final success = await _controller.detectCurrentLocation();
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Location updated to ${_controller.currentLocation}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      });
    }
  }

  /// Detect location on initialization
  Future<void> _detectLocationOnInit() async {
    final success = await _controller.detectCurrentLocation();
    
    if (!success && mounted && !_controller.locationPermissionDenied) {
      // Show info dialog about location benefits
      _showLocationPrompt();
    }
  }

  /// Show location prompt dialog
  void _showLocationPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue),
            SizedBox(width: 8),
            Text('Enable Location'),
          ],
        ),
        content: const Text(
          'Allow location access to get better search results near you. '
          'You can still search without location, but results will be based on species or breeds only.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // User declined, continue without location
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _controller.requestLocationPermission();
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Location set to ${_controller.currentLocation}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (!success && mounted) {
                // Check what went wrong
                if (_controller.locationPermissionDenied) {
                  _showPermissionDeniedDialog();
                } else if (_controller.locationServiceDisabled) {
                  _showServiceDisabledDialog();
                }
              }
            },
            child: const Text('Enable Location'),
          ),
        ],
      ),
    );
  }

  /// Show permission denied dialog
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission is required to show results near you. '
          'You can enable it in app settings or continue searching without location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Without Location'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _returnedFromSettings = true;
              await _controller.openAppSettings();
              // Location will be detected automatically when app resumes
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show service disabled dialog
  void _showServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Location Service Disabled'),
          ],
        ),
        content: const Text(
          'Location service is turned off on your device. '
          'Please enable it in your device settings to use location-based features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Without Location'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _returnedFromSettings = true;
              await _controller.openLocationSettings();
              // Location will be detected automatically when app resumes
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    
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
    // Allow search even with empty query if category filter is set
    if (query.trim().isEmpty && _controller.selectedCategory == null) return;
    
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
    
    // Perform search with the query (can be empty if category filter is set)
    await _controller.search(query);
    
    // Close loading dialog
    if (mounted) {
      Navigator.pop(context);
      
      // Use category for display if query is empty
      final displayQuery = query.trim().isEmpty 
          ? (_controller.selectedCategory ?? 'All') 
          : query;
      
      // Navigate to results page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(
            query: displayQuery,
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
    // Navigate to location search page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSearchPage(
          currentLocation: _controller.currentLocation,
          onLocationSelected: (location, {latitude, longitude}) {
            _controller.updateLocation(
              location,
              latitude: latitude,
              longitude: longitude,
            );
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Location updated to $location')),
              );
            }
          },
        ),
      ),
    );
  }

  /// Handle category tap
  void _handleCategoryTap(String category) {
    // Only set the category filter, don't set search text
    // This ensures we search by species only, not species+breed
    _controller.setCategory(category);
    _handleSearch(''); // Pass empty string, category is already set
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
            // Trigger search with filters (even if query is empty but category is set)
            if (_searchController.text.isNotEmpty || _controller.selectedCategory != null) {
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
                      isDetecting: _controller.isDetectingLocation,
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
