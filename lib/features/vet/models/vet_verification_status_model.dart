/// Vet verification status model
///
/// Maps the response from GET /api/auth/vet/verification-status/
/// Handles all three states: never applied, pending, approved, rejected.
class VetVerificationStatusModel {
  final bool hasApplied;
  final int? requestId;
  final String? status; // 'PENDING', 'APPROVED', 'REJECTED'
  final DateTime? submittedAt;
  final Map<String, dynamic>? documents;
  final Map<String, dynamic>? rejectedDocuments;
  final String? adminRemarks;
  final String? rejectionReason;
  final DateTime? reviewedAt;

  const VetVerificationStatusModel({
    required this.hasApplied,
    this.requestId,
    this.status,
    this.submittedAt,
    this.documents,
    this.rejectedDocuments,
    this.adminRemarks,
    this.rejectionReason,
    this.reviewedAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';

  /// Get the GCS key/URL for a specific document
  String? getDocumentUrl(String key) {
    return documents?[key] as String?;
  }

  /// Check if a specific document was rejected
  bool isDocumentRejected(String key) {
    final docInfo = rejectedDocuments?[key];
    if (docInfo is Map) {
      return docInfo['rejected'] == true;
    }
    return false;
  }

  /// Get the rejection reason for a specific document
  String? getDocumentRejectionReason(String key) {
    final docInfo = rejectedDocuments?[key];
    if (docInfo is Map) {
      return docInfo['reason'] as String?;
    }
    return null;
  }

  /// Get list of document keys that were rejected
  List<String> get rejectedDocumentKeys {
    if (rejectedDocuments == null) return [];
    final keys = <String>[];
    rejectedDocuments!.forEach((key, value) {
      if (value is Map && value['rejected'] == true) {
        keys.add(key);
      }
    });
    return keys;
  }

  factory VetVerificationStatusModel.fromJson(Map<String, dynamic> json) {
    return VetVerificationStatusModel(
      hasApplied: json['has_applied'] as bool? ?? false,
      requestId: json['request_id'] as int?,
      status: json['status'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'] as String)
          : null,
      documents: json['documents'] as Map<String, dynamic>?,
      rejectedDocuments: json['rejected_documents'] as Map<String, dynamic>?,
      adminRemarks: json['admin_remarks'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_applied': hasApplied,
      'request_id': requestId,
      'status': status,
      'submitted_at': submittedAt?.toIso8601String(),
      'documents': documents,
      'rejected_documents': rejectedDocuments,
      'admin_remarks': adminRemarks,
      'rejection_reason': rejectionReason,
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }
}
