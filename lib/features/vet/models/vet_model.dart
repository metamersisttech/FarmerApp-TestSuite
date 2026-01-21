/// Vet data model representing a veterinarian
class VetModel {
  final int id;
  final String name;
  final String? profileImage;
  final String specialization;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final int experienceYears;
  final double consultationFee;
  final bool isAvailable;
  final bool isVerified;

  const VetModel({
    required this.id,
    required this.name,
    this.profileImage,
    required this.specialization,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.experienceYears,
    required this.consultationFee,
    this.isAvailable = true,
    this.isVerified = false,
  });

  /// Create VetModel from JSON (for future API integration)
  factory VetModel.fromJson(Map<String, dynamic> json) {
    return VetModel(
      id: json['id'] as int,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String?,
      specialization: json['specialization'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      distanceKm: (json['distance_km'] as num).toDouble(),
      experienceYears: json['experience_years'] as int,
      consultationFee: (json['consultation_fee'] as num).toDouble(),
      isAvailable: json['is_available'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  /// Convert VetModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'specialization': specialization,
      'rating': rating,
      'review_count': reviewCount,
      'distance_km': distanceKm,
      'experience_years': experienceYears,
      'consultation_fee': consultationFee,
      'is_available': isAvailable,
      'is_verified': isVerified,
    };
  }
}
