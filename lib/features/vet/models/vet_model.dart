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

  // Detail page fields
  final String? bio;
  final List<String> languages;
  final String? clinicName;
  final String? clinicAddress;
  final String? workingHours;
  final List<String> animalTypes;
  final List<String> services;
  final double? videoCallFee;
  final double? homeVisitFee;
  final String? phoneNumber;

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
    this.bio,
    this.languages = const [],
    this.clinicName,
    this.clinicAddress,
    this.workingHours,
    this.animalTypes = const [],
    this.services = const [],
    this.videoCallFee,
    this.homeVisitFee,
    this.phoneNumber,
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
      bio: json['bio'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      clinicName: json['clinic_name'] as String?,
      clinicAddress: json['clinic_address'] as String?,
      workingHours: json['working_hours'] as String?,
      animalTypes: (json['animal_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      videoCallFee: (json['video_call_fee'] as num?)?.toDouble(),
      homeVisitFee: (json['home_visit_fee'] as num?)?.toDouble(),
      phoneNumber: json['phone_number'] as String?,
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
      'bio': bio,
      'languages': languages,
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
      'working_hours': workingHours,
      'animal_types': animalTypes,
      'services': services,
      'video_call_fee': videoCallFee,
      'home_visit_fee': homeVisitFee,
      'phone_number': phoneNumber,
    };
  }

  /// Get initials from name for avatar fallback
  String get initials {
    return name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  /// Format consultation fee for display
  String get formattedConsultationFee => '\u20B9${consultationFee.toInt()}';

  /// Format video call fee for display
  String? get formattedVideoCallFee =>
      videoCallFee != null ? '\u20B9${videoCallFee!.toInt()}' : null;

  /// Format home visit fee for display
  String? get formattedHomeVisitFee =>
      homeVisitFee != null ? '\u20B9${homeVisitFee!.toInt()}' : null;

  /// Format languages as comma-separated string
  String get languagesDisplay => languages.join(', ');
}
