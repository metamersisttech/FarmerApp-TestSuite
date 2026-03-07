/// Location models for India address system
library;

/// State model
class StateModel {
  final String name;
  final String code;

  const StateModel({
    required this.name,
    required this.code,
  });
}

/// City model
class CityModel {
  final String name;
  final String stateCode;

  const CityModel({
    required this.name,
    required this.stateCode,
  });
}

/// Area model
class AreaModel {
  final String name;
  final String cityName;
  final String pincode;

  const AreaModel({
    required this.name,
    required this.cityName,
    this.pincode = '',
  });
}

/// Complete location model
class LocationData {
  final String? state;
  final String? city;
  final String? area;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;

  const LocationData({
    this.state,
    this.city,
    this.area,
    this.fullAddress,
    this.latitude,
    this.longitude,
  });

  String get displayLocation {
    if (area != null && city != null) {
      return '$area, $city';
    } else if (city != null && state != null) {
      return '$city, $state';
    } else if (city != null) {
      return city!;
    }
    return 'Select Location';
  }

  LocationData copyWith({
    String? state,
    String? city,
    String? area,
    String? fullAddress,
    double? latitude,
    double? longitude,
  }) {
    return LocationData(
      state: state ?? this.state,
      city: city ?? this.city,
      area: area ?? this.area,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
