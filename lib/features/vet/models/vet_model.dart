/// Vet data model representing a veterinarian
///
/// Maps both the public vet list (GET /api/vets/) and
/// vet detail (GET /api/vets/{id}/) API responses.
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

  // API-specific fields
  final String? qualifications;
  final String? registrationNo;
  final List<String> specializations;

  const VetModel({
    required this.id,
    required this.name,
    this.profileImage,
    required this.specialization,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.distanceKm = 0.0,
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
    this.qualifications,
    this.registrationNo,
    this.specializations = const [],
  });

  /// Parse a fee value that may be a string "500.00" or a num
  static double _parseDoubleFee(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Parse an optional fee value
  static double? _parseOptionalFee(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  /// Format username to display name (capitalize, replace underscores)
  static String _formatUsername(String username) {
    return username
        .split(RegExp(r'[_\s]+'))
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  /// Create VetModel from API JSON response
  factory VetModel.fromJson(Map<String, dynamic> json) {
    // Handle name from user object or flat fields
    String name;
    if (json['user'] is Map<String, dynamic>) {
      // Nested user object (some API formats)
      final user = json['user'] as Map<String, dynamic>;
      name = _formatUsername(user['username'] as String? ?? 'Unknown');
    } else if (json['user_first_name'] != null || json['user_last_name'] != null) {
      // Flat fields: user_first_name + user_last_name
      final first = json['user_first_name'] as String? ?? '';
      final last = json['user_last_name'] as String? ?? '';
      name = '$first $last'.trim();
      if (name.isEmpty) {
        name = _formatUsername(json['user_name'] as String? ?? 'Unknown');
      }
    } else if (json['user_name'] != null) {
      // Flat field: user_name only
      name = _formatUsername(json['user_name'] as String);
    } else {
      name = json['name'] as String? ?? 'Unknown';
    }

    // Parse specializations list
    List<String> specList = [];
    final rawSpecs = json['specializations'];
    if (rawSpecs is List) {
      specList = rawSpecs.map((e) => e.toString()).toList();
    }

    return VetModel(
      id: json['vet_id'] as int? ?? json['id'] as int? ?? 0,
      name: name,
      profileImage: json['profile_image'] as String?,
      specialization: json['specialization'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      experienceYears: json['years_of_experience'] as int? ??
          json['experience_years'] as int? ??
          0,
      consultationFee: _parseDoubleFee(json['consultation_fee']),
      isAvailable: json['available'] as bool? ??
          json['is_available'] as bool? ??
          true,
      isVerified: json['is_documents_verified'] as bool? ??
          json['is_verified'] as bool? ??
          false,
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
      videoCallFee: _parseOptionalFee(json['video_consultation_fee'] ??
          json['video_call_fee']),
      homeVisitFee: _parseOptionalFee(json['home_visit_fee']),
      phoneNumber: json['phone_number'] as String?,
      qualifications: json['qualifications'] as String?,
      registrationNo: json['registration_no'] as String?,
      specializations: specList,
    );
  }

  /// Convert VetModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'vet_id': id,
      'name': name,
      'profile_image': profileImage,
      'specialization': specialization,
      'specializations': specializations,
      'rating': rating,
      'review_count': reviewCount,
      'distance_km': distanceKm,
      'years_of_experience': experienceYears,
      'consultation_fee': consultationFee,
      'available': isAvailable,
      'is_documents_verified': isVerified,
      'bio': bio,
      'languages': languages,
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
      'working_hours': workingHours,
      'animal_types': animalTypes,
      'services': services,
      'video_consultation_fee': videoCallFee,
      'home_visit_fee': homeVisitFee,
      'phone_number': phoneNumber,
      'qualifications': qualifications,
      'registration_no': registrationNo,
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
