import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/models/appointment_listing_item.dart';
import 'package:flutter_app/features/appointment/services/appointment_service.dart';
import 'package:flutter_app/features/vet/models/vet_model.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Mixin for Book Appointment screen state management
mixin BookAppointmentStateMixin<T extends StatefulWidget> on State<T> {
  final AppointmentService _appointmentService = AppointmentService();

  late VetModel vet;
  final TextEditingController notesController = TextEditingController();

  String selectedMode = 'in_person';
  AppointmentListingItem? selectedListing;
  List<AppointmentListingItem> userListings = [];

  bool isSubmitting = false;
  bool isLoadingListings = true;

  /// Initialize with vet data and load user listings
  Future<void> initializeBooking(VetModel vetModel) async {
    vet = vetModel;
    await loadUserListings();
  }

  /// Load user's listings for the animal dropdown
  Future<void> loadUserListings() async {
    if (!mounted) return;
    setState(() => isLoadingListings = true);

    try {
      final result = await _appointmentService.getUserListings();
      if (!mounted) return;

      setState(() {
        if (result.success && result.userListings != null) {
          userListings = result.userListings!;
        }
        isLoadingListings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingListings = false);
    }
  }

  /// Set the consultation mode
  void selectMode(String mode) {
    if (!mounted) return;
    setState(() => selectedMode = mode);
  }

  /// Set the selected listing (animal)
  void selectListing(AppointmentListingItem? listing) {
    if (!mounted) return;
    setState(() => selectedListing = listing);
  }

  /// Get the fee for the currently selected mode
  String get selectedFee {
    switch (selectedMode) {
      case 'in_person':
        return vet.formattedConsultationFee;
      case 'video':
        return vet.formattedVideoCallFee ?? vet.formattedConsultationFee;
      case 'phone':
        return vet.formattedVideoCallFee ?? vet.formattedConsultationFee;
      default:
        return vet.formattedConsultationFee;
    }
  }

  /// Submit the appointment request
  Future<void> submitAppointment() async {
    if (isSubmitting || !mounted) return;

    setState(() => isSubmitting = true);

    try {
      final result = await _appointmentService.createAppointment(
        vetId: vet.id,
        listingId: selectedListing?.listingId,
        mode: selectedMode,
        notes: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
      );

      if (!mounted) return;
      setState(() => isSubmitting = false);

      if (result.success) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar(result.message ?? 'Failed to book appointment');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      _showErrorSnackBar('Failed to book appointment. Please try again.');
    }
  }

  /// Show success dialog and navigate to My Appointments
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Appointment Requested!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your appointment request has been sent to ${vet.name}. '
              'You will be notified once the vet confirms.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.myAppointments,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'View My Appointments',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  /// Navigate back
  void handleBackTap() {
    Navigator.of(context).pop();
  }

  /// Dispose controllers
  void disposeBooking() {
    notesController.dispose();
  }
}
