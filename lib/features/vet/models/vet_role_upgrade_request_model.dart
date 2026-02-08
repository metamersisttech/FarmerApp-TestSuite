/// Vet role upgrade request model
///
/// Request body for POST /api/auth/role/upgrade/
class VetRoleUpgradeRequestModel {
  final String role;
  final String vetCertificate;
  final String degreeCertificate;
  final String registrationNo;
  final String qualifications;
  final String clinicName;
  final String collegeName;
  final String? specialization;

  const VetRoleUpgradeRequestModel({
    this.role = 'vet',
    required this.vetCertificate,
    required this.degreeCertificate,
    required this.registrationNo,
    required this.qualifications,
    required this.clinicName,
    required this.collegeName,
    this.specialization,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'role': role,
      'vet_certificate': vetCertificate,
      'degree_certificate': degreeCertificate,
      'registration_no': registrationNo,
      'qualifications': qualifications,
      'clinic_name': clinicName,
      'college_name': collegeName,
    };
    if (specialization != null && specialization!.isNotEmpty) {
      json['specialization'] = specialization;
    }
    return json;
  }
}
