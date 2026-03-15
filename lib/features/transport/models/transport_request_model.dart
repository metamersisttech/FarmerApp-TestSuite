/// Transport Request Model
///
/// Represents a transport request with route, cargo, fare, and status.
/// Maps to Django TransportRequestSerializer.
library;

import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/transport/models/cargo_animal_model.dart';
import 'package:flutter_app/features/transport/models/transport_provider_model.dart';
import 'package:flutter_app/features/transport/models/vehicle_model.dart';

/// Transport request status
enum TransportRequestStatus {
  pending('PENDING', 'Pending'),
  accepted('ACCEPTED', 'Accepted'),
  inProgress('IN_PROGRESS', 'In Progress'),
  inTransit('IN_TRANSIT', 'In Transit'),
  completed('COMPLETED', 'Completed'),
  cancelled('CANCELLED', 'Cancelled'),
  expired('EXPIRED', 'Expired');

  final String value;
  final String displayName;
  const TransportRequestStatus(this.value, this.displayName);

  static TransportRequestStatus fromString(String value) {
    return TransportRequestStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => TransportRequestStatus.pending,
    );
  }

  /// Get status color
  Color get color {
    switch (this) {
      case TransportRequestStatus.pending:
        return Colors.orange;
      case TransportRequestStatus.accepted:
        return Colors.blue;
      case TransportRequestStatus.inProgress:
        return Colors.indigo;
      case TransportRequestStatus.inTransit:
        return Colors.purple;
      case TransportRequestStatus.completed:
        return Colors.green;
      case TransportRequestStatus.cancelled:
        return Colors.red;
      case TransportRequestStatus.expired:
        return Colors.grey;
    }
  }
}

class TransportRequestModel {
  final int requestId;
  final UserModel? requestor;
  final String sourceAddress;
  final double sourceLatitude;
  final double sourceLongitude;
  final String destinationAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final double distanceKm;
  final List<CargoAnimalModel> cargoAnimals;
  final double estimatedWeightKg;
  final DateTime pickupDate;
  final TimeOfDay? pickupTime;
  final double estimatedFareMin;
  final double estimatedFareMax;
  final String? notes;
  final double? distanceFromProvider;
  final DateTime? expiresAt;
  final String status;
  final TransportProviderModel? transportProvider;
  final VehicleModel? vehicle;
  final double? proposedFare;
  final bool fareApprovedByRequestor;
  final bool fareApprovedByProvider;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final String? cancellationReason;
  final double? finalFare;
  final double? providerRating;
  final String? providerReview;

  const TransportRequestModel({
    required this.requestId,
    this.requestor,
    required this.sourceAddress,
    required this.sourceLatitude,
    required this.sourceLongitude,
    required this.destinationAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.distanceKm,
    this.cargoAnimals = const [],
    this.estimatedWeightKg = 0.0,
    required this.pickupDate,
    this.pickupTime,
    this.estimatedFareMin = 0.0,
    this.estimatedFareMax = 0.0,
    this.notes,
    this.distanceFromProvider,
    this.expiresAt,
    this.status = 'PENDING',
    this.transportProvider,
    this.vehicle,
    this.proposedFare,
    this.fareApprovedByRequestor = false,
    this.fareApprovedByProvider = false,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    this.cancellationReason,
    this.finalFare,
    this.providerRating,
    this.providerReview,
  });

  /// Parse numeric value from various types
  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double? _parseOptionalDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse time string "HH:MM" or "HH:MM:SS" to TimeOfDay
  static TimeOfDay? _parseTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final parts = value.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    }
    return null;
  }

  factory TransportRequestModel.fromJson(Map<String, dynamic> json) {
    // Parse requestor
    UserModel? requestor;
    if (json['requestor'] is Map<String, dynamic>) {
      requestor = UserModel.fromJson(json['requestor'] as Map<String, dynamic>);
    }

    // Parse cargo animals
    List<CargoAnimalModel> cargoAnimals = [];
    final rawCargo = json['cargo_animals'] ?? json['cargo'];
    if (rawCargo is List) {
      cargoAnimals = rawCargo
          .whereType<Map<String, dynamic>>()
          .map((c) => CargoAnimalModel.fromJson(c))
          .toList();
    }

    // Parse transport provider
    TransportProviderModel? transportProvider;
    if (json['transport_provider'] is Map<String, dynamic>) {
      transportProvider = TransportProviderModel.fromJson(
          json['transport_provider'] as Map<String, dynamic>);
    }

    // Parse vehicle
    VehicleModel? vehicle;
    if (json['vehicle'] is Map<String, dynamic>) {
      vehicle = VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>);
    }

    return TransportRequestModel(
      requestId: json['request_id'] as int? ?? json['id'] as int? ?? 0,
      requestor: requestor,
      sourceAddress: json['source_address'] as String? ?? '',
      sourceLatitude: _parseDouble(json['source_latitude']),
      sourceLongitude: _parseDouble(json['source_longitude']),
      destinationAddress: json['destination_address'] as String? ?? '',
      destinationLatitude: _parseDouble(json['destination_latitude']),
      destinationLongitude: _parseDouble(json['destination_longitude']),
      distanceKm: _parseDouble(json['distance_km']),
      cargoAnimals: cargoAnimals,
      estimatedWeightKg: _parseDouble(json['estimated_weight_kg']),
      pickupDate: json['pickup_date'] != null
          ? DateTime.parse(json['pickup_date'] as String)
          : DateTime.now(),
      pickupTime: _parseTime(json['pickup_time']),
      estimatedFareMin: _parseDouble(json['estimated_fare_min']),
      estimatedFareMax: _parseDouble(json['estimated_fare_max']),
      notes: json['notes'] as String?,
      distanceFromProvider: _parseOptionalDouble(json['distance_from_provider']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      status: json['status'] as String? ?? 'PENDING',
      transportProvider: transportProvider,
      vehicle: vehicle,
      proposedFare: _parseOptionalDouble(json['proposed_fare']),
      fareApprovedByRequestor: json['fare_approved_by_requestor'] as bool? ?? false,
      fareApprovedByProvider: json['fare_approved_by_provider'] as bool? ?? false,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      cancellationReason: json['cancellation_reason'] as String?,
      finalFare: _parseOptionalDouble(json['final_fare']),
      providerRating: _parseOptionalDouble(json['provider_rating']),
      providerReview: json['provider_review'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      if (requestor != null) 'requestor': requestor!.toJson(),
      'source_address': sourceAddress,
      'source_latitude': sourceLatitude,
      'source_longitude': sourceLongitude,
      'destination_address': destinationAddress,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'distance_km': distanceKm,
      'cargo_animals': cargoAnimals.map((c) => c.toJson()).toList(),
      'estimated_weight_kg': estimatedWeightKg,
      'pickup_date': pickupDate.toIso8601String().split('T')[0],
      if (pickupTime != null)
        'pickup_time': '${pickupTime!.hour.toString().padLeft(2, '0')}:${pickupTime!.minute.toString().padLeft(2, '0')}',
      'estimated_fare_min': estimatedFareMin,
      'estimated_fare_max': estimatedFareMax,
      if (notes != null) 'notes': notes,
      'status': status,
      if (proposedFare != null) 'proposed_fare': proposedFare,
      'fare_approved_by_requestor': fareApprovedByRequestor,
      'fare_approved_by_provider': fareApprovedByProvider,
    };
  }

  /// Get status enum
  TransportRequestStatus get statusEnum =>
      TransportRequestStatus.fromString(status);

  /// Get status display name
  String get statusDisplay => statusEnum.displayName;

  /// Get status color
  Color get statusColor => statusEnum.color;

  /// Get formatted pickup date
  String get formattedPickupDate {
    return '${pickupDate.day}/${pickupDate.month}/${pickupDate.year}';
  }

  /// Get formatted pickup time
  String? get formattedPickupTime {
    if (pickupTime == null) return null;
    final hour = pickupTime!.hourOfPeriod == 0 ? 12 : pickupTime!.hourOfPeriod;
    final period = pickupTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${pickupTime!.minute.toString().padLeft(2, '0')} $period';
  }

  /// Get formatted distance
  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';

  /// Get formatted distance from provider
  String? get formattedDistanceFromProvider {
    if (distanceFromProvider == null) return null;
    return '${distanceFromProvider!.toStringAsFixed(1)} km away';
  }

  /// Get formatted fare range
  String get formattedFareRange =>
      '\u20B9${estimatedFareMin.toStringAsFixed(0)} - \u20B9${estimatedFareMax.toStringAsFixed(0)}';

  /// Get formatted fare (final or proposed or range)
  String get formattedFare {
    if (finalFare != null) {
      return '\u20B9${finalFare!.toStringAsFixed(0)}';
    }
    if (proposedFare != null) {
      return '\u20B9${proposedFare!.toStringAsFixed(0)}';
    }
    return formattedFareRange;
  }

  /// Get formatted proposed fare
  String? get formattedProposedFare {
    if (proposedFare == null) return null;
    return '\u20B9${proposedFare!.toStringAsFixed(0)}';
  }

  /// Get formatted final fare
  String? get formattedFinalFare {
    if (finalFare == null) return null;
    return '\u20B9${finalFare!.toStringAsFixed(0)}';
  }

  /// Get formatted weight
  String get formattedWeight => '${estimatedWeightKg.toStringAsFixed(0)} kg';

  /// Get cargo summary (e.g., "2 Cattle, 1 Buffalo")
  String get cargoSummary {
    if (cargoAnimals.isEmpty) return 'No cargo specified';
    return cargoAnimals.map((c) => c.summary).join(', ');
  }

  /// Get total animal count
  int get totalAnimalCount =>
      cargoAnimals.fold(0, (sum, c) => sum + c.count);

  /// Check if request is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get time remaining until expiry
  Duration? get timeUntilExpiry {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if fare is agreed upon by both parties
  bool get isFareAgreed => fareApprovedByRequestor && fareApprovedByProvider;

  /// Check if request can be accepted
  bool get canAccept => statusEnum == TransportRequestStatus.pending && !isExpired;

  /// Check if fare can be proposed
  bool get canProposeFare => statusEnum == TransportRequestStatus.accepted;

  /// Check if pickup can be confirmed
  bool get canConfirmPickup =>
      statusEnum == TransportRequestStatus.inProgress && isFareAgreed;

  /// Check if request can be cancelled
  bool get canCancel =>
      statusEnum == TransportRequestStatus.pending ||
      statusEnum == TransportRequestStatus.accepted ||
      statusEnum == TransportRequestStatus.inProgress;

  /// Get route string
  String get routeDisplay => '$sourceAddress → $destinationAddress';

  TransportRequestModel copyWith({
    int? requestId,
    UserModel? requestor,
    String? sourceAddress,
    double? sourceLatitude,
    double? sourceLongitude,
    String? destinationAddress,
    double? destinationLatitude,
    double? destinationLongitude,
    double? distanceKm,
    List<CargoAnimalModel>? cargoAnimals,
    double? estimatedWeightKg,
    DateTime? pickupDate,
    TimeOfDay? pickupTime,
    double? estimatedFareMin,
    double? estimatedFareMax,
    String? notes,
    double? distanceFromProvider,
    DateTime? expiresAt,
    String? status,
    TransportProviderModel? transportProvider,
    VehicleModel? vehicle,
    double? proposedFare,
    bool? fareApprovedByRequestor,
    bool? fareApprovedByProvider,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    String? cancellationReason,
    double? finalFare,
    double? providerRating,
    String? providerReview,
  }) {
    return TransportRequestModel(
      requestId: requestId ?? this.requestId,
      requestor: requestor ?? this.requestor,
      sourceAddress: sourceAddress ?? this.sourceAddress,
      sourceLatitude: sourceLatitude ?? this.sourceLatitude,
      sourceLongitude: sourceLongitude ?? this.sourceLongitude,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      distanceKm: distanceKm ?? this.distanceKm,
      cargoAnimals: cargoAnimals ?? this.cargoAnimals,
      estimatedWeightKg: estimatedWeightKg ?? this.estimatedWeightKg,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTime: pickupTime ?? this.pickupTime,
      estimatedFareMin: estimatedFareMin ?? this.estimatedFareMin,
      estimatedFareMax: estimatedFareMax ?? this.estimatedFareMax,
      notes: notes ?? this.notes,
      distanceFromProvider: distanceFromProvider ?? this.distanceFromProvider,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      transportProvider: transportProvider ?? this.transportProvider,
      vehicle: vehicle ?? this.vehicle,
      proposedFare: proposedFare ?? this.proposedFare,
      fareApprovedByRequestor: fareApprovedByRequestor ?? this.fareApprovedByRequestor,
      fareApprovedByProvider: fareApprovedByProvider ?? this.fareApprovedByProvider,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      finalFare: finalFare ?? this.finalFare,
      providerRating: providerRating ?? this.providerRating,
      providerReview: providerReview ?? this.providerReview,
    );
  }

  @override
  String toString() {
    return 'TransportRequestModel(requestId: $requestId, status: $status, route: $routeDisplay)';
  }
}
