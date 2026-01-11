import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Result of location operations
class LocationResult {
  final bool success;
  final Position? position;
  final String? errorMessage;
  final bool permissionDenied;
  final bool serviceDisabled;
  final String? address; // Add address field

  const LocationResult({
    required this.success,
    this.position,
    this.errorMessage,
    this.permissionDenied = false,
    this.serviceDisabled = false,
    this.address,
  });

  factory LocationResult.success(Position position, {String? address}) {
    return LocationResult(
      success: true,
      position: position,
      address: address,
    );
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
  /// NOTE: This method expects permission to already be granted
  /// Call requestPermission() separately before calling this if needed
  Future<LocationResult> getCurrentLocation({bool includeAddress = false}) async {
    try {
      // Check permission status (but don't request - that should be done explicitly)
      final permission = await checkPermission();
      
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return LocationResult.permissionDenied();
      }

      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.serviceDisabled();
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Get address if requested
      String? address;
      if (includeAddress) {
        address = await getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      }

      return LocationResult.success(position, address: address);
    } catch (e) {
      return LocationResult.error('Failed to get location: ${e.toString()}');
    }
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Check if this is the Android emulator default location (Mountain View, CA)
      // Default emulator coords: 37.4220, -122.0841 (with some variance)
      final isEmulatorDefault = (latitude >= 37.0 && latitude <= 38.0) &&
          (longitude >= -123.0 && longitude <= -121.0);
      
      if (isEmulatorDefault) {
        debugPrint('⚠️ Detected emulator default location (Mountain View, CA)');
        debugPrint('💡 TIP: Set custom location in emulator settings or use: adb emu geo fix 77.5946 12.9716');
        // Return a generic message instead of Mountain View
        return 'Set location in emulator';
      }

      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isEmpty) {
        return null;
      }

      final place = placemarks.first;
      
      debugPrint('🗺️ Geocoding result:');
      debugPrint('  SubLocality: ${place.subLocality}');
      debugPrint('  Locality (City): ${place.locality}');
      debugPrint('  SubAdministrativeArea: ${place.subAdministrativeArea}');
      debugPrint('  AdministrativeArea (State): ${place.administrativeArea}');
      debugPrint('  Country: ${place.country}');
      
      // Format address: "SubLocality, Locality" (Area, City)
      final parts = <String>[];
      
      // First: Add SubLocality (area/neighborhood) if available
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        parts.add(place.subLocality!);
      }
      
      // Second: Add Locality (city) if available and different from subLocality
      if (place.locality != null && 
          place.locality!.isNotEmpty &&
          place.locality != place.subLocality) {
        parts.add(place.locality!);
      }
      
      // Fallback: If we don't have both, try other fields
      if (parts.isEmpty) {
        // Try locality alone
        if (place.locality != null && place.locality!.isNotEmpty) {
          parts.add(place.locality!);
        } else if (place.subAdministrativeArea != null && 
                   place.subAdministrativeArea!.isNotEmpty) {
          parts.add(place.subAdministrativeArea!);
        } else if (place.administrativeArea != null && 
                   place.administrativeArea!.isNotEmpty) {
          parts.add(place.administrativeArea!);
        }
      }

      final address = parts.isEmpty ? 'Current Location' : parts.join(', ');
      debugPrint('📍 Final address: $address (lat: $latitude, lng: $longitude)');
      return address;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return 'Current Location';
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

