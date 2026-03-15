/// Transport Provider Model
///
/// Represents a transport service provider with profile, vehicles, and status.
/// Maps to Django TransportProviderSerializer.
library;

import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/transport/models/vehicle_model.dart';

class TransportProviderModel {
  final int providerId;
  final UserModel? user;
  final String businessName;
  final String? bio;
  final int serviceRadiusKm;
  final double rating;
  final int totalTrips;
  final int completedTrips;
  final bool available;
  final double? latitude;
  final double? longitude;
  final bool isDocumentsVerified;
  final String? drivingLicenseNumber;
  final DateTime? drivingLicenseExpiry;
  final String? drivingLicenseImage; // GCS key
  final bool drivingLicenseVerified;
  final List<VehicleModel> vehicles;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TransportProviderModel({
    required this.providerId,
    this.user,
    required this.businessName,
    this.bio,
    this.serviceRadiusKm = 50,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.completedTrips = 0,
    this.available = false,
    this.latitude,
    this.longitude,
    this.isDocumentsVerified = false,
    this.drivingLicenseNumber,
    this.drivingLicenseExpiry,
    this.drivingLicenseImage,
    this.drivingLicenseVerified = false,
    this.vehicles = const [],
    required this.createdAt,
    this.updatedAt,
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

  factory TransportProviderModel.fromJson(Map<String, dynamic> json) {
    // Parse user
    UserModel? user;
    if (json['user'] is Map<String, dynamic>) {
      user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    }

    // Parse vehicles
    List<VehicleModel> vehicles = [];
    final rawVehicles = json['vehicles'];
    if (rawVehicles is List) {
      vehicles = rawVehicles
          .whereType<Map<String, dynamic>>()
          .map((v) => VehicleModel.fromJson(v))
          .toList();
    }

    return TransportProviderModel(
      providerId: json['provider_id'] as int? ?? json['id'] as int? ?? 0,
      user: user,
      businessName: json['business_name'] as String? ?? '',
      bio: json['bio'] as String?,
      serviceRadiusKm: json['service_radius_km'] as int? ?? 50,
      rating: _parseDouble(json['rating']),
      totalTrips: json['total_trips'] as int? ?? 0,
      completedTrips: json['completed_trips'] as int? ?? 0,
      available: json['available'] as bool? ?? false,
      latitude: _parseOptionalDouble(json['latitude']),
      longitude: _parseOptionalDouble(json['longitude']),
      isDocumentsVerified: json['is_documents_verified'] as bool? ?? false,
      drivingLicenseNumber: json['driving_license_number'] as String?,
      drivingLicenseExpiry: json['driving_license_expiry'] != null
          ? DateTime.tryParse(json['driving_license_expiry'] as String)
          : null,
      drivingLicenseImage: json['driving_license_image'] as String?,
      drivingLicenseVerified: json['driving_license_verified'] as bool? ?? false,
      vehicles: vehicles,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_id': providerId,
      if (user != null) 'user': user!.toJson(),
      'business_name': businessName,
      if (bio != null) 'bio': bio,
      'service_radius_km': serviceRadiusKm,
      'rating': rating,
      'total_trips': totalTrips,
      'completed_trips': completedTrips,
      'available': available,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'is_documents_verified': isDocumentsVerified,
      if (drivingLicenseNumber != null) 'driving_license_number': drivingLicenseNumber,
      if (drivingLicenseExpiry != null)
        'driving_license_expiry': drivingLicenseExpiry!.toIso8601String().split('T')[0],
      if (drivingLicenseImage != null) 'driving_license_image': drivingLicenseImage,
      'driving_license_verified': drivingLicenseVerified,
      'vehicles': vehicles.map((v) => v.toJson()).toList(),
    };
  }

  /// Get provider name from user or business name
  String get displayName {
    if (user != null) {
      return user!.fullNameDisplay;
    }
    return businessName;
  }

  /// Get profile image URL
  String? get profileImageUrl {
    return user?.profileImage;
  }

  /// Get driving license image URL
  String? get drivingLicenseImageUrl {
    if (drivingLicenseImage == null) return null;
    return CommonHelper.getImageUrl(drivingLicenseImage!);
  }

  /// Get formatted rating
  String get formattedRating => rating.toStringAsFixed(1);

  /// Get formatted service radius
  String get formattedServiceRadius => '$serviceRadiusKm km';

  /// Check if provider has active vehicles
  bool get hasActiveVehicles => vehicles.any((v) => v.isActive);

  /// Get count of active vehicles
  int get activeVehicleCount => vehicles.where((v) => v.isActive).length;

  /// Check if license is expired
  bool get isLicenseExpired {
    if (drivingLicenseExpiry == null) return false;
    return drivingLicenseExpiry!.isBefore(DateTime.now());
  }

  /// Get initials for avatar fallback
  String get initials {
    return displayName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  TransportProviderModel copyWith({
    int? providerId,
    UserModel? user,
    String? businessName,
    String? bio,
    int? serviceRadiusKm,
    double? rating,
    int? totalTrips,
    int? completedTrips,
    bool? available,
    double? latitude,
    double? longitude,
    bool? isDocumentsVerified,
    String? drivingLicenseNumber,
    DateTime? drivingLicenseExpiry,
    String? drivingLicenseImage,
    bool? drivingLicenseVerified,
    List<VehicleModel>? vehicles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransportProviderModel(
      providerId: providerId ?? this.providerId,
      user: user ?? this.user,
      businessName: businessName ?? this.businessName,
      bio: bio ?? this.bio,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      completedTrips: completedTrips ?? this.completedTrips,
      available: available ?? this.available,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDocumentsVerified: isDocumentsVerified ?? this.isDocumentsVerified,
      drivingLicenseNumber: drivingLicenseNumber ?? this.drivingLicenseNumber,
      drivingLicenseExpiry: drivingLicenseExpiry ?? this.drivingLicenseExpiry,
      drivingLicenseImage: drivingLicenseImage ?? this.drivingLicenseImage,
      drivingLicenseVerified: drivingLicenseVerified ?? this.drivingLicenseVerified,
      vehicles: vehicles ?? this.vehicles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TransportProviderModel(providerId: $providerId, businessName: $businessName, available: $available)';
  }
}
