/// Vehicle Model for Transport Feature
///
/// Represents a transport vehicle with registration, capacity, and documents.
/// Maps to Django VehicleSerializer.
library;

import 'package:flutter_app/core/helpers/common_helper.dart';

/// Vehicle types available for transport
enum VehicleType {
  pickup('PICKUP', 'Pickup'),
  miniTruck('MINI_TRUCK', 'Mini Truck'),
  truck('TRUCK', 'Truck'),
  trailer('TRAILER', 'Trailer'),
  tempo('TEMPO', 'Tempo'),
  other('OTHER', 'Other');

  final String value;
  final String displayName;
  const VehicleType(this.value, this.displayName);

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => VehicleType.other,
    );
  }
}

class VehicleModel {
  final int vehicleId;
  final String vehicleType;
  final String registrationNumber;
  final String make;
  final String model;
  final int? year;
  final double maxWeightKg;
  final double? maxLengthCm;
  final double? maxWidthCm;
  final double? maxHeightCm;
  final String? rcDocument; // GCS key
  final String? insuranceDocument; // GCS key
  final List<String> vehicleImages; // List of GCS keys
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const VehicleModel({
    required this.vehicleId,
    required this.vehicleType,
    required this.registrationNumber,
    required this.make,
    required this.model,
    this.year,
    required this.maxWeightKg,
    this.maxLengthCm,
    this.maxWidthCm,
    this.maxHeightCm,
    this.rcDocument,
    this.insuranceDocument,
    this.vehicleImages = const [],
    this.isActive = true,
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

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Parse vehicle images
    List<String> images = [];
    final rawImages = json['vehicle_images'] ?? json['images'];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    }

    return VehicleModel(
      vehicleId: json['vehicle_id'] as int? ?? json['id'] as int? ?? 0,
      vehicleType: json['vehicle_type'] as String? ?? 'OTHER',
      registrationNumber: json['registration_number'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: _parseOptionalInt(json['year']),
      maxWeightKg: _parseDouble(json['max_weight_kg']),
      maxLengthCm: _parseOptionalDouble(json['max_length_cm']),
      maxWidthCm: _parseOptionalDouble(json['max_width_cm']),
      maxHeightCm: _parseOptionalDouble(json['max_height_cm']),
      rcDocument: json['rc_document'] as String?,
      insuranceDocument: json['insurance_document'] as String?,
      vehicleImages: images,
      isActive: json['is_active'] as bool? ?? true,
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
      'vehicle_id': vehicleId,
      'vehicle_type': vehicleType,
      'registration_number': registrationNumber,
      'make': make,
      'model': model,
      if (year != null) 'year': year,
      'max_weight_kg': maxWeightKg,
      if (maxLengthCm != null) 'max_length_cm': maxLengthCm,
      if (maxWidthCm != null) 'max_width_cm': maxWidthCm,
      if (maxHeightCm != null) 'max_height_cm': maxHeightCm,
      if (rcDocument != null) 'rc_document': rcDocument,
      if (insuranceDocument != null) 'insurance_document': insuranceDocument,
      'vehicle_images': vehicleImages,
      'is_active': isActive,
    };
  }

  /// Get vehicle type enum
  VehicleType get vehicleTypeEnum => VehicleType.fromString(vehicleType);

  /// Get vehicle type display name
  String get vehicleTypeDisplay => vehicleTypeEnum.displayName;

  /// Get formatted weight capacity
  String get formattedMaxWeight => '${maxWeightKg.toStringAsFixed(0)} kg';

  /// Get formatted dimensions if available
  String? get formattedDimensions {
    if (maxLengthCm == null && maxWidthCm == null && maxHeightCm == null) {
      return null;
    }
    final parts = <String>[];
    if (maxLengthCm != null) parts.add('L: ${maxLengthCm!.toStringAsFixed(0)}cm');
    if (maxWidthCm != null) parts.add('W: ${maxWidthCm!.toStringAsFixed(0)}cm');
    if (maxHeightCm != null) parts.add('H: ${maxHeightCm!.toStringAsFixed(0)}cm');
    return parts.join(' x ');
  }

  /// Get display title (Make Model Year)
  String get displayTitle {
    final parts = [make, model];
    if (year != null) parts.add('($year)');
    return parts.join(' ');
  }

  /// Get first vehicle image URL
  String? get primaryImageUrl {
    if (vehicleImages.isEmpty) return null;
    return CommonHelper.getImageUrl(vehicleImages.first);
  }

  /// Get all vehicle image URLs
  List<String> get imageUrls {
    return vehicleImages.map((key) => CommonHelper.getImageUrl(key)).toList();
  }

  /// Get RC document URL
  String? get rcDocumentUrl {
    if (rcDocument == null) return null;
    return CommonHelper.getImageUrl(rcDocument!);
  }

  /// Get insurance document URL
  String? get insuranceDocumentUrl {
    if (insuranceDocument == null) return null;
    return CommonHelper.getImageUrl(insuranceDocument!);
  }

  VehicleModel copyWith({
    int? vehicleId,
    String? vehicleType,
    String? registrationNumber,
    String? make,
    String? model,
    int? year,
    double? maxWeightKg,
    double? maxLengthCm,
    double? maxWidthCm,
    double? maxHeightCm,
    String? rcDocument,
    String? insuranceDocument,
    List<String>? vehicleImages,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleType: vehicleType ?? this.vehicleType,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      maxWeightKg: maxWeightKg ?? this.maxWeightKg,
      maxLengthCm: maxLengthCm ?? this.maxLengthCm,
      maxWidthCm: maxWidthCm ?? this.maxWidthCm,
      maxHeightCm: maxHeightCm ?? this.maxHeightCm,
      rcDocument: rcDocument ?? this.rcDocument,
      insuranceDocument: insuranceDocument ?? this.insuranceDocument,
      vehicleImages: vehicleImages ?? this.vehicleImages,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'VehicleModel(vehicleId: $vehicleId, registration: $registrationNumber, type: $vehicleType)';
  }
}
