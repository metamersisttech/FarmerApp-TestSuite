import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/postlistings/health/services/health_service.dart';

/// Controller for health page operations
class HealthController extends BaseController {
  final HealthService _healthService;

  // Callbacks for UI feedback
  Function(String message)? onShowSuccess;
  Function(String message)? onShowError;

  HealthController({HealthService? healthService})
      : _healthService = healthService ?? HealthService();

  // Upload state
  bool _isUploadingCertificate = false;

  bool get isUploadingCertificate => _isUploadingCertificate;

  /// Upload vet certificate
  Future<UploadResult> uploadVetCertificate(String filePath) async {
    _isUploadingCertificate = true;
    notifyListeners();

    final result = await _healthService.uploadVetCertificate(filePath);

    _isUploadingCertificate = false;
    notifyListeners();

    if (!result.success) {
      setError(result.errorMessage ?? 'Failed to upload certificate');
    }

    return result;
  }

  /// Update health information
  Future<HealthResult> updateHealthInfo(
    int listingId,
    Map<String, dynamic> healthData,
  ) async {
    setLoading(true);
    clearError();

    final result = await _healthService.patchHealthData(listingId, healthData);

    if (!result.success) {
      setError(result.errorMessage ?? 'Failed to update health information');
    }

    setLoading(false);
    return result;
  }

  /// Format health status for display
  String formatHealthStatus(String status) {
    return status
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Build health data for API
  Map<String, dynamic> prepareHealthData({
    String? vaccinationStatus,
    String? healthStatus,
    String? vetCertificateKey,
    required String pashuAadhar,
    required String color,
    required String height,
  }) {
    final patchData = <String, dynamic>{};

    if (vaccinationStatus != null) {
      patchData['vaccination_status'] = vaccinationStatus;
    }
    if (healthStatus != null) {
      patchData['health_status'] = healthStatus;
    }
    if (vetCertificateKey != null) {
      patchData['vet_certificate'] = vetCertificateKey;
    }

    final pashu = pashuAadhar.trim();
    if (pashu.isNotEmpty) {
      patchData['pashu_aadhar'] = pashu;
    }

    final col = color.trim();
    if (col.isNotEmpty) {
      patchData['color'] = col;
    }

    final heightValue = double.tryParse(height.trim());
    if (heightValue != null && heightValue > 0) {
      patchData['height_cm'] = heightValue;
    }

    return patchData;
  }
}
