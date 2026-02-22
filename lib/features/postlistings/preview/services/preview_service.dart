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

/// Service for preview page operations
class PreviewService {
  final BackendHelper _backendHelper;

  PreviewService({BackendHelper? backendHelper})
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

  /// Publish listing (if needed - currently listing is auto-saved)
  Future<PreviewResult> publishListing(int listingId) async {
    try {
      // Currently the listing is already created and updated via POST/PATCH
      // This method is here for future use if a separate publish action is needed
      await Future.delayed(const Duration(milliseconds: 500));
      return PreviewResult.success(listingData: {'listing_id': listingId});
    } catch (e) {
      return PreviewResult.error(e.toString());
    }
  }
}
