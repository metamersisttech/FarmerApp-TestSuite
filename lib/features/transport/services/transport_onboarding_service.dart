/// Transport Onboarding Service
///
/// Handles transport role upgrade and onboarding operations.
library;

import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/transport/models/onboarding_request_model.dart';
import 'package:flutter_app/features/transport/models/transport_result_models.dart';

class TransportOnboardingService {
  final BackendHelper _backendHelper;

  TransportOnboardingService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Apply for transport role
  /// Initiates the role upgrade request for transport provider
  Future<OnboardingResult> applyForRole() async {
    try {
      final response = await _backendHelper.postRoleUpgrade({
        'requested_role': 'transport',
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
    required String drivingLicenseImageKey,
    required String vehicleRcImageKey,
  }) async {
    try {
      final data = {
        'requested_role': 'transport',
        'business_name': businessName,
        'years_of_experience': yearsOfExperience,
        'service_radius_km': serviceRadiusKm,
        'driving_license_number': drivingLicenseNumber,
        'driving_license_expiry': drivingLicenseExpiry.toIso8601String().split('T')[0],
        'driving_license_image': drivingLicenseImageKey,
        'vehicle_rc_image': vehicleRcImageKey,
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
      final response = await _backendHelper.patchRoleUpgrade(requestId, {});
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
    String? drivingLicenseImageKey,
    String? drivingLicenseNumber,
    DateTime? drivingLicenseExpiry,
    String? vehicleRcImageKey,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (drivingLicenseImageKey != null) {
        data['driving_license_image'] = drivingLicenseImageKey;
      }
      if (drivingLicenseNumber != null) {
        data['driving_license_number'] = drivingLicenseNumber;
      }
      if (drivingLicenseExpiry != null) {
        data['driving_license_expiry'] = drivingLicenseExpiry.toIso8601String().split('T')[0];
      }
      if (vehicleRcImageKey != null) {
        data['vehicle_rc_image'] = vehicleRcImageKey;
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
