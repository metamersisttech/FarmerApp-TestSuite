import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/media/image_upload_picker.dart';

/// Media Tab - Upload photos/videos with PATCH integration
class MediaTab extends StatefulWidget {
  final int listingId;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;

  const MediaTab({
    super.key,
    required this.listingId,
    required this.onNext,
    this.onPrevious,
  });

  @override
  State<MediaTab> createState() => _MediaTabState();
}

class _MediaTabState extends State<MediaTab> with ToastMixin {
  final BackendHelper _backendHelper = BackendHelper();

  // Selected images (local files)
  List<File> _selectedImages = [];

  // Uploaded image keys (GCS keys)
  List<String> _uploadedImageKeys = [];

  // Uploaded image URLs (for display)
  List<String> _uploadedImageUrls = [];

  bool _isUploading = false;
  bool _isSubmitting = false;

  static const int maxImages = 10;

  /// Handle images changed from picker
  void _onImagesChanged(List<File> images) {
    setState(() {
      _selectedImages = images;
    });
  }

  /// Handle uploaded URL removed
  void _onUploadedUrlRemoved(String url) {
    final index = _uploadedImageUrls.indexOf(url);
    if (index != -1) {
      setState(() {
        _uploadedImageUrls.removeAt(index);
        if (index < _uploadedImageKeys.length) {
          _uploadedImageKeys.removeAt(index);
        }
      });
    }
  }

  /// Handle Next button press
  Future<void> _handleNext() async {
    // Validate at least one image
    if (_selectedImages.isEmpty && _uploadedImageKeys.isEmpty) {
      showErrorToast('Please add at least one image');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Upload any new images
      if (_selectedImages.isNotEmpty) {
        setState(() => _isUploading = true);

        final filePaths = _selectedImages.map((f) => f.path).toList();
        final uploadResults = await _backendHelper.postUploadMultipleFiles(
          filePaths,
          'listings',
        );

        // Extract keys and URLs from results
        for (final result in uploadResults) {
          final key = result['key'] as String?;
          final url = result['url'] as String?;
          if (key != null) {
            _uploadedImageKeys.add(key);
          }
          if (url != null) {
            _uploadedImageUrls.add(url);
          }
        }

        // Clear local files after upload
        _selectedImages = [];
        setState(() => _isUploading = false);
      }

      // PATCH listing with image keys
      if (_uploadedImageKeys.isNotEmpty) {
        await _backendHelper.patchUpdateListing(widget.listingId, {
          'animal_images': _uploadedImageKeys,
        });

        if (!mounted) return;
        showSuccessToast('Images saved successfully!');
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      widget.onNext();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isUploading = false;
      });
      showErrorToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable content
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
                  selectedImages: _selectedImages,
                  uploadedUrls: _uploadedImageUrls,
                  onImagesChanged: _onImagesChanged,
                  onUploadedUrlRemoved: _onUploadedUrlRemoved,
                  maxImages: maxImages,
                  isLoading: _isUploading,
                  placeholderText: 'Tap to upload photos',
                  placeholderHint: 'Add up to $maxImages photos',
                  bottomSheetTitle: 'Add Photo',
                ),

                const SizedBox(height: 24),

                // Tips section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Tips for better photos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip('Take photos in good lighting'),
                      _buildTip('Show the animal from multiple angles'),
                      _buildTip('Include close-ups of distinctive features'),
                      _buildTip('Avoid blurry or dark images'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Fixed navigation buttons at bottom
        Container(
          padding: const EdgeInsets.all(20),
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
              // Previous button (if available)
              if (widget.onPrevious != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : widget.onPrevious,
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

              // Next button
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authPrimaryColor,
                    disabledBackgroundColor: AppTheme.authPrimaryColor.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSubmitting
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

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.blue.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
