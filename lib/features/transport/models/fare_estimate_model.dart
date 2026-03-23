/// Fare Estimate Model
///
/// Represents a fare estimate response from the transport estimate API.
/// Maps to Django FareEstimateSerializer.
library;

class FareEstimateModel {
  final double distanceKm;
  final double estimatedFareMin;
  final double estimatedFareMax;
  final double estimatedWeightKg;
  final String? sourceAddress;
  final String? destinationAddress;

  const FareEstimateModel({
    required this.distanceKm,
    required this.estimatedFareMin,
    required this.estimatedFareMax,
    this.estimatedWeightKg = 0.0,
    this.sourceAddress,
    this.destinationAddress,
  });

  /// Parse numeric value from various types
  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory FareEstimateModel.fromJson(Map<String, dynamic> json) {
    return FareEstimateModel(
      distanceKm: _parseDouble(json['distance_km']),
      estimatedFareMin: _parseDouble(json['estimated_fare_min']),
      estimatedFareMax: _parseDouble(json['estimated_fare_max']),
      estimatedWeightKg: _parseDouble(json['estimated_weight_kg']),
      sourceAddress: json['source_address'] as String?,
      destinationAddress: json['destination_address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance_km': distanceKm,
      'estimated_fare_min': estimatedFareMin,
      'estimated_fare_max': estimatedFareMax,
      'estimated_weight_kg': estimatedWeightKg,
      if (sourceAddress != null) 'source_address': sourceAddress,
      if (destinationAddress != null) 'destination_address': destinationAddress,
    };
  }

  /// Get formatted distance
  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';

  /// Get formatted fare range
  String get formattedFareRange =>
      '\u20B9${estimatedFareMin.toStringAsFixed(0)} - \u20B9${estimatedFareMax.toStringAsFixed(0)}';

  /// Get formatted minimum fare
  String get formattedFareMin => '\u20B9${estimatedFareMin.toStringAsFixed(0)}';

  /// Get formatted maximum fare
  String get formattedFareMax => '\u20B9${estimatedFareMax.toStringAsFixed(0)}';

  /// Get average fare
  double get averageFare => (estimatedFareMin + estimatedFareMax) / 2;

  /// Get formatted average fare
  String get formattedAverageFare => '\u20B9${averageFare.toStringAsFixed(0)}';

  /// Get formatted weight
  String get formattedWeight => '${estimatedWeightKg.toStringAsFixed(0)} kg';

  FareEstimateModel copyWith({
    double? distanceKm,
    double? estimatedFareMin,
    double? estimatedFareMax,
    double? estimatedWeightKg,
    String? sourceAddress,
    String? destinationAddress,
  }) {
    return FareEstimateModel(
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedFareMin: estimatedFareMin ?? this.estimatedFareMin,
      estimatedFareMax: estimatedFareMax ?? this.estimatedFareMax,
      estimatedWeightKg: estimatedWeightKg ?? this.estimatedWeightKg,
      sourceAddress: sourceAddress ?? this.sourceAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
    );
  }

  @override
  String toString() {
    return 'FareEstimateModel(distance: $formattedDistance, fare: $formattedFareRange)';
  }
}
