import 'dart:io';
import 'package:flutter/material.dart';

/// Mixin for media page state management
mixin MediaStateMixin<T extends StatefulWidget> on State<T> {
  // Selected images (local files)
  List<File> selectedImages = [];

  // Uploaded image keys (GCS keys)
  List<String> uploadedImageKeys = [];

  // Uploaded image URLs (for display)
  List<String> uploadedImageUrls = [];

  // Loading states
  bool isSubmitting = false;

  static const int maxImages = 10;

  /// Add images to selection
  void addImages(List<File> images) {
    if (mounted) {
      setState(() {
        selectedImages = images;
      });
    }
  }

  /// Remove image from selection
  void removeImage(File image) {
    if (mounted) {
      setState(() {
        selectedImages.remove(image);
      });
    }
  }

  /// Handle uploaded URL removed
  void removeUploadedUrl(String url) {
    final index = uploadedImageUrls.indexOf(url);
    if (index != -1) {
      if (mounted) {
        setState(() {
          uploadedImageUrls.removeAt(index);
          if (index < uploadedImageKeys.length) {
            uploadedImageKeys.removeAt(index);
          }
        });
      }
    }
  }

  /// Clear all images
  void clearImages() {
    if (mounted) {
      setState(() {
        selectedImages.clear();
      });
    }
  }

  /// Set submitting state
  void setSubmitting(bool submitting) {
    if (mounted) {
      setState(() {
        isSubmitting = submitting;
      });
    }
  }

  /// Add uploaded keys and URLs
  void addUploadedData(List<String> keys, List<String> urls) {
    if (mounted) {
      setState(() {
        uploadedImageKeys.addAll(keys);
        uploadedImageUrls.addAll(urls);
      });
    }
  }

  /// Validate at least one image
  bool validateImages() {
    return selectedImages.isNotEmpty || uploadedImageKeys.isNotEmpty;
  }
}
