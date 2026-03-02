import 'package:flutter_app/core/helpers/backend_helper.dart';

/// Result of preview operations
class PreviewResult {
  final bool success;
  final Map<String, dynamic>? listingData;
  final String? errorMessage;

  const PreviewResult({
    required this.success,
    this.listingData,
    this.errorMessage,
  });

  factory PreviewResult.success({required Map<String, dynamic> listingData}) {
    return PreviewResult(
      success: true,
      listingData: listingData,
    );
  }

  factory PreviewResult.error(String message) {
    return PreviewResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Service for edit listing preview: fetch listing by ID only.
class EditPreviewService {
  final BackendHelper _backendHelper;

  EditPreviewService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Get listing by ID for preview
  Future<PreviewResult> getListingById(int listingId) async {
    try {
      final response = await _backendHelper.getListingById(listingId);
      return PreviewResult.success(listingData: response);
    } catch (e) {
      return PreviewResult.error(e.toString());
    }
  }
}
