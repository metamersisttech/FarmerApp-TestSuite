import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/editlistings/preview/services/edit_preview_service.dart';

/// Controller for edit listing preview: fetch listing for display.
class EditPreviewController extends BaseController {
  final EditPreviewService _previewService;

  EditPreviewController({EditPreviewService? previewService})
      : _previewService = previewService ?? EditPreviewService();

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
}
