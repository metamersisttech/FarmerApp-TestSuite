import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/search/models/location_search_model.dart';

/// Location Search Service
///
/// Handles location search API calls using OpenStreetMap Nominatim
class LocationSearchService {
  final BackendHelper _backendHelper = BackendHelper();

  /// Search for locations by query string
  /// 
  /// Parameters:
  /// - query: Search query string (city, area, place name)
  /// 
  /// Returns: LocationSearchResponse with list of matching locations
  /// 
  /// API Example: GET /api/locationsearch/?q=shivajinagar
  Future<LocationSearchResponse> searchLocations(String query) async {
    try {
      if (query.trim().isEmpty) {
        return LocationSearchResponse(query: '', results: []);
      }

      // Call location search endpoint
      final response = await _backendHelper.getLocationSearch(query);
      
      // Parse response using model
      return LocationSearchResponse.fromJson(response);
    } on BackendException catch (e) {
      throw Exception('Location search failed: ${e.message}');
    } catch (e) {
      throw Exception('Location search failed: ${e.toString()}');
    }
  }

  /// Get location suggestions for autocomplete
  /// 
  /// Parameters:
  /// - query: Partial search query
  /// 
  /// Returns: List of location suggestion strings
  Future<List<String>> getLocationSuggestions(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final response = await searchLocations(query);
      
      // Extract short names for suggestions
      return response.results
          .map((location) => location.shortName)
          .take(5) // Limit to 5 suggestions
          .toList();
    } catch (e) {
      // Return empty list on error (don't fail the whole search)
      return [];
    }
  }
}
