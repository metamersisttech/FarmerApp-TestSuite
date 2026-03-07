import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
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

      final address = parts.isEmpty ? null : parts.join(', ');
      debugPrint('📍 Final address: ${address ?? 'No address found'} (lat: $latitude, lng: $longitude)');
      return address;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
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

  /// Show location permission dialog with slide from top animation
  static Future<bool> showLocationPermissionDialog(BuildContext context) async {
    return await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'Location Permission',
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) {
            return const SizedBox.shrink();
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            // Slide from top animation
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));

            // Fade animation for smooth appearance
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ));

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 20,
                      right: 20,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
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
                                Icons.location_on,
                                size: 48,
                                color: AppTheme.authPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Title
                            const Text(
                              'Enable Location',
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
                              'Please enable location access to find nearby livestock, sellers, and services in your area.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Enable Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
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
                                  'Enable',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Not Now Button
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
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
                    ),
                  ),
                ),
              ),
            );
          },
        ) ??
        false;
  }
}

