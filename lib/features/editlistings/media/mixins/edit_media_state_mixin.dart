import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';

/// Mixin for edit media page: same state as postlistings media + pre-fill.
mixin EditMediaStateMixin<T extends StatefulWidget> on State<T> {
  List<File> selectedImages = [];
  List<String> uploadedImageKeys = [];
  List<String> uploadedImageUrls = [];
  bool isSubmitting = false;

  static const int maxImages = 10;

  void addImages(List<File> images) {
    if (mounted) setState(() => selectedImages = images);
  }

  void removeImage(File image) {
    if (mounted) setState(() => selectedImages.remove(image));
  }

  void removeUploadedUrl(String url) {
    final index = uploadedImageUrls.indexOf(url);
    if (index != -1 && mounted) {
      setState(() {
        uploadedImageUrls.removeAt(index);
        if (index < uploadedImageKeys.length) {
          uploadedImageKeys.removeAt(index);
        }
      });
    }
  }

  void clearImages() {
    if (mounted) setState(() => selectedImages.clear());
  }

  void setSubmitting(bool submitting) {
    if (mounted) setState(() => isSubmitting = submitting);
  }

  void addUploadedData(List<String> keys, List<String> urls) {
    if (mounted) {
      setState(() {
        uploadedImageKeys.addAll(keys);
        uploadedImageUrls.addAll(urls);
      });
    }
  }

  bool validateImages() {
    return selectedImages.isNotEmpty || uploadedImageKeys.isNotEmpty;
  }

  /// Pre-fill from listing API response (existing images)
  void preFillFromListing(Map<String, dynamic> listing) {
    if (!mounted) return;
    final urls = <String>[];
    final keys = <String>[];
    final primary = listing['primary_image']?.toString();
    if (primary != null && primary.isNotEmpty) {
      urls.add(CommonHelper.getImageUrl(primary));
      keys.add(primary);
    }
    final images = listing['animal_images'] ?? listing['image_urls'];
    if (images is List) {
      for (final e in images) {
        final s = e.toString();
        if (s.isEmpty) continue;
        final url = CommonHelper.getImageUrl(s);
        if (url.isNotEmpty && !urls.contains(url)) {
          urls.add(url);
          keys.add(s);
        }
      }
    }
    if (urls.isEmpty && keys.isEmpty) return;
    setState(() {
      uploadedImageUrls = urls;
      uploadedImageKeys = keys;
    });
  }
}
