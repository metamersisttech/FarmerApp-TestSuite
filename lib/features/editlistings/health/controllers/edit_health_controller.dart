import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/editlistings/health/services/edit_health_service.dart';

/// Controller for edit listing health: load listing for pre-fill, upload cert, PATCH.
class EditHealthController extends BaseController {
  final EditHealthService _healthService;

  EditHealthController({EditHealthService? healthService})
      : _healthService = healthService ?? EditHealthService();

  bool _isUploadingCertificate = false;

  bool get isUploadingCertificate => _isUploadingCertificate;

  /// Load listing by ID for pre-fill
  Future<Map<String, dynamic>?> loadListing(int listingId) async {
    return _healthService.getListingById(listingId);
  }

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
