import 'package:flutter/material.dart';
import 'package:flutter_app/features/vet/models/vet_model.dart';
import 'package:flutter_app/features/vet/models/vet_review_model.dart';
import 'package:flutter_app/features/vet/services/vet_service.dart';

/// Mixin for Vet Detail page state management
mixin VetDetailStateMixin<T extends StatefulWidget> on State<T> {
  final VetService _vetService = VetService();

  VetModel? vet;
  List<VetReviewModel> reviews = [];
  bool isLoading = true;
  String? errorMessage;

  /// Get vet ID - must be implemented by the page
  int get vetId;

  /// Initialize and load vet details
  Future<void> initializeVetDetail() async {
    await loadVetDetails();
  }

  /// Load vet details and reviews
  Future<void> loadVetDetails() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Load vet details and reviews in parallel
      final results = await Future.wait([
        _vetService.getVetById(vetId),
        _vetService.getReviews(vetId),
      ]);

      if (!mounted) return;

      final loadedVet = results[0] as VetModel?;
      final loadedReviews = results[1] as List<VetReviewModel>;

      if (loadedVet == null) {
        setState(() {
          errorMessage = 'Vet not found';
          isLoading = false;
        });
        return;
      }

      setState(() {
        vet = loadedVet;
        reviews = loadedReviews;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Failed to load vet details';
        isLoading = false;
      });
    }
  }

  /// Handle call button tap
  void handleCallTap() {
    if (mounted && vet != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling ${vet!.name}...'),
          backgroundColor: const Color(0xFF3B9B59),
        ),
      );
    }
  }

  /// Handle video call button tap
  void handleVideoTap() {
    if (mounted && vet != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Starting video call with ${vet!.name}...'),
          backgroundColor: const Color(0xFF3B9B59),
        ),
      );
    }
  }

  /// Handle chat button tap
  void handleChatTap() {
    if (mounted && vet != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening chat with ${vet!.name}...'),
          backgroundColor: const Color(0xFF3B9B59),
        ),
      );
    }
  }

  /// Handle book appointment button tap
  void handleBookTap() {
    if (mounted && vet != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking appointment with ${vet!.name}...'),
          backgroundColor: const Color(0xFF3B9B59),
        ),
      );
    }
  }

  /// Navigate back
  void handleBackTap() {
    Navigator.of(context).pop();
  }

  /// Check if data is loaded
  bool get hasData => vet != null;
}
