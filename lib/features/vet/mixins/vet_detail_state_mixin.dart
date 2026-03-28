import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/features/vet/models/vet_model.dart';
import 'package:flutter_app/features/vet/models/vet_review_model.dart';
import 'package:flutter_app/features/vet/models/vet_availability_slot_model.dart';
import 'package:flutter_app/features/vet/services/vet_service.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

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

  /// Handle call button tap — launch phone dialer or show unavailable
  void handleCallTap() async {
    if (!mounted || vet == null) return;

    final phone = vet!.phoneNumber;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available for this vet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open phone dialer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle video call button tap — show coming soon dialog
  void handleVideoTap() {
    if (!mounted || vet == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Video Consultation'),
        content: const Text(
          'Video consultation is coming soon! You can book an in-person or chat appointment in the meantime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handle chat button tap — prompt to book appointment first
  void handleChatTap() {
    if (!mounted || vet == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chat with Vet'),
        content: Text(
          'Book an appointment first to chat with ${vet!.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushNamed(
                context,
                AppRoutes.bookAppointment,
                arguments: vet,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
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
