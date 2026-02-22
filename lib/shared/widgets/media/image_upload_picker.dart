import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// A reusable image upload picker widget that supports both single and multiple images.
///
/// Features:
/// - Grid layout showing selected images with thumbnails
/// - Add button to pick more images (camera or gallery)
/// - Remove button on each image
/// - Supports both local files and network URLs (for edit mode)
/// - Loading overlay during upload
/// - Configurable max image limit
class ImageUploadPicker extends StatefulWidget {
  /// List of locally selected image files
  final List<File> selectedImages;

  /// List of already uploaded image URLs (for edit mode / displaying existing images)
  final List<String> uploadedUrls;

  /// Callback when images are changed (added or removed)
  final Function(List<File>) onImagesChanged;

  /// Callback when an uploaded URL is removed
  final Function(String)? onUploadedUrlRemoved;

  /// Maximum number of images allowed
  final int maxImages;

  /// Whether to allow camera as a source
  final bool allowCamera;

  /// Whether to allow gallery as a source
  final bool allowGallery;

  /// Whether the picker is enabled
  final bool enabled;

  /// Whether to show loading overlay
  final bool isLoading;

  /// Title for the bottom sheet
  final String? bottomSheetTitle;

  /// Placeholder text when no images selected
  final String? placeholderText;

  /// Hint text below placeholder
  final String? placeholderHint;

  const ImageUploadPicker({
    super.key,
    this.selectedImages = const [],
    this.uploadedUrls = const [],
    required this.onImagesChanged,
    this.onUploadedUrlRemoved,
    this.maxImages = 10,
    this.allowCamera = true,
    this.allowGallery = true,
    this.enabled = true,
    this.isLoading = false,
    this.bottomSheetTitle,
    this.placeholderText,
    this.placeholderHint,
  });

  @override
  State<ImageUploadPicker> createState() => _ImageUploadPickerState();
}

class _ImageUploadPickerState extends State<ImageUploadPicker> {
  final ImagePicker _picker = ImagePicker();

  /// Total count of images (local + uploaded)
  int get _totalImageCount => widget.selectedImages.length + widget.uploadedUrls.length;

  /// Whether we can add more images
  bool get _canAddMore => _totalImageCount < widget.maxImages && widget.enabled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        _totalImageCount == 0 ? _buildEmptyState() : _buildImageGrid(),

        // Loading overlay
        if (widget.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Uploading...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build empty state with placeholder
  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: widget.enabled ? _showImageSourceBottomSheet : null,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.enabled ? AppTheme.authPrimaryColor.withOpacity(0.5) : Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 64,
                color: widget.enabled ? AppTheme.authPrimaryColor.withOpacity(0.6) : Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                widget.placeholderText ?? 'Tap to upload photos',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.enabled ? Colors.grey[700] : Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.placeholderHint ?? 'Maximum ${widget.maxImages} files',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build image grid with thumbnails and add button
  Widget _buildImageGrid() {
    final itemCount = _totalImageCount + (_canAddMore ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image count indicator
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '$_totalImageCount / ${widget.maxImages} images',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // Add button at the end
            if (_canAddMore && index == _totalImageCount) {
              return _buildAddButton();
            }

            // Show uploaded URLs first, then local files
            if (index < widget.uploadedUrls.length) {
              return _buildNetworkImageTile(widget.uploadedUrls[index], index);
            } else {
              final localIndex = index - widget.uploadedUrls.length;
              return _buildLocalImageTile(widget.selectedImages[localIndex], localIndex);
            }
          },
        ),
      ],
    );
  }

  /// Build add image button
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showImageSourceBottomSheet,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.authPrimaryColor.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppTheme.authPrimaryColor.withOpacity(0.8),
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.authPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build tile for local image file
  Widget _buildLocalImageTile(File file, int index) {
    return Stack(
      children: [
        // Image
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.file(
              file,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),

        // Remove button
        if (widget.enabled)
          Positioned(
            top: 4,
            right: 4,
            child: _buildRemoveButton(() => _removeLocalImage(index)),
          ),
      ],
    );
  }

  /// Build tile for network image URL
  Widget _buildNetworkImageTile(String url, int index) {
    return Stack(
      children: [
        // Image
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey[400],
                  size: 32,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Uploaded badge
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_done, color: Colors.white, size: 12),
                SizedBox(width: 2),
                Text(
                  'Uploaded',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),

        // Remove button
        if (widget.enabled)
          Positioned(
            top: 4,
            right: 4,
            child: _buildRemoveButton(() => _removeUploadedUrl(url)),
          ),
      ],
    );
  }

  /// Build remove button widget
  Widget _buildRemoveButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  /// Show bottom sheet to select image source
  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                widget.bottomSheetTitle ?? 'Add Photo',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // Options
              if (widget.allowCamera)
                _ImageSourceOption(
                  icon: Icons.camera_alt_outlined,
                  title: 'Take a picture',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              if (widget.allowCamera && widget.allowGallery) const Divider(height: 1),
              if (widget.allowGallery)
                _ImageSourceOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Select from gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickMultipleImages();
                  },
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick a single image from camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final newImages = List<File>.from(widget.selectedImages)..add(File(pickedFile.path));
        widget.onImagesChanged(newImages);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  /// Pick multiple images from gallery
  Future<void> _pickMultipleImages() async {
    try {
      final remainingSlots = widget.maxImages - _totalImageCount;
      if (remainingSlots <= 0) return;

      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        final filesToAdd = pickedFiles.take(remainingSlots).map((xf) => File(xf.path)).toList();
        final newImages = List<File>.from(widget.selectedImages)..addAll(filesToAdd);
        widget.onImagesChanged(newImages);
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  /// Remove a local image at given index
  void _removeLocalImage(int index) {
    final newImages = List<File>.from(widget.selectedImages)..removeAt(index);
    widget.onImagesChanged(newImages);
  }

  /// Remove an uploaded URL
  void _removeUploadedUrl(String url) {
    if (widget.onUploadedUrlRemoved != null) {
      widget.onUploadedUrlRemoved!(url);
    }
  }
}

/// Image source option widget for bottom sheet
class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
