/// Transport Onboarding Controller
///
/// Manages transport role upgrade and onboarding flow state.
library;

import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/onboarding_request_model.dart';
import 'package:flutter_app/features/transport/models/transport_result_models.dart';
import 'package:flutter_app/features/transport/services/transport_onboarding_service.dart';

class TransportOnboardingController extends BaseController {
  final TransportOnboardingService _onboardingService;

  OnboardingRequestModel? _request;
  String? _drivingLicenseImageKey;
  String? _vehicleRcImageKey;
  bool _isUploading = false;

  OnboardingRequestModel? get request => _request;
  OnboardingRequestModel? get onboardingRequest => _request;
  String? get drivingLicenseImageKey => _drivingLicenseImageKey;
  String? get vehicleRcImageKey => _vehicleRcImageKey;
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
    if (_drivingLicenseImageKey == null) {
      setError('Please upload your driving license');
      return false;
    }
    if (_vehicleRcImageKey == null) {
      setError('Please upload your vehicle RC');
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
        drivingLicenseImageKey: _drivingLicenseImageKey!,
        vehicleRcImageKey: _vehicleRcImageKey!,
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
    String? drivingLicenseImageKey,
    String? drivingLicenseNumber,
    DateTime? drivingLicenseExpiry,
    String? vehicleRcImageKey,
  }) async {
    if (isDisposed) return false;

    setLoading(true);
    clearError();

    try {
      final result = await _onboardingService.resubmitDocument(
        requestId: requestId,
        drivingLicenseImageKey: drivingLicenseImageKey,
        drivingLicenseNumber: drivingLicenseNumber,
        drivingLicenseExpiry: drivingLicenseExpiry,
        vehicleRcImageKey: vehicleRcImageKey,
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
        _drivingLicenseImageKey = key;
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

  /// Upload vehicle RC image
  Future<bool> uploadVehicleRc(String filePath) async {
    if (isDisposed) return false;

    _isUploading = true;
    notifyListeners();

    try {
      final key = await _onboardingService.uploadDocument(filePath);
      if (isDisposed) return false;

      if (key != null) {
        _vehicleRcImageKey = key;
        _isUploading = false;
        notifyListeners();
        return true;
      } else {
        setError('Failed to upload vehicle RC');
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to upload vehicle RC: $e');
        _isUploading = false;
        notifyListeners();
      }
      return false;
    }
  }

  /// Clear uploaded images
  void clearUploadedImages() {
    _drivingLicenseImageKey = null;
    _vehicleRcImageKey = null;
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
    _drivingLicenseImageKey = null;
    _vehicleRcImageKey = null;
    _isUploading = false;
    clearError();
    notifyListeners();
  }
}
