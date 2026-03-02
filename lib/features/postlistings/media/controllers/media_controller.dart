import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/postlistings/media/services/media_service.dart';

/// Controller for media page operations
class MediaController extends BaseController {
  final MediaService _mediaService;

  MediaController({MediaService? mediaService})
      : _mediaService = mediaService ?? MediaService();

  // Upload state
  bool _isUploading = false;

  bool get isUploading => _isUploading;

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
