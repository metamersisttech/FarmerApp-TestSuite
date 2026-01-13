import 'package:flutter/material.dart';

/// Mixin for Animal Detail page UI state management
mixin AnimalDetailStateMixin<T extends StatefulWidget> on State<T> {
  int currentImageIndex = 0;
  late PageController imagePageController;

  /// Initialize the image page controller
  void initImageController() {
    imagePageController = PageController();
  }

  /// Dispose the image page controller
  void disposeImageController() {
    imagePageController.dispose();
  }

  /// Set the current image index
  void setImageIndex(int index) {
    if (mounted) {
      setState(() => currentImageIndex = index);
    }
  }

  /// Navigate to next image
  void nextImage(int totalImages) {
    if (currentImageIndex < totalImages - 1) {
      imagePageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to previous image
  void previousImage() {
    if (currentImageIndex > 0) {
      imagePageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Jump to specific image
  void jumpToImage(int index) {
    imagePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Show coming soon action toast
  void showComingSoonAction(String actionName) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$actionName coming soon!'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    }
  }
}
