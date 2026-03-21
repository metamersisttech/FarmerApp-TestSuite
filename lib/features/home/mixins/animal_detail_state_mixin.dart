import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/controllers/animal_detail_controller.dart';

/// Mixin for reusable Animal Detail state coordination
/// 
/// Purpose: Share common state management patterns
/// - Controller lifecycle management
/// - Listener setup and teardown
/// - Image gallery state coordination
/// - UI state synchronization
/// 
/// Does NOT contain business logic - only coordinates state
mixin AnimalDetailStateMixin<T extends StatefulWidget> on State<T> {
  late AnimalDetailController controller;
  int currentImageIndex = 0;
  late PageController imagePageController;

  /// Get the listing ID (must be implemented by the screen)
  int get listingId;

  /// Initialize controller and image controller with callbacks
  void initializeAnimalDetail({
    Function(String)? onShowComingSoon,
    Function(String)? onShowSuccess,
    Function(String)? onShowError,
  }) {
    controller = AnimalDetailController();
    controller.onShowComingSoon = onShowComingSoon ?? _defaultShowComingSoon;
    controller.onShowSuccess = onShowSuccess ?? _defaultShowSuccess;
    controller.onShowError = onShowError ?? _defaultShowError;
    
    // Add listener to rebuild when controller state changes
    controller.addListener(_onControllerChanged);
    
    imagePageController = PageController();
  }

  /// Handle controller state changes
  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        // Rebuild when controller state changes
      });
    }
  }

  /// Dispose controllers
  void disposeAnimalDetail() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
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

  // ========== Default Toast/SnackBar Methods ==========

  void _defaultShowComingSoon(String actionName) {
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

  void _defaultShowSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    }
  }

  void _defaultShowError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    }
  }
}
