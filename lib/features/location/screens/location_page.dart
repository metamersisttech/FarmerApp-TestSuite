import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/location/controllers/location_controller.dart';
import 'package:flutter_app/features/location/widgets/location_search_bar.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/helpers/backend_helper.dart';

/// Main location selection page
class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> with ToastMixin {
  late final LocationController _controller;
  final TextEditingController _searchController = TextEditingController();
  final BackendHelper _backendHelper = BackendHelper();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = LocationController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Handle search text changes with debouncing
  void _onSearchChanged() {
    _debounceTimer?.cancel();

    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // Debounce search by 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performLocationSearch(query);
    });
  }

  /// Perform location search using backend endpoint
  Future<void> _performLocationSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await _backendHelper.getLocationSearch(query);

      if (!mounted) return;

      final results = response['results'] as List<dynamic>? ?? [];

      setState(() {
        _searchResults = results.map((e) => e as Map<String, dynamic>).toList();
        _isSearching = false;
      });
    } catch (e) {
      print('❌ Error searching locations: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
        showErrorToast('Failed to search locations');
      }
    }
  }

  /// Handle location selection from search results
  void _handleLocationSelect(Map<String, dynamic> location) {
    final displayName = location['display_name'] as String;
    final lat = location['lat'];
    final lon = location['lon'];

    // Parse coordinates
    double? latitude;
    double? longitude;

    if (lat != null) {
      latitude = double.tryParse(lat.toString());
    }
    if (lon != null) {
      longitude = double.tryParse(lon.toString());
    }

    // Create location model and return
    final locationData = _controller.createLocationFromSearch(
      displayName: displayName,
      latitude: latitude,
      longitude: longitude,
    );

    // Show success message
    showSuccessToast('Location selected: $displayName');

    // Return to previous page with selected location
    Navigator.pop(context, locationData);
  }

  /// Handle use current location
  void _handleUseCurrentLocation() async {
    // First, check permission status
    final locationService = _controller.locationService;
    final currentPermission = await locationService.checkPermission();

    print('📍 =================================');
    print('📍 Current permission status: $currentPermission');
    print('📍 =================================');

    // If permission is denied or deniedForever, show dialog to request permission
    if (currentPermission == LocationPermission.denied ||
        currentPermission == LocationPermission.deniedForever) {
      print('⚠️ Permission is $currentPermission');

      if (!mounted) return;

      // Show our custom dialog first
      print('🔔 Showing custom permission dialog...');
      final shouldEnable = await _showLocationPermissionDialog();

      print('👤 User response to custom dialog: $shouldEnable');

      if (!shouldEnable) {
        // User declined permission
        if (mounted) {
          showInfoToast('Location permission required to use this feature');
        }
        return;
      }

      print('✅ User agreed to enable permission');

      // User agreed - now handle based on permission state
      if (currentPermission == LocationPermission.deniedForever) {
        // Permission permanently denied, must open app settings
        print('🔴 Permission is deniedForever - opening app settings');
        if (mounted) {
          showInfoToast('Please enable location permission in app settings');
        }
        await locationService.openAppSettings();
        return;
      } else {
        // Permission is just 'denied', now trigger the system permission dialog
        print(
          '🔔 Permission is denied - requesting system permission dialog...',
        );
        print('🔔 Calling Geolocator.requestPermission()...');

        final newPermission = await locationService.requestPermission();

        print('📍 =================================');
        print('📍 System permission result: $newPermission');
        print('📍 =================================');

        if (!mounted) return;

        // Check if permission was granted
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          print('❌ User denied permission');
          showErrorToast('Location permission denied');
          return;
        }

        // Permission granted! Continue to get location
        print('✅ Permission granted! Proceeding to get location...');
      }
    } else {
      print('✅ Permission already granted: $currentPermission');
    }

    // Check if location service is enabled
    print('🔍 Checking if location service is enabled...');
    final serviceEnabled = await locationService.isLocationServiceEnabled();
    print('📍 Location service enabled: $serviceEnabled');

    if (!serviceEnabled) {
      print('⚠️ Location service disabled - showing dialog');
      if (mounted) {
        final shouldEnable = await _showLocationServiceDialog();
        if (shouldEnable) {
          await locationService.openLocationSettings();
        }
      }
      return;
    }

    // Now try to get location (this will use the granted permission)
    print('🔍 Getting current location...');
    final success = await _controller.getCurrentLocation();

    print('📍 Get location result: $success');

    if (!mounted) return;

    if (success) {
      print('✅ Location retrieved successfully');
      print('📍 Location: ${_controller.selectedLocation.displayLocation}');

      // Show toast first
      showSuccessToast('Location updated successfully');

      // Use addPostFrameCallback to ensure navigation happens after current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          // Return to previous page with location data
          Navigator.pop(context, _controller.selectedLocation);
        }
      });
    } else if (_controller.errorMessage != null) {
      print('❌ Error getting location: ${_controller.errorMessage}');
      showErrorToast(_controller.errorMessage!);
    }
  }

  /// Show location permission request dialog
  Future<bool> _showLocationPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.authPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppTheme.authPrimaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Enable Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            content: const Text(
              'We need location permission to detect your current location automatically.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.authPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'Enable',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Show location service disabled dialog
  Future<bool> _showLocationServiceDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.location_off, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Location Service Disabled',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Please turn on location services in your device settings to use this feature.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.authPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'Open Settings',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Select Location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.authPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Search bar
          LocationSearchBar(
            hint: 'Search city, area or neighbourhood',
            controller: _searchController,
            onChanged: (value) {
              // Handled by listener
            },
          ),

          const SizedBox(height: 8),

          // Use current location button
          _buildUseCurrentLocationButton(),

          const SizedBox(height: 16),

          // Search results or empty state
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildUseCurrentLocationButton() {
    return InkWell(
      onTap: _handleUseCurrentLocation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.authPrimaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.authPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.my_location,
                color: AppTheme.authPrimaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use Current Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.authPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Enable location to detect automatically',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  /// Build search results section
  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.authPrimaryColor),
            SizedBox(height: 16),
            Text(
              'Searching locations...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Search for a location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type city, area or neighbourhood name',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty && !_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No locations found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        final displayName = location['display_name'] as String? ?? 'Unknown';

        return InkWell(
          onTap: () => _handleLocationSelect(location),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.authPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppTheme.authPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2B2B2B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
