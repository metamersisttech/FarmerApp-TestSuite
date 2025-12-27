import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Result of location operations
class LocationResult {
  final bool success;
  final Position? position;
  final String? errorMessage;
  final bool permissionDenied;
  final bool serviceDisabled;

  const LocationResult({
    required this.success,
    this.position,
    this.errorMessage,
    this.permissionDenied = false,
    this.serviceDisabled = false,
  });

  factory LocationResult.success(Position position) {
    return LocationResult(success: true, position: position);
  }

  factory LocationResult.permissionDenied() {
    return const LocationResult(
      success: false,
      permissionDenied: true,
      errorMessage: 'Location permission denied',
    );
  }

  factory LocationResult.serviceDisabled() {
    return const LocationResult(
      success: false,
      serviceDisabled: true,
      errorMessage: 'Location services are disabled',
    );
  }

  factory LocationResult.error(String message) {
    return LocationResult(success: false, errorMessage: message);
  }
}

/// Service for handling location operations
class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Check if permission is granted
  Future<bool> isPermissionGranted() async {
    final permission = await checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permission and check service
  /// Returns true if permission granted and service enabled
  Future<LocationResult> requestLocationAccess() async {
    // Check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationResult.serviceDisabled();
    }

    // Check permission
    LocationPermission permission = await checkPermission();
    
    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationResult.permissionDenied();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied
      return LocationResult.permissionDenied();
    }

    return const LocationResult(success: true);
  }

  /// Get current location
  Future<LocationResult> getCurrentLocation() async {
    try {
      // First check/request permission
      final accessResult = await requestLocationAccess();
      if (!accessResult.success) {
        return accessResult;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LocationResult.success(position);
    } catch (e) {
      return LocationResult.error('Failed to get location: ${e.toString()}');
    }
  }

  /// Open app settings (for when permission is permanently denied)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings (for when service is disabled)
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Show location permission dialog
  static Future<bool> showLocationPermissionDialog(BuildContext context) async {
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
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Enable Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Please enable location access to find nearby livestock, sellers, and services in your area.',
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
                  'Not Now',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
}

