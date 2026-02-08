import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/services/appointment_service.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Mixin for Appointment Detail screen state management
mixin AppointmentDetailStateMixin<T extends StatefulWidget> on State<T> {
  final AppointmentService _service = AppointmentService();

  AppointmentModel? appointment;
  bool isLoading = true;
  String? errorMessage;

  /// Get appointment ID - must be implemented by the page
  int get appointmentId;

  /// Load appointment detail
  Future<void> loadAppointmentDetail() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _service.getAppointmentById(appointmentId);

      if (!mounted) return;

      if (result.success && result.appointment != null) {
        setState(() {
          appointment = result.appointment;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result.message ?? 'Failed to load appointment';
          isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Failed to load appointment details';
        isLoading = false;
      });
    }
  }

  /// Handle cancel
  Future<void> handleCancel() async {
    if (appointment == null || !appointment!.canCancel) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text('Cancel Appointment?'),
        content: Text(
          'Are you sure you want to cancel your appointment with ${appointment!.vet.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => isLoading = true);
      try {
        final result = await _service.cancelAppointment(appointmentId);
        if (!mounted) return;
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload to get updated status
          await loadAppointmentDetail();
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Failed to cancel'),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      } catch (_) {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to cancel appointment'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  /// Handle chat (placeholder)
  void handleChat() {
    if (appointment != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening chat with ${appointment!.vet.name}...'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  /// Handle call
  void handleCall() {
    if (appointment != null &&
        appointment!.isPhoneVisible &&
        appointment!.vet.phone != null &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling ${appointment!.vet.name}...'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  /// Navigate back
  void handleBackTap() {
    Navigator.of(context).pop();
  }
}
