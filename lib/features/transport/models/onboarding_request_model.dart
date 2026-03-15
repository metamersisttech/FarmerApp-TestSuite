/// Onboarding Request Model
///
/// Represents a transport role upgrade/onboarding request.
/// Maps to Django RoleUpgradeRequestSerializer for transport providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';

/// Onboarding request status
enum OnboardingStatus {
  pending('PENDING', 'Pending Review'),
  approved('APPROVED', 'Approved'),
  rejected('REJECTED', 'Rejected');

  final String value;
  final String displayName;
  const OnboardingStatus(this.value, this.displayName);

  static OnboardingStatus fromString(String value) {
    return OnboardingStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => OnboardingStatus.pending,
    );
  }

  Color get color {
    switch (this) {
      case OnboardingStatus.pending:
        return Colors.orange;
      case OnboardingStatus.approved:
        return Colors.green;
      case OnboardingStatus.rejected:
        return Colors.red;
    }
  }
}

/// Document status for individual documents
enum DocumentStatus {
  pending('PENDING', 'Pending'),
  approved('APPROVED', 'Approved'),
  rejected('REJECTED', 'Rejected');

  final String value;
  final String displayName;
  const DocumentStatus(this.value, this.displayName);

  static DocumentStatus fromString(String value) {
    return DocumentStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => DocumentStatus.pending,
    );
  }
}

/// Document model for tracking individual document status
class DocumentModel {
  final String documentType;
  final String? documentKey; // GCS key
  final String status;
  final String? rejectionReason;

  const DocumentModel({
    required this.documentType,
    this.documentKey,
    this.status = 'PENDING',
    this.rejectionReason,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      documentType: json['document_type'] as String? ?? '',
      documentKey: json['document_key'] as String? ?? json['key'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_type': documentType,
      if (documentKey != null) 'document_key': documentKey,
      'status': status,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
    };
  }

  DocumentStatus get statusEnum => DocumentStatus.fromString(status);
  String get statusDisplay => statusEnum.displayName;
  bool get isApproved => statusEnum == DocumentStatus.approved;
  bool get isRejected => statusEnum == DocumentStatus.rejected;
  bool get isPending => statusEnum == DocumentStatus.pending;

  String? get documentUrl {
    if (documentKey == null) return null;
    return CommonHelper.getImageUrl(documentKey!);
  }
}

class OnboardingRequestModel {
  final int requestId;
  final int userId;
  final String requestedRole;
  final String status;
  final String? rejectionReason;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  // Transport-specific fields
  final String? businessName;
  final int? yearsOfExperience;
  final int? serviceRadiusKm;
  final String? drivingLicenseNumber;
  final DateTime? drivingLicenseExpiry;
  final String? drivingLicenseImage; // GCS key
  final String? vehicleRcImage; // GCS key

  // Document statuses
  final List<DocumentModel> documents;

  const OnboardingRequestModel({
    required this.requestId,
    required this.userId,
    required this.requestedRole,
    this.status = 'PENDING',
    this.rejectionReason,
    required this.submittedAt,
    this.reviewedAt,
    this.businessName,
    this.yearsOfExperience,
    this.serviceRadiusKm,
    this.drivingLicenseNumber,
    this.drivingLicenseExpiry,
    this.drivingLicenseImage,
    this.vehicleRcImage,
    this.documents = const [],
  });

  factory OnboardingRequestModel.fromJson(Map<String, dynamic> json) {
    // Parse documents
    List<DocumentModel> documents = [];
    final rawDocs = json['documents'];
    if (rawDocs is List) {
      documents = rawDocs
          .whereType<Map<String, dynamic>>()
          .map((d) => DocumentModel.fromJson(d))
          .toList();
    }

    return OnboardingRequestModel(
      requestId: json['request_id'] as int? ?? json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? json['user'] as int? ?? 0,
      requestedRole: json['requested_role'] as String? ?? 'transport',
      status: json['status'] as String? ?? 'PENDING',
      rejectionReason: json['rejection_reason'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now()),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      businessName: json['business_name'] as String?,
      yearsOfExperience: json['years_of_experience'] as int?,
      serviceRadiusKm: json['service_radius_km'] as int?,
      drivingLicenseNumber: json['driving_license_number'] as String?,
      drivingLicenseExpiry: json['driving_license_expiry'] != null
          ? DateTime.tryParse(json['driving_license_expiry'] as String)
          : null,
      drivingLicenseImage: json['driving_license_image'] as String?,
      vehicleRcImage: json['vehicle_rc_image'] as String?,
      documents: documents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'user_id': userId,
      'requested_role': requestedRole,
      'status': status,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      'submitted_at': submittedAt.toIso8601String(),
      if (reviewedAt != null) 'reviewed_at': reviewedAt!.toIso8601String(),
      if (businessName != null) 'business_name': businessName,
      if (yearsOfExperience != null) 'years_of_experience': yearsOfExperience,
      if (serviceRadiusKm != null) 'service_radius_km': serviceRadiusKm,
      if (drivingLicenseNumber != null) 'driving_license_number': drivingLicenseNumber,
      if (drivingLicenseExpiry != null)
        'driving_license_expiry': drivingLicenseExpiry!.toIso8601String().split('T')[0],
      if (drivingLicenseImage != null) 'driving_license_image': drivingLicenseImage,
      if (vehicleRcImage != null) 'vehicle_rc_image': vehicleRcImage,
      'documents': documents.map((d) => d.toJson()).toList(),
    };
  }

  /// Get status enum
  OnboardingStatus get statusEnum => OnboardingStatus.fromString(status);

  /// Get status display name
  String get statusDisplay => statusEnum.displayName;

  /// Get status color
  Color get statusColor => statusEnum.color;

  /// Check if approved
  bool get isApproved => statusEnum == OnboardingStatus.approved;

  /// Check if rejected
  bool get isRejected => statusEnum == OnboardingStatus.rejected;

  /// Check if pending
  bool get isPending => statusEnum == OnboardingStatus.pending;

  /// Get formatted submission date
  String get formattedSubmittedDate =>
      '${submittedAt.day}/${submittedAt.month}/${submittedAt.year}';

  /// Alias for formattedSubmittedDate
  String get formattedCreatedAt => formattedSubmittedDate;

  /// Check if driving license is verified
  bool get drivingLicenseVerified {
    final licenseDoc = documents.where((d) =>
        d.documentType == 'driving_license' ||
        d.documentType == 'DRIVING_LICENSE').firstOrNull;
    return licenseDoc?.isApproved ?? false;
  }

  /// Get driving license image URL
  String? get drivingLicenseImageUrl {
    if (drivingLicenseImage == null) return null;
    return CommonHelper.getImageUrl(drivingLicenseImage!);
  }

  /// Get vehicle RC image URL
  String? get vehicleRcImageUrl {
    if (vehicleRcImage == null) return null;
    return CommonHelper.getImageUrl(vehicleRcImage!);
  }

  /// Get rejected documents
  List<DocumentModel> get rejectedDocuments =>
      documents.where((d) => d.isRejected).toList();

  /// Check if has rejected documents
  bool get hasRejectedDocuments => rejectedDocuments.isNotEmpty;

  /// Check if can resubmit
  bool get canResubmit => isRejected && hasRejectedDocuments;

  OnboardingRequestModel copyWith({
    int? requestId,
    int? userId,
    String? requestedRole,
    String? status,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? businessName,
    int? yearsOfExperience,
    int? serviceRadiusKm,
    String? drivingLicenseNumber,
    DateTime? drivingLicenseExpiry,
    String? drivingLicenseImage,
    String? vehicleRcImage,
    List<DocumentModel>? documents,
  }) {
    return OnboardingRequestModel(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      requestedRole: requestedRole ?? this.requestedRole,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      businessName: businessName ?? this.businessName,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      drivingLicenseNumber: drivingLicenseNumber ?? this.drivingLicenseNumber,
      drivingLicenseExpiry: drivingLicenseExpiry ?? this.drivingLicenseExpiry,
      drivingLicenseImage: drivingLicenseImage ?? this.drivingLicenseImage,
      vehicleRcImage: vehicleRcImage ?? this.vehicleRcImage,
      documents: documents ?? this.documents,
    );
  }

  @override
  String toString() {
    return 'OnboardingRequestModel(requestId: $requestId, status: $status, role: $requestedRole)';
  }
}
