import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/vet/models/vet_verification_status_model.dart';
import 'package:flutter_app/features/vet/models/vet_role_upgrade_request_model.dart';
import 'package:flutter_app/features/vet/models/vet_role_upgrade_response_model.dart';
import 'package:flutter_app/features/vet/services/vet_onboarding_service.dart';

/// Controller for vet onboarding operations
class VetOnboardingController extends BaseController {
  final VetOnboardingService _service;

  VetVerificationStatusModel? _verificationStatus;
  VetRoleUpgradeResponseModel? _upgradeResponse;

  VetOnboardingController({VetOnboardingService? service})
      : _service = service ?? VetOnboardingService();

  VetVerificationStatusModel? get verificationStatus => _verificationStatus;
  VetRoleUpgradeResponseModel? get upgradeResponse => _upgradeResponse;

  /// Check verification status
  Future<VetOnboardingResult> checkVerificationStatus() async {
    setLoading(true);
    clearError();

    try {
      final result = await _service.getVerificationStatus();

      if (result.success && result.verificationStatus != null) {
        _verificationStatus = result.verificationStatus;
        notifyListeners();
      } else if (result.message != null) {
        setError(result.message);
      }

      setLoading(false);
      return result;
    } catch (e) {
      setError('Failed to check verification status.');
      setLoading(false);
      return VetOnboardingResult.error('Failed to check verification status.');
    }
  }

  /// Submit initial role upgrade application
  Future<VetOnboardingResult> submitApplication(
    VetRoleUpgradeRequestModel request,
  ) async {
    setLoading(true);
    clearError();

    try {
      final result = await _service.submitRoleUpgrade(request);

      if (result.success && result.upgradeResponse != null) {
        _upgradeResponse = result.upgradeResponse;
        notifyListeners();
      } else if (result.message != null) {
        setError(result.message);
      }

      setLoading(false);
      return result;
    } catch (e) {
      setError('Failed to submit application.');
      setLoading(false);
      return VetOnboardingResult.error('Failed to submit application.');
    }
  }

  /// Resubmit rejected documents
  Future<VetOnboardingResult> resubmitDocuments(
    int requestId,
    Map<String, dynamic> updatedFields,
  ) async {
    setLoading(true);
    clearError();

    try {
      final result = await _service.resubmitDocuments(
        requestId,
        updatedFields,
      );

      if (result.success && result.upgradeResponse != null) {
        _upgradeResponse = result.upgradeResponse;
        notifyListeners();
      } else if (result.message != null) {
        setError(result.message);
      }

      setLoading(false);
      return result;
    } catch (e) {
      setError('Failed to resubmit documents.');
      setLoading(false);
      return VetOnboardingResult.error('Failed to resubmit documents.');
    }
  }

  /// Upload a document file, returns GCS key
  Future<String?> uploadDocument(String filePath) async {
    try {
      return await _service.uploadDocument(filePath);
    } catch (e) {
      return null;
    }
  }
}
