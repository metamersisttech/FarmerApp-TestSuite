import 'package:flutter/material.dart';
import 'package:flutter_app/features/vet/controllers/vet_controller.dart';
import 'package:flutter_app/features/vet/models/vet_model.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Mixin for Vet Services page state management
mixin VetStateMixin<T extends StatefulWidget> on State<T> {
  late VetController vetController;
  final TextEditingController searchController = TextEditingController();
  late ScrollController scrollController;

  /// Initialize vet controller and load data
  void initializeVetController() {
    vetController = VetController();
    vetController.addListener(_onControllerUpdate);
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
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

  /// Scroll listener for pagination
  void _onScroll() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    // Trigger load more when 80% scrolled
    if (currentScroll >= maxScroll * 0.8) {
      vetController.loadMoreVets();
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

  /// Handle book button tap — navigate to booking screen
  void handleBookTap(VetModel vet) {
    if (mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.bookAppointment,
        arguments: vet,
      );
    }
  }

  /// Handle vet card tap - navigate to vet detail page
  void handleVetCardTap(VetModel vet) {
    if (mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.vetDetail,
        arguments: vet.id,
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
    scrollController.dispose();
  }
}
