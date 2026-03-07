/// Location Search Model
///
/// Represents a location search result from OpenStreetMap Nominatim API
class LocationSearchModel {
  final String displayName;
  final String latitude;
  final String longitude;
  final String type;

  LocationSearchModel({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.type,
  });

  /// Create from JSON
  factory LocationSearchModel.fromJson(Map<String, dynamic> json) {
    return LocationSearchModel(
      displayName: json['display_name'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      type: json['type'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
    };
  }

  /// Get short display name (city/area name)
  String get shortName {
    // Extract first part before first comma
    final parts = displayName.split(',');
    return parts.isNotEmpty ? parts[0].trim() : displayName;
  }

  /// Get formatted location string for display
  String get formattedLocation {
    // Get first 2-3 parts for better context
    final parts = displayName.split(',');
    if (parts.length >= 3) {
      return '${parts[0].trim()}, ${parts[1].trim()}, ${parts[2].trim()}';
    } else if (parts.length >= 2) {
      return '${parts[0].trim()}, ${parts[1].trim()}';
    }
    return displayName;
  }

  @override
  String toString() {
    return 'LocationSearchModel(displayName: $displayName, lat: $latitude, lng: $longitude, type: $type)';
  }
}

/// Location Search Response Model
class LocationSearchResponse {
  final String query;
  final List<LocationSearchModel> results;

  LocationSearchResponse({
    required this.query,
    required this.results,
  });

  /// Create from JSON
  factory LocationSearchResponse.fromJson(Map<String, dynamic> json) {
    final resultsList = json['results'] as List<dynamic>? ?? [];
    
    return LocationSearchResponse(
      query: json['query'] ?? '',
      results: resultsList
          .map((item) => LocationSearchModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'results': results.map((r) => r.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'LocationSearchResponse(query: $query, results: ${results.length} items)';
  }
}
