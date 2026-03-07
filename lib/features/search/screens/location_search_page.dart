import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/search/models/location_search_model.dart';
import 'package:flutter_app/features/search/services/location_search_service.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Location Search Page
///
/// Allows users to search and select a location using OpenStreetMap
class LocationSearchPage extends StatefulWidget {
  final String? currentLocation;
  final Function(String location, {double? latitude, double? longitude}) onLocationSelected;

  const LocationSearchPage({
    super.key,
    this.currentLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LocationSearchService _locationSearchService = LocationSearchService();
  
  Timer? _debounceTimer;
  bool _isLoading = false;
  String? _errorMessage;
  List<LocationSearchModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    
    // Auto-focus search bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    
    // Add listener for debounced search
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Called when search text changes (debounced)
  void _onSearchTextChanged() {
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchResults.clear();
          _errorMessage = null;
        });
      }
    });
  }

  /// Perform location search
  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _locationSearchService.searchLocations(query);
      
      setState(() {
        _searchResults = response.results;
        _isLoading = false;
        
        if (_searchResults.isEmpty) {
          _errorMessage = 'No locations found for "$query"';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Search failed: ${e.toString()}';
        _searchResults.clear();
      });
    }
  }

  /// Handle location selection
  void _handleLocationSelect(LocationSearchModel location) {
    // Parse latitude and longitude as doubles
    final lat = double.tryParse(location.latitude);
    final lng = double.tryParse(location.longitude);
    
    widget.onLocationSelected(
      location.formattedLocation,
      latitude: lat,
      longitude: lng,
    );
    Navigator.pop(context);
  }

  /// Handle back button
  void _handleBack() {
    Navigator.pop(context);
  }

  /// Clear search
  void _handleClearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _handleBack,
        ),
        title: const Text(
          'Select Location',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search for city or area...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: _handleClearSearch,
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          const Divider(height: 1),

          // Current Location (if provided)
          if (widget.currentLocation != null && widget.currentLocation!.isNotEmpty)
            Container(
              color: Colors.white,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.authPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: AppTheme.authPrimaryColor,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                subtitle: Text(
                  widget.currentLocation!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

          // Search Results
          Expanded(
            child: _buildResultsSection(),
          ),
        ],
      ),
    );
  }

  /// Build results section
  Widget _buildResultsSection() {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.authPrimaryColor,
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state (no search yet)
    if (_searchResults.isEmpty && _searchController.text.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Search for a city or area',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start typing to see suggestions',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Results list
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        return _buildLocationItem(location);
      },
    );
  }

  /// Build location item
  Widget _buildLocationItem(LocationSearchModel location) {
    return ListTile(
      onTap: () => _handleLocationSelect(location),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getLocationIcon(location.type),
          color: AppTheme.authPrimaryColor,
          size: 20,
        ),
      ),
      title: Text(
        location.shortName,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        location.displayName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }

  /// Get icon based on location type
  IconData _getLocationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'city':
        return Icons.location_city;
      case 'town':
      case 'village':
        return Icons.holiday_village;
      case 'station':
        return Icons.train;
      case 'administrative':
        return Icons.domain;
      case 'suburb':
        return Icons.home_work;
      default:
        return Icons.place;
    }
  }
}
