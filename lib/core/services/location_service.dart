import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Location Service
///
/// Handles GPS location detection and reverse geocoding
class LocationService {

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position
  /// 
  /// Returns Position with latitude and longitude
  Future<Position> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      
      if (kDebugMode) {
        print('📍 [LocationService] Current position: ${position.latitude}, ${position.longitude}');
      }
      
      return position;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [LocationService] Failed to get position: $e');
      }
      rethrow;
    }
  }

  /// Get current location with permission handling
  /// 
  /// Returns LocationResult with status and optional position
  Future<LocationResult> getCurrentLocationWithPermission() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          status: LocationStatus.serviceDisabled,
          message: 'Location services are disabled',
        );
      }

      // Check permission
      LocationPermission permission = await checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await requestPermission();
        
        if (permission == LocationPermission.denied) {
          return LocationResult(
            status: LocationStatus.permissionDenied,
            message: 'Location permission denied',
          );
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          status: LocationStatus.permissionDeniedForever,
          message: 'Location permission permanently denied',
        );
      }

      // Get position
      final position = await getCurrentPosition();
      
      return LocationResult(
        status: LocationStatus.success,
        position: position,
        message: 'Location retrieved successfully',
      );
    } catch (e) {
      return LocationResult(
        status: LocationStatus.error,
        message: 'Failed to get location: ${e.toString()}',
      );
    }
  }

  /// Reverse geocode coordinates to location name
  /// 
  /// Uses Nominatim reverse geocoding API
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      if (kDebugMode) {
        print('🌍 [LocationService] Reverse geocoding: $latitude, $longitude');
      }

      // For reverse geocoding, we'll need to implement a separate backend endpoint
      // or use a third-party service. For now, return a placeholder
      // The backend should implement: GET /api/reverse-geocode/?lat={lat}&lon={lon}
      
      // Fallback: Use approximate location based on coordinates
      // This is a temporary solution until backend implements reverse geocoding
      return 'Your location';
    } catch (e) {
      if (kDebugMode) {
        print('❌ [LocationService] Reverse geocoding failed: $e');
      }
      return null;
    }
  }

  /// Get current location name
  /// 
  /// Gets GPS position and converts to location name
  Future<String?> getCurrentLocationName() async {
    try {
      final result = await getCurrentLocationWithPermission();
      
      if (result.status == LocationStatus.success && result.position != null) {
        final position = result.position!;
        return await reverseGeocode(position.latitude, position.longitude);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [LocationService] Failed to get location name: $e');
      }
      return null;
    }
  }

  /// Open app settings for location permission
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}

/// Location Result
class LocationResult {
  final LocationStatus status;
  final Position? position;
  final String message;

  LocationResult({
    required this.status,
    this.position,
    required this.message,
  });

  bool get isSuccess => status == LocationStatus.success;
  bool get isPermissionDenied => 
      status == LocationStatus.permissionDenied || 
      status == LocationStatus.permissionDeniedForever;
  bool get isServiceDisabled => status == LocationStatus.serviceDisabled;
}

/// Location Status
enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}
