import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/postlistings/media/controllers/media_controller.dart';
import 'package:flutter_app/features/postlistings/media/mixins/media_state_mixin.dart';
import 'package:flutter_app/features/postlistings/media/widgets/photo_tips_card.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/media/image_upload_picker.dart';

/// Media Page - Upload photos/videos
class MediaPage extends StatefulWidget {
  final int listingId;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;

  const MediaPage({
    super.key,
    required this.listingId,
    required this.onNext,
    this.onPrevious,
  });

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage>
    with MediaStateMixin, ToastMixin {
  late final MediaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MediaController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handle Next button press
  Future<void> _handleNext() async {
    // Validate at least one image
    if (!validateImages()) {
      showErrorToast('Please add at least one image');
      return;
    }

    setSubmitting(true);

    try {
      // Upload any new images
      if (selectedImages.isNotEmpty) {
        final filePaths = selectedImages.map((f) => f.path).toList();
        final uploadResult = await _controller.uploadImages(filePaths);

        if (!mounted) return;

        if (uploadResult.success &&
            uploadResult.fileKeys != null &&
            uploadResult.fileUrls != null) {
          addUploadedData(uploadResult.fileKeys!, uploadResult.fileUrls!);
          clearImages(); // Clear local files after upload
        } else {
          setSubmitting(false);
          showErrorToast(uploadResult.errorMessage ?? 'Failed to upload images');
          return;
        }
      }

      // PATCH listing with image keys
      if (uploadedImageKeys.isNotEmpty) {
        final result =
            await _controller.updateListingMedia(widget.listingId, uploadedImageKeys);

        if (!mounted) return;

        if (result.success) {
          setSubmitting(false);
          showSuccessToast('Images saved successfully!');
          widget.onNext();
        } else {
          setSubmitting(false);
          showErrorToast(result.errorMessage ?? 'Failed to save images');
        }
      } else {
        if (!mounted) return;
        setSubmitting(false);
        widget.onNext();
      }
    } catch (e) {
      if (!mounted) return;
      setSubmitting(false);
      showErrorToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload Media',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add photos of your animal to attract buyers',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Image Upload Picker
                ImageUploadPicker(
                  selectedImages: selectedImages,
                  uploadedUrls: uploadedImageUrls,
                  onImagesChanged: addImages,
                  onUploadedUrlRemoved: removeUploadedUrl,
                  maxImages: MediaStateMixin.maxImages,
                  isLoading: _controller.isUploading,
                  placeholderText: 'Tap to upload photos',
                  placeholderHint: 'Add up to ${MediaStateMixin.maxImages} photos',
                  bottomSheetTitle: 'Add Photo',
                ),

                const SizedBox(height: 24),

                // Tips section
                const PhotoTipsCard(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Fixed navigation buttons at bottom
        Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).padding.bottom + 20, // Add system nav bar padding
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.onPrevious != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : widget.onPrevious,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authPrimaryColor,
                    disabledBackgroundColor: AppTheme.authPrimaryColor.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Next',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
