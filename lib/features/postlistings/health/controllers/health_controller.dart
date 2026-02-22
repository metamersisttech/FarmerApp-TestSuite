import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/postlistings/health/services/health_service.dart';

/// Controller for health page operations
class HealthController extends BaseController {
  final HealthService _healthService;

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
}
