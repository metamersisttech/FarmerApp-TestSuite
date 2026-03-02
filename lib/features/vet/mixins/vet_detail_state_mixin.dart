import 'package:flutter/material.dart';
import 'package:flutter_app/features/vet/models/vet_model.dart';
import 'package:flutter_app/features/vet/models/vet_review_model.dart';
import 'package:flutter_app/features/vet/models/vet_availability_slot_model.dart';
import 'package:flutter_app/features/vet/services/vet_service.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Mixin for Vet Detail page state management
mixin VetDetailStateMixin<T extends StatefulWidget> on State<T> {
  final VetService _vetService = VetService();

  VetModel? vet;
  List<VetReviewModel> reviews = [];
  List<VetAvailabilitySlotModel> availabilitySlots = [];
  bool isLoading = true;
  String? errorMessage;

  /// Get vet ID - must be implemented by the page
  int get vetId;

  /// Initialize and load vet details
  Future<void> initializeVetDetail() async {
    await loadVetDetails();
  }

  /// Load vet details and availability
  Future<void> loadVetDetails() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Load vet details and availability in parallel
      final results = await Future.wait([
        _vetService.getVetById(vetId),
        _vetService.getVetAvailability(vetId),
      ]);

      if (!mounted) return;

      final vetResult = results[0];
      final availabilityResult = results[1];

      if (!vetResult.success || vetResult.vet == null) {
        setState(() {
          errorMessage = vetResult.message ?? 'Vet not found';
          isLoading = false;
        });
        return;
      }

      setState(() {
        vet = vetResult.vet;
        if (availabilityResult.success &&
            availabilityResult.availability != null) {
          availabilitySlots = availabilityResult.availability!;
        }
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

  /// Handle book appointment button tap — navigate to booking screen
  void handleBookTap() {
    if (mounted && vet != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.bookAppointment,
        arguments: vet,
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
