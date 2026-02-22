import 'package:flutter/material.dart';
import 'package:flutter_app/data/services/location_service.dart';
import 'package:flutter_app/features/location/models/location_model.dart';
import 'package:flutter_app/features/location/screens/location_page.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:geolocator/geolocator.dart';

/// Mixin for location-related functionality
/// Requires ToastMixin to be mixed in the using class
mixin LocationMixin<T extends StatefulWidget> on State<T> {
  final LocationService _locationService = LocationService();
  String _currentLocationText = 'Bangalore, IN';

  /// Get current location text
  String get currentLocationText => _currentLocationText;

  /// Check and request location permission
  /// Shows dialog only when needed based on current permission status
  /// Note: Requires ToastMixin to be mixed in for toast functionality
  Future<void> checkLocationPermission() async {
    if (!mounted) return;

    try {
      // Check current permission status
      final currentPermission = await _locationService.checkPermission();

      print('📍 Current location permission: $currentPermission');

      // If user has granted permanent permission, auto-fetch location
      if (currentPermission == LocationPermission.always ||
          currentPermission == LocationPermission.whileInUse) {
        print('✅ Location permission already granted, fetching location...');
        await fetchAndDisplayCurrentLocation();
        return;
      }

      print('⚠️ Location permission not granted, showing dialog...');

      // Show dialog for denied permissions
      final shouldEnable = await LocationService.showLocationPermissionDialog(
        context,
      );

      print('👤 User response to dialog: $shouldEnable');

      if (shouldEnable && mounted) {
        // User clicked "Enable" - request permission
        final result = await _locationService.requestLocationAccess();

        if (!mounted) return;

        if (result.success) {
          _showSuccessToast('Location access enabled');
          await fetchAndDisplayCurrentLocation();
        } else if (result.serviceDisabled) {
          _showErrorToast('Please enable location services in settings');
          await _locationService.openLocationSettings();
        } else if (result.permissionDenied) {
          _showErrorToast('Location permission denied');
        }
      } else if (!shouldEnable) {
        _showInfoToast('You can enable location later from settings');
      }
    } catch (e) {
      print('❌ Error checking location permission: $e');
    }
  }

  // Toast helper methods (to be overridden by ToastMixin in the using class)
  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInfoToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Fetch current location and display it
  Future<void> fetchAndDisplayCurrentLocation() async {
    try {
      // Show loading indicator
      setState(() {
        _currentLocationText = 'Getting location...';
      });

      // Get location with address
      final locationResult = await _locationService.getCurrentLocation(
        includeAddress: true,
      );

      if (!mounted) return;

      if (locationResult.success && locationResult.address != null) {
        setState(() {
          _currentLocationText = locationResult.address!;
        });
        print('📍 Location updated: ${locationResult.address}');
      } else {
        // Fallback to default if failed
        setState(() {
          _currentLocationText = 'Bangalore, IN';
        });
        print('⚠️ Failed to get address, using default');
      }
    } catch (e) {
      print('❌ Error fetching location: $e');
      // Fallback to default
      if (mounted) {
        setState(() {
          _currentLocationText = 'Bangalore, IN';
        });
      }
    }
  }

  /// Check location service status on page load
  /// Shows dialog automatically if location is turned off
  Future<void> checkLocationServiceStatus() async {
    if (!mounted) return;

    // Wait a bit for the page to settle before showing dialog
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Check if location services are enabled
    final serviceEnabled = await _locationService.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print('🔴 Location services are disabled, showing dialog...');
      showLocationOffDialog();
    } else {
      print('✅ Location services are enabled');
    }
  }

  /// Show dialog when device location is turned off
  void showLocationOffDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Location Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.authPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off,
                size: 48,
                color: AppTheme.authPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Device location is off',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B2B2B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Share your current location to easily buy and postlistings near you',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Enable Location Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final opened = await _locationService.openLocationSettings();
                  if (!opened) {
                    _showErrorToast('Could not open location settings');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.authPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Enable Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Not Now',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle location tap - Navigate to location page
  Future<void> handleLocationTap() async {
    final selectedLocation = await Navigator.push<LocationData>(
      context,
      MaterialPageRoute(builder: (context) => const LocationPage()),
    );

    if (selectedLocation != null && mounted) {
      setState(() {
        _currentLocationText = selectedLocation.displayLocation;
      });

      _showSuccessToast(
        'Location updated to ${selectedLocation.displayLocation}',
      );
    }
  }
}
