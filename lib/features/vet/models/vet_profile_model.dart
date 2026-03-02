/// Vet profile model for the vet's own profile management
///
/// Maps the response from GET /api/vets/me/
class VetProfileModel {
  final int vetId;
  final Map<String, dynamic> user;
  final String? clinicName;
  final String? qualifications;
  final String? registrationNo;
  final String? specialization;
  final List<String> specializations;
  final int? yearsOfExperience;
  final String? bio;
  final String? consultationFee;
  final String? videoConsultationFee;
  final String? homeVisitFee;
  final String? emergencyFeeMultiplier;
  final bool available;
  final String? latitude;
  final String? longitude;
  final bool isDocumentsVerified;

  const VetProfileModel({
    required this.vetId,
    required this.user,
    this.clinicName,
    this.qualifications,
    this.registrationNo,
    this.specialization,
    this.specializations = const [],
    this.yearsOfExperience,
    this.bio,
    this.consultationFee,
    this.videoConsultationFee,
    this.homeVisitFee,
    this.emergencyFeeMultiplier,
    this.available = true,
    this.latitude,
    this.longitude,
    this.isDocumentsVerified = false,
  });

  // User helper getters
  int get userId => user['id'] as int? ?? 0;
  String get userName => user['username'] as String? ?? '';
  String get userEmail => user['email'] as String? ?? '';

  /// Get display name (username with "Dr." prefix if not already)
  String get displayName {
    final name = userName;
    if (name.isEmpty) return 'Vet';
    return name;
  }

  /// Get initials for avatar
  String get initials {
    final name = userName;
    if (name.isEmpty) return 'V';
    final parts = name.split(RegExp(r'[_\s]+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  factory VetProfileModel.fromJson(Map<String, dynamic> json) {
    final rawSpecializations = json['specializations'];
    List<String> specList = [];
    if (rawSpecializations is List) {
      specList = rawSpecializations.map((e) => e.toString()).toList();
    }

    return VetProfileModel(
      vetId: json['vet_id'] as int? ?? 0,
      user: json['user'] as Map<String, dynamic>? ?? {},
      clinicName: json['clinic_name'] as String?,
      qualifications: json['qualifications'] as String?,
      registrationNo: json['registration_no'] as String?,
      specialization: json['specialization'] as String?,
      specializations: specList,
      yearsOfExperience: json['years_of_experience'] as int?,
      bio: json['bio'] as String?,
      consultationFee: json['consultation_fee']?.toString(),
      videoConsultationFee: json['video_consultation_fee']?.toString(),
      homeVisitFee: json['home_visit_fee']?.toString(),
      emergencyFeeMultiplier: json['emergency_fee_multiplier']?.toString(),
      available: json['available'] as bool? ?? true,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      isDocumentsVerified: json['is_documents_verified'] as bool? ?? false,
    );
  }

  /// Create a copy with updated availability
  VetProfileModel copyWith({bool? available}) {
    return VetProfileModel(
      vetId: vetId,
      user: user,
      clinicName: clinicName,
      qualifications: qualifications,
      registrationNo: registrationNo,
      specialization: specialization,
      specializations: specializations,
      yearsOfExperience: yearsOfExperience,
      bio: bio,
      consultationFee: consultationFee,
      videoConsultationFee: videoConsultationFee,
      homeVisitFee: homeVisitFee,
      emergencyFeeMultiplier: emergencyFeeMultiplier,
      available: available ?? this.available,
      latitude: latitude,
      longitude: longitude,
      isDocumentsVerified: isDocumentsVerified,
    );
  }
}
