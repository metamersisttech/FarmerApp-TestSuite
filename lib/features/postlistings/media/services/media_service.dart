import 'package:flutter_app/core/helpers/backend_helper.dart';

/// Result of media operations
class MediaResult {
  final bool success;
  final String? errorMessage;

  const MediaResult({
    required this.success,
    this.errorMessage,
  });

  factory MediaResult.success() {
    return const MediaResult(success: true);
  }

  factory MediaResult.error(String message) {
    return MediaResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Result of multiple files upload operation
class MultipleUploadResult {
  final bool success;
  final List<String>? fileKeys;
  final List<String>? fileUrls;
  final String? errorMessage;

  const MultipleUploadResult({
    required this.success,
    this.fileKeys,
    this.fileUrls,
    this.errorMessage,
  });

  factory MultipleUploadResult.success({
    required List<String> fileKeys,
    required List<String> fileUrls,
  }) {
    return MultipleUploadResult(
      success: true,
      fileKeys: fileKeys,
      fileUrls: fileUrls,
    );
  }

  factory MultipleUploadResult.error(String message) {
    return MultipleUploadResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Service for media page operations
class MediaService {
  final BackendHelper _backendHelper;

  MediaService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Upload multiple image files
  Future<MultipleUploadResult> uploadMultipleFiles(
      List<String> filePaths) async {
    try {
      final uploadResults = await _backendHelper.postUploadMultipleFiles(
        filePaths,
        'listings',
      );

      final fileKeys = <String>[];
      final fileUrls = <String>[];

      for (final result in uploadResults) {
        final key = result['key'] as String?;
        final url = result['url'] as String?;
        if (key != null) {
          fileKeys.add(key);
        }
        if (url != null) {
          fileUrls.add(url);
        }
      }

      if (fileKeys.isEmpty) {
        return MultipleUploadResult.error('No files were uploaded successfully');
      }

      return MultipleUploadResult.success(
        fileKeys: fileKeys,
        fileUrls: fileUrls,
      );
    } catch (e) {
      return MultipleUploadResult.error(e.toString());
    }
  }

  /// Update listing with media data
  Future<MediaResult> patchMediaData(
    int listingId,
    List<String> imageKeys,
  ) async {
    try {
      await _backendHelper.patchUpdateListing(listingId, {
        'animal_images': imageKeys,
      });
      return MediaResult.success();
    } catch (e) {
      return MediaResult.error(e.toString());
    }
  }
}
