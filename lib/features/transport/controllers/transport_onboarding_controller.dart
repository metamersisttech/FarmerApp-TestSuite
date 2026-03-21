/// Transport Onboarding Controller
///
/// Manages transport role upgrade and onboarding flow state.
library;

import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/onboarding_request_model.dart';
import 'package:flutter_app/features/transport/models/transport_result_models.dart';
import 'package:flutter_app/features/transport/models/transport_verification_status_model.dart';
import 'package:flutter_app/features/transport/services/transport_onboarding_service.dart';

class TransportOnboardingController extends BaseController {
  final TransportOnboardingService _onboardingService;

  OnboardingRequestModel? _request;
  TransportVerificationStatusModel? _verificationStatus;
  String? _drivingLicenseKey;
  String? _kycDocumentKey;
  bool _isUploading = false;

  OnboardingRequestModel? get request => _request;
  OnboardingRequestModel? get onboardingRequest => _request;
  TransportVerificationStatusModel? get verificationStatus => _verificationStatus;
  String? get drivingLicenseKey => _drivingLicenseKey;
  String? get kycDocumentKey => _kycDocumentKey;
  bool get isUploading => _isUploading;

  /// Check if request exists
  bool get hasRequest => _request != null;

  /// Check if approved
  bool get isApproved => _request?.isApproved ?? false;

  /// Check if rejected
  bool get isRejected => _request?.isRejected ?? false;

  /// Check if pending
  bool get isPending => _request?.isPending ?? false;

  /// Check if can resubmit
  bool get canResubmit => _request?.canResubmit ?? false;

  TransportOnboardingController({
    TransportOnboardingService? onboardingService,
  }) : _onboardingService = onboardingService ?? TransportOnboardingService();

  /// Check verification status
  Future<VerificationStatusResult> checkVerificationStatus() async {
    if (isDisposed) {
      return VerificationStatusResult.failed('Controller disposed');
    }

    setLoading(true);
    clearError();

    try {
      final result = await _onboardingService.getVerificationStatus();

      if (isDisposed) {
        return VerificationStatusResult.failed('Controller disposed');
      }

      if (result.success && result.verificationStatus != null) {
        _verificationStatus = result.verificationStatus;
        notifyListeners();
      } else if (result.errorMessage != null) {
        setError(result.errorMessage);
      }

      setLoading(false);
      return result;
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to check verification status.');
        setLoading(false);
      }
      return VerificationStatusResult.failed('Failed to check verification status.');
    }
  }

  /// Apply for transport role (initial request)
  Future<bool> applyForRole() async {
    if (isDisposed) return false;

    setLoading(true);
    clearError();

    try {
      final result = await _onboardingService.applyForRole();

      if (isDisposed) return false;

      if (result.success) {
        _request = result.request;
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to apply for transport role');
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to apply for transport role: $e');
      }
      return false;
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Submit full onboarding form
  Future<bool> submitOnboarding({
    required String businessName,
    required int yearsOfExperience,
    required int serviceRadiusKm,
    required String drivingLicenseNumber,
    required DateTime drivingLicenseExpiry,
  }) async {
    if (isDisposed) return false;

    // Validate images are uploaded
    if (_drivingLicenseKey == null) {
      setError('Please upload your driving license');
      return false;
    }
    if (_kycDocumentKey == null) {
      setError('Please upload your KYC document');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      final result = await _onboardingService.submitOnboarding(
        businessName: businessName,
        yearsOfExperience: yearsOfExperience,
        serviceRadiusKm: serviceRadiusKm,
        drivingLicenseNumber: drivingLicenseNumber,
        drivingLicenseExpiry: drivingLicenseExpiry,
        drivingLicenseKey: _drivingLicenseKey!,
        kycDocumentKey: _kycDocumentKey!,
      );

      if (isDisposed) return false;

      if (result.success) {
        _request = result.request;
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to submit onboarding');
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to submit onboarding: $e');
      }
      return false;
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Check status of existing request
  Future<void> checkStatus(int requestId) async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      final result = await _onboardingService.checkUpgradeStatus(requestId);

      if (isDisposed) return;

      if (result.success) {
        _request = result.request;
        notifyListeners();
      } else {
        setError(result.errorMessage ?? 'Failed to check status');
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to check status: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Resubmit rejected document
  Future<bool> resubmitDocument({
    required int requestId,
    String? drivingLicenseKey,
    String? drivingLicenseNumber,
    DateTime? drivingLicenseExpiry,
    String? kycDocumentKey,
  }) async {
    if (isDisposed) return false;

    setLoading(true);
    clearError();

    try {
      final result = await _onboardingService.resubmitDocument(
        requestId: requestId,
        drivingLicenseKey: drivingLicenseKey,
        drivingLicenseNumber: drivingLicenseNumber,
        drivingLicenseExpiry: drivingLicenseExpiry,
        kycDocumentKey: kycDocumentKey,
      );

      if (isDisposed) return false;

      if (result.success) {
        _request = result.request;
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to resubmit document');
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to resubmit document: $e');
      }
      return false;
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Upload driving license image
  Future<bool> uploadDrivingLicense(String filePath) async {
    if (isDisposed) return false;

    _isUploading = true;
    notifyListeners();

    try {
      final key = await _onboardingService.uploadDocument(filePath);
      if (isDisposed) return false;

      if (key != null) {
        _drivingLicenseKey = key;
        _isUploading = false;
        notifyListeners();
        return true;
      } else {
        setError('Failed to upload driving license');
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to upload driving license: $e');
        _isUploading = false;
        notifyListeners();
      }
      return false;
    }
  }

  /// Upload KYC document
  Future<bool> uploadKycDocument(String filePath) async {
    if (isDisposed) return false;

    _isUploading = true;
    notifyListeners();

    try {
      final key = await _onboardingService.uploadDocument(filePath);
      if (isDisposed) return false;

      if (key != null) {
        _kycDocumentKey = key;
        _isUploading = false;
        notifyListeners();
        return true;
      } else {
        setError('Failed to upload KYC document');
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to upload KYC document: $e');
        _isUploading = false;
        notifyListeners();
      }
      return false;
    }
  }

  /// Clear uploaded images
  void clearUploadedImages() {
    _drivingLicenseKey = null;
    _kycDocumentKey = null;
    notifyListeners();
  }

  /// Clear uploaded license
  void clearUploadedLicense() {
    _drivingLicenseKey = null;
    notifyListeners();
  }

  /// Clear uploaded KYC document
  void clearUploadedKyc() {
    _kycDocumentKey = null;
    notifyListeners();
  }

  /// Cancel application
  Future<OnboardingResult> cancelApplication(int requestId) async {
    if (isDisposed) return OnboardingResult(success: false, errorMessage: 'Controller disposed');

    setLoading(true);
    clearError();

    try {
      final result = await _onboardingService.cancelApplication(requestId);

      if (isDisposed) return OnboardingResult(success: false, errorMessage: 'Controller disposed');

      if (result.success) {
        _request = null;
        notifyListeners();
      } else {
        setError(result.errorMessage ?? 'Failed to cancel application');
      }
      return result;
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to cancel application: $e');
      }
      return OnboardingResult(success: false, errorMessage: e.toString());
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Reset state
  void reset() {
    _request = null;
    _drivingLicenseKey = null;
    _kycDocumentKey = null;
    _isUploading = false;
    clearError();
    notifyListeners();
  }
}
