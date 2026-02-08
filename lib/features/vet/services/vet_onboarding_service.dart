import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/vet/models/vet_verification_status_model.dart';
import 'package:flutter_app/features/vet/models/vet_role_upgrade_request_model.dart';
import 'package:flutter_app/features/vet/models/vet_role_upgrade_response_model.dart';

/// Result of vet onboarding operations
class VetOnboardingResult {
  final bool success;
  final String? message;
  final VetVerificationStatusModel? verificationStatus;
  final VetRoleUpgradeResponseModel? upgradeResponse;

  const VetOnboardingResult({
    required this.success,
    this.message,
    this.verificationStatus,
    this.upgradeResponse,
  });

  factory VetOnboardingResult.success({
    VetVerificationStatusModel? verificationStatus,
    VetRoleUpgradeResponseModel? upgradeResponse,
    String? message,
  }) {
    return VetOnboardingResult(
      success: true,
      message: message,
      verificationStatus: verificationStatus,
      upgradeResponse: upgradeResponse,
    );
  }

  factory VetOnboardingResult.error(String message) {
    return VetOnboardingResult(success: false, message: message);
  }
}

/// Service for vet onboarding operations
class VetOnboardingService {
  final BackendHelper _backendHelper;
  final CommonHelper _commonHelper;

  VetOnboardingService({
    BackendHelper? backendHelper,
    CommonHelper? commonHelper,
  })  : _backendHelper = backendHelper ?? BackendHelper(),
        _commonHelper = commonHelper ?? CommonHelper();

  /// Initialize API client with stored token
  Future<void> _initializeAuth() async {
    final accessToken = await _commonHelper.getAccessToken();
    if (accessToken != null) {
      APIClient().setAuthorization(accessToken);
    }
  }

  /// Get vet verification status
  /// GET /api/auth/vet/verification-status/
  Future<VetOnboardingResult> getVerificationStatus() async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.getVetVerificationStatus();
      final status = VetVerificationStatusModel.fromJson(json);
      return VetOnboardingResult.success(verificationStatus: status);
    } on BackendException catch (e) {
      return VetOnboardingResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting verification status: $e');
      return VetOnboardingResult.error('Failed to check verification status.');
    }
  }

  /// Submit role upgrade application
  /// POST /api/auth/role/upgrade/
  Future<VetOnboardingResult> submitRoleUpgrade(
    VetRoleUpgradeRequestModel request,
  ) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.postRoleUpgrade(request.toJson());
      final response = VetRoleUpgradeResponseModel.fromJson(json);
      return VetOnboardingResult.success(upgradeResponse: response);
    } on BackendException catch (e) {
      return VetOnboardingResult.error(e.message);
    } catch (e) {
      debugPrint('Error submitting role upgrade: $e');
      return VetOnboardingResult.error('Failed to submit application.');
    }
  }

  /// Resubmit documents for a rejected application
  /// PATCH /api/auth/role/upgrade/{requestId}/
  Future<VetOnboardingResult> resubmitDocuments(
    int requestId,
    Map<String, dynamic> updatedFields,
  ) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.patchRoleUpgrade(
        requestId,
        updatedFields,
      );
      final response = VetRoleUpgradeResponseModel.fromJson(json);
      return VetOnboardingResult.success(upgradeResponse: response);
    } on BackendException catch (e) {
      return VetOnboardingResult.error(e.message);
    } catch (e) {
      debugPrint('Error resubmitting documents: $e');
      return VetOnboardingResult.error('Failed to resubmit documents.');
    }
  }

  /// Upload a single document file
  /// Returns the GCS key on success, null on failure
  Future<String?> uploadDocument(String filePath) async {
    try {
      await _initializeAuth();
      final result = await _backendHelper.postUploadFile(
        filePath,
        'vet_certificates',
      );
      return result['key'] as String?;
    } on BackendException catch (e) {
      debugPrint('Error uploading document: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error uploading document: $e');
      return null;
    }
  }
}
