/// Transport Onboarding Service
///
/// Handles transport role upgrade and onboarding operations.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/transport/models/onboarding_request_model.dart';
import 'package:flutter_app/features/transport/models/transport_result_models.dart';
import 'package:flutter_app/features/transport/models/transport_verification_status_model.dart';

class TransportOnboardingService {
  final BackendHelper _backendHelper;
  final CommonHelper _commonHelper;

  TransportOnboardingService({
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

  /// Get transport verification status
  /// GET /api/auth/transport/verification-status/
  Future<VerificationStatusResult> getVerificationStatus() async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.getTransportVerificationStatus();
      final status = TransportVerificationStatusModel.fromJson(json);
      return VerificationStatusResult.successful(status);
    } on BackendException catch (e) {
      return VerificationStatusResult.failed(e.message);
    } catch (e) {
      return VerificationStatusResult.failed('Failed to check verification status.');
    }
  }

  /// Apply for transport role
  /// Initiates the role upgrade request for transport provider
  Future<OnboardingResult> applyForRole() async {
    try {
      final response = await _backendHelper.postRoleUpgrade({
        'role': 'transport',
      });

      final request = OnboardingRequestModel.fromJson(response);
      return OnboardingResult.successful(request: request);
    } on BackendException catch (e) {
      return OnboardingResult.failed(e.message);
    } catch (e) {
      return OnboardingResult.failed('Failed to apply for transport role: $e');
    }
  }

  /// Submit full onboarding form with documents
  Future<OnboardingResult> submitOnboarding({
    required String businessName,
    required int yearsOfExperience,
    required int serviceRadiusKm,
    required String drivingLicenseNumber,
    required DateTime drivingLicenseExpiry,
    required String drivingLicenseKey,
    required String kycDocumentKey,
  }) async {
    try {
      final data = {
        'role': 'transport',
        'documents': [kycDocumentKey],
        'business_name': businessName,
        'years_of_experience': yearsOfExperience,
        'service_radius_km': serviceRadiusKm,
        'driving_license_number': drivingLicenseNumber,
        'driving_license_expiry': drivingLicenseExpiry.toIso8601String().split('T')[0],
        'driving_license': drivingLicenseKey,
      };

      final response = await _backendHelper.postRoleUpgrade(data);
      final request = OnboardingRequestModel.fromJson(response);
      return OnboardingResult.successful(request: request);
    } on BackendException catch (e) {
      return OnboardingResult.failed(e.message);
    } catch (e) {
      return OnboardingResult.failed('Failed to submit onboarding: $e');
    }
  }

  /// Check role upgrade request status
  Future<StatusCheckResult> checkUpgradeStatus(int requestId) async {
    try {
      final response = await _backendHelper.getRoleUpgradeById(requestId);

      // Debug: Log the raw API response to check if business_name is present
      debugPrint('=== GET /api/auth/role/upgrade/$requestId/ ===');
      debugPrint('Full response: $response');
      debugPrint('business_name value: ${response['business_name']}');
      debugPrint('All keys: ${response.keys.toList()}');
      debugPrint('=============================================');

      final request = OnboardingRequestModel.fromJson(response);
      return StatusCheckResult.successful(request);
    } on BackendException catch (e) {
      return StatusCheckResult.failed(e.message);
    } catch (e) {
      return StatusCheckResult.failed('Failed to check status: $e');
    }
  }

  /// Resubmit rejected document
  Future<ResubmitResult> resubmitDocument({
    required int requestId,
    String? drivingLicenseKey,
    String? drivingLicenseNumber,
    DateTime? drivingLicenseExpiry,
    String? kycDocumentKey,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (drivingLicenseKey != null) {
        data['driving_license'] = drivingLicenseKey;
      }
      if (drivingLicenseNumber != null) {
        data['driving_license_number'] = drivingLicenseNumber;
      }
      if (drivingLicenseExpiry != null) {
        data['driving_license_expiry'] = drivingLicenseExpiry.toIso8601String().split('T')[0];
      }
      if (kycDocumentKey != null) {
        data['documents'] = [kycDocumentKey];
      }

      final response = await _backendHelper.patchRoleUpgrade(requestId, data);
      final request = OnboardingRequestModel.fromJson(response);
      return ResubmitResult.successful(request);
    } on BackendException catch (e) {
      return ResubmitResult.failed(e.message);
    } catch (e) {
      return ResubmitResult.failed('Failed to resubmit document: $e');
    }
  }

  /// Upload document and get GCS key
  Future<String?> uploadDocument(String filePath) async {
    try {
      final response = await _backendHelper.postUploadFile(filePath, 'documents');
      return response['key'] as String?;
    } on BackendException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Cancel role upgrade application
  Future<OnboardingResult> cancelApplication(int requestId) async {
    try {
      await _backendHelper.deleteRoleUpgrade(requestId);
      return OnboardingResult.successful();
    } on BackendException catch (e) {
      return OnboardingResult.failed(e.message);
    } catch (e) {
      return OnboardingResult.failed('Failed to cancel application: $e');
    }
  }
}
