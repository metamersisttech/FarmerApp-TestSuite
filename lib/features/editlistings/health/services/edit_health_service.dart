import 'package:flutter_app/core/helpers/backend_helper.dart';

/// Result of health operations
class HealthResult {
  final bool success;
  final String? errorMessage;

  const HealthResult({
    required this.success,
    this.errorMessage,
  });

  factory HealthResult.success() {
    return const HealthResult(success: true);
  }

  factory HealthResult.error(String message) {
    return HealthResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Result of file upload operation
class UploadResult {
  final bool success;
  final String? fileKey;
  final String? errorMessage;

  const UploadResult({
    required this.success,
    this.fileKey,
    this.errorMessage,
  });

  factory UploadResult.success({required String fileKey}) {
    return UploadResult(
      success: true,
      fileKey: fileKey,
    );
  }

  factory UploadResult.error(String message) {
    return UploadResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Service for edit listing health: load listing for pre-fill, upload cert, PATCH.
class EditHealthService {
  final BackendHelper _backendHelper;

  EditHealthService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Get listing by ID for pre-fill
  Future<Map<String, dynamic>?> getListingById(int listingId) async {
    try {
      return await _backendHelper.getListingById(listingId);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload vet certificate file
  Future<UploadResult> uploadVetCertificate(String filePath) async {
    try {
      final uploadResult = await _backendHelper.postUploadFile(
        filePath,
        'vet_certificates',
      );

      final fileKey = uploadResult['key'] as String?;
      if (fileKey == null) {
        return UploadResult.error('Failed to get file key from upload response');
      }

      return UploadResult.success(fileKey: fileKey);
    } catch (e) {
      return UploadResult.error(e.toString());
    }
  }

  /// Update listing with health data
  Future<HealthResult> patchHealthData(
    int listingId,
    Map<String, dynamic> healthData,
  ) async {
    try {
      await _backendHelper.patchUpdateListing(listingId, healthData);
      return HealthResult.success();
    } catch (e) {
      return HealthResult.error(e.toString());
    }
  }
}
