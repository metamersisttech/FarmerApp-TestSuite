import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/postlistings/preview/services/preview_service.dart';

/// Controller for preview page operations
class PreviewController extends BaseController {
  final PreviewService _previewService;

  PreviewController({PreviewService? previewService})
      : _previewService = previewService ?? PreviewService();

  Map<String, dynamic>? _listingData;

  Map<String, dynamic>? get listingData => _listingData;

  /// Fetch listing preview
  Future<PreviewResult> fetchListingPreview(int listingId) async {
    setLoading(true);
    clearError();

    final result = await _previewService.getListingById(listingId);

    if (result.success && result.listingData != null) {
      _listingData = result.listingData;
    } else {
      setError(result.errorMessage ?? 'Failed to load preview');
    }

    setLoading(false);
    notifyListeners();

    return result;
  }

  /// Publish listing
  Future<PreviewResult> publishListing(int listingId) async {
    setLoading(true);
    clearError();

    final result = await _previewService.publishListing(listingId);

    if (!result.success) {
      setError(result.errorMessage ?? 'Failed to publish listing');
    }

    setLoading(false);
    return result;
  }
}
