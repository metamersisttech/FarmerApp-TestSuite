import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/controllers/animal_detail_controller.dart';
import 'package:flutter_app/features/home/widgets/animal_detail/bid_price_bottom_sheet.dart';
import 'package:flutter_app/features/messaging/services/messaging_service.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Mixin for Animal Detail page functionality and coordination
/// Contains all business logic coordination and UI event handlers
mixin AnimalDetailStateMixin<T extends StatefulWidget> on State<T> {
  late AnimalDetailController controller;
  int currentImageIndex = 0;
  late PageController imagePageController;

  /// Get the listing ID (must be implemented by the screen)
  int get listingId;

  /// Initialize controller and image controller
  void initializeAnimalDetail() {
    controller = AnimalDetailController();
    imagePageController = PageController();
  }

  /// Dispose controllers
  void disposeAnimalDetail() {
    controller.dispose();
    imagePageController.dispose();
  }

  /// Fetch animal details from API
  Future<void> fetchDetails() async {
    await controller.fetchAnimalDetail(listingId);

    if (!mounted) return;

    setState(() {});

    if (controller.errorMessage != null) {
      showErrorToast(controller.errorMessage!);
    }
  }

  /// Handle back button tap
  void handleBackTap() {
    Navigator.of(context).pop();
  }

  /// Handle share button tap
  void handleShareTap() {
    controller.shareAnimal();
    showComingSoonAction('Share');
  }

  /// Handle favorite button tap
  Future<void> handleFavoriteTap() async {
    await controller.toggleFavorite();
    
    if (!mounted) return;
    
    setState(() {});
    
    if (controller.errorMessage != null) {
      showErrorToast(controller.errorMessage!);
    } else {
      showSuccessToast(
        controller.isFavorite ? 'Added to favorites' : 'Removed from favorites',
      );
    }
  }

  /// Handle call button tap
  void handleCallTap() {
    showComingSoonAction('Call');
  }

  /// Handle chat button tap - start or open conversation with seller
  Future<void> handleChatTap() async {
    if (!mounted) return;

    // Show a brief loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening chat...'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final messagingService = MessagingService();
    final result = await messagingService.startConversation(listingId);

    if (!mounted) return;

    // Dismiss the loading snackbar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result.success && result.conversation != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.directChat,
        arguments: result.conversation,
      );
    } else {
      showErrorToast(result.message ?? 'Failed to start conversation');
    }
  }

  /// Handle video button tap
  void handleVideoTap() {
    showComingSoonAction('Video call');
  }

  /// Handle buy now button tap - opens bid pricing bottom sheet
  void handleBuyNowTap() {
    final animal = controller.animalDetail;
    if (animal == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BidPriceBottomSheet(
        listedPrice: animal.price,
        animalTitle: animal.title,
      ),
    );
  }

  /// Handle book transport tap
  void handleBookTransportTap() {
    showComingSoonAction('Book Transport');
  }

  /// Handle seller contact tap
  void handleSellerContactTap() {
    showComingSoonAction('Contact Seller');
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

  // ========== Toast/SnackBar Methods ==========

  /// Show coming soon action toast
  void showComingSoonAction(String actionName) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$actionName coming soon!'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
        ),
      );
    }
  }

  /// Show success toast
  void showSuccessToast(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
        ),
      );
    }
  }

  /// Show error toast
  void showErrorToast(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
        ),
      );
    }
  }
}
