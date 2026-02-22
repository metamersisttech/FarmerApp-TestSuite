import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/editlistings/media/services/edit_media_service.dart';

/// Controller for edit listing media: load listing, upload images, PATCH.
class EditMediaController extends BaseController {
  final EditMediaService _mediaService;

  EditMediaController({EditMediaService? mediaService})
      : _mediaService = mediaService ?? EditMediaService();

  bool _isUploading = false;

  bool get isUploading => _isUploading;

  /// Load listing by ID for pre-fill (existing images)
  Future<Map<String, dynamic>?> loadListing(int listingId) async {
    return _mediaService.getListingById(listingId);
  }

  /// Upload multiple images
  Future<MultipleUploadResult> uploadImages(List<String> filePaths) async {
    _isUploading = true;
    notifyListeners();

    final result = await _mediaService.uploadMultipleFiles(filePaths);

    _isUploading = false;
    notifyListeners();

    if (!result.success) {
      setError(result.errorMessage ?? 'Failed to upload images');
    }

    return result;
  }

  /// Update listing with media data
  Future<MediaResult> updateListingMedia(
    int listingId,
    List<String> imageKeys,
  ) async {
    setLoading(true);
    clearError();

    final result = await _mediaService.patchMediaData(listingId, imageKeys);

    if (!result.success) {
      setError(result.errorMessage ?? 'Failed to update media');
    }

    setLoading(false);
    return result;
  }
}
