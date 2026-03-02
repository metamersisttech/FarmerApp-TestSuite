/// Vet role upgrade response model
///
/// Maps the response from POST /api/auth/role/upgrade/ (201)
/// and PATCH /api/auth/role/upgrade/{id}/ (200)
class VetRoleUpgradeResponseModel {
  final int requestId;
  final int? requestedRole;
  final String? requestedRoleName;
  final String status;
  final Map<String, dynamic>? additionalInfo;
  final List<String>? documents;
  final String? rejectionReason;
  final Map<String, dynamic>? rejectedDocuments;
  final String? adminRemarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? reviewedAt;
  final String? message;

  const VetRoleUpgradeResponseModel({
    required this.requestId,
    required this.status,
    this.requestedRole,
    this.requestedRoleName,
    this.additionalInfo,
    this.documents,
    this.rejectionReason,
    this.rejectedDocuments,
    this.adminRemarks,
    this.createdAt,
    this.updatedAt,
    this.reviewedAt,
    this.message,
  });

  bool get isPending => status == 'PENDING';

  factory VetRoleUpgradeResponseModel.fromJson(Map<String, dynamic> json) {
    return VetRoleUpgradeResponseModel(
      requestId: json['request_id'] as int,
      status: json['status'] as String,
      requestedRole: json['requested_role'] as int?,
      requestedRoleName: json['requested_role_name'] as String?,
      additionalInfo: json['additional_info'] as Map<String, dynamic>?,
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      rejectionReason: json['rejection_reason'] as String?,
      rejectedDocuments: json['rejected_documents'] as Map<String, dynamic>?,
      adminRemarks: json['admin_remarks'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'] as String)
          : null,
      message: json['message'] as String?,
    );
  }
}
