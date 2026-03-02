import 'package:flutter/material.dart';

/// Mixin for edit preview page state (same as postlistings preview).
mixin EditPreviewStateMixin<T extends StatefulWidget> on State<T> {
  Map<String, dynamic>? listingData;
  late PageController imagePageController;
  int currentImageIndex = 0;
  bool isPublishing = false;
  String? error;

  void initializeControllers() {
    imagePageController = PageController();
  }

  void disposeControllers() {
    imagePageController.dispose();
  }

  void setListingData(Map<String, dynamic>? data) {
    if (mounted) setState(() => listingData = data);
  }

  void setImageIndex(int index) {
    if (mounted) setState(() => currentImageIndex = index);
  }

  void setPublishing(bool publishing) {
    if (mounted) setState(() => isPublishing = publishing);
  }

  void setError(String? errorMessage) {
    if (mounted) setState(() => error = errorMessage);
  }

  double parseNumber(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String formatPrice(dynamic price) {
    if (price == null) return '0';
    final numPrice = price is num ? price : num.tryParse(price.toString()) ?? 0;
    if (numPrice >= 100000) {
      return '${(numPrice / 100000).toStringAsFixed(numPrice % 100000 == 0 ? 0 : 1)}L';
    } else if (numPrice >= 1000) {
      final formatted = numPrice.toStringAsFixed(0);
      final result = StringBuffer();
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
          result.write(',');
        }
        result.write(formatted[i]);
        count++;
      }
      return result.toString().split('').reversed.join();
    }
    return numPrice.toStringAsFixed(0);
  }
}
