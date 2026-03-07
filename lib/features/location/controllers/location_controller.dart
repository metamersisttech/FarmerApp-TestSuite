import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/location/models/location_model.dart';
import 'package:flutter_app/features/location/services/location_data_service.dart';
import 'package:flutter_app/data/services/location_service.dart';

/// Controller for location selection
class LocationController extends BaseController {
  final LocationDataService _locationDataService;
  final LocationService _locationService;

  LocationData _selectedLocation = const LocationData();
  
  LocationData get selectedLocation => _selectedLocation;
  
  // Expose location service for permission checks
  LocationService get locationService => _locationService;

  LocationController({
    LocationDataService? locationDataService,
    LocationService? locationService,
  })  : _locationDataService = locationDataService ?? LocationDataService(),
        _locationService = locationService ?? LocationService();

  /// Get all states
  List<StateModel> getAllStates() {
    return _locationDataService.getAllStates();
  }

  /// Search states
  List<StateModel> searchStates(String query) {
    return _locationDataService.searchStates(query);
  }

  /// Get cities for state
  List<CityModel> getCitiesForState(String stateCode) {
    return _locationDataService.getCitiesForState(stateCode);
  }

  /// Search cities
  List<CityModel> searchCities(String query, String stateCode) {
    return _locationDataService.searchCities(query, stateCode);
  }

  /// Get areas for city
  List<AreaModel> getAreasForCity(String cityName, String stateCode) {
    return _locationDataService.getAreasForCity(cityName, stateCode);
  }

  /// Search areas
  List<AreaModel> searchAreas(String query, String cityName, String stateCode) {
    return _locationDataService.searchAreas(query, cityName, stateCode);
  }

  /// Select state
  void selectState(String stateName) {
    _selectedLocation = _selectedLocation.copyWith(
      state: stateName,
      city: null, // Reset city and area when state changes
      area: null,
    );
    notifyListeners();
  }

  /// Select city
  void selectCity(String cityName) {
    _selectedLocation = _selectedLocation.copyWith(
      city: cityName,
      area: null, // Reset area when city changes
    );
    notifyListeners();
  }

  /// Select area
  void selectArea(String areaName) {
    _selectedLocation = _selectedLocation.copyWith(area: areaName);
    notifyListeners();
  }

  /// Get current location from device
  Future<bool> getCurrentLocation() async {
    setLoading(true);
    clearError();

    try {
      // Get current position with address
      final locationResult = await _locationService.getCurrentLocation(
        includeAddress: true,
      );
      
      if (locationResult.success && locationResult.position != null) {
        // Use the reverse geocoded address
        final address = locationResult.address ?? 'Current Location';
        
        // Parse address parts (format: "Area, City" or "City, State")
        final parts = address.split(', ');
        String? area, city;
        
        if (parts.length >= 2) {
          area = parts[0];
          city = parts[1];
        } else if (parts.length == 1) {
          city = parts[0];
        }
        
        _selectedLocation = LocationData(
          city: city ?? 'Unknown',
          area: area,
          fullAddress: address,
        );
        
        setLoading(false);
        return true;
      } else {
        setError(locationResult.errorMessage ?? 'Failed to get location');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('Failed to get current location');
      setLoading(false);
      return false;
    }
  }

  /// Reset selection
  void reset() {
    _selectedLocation = const LocationData();
    clearError();
    notifyListeners();
  }

  /// Create location from search result
  LocationData createLocationFromSearch({
    required String displayName,
    double? latitude,
    double? longitude,
  }) {
    // Parse the display name to extract location parts
    // Format examples:
    // "Mumbai, Maharashtra, India"
    // "Bangalore Urban, Karnataka, India"
    final parts = displayName.split(', ');
    
    String? area, city, state;
    
    if (parts.length >= 3) {
      area = parts[0];
      city = parts[1];
      state = parts[2];
    } else if (parts.length == 2) {
      city = parts[0];
      state = parts[1];
    } else if (parts.length == 1) {
      city = parts[0];
    }
    
    _selectedLocation = LocationData(
      city: city ?? 'Unknown',
      area: area,
      state: state,
      fullAddress: displayName,
      latitude: latitude,
      longitude: longitude,
    );
    
    notifyListeners();
    return _selectedLocation;
  }
}
