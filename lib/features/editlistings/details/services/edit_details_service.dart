import 'package:flutter_app/core/helpers/backend_helper.dart';

/// Result of edit/update listing operation
class EditDetailsResult {
  final bool success;
  final String? errorMessage;

  const EditDetailsResult({
    required this.success,
    this.errorMessage,
  });

  factory EditDetailsResult.success() {
    return const EditDetailsResult(success: true);
  }

  factory EditDetailsResult.error(String message) {
    return EditDetailsResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Service for edit listing details: load listing by ID and PATCH update.
class EditDetailsService {
  final BackendHelper _backendHelper;

  EditDetailsService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Get a single listing by ID for pre-fill
  Future<Map<String, dynamic>?> getListingById(int listingId) async {
    try {
      return await _backendHelper.getListingById(listingId);
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH update an existing listing
  Future<EditDetailsResult> patchUpdateListing(
    int listingId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _backendHelper.patchUpdateListing(listingId, data);
      return EditDetailsResult.success();
    } catch (e) {
      return EditDetailsResult.error(e.toString());
    }
  }
}
