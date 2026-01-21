import 'package:flutter/material.dart';
import 'package:flutter_app/features/vet/controllers/vet_controller.dart';
import 'package:flutter_app/features/vet/models/vet_model.dart';

/// Mixin for Vet Services page state management
mixin VetStateMixin<T extends StatefulWidget> on State<T> {
  late VetController vetController;
  final TextEditingController searchController = TextEditingController();

  /// Initialize vet controller and load data
  void initializeVetController() {
    vetController = VetController();
    vetController.addListener(_onControllerUpdate);
  }

  /// Load initial vet data
  Future<void> loadVets() async {
    await vetController.loadVets();
  }

  /// Controller update listener
  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Handle breed chip selection
  void handleBreedSelected(String breed) {
    vetController.setSelectedBreed(breed);
  }

  /// Handle search input
  void handleSearch(String query) {
    vetController.searchVets(query);
  }

  /// Handle book button tap
  void handleBookTap(VetModel vet) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking appointment with ${vet.name}...'),
          backgroundColor: const Color(0xFF3B9B59),
        ),
      );
    }
  }

  /// Handle call button tap
  void handleCallTap(VetModel vet) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling ${vet.name}...'),
        ),
      );
    }
  }

  /// Handle video call button tap
  void handleVideoTap(VetModel vet) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Starting video call with ${vet.name}...'),
        ),
      );
    }
  }

  /// Handle chat button tap
  void handleChatTap(VetModel vet) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening chat with ${vet.name}...'),
        ),
      );
    }
  }

  /// Handle promo banner "Book Now" tap
  void handlePromoBannerTap() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promo code FIRST2024 applied!'),
          backgroundColor: Color(0xFF3B9B59),
        ),
      );
    }
  }

  /// Navigate back
  void handleBackTap() {
    Navigator.of(context).pop();
  }

  /// Dispose vet controller
  void disposeVetController() {
    vetController.removeListener(_onControllerUpdate);
    vetController.dispose();
    searchController.dispose();
  }
}
