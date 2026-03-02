import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/models/available_slot_model.dart';
import 'package:flutter_app/features/appointment/models/available_slots_response.dart';
import 'package:flutter_app/features/appointment/services/appointment_service.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Mixin for ApproveAppointmentScreen state management
mixin ApproveAppointmentStateMixin<T extends StatefulWidget> on State<T> {
  final AppointmentService _service = AppointmentService();

  late AppointmentModel appointment;
  late int vetId;

  DateTime? selectedDate;
  AvailableSlot? selectedSlot;
  AvailableSlotsResponse? slotsResponse;

  bool isLoadingSlots = false;
  bool isSubmitting = false;
  String? slotsError;

  /// Initialize with appointment data and vet ID
  void initializeApproval(AppointmentModel appt, {required int id}) {
    appointment = appt;
    vetId = id;
  }

  /// Called when user picks a date from the calendar
  Future<void> onDateSelected(DateTime date) async {
    if (!mounted) return;
    setState(() {
      selectedDate = date;
      selectedSlot = null;
      slotsResponse = null;
      slotsError = null;
    });
    await _loadSlotsForDate(date);
  }

  /// Load available slots for the selected date
  Future<void> _loadSlotsForDate(DateTime date) async {
    if (!mounted) return;

    setState(() {
      isLoadingSlots = true;
      slotsError = null;
    });

    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final result = await _service.getAvailableSlots(
        vetId: vetId,
        date: dateStr,
      );

      if (!mounted) return;

      if (result.success && result.availableSlots != null) {
        setState(() {
          slotsResponse = result.availableSlots;
          isLoadingSlots = false;
        });
      } else {
        setState(() {
          slotsError = result.message ?? 'No slots available for this date.';
          isLoadingSlots = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        slotsError = 'Failed to load time slots.';
        isLoadingSlots = false;
      });
    }
  }

  /// Called when user taps a slot in the grid
  void onSlotSelected(AvailableSlot slot) {
    if (!slot.available || !mounted) return;
    setState(() => selectedSlot = slot);
  }

  /// Whether the confirm button should be enabled
  bool get canConfirm =>
      selectedDate != null && selectedSlot != null && !isSubmitting;

  /// Format date for display
  String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Submit approval
  Future<void> submitApproval() async {
    if (!canConfirm || !mounted) return;

    setState(() => isSubmitting = true);

    try {
      final dateStr =
          '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
      final result = await _service.approveAppointment(
        appointmentId: appointment.appointmentId,
        scheduledDate: dateStr,
        startTime: selectedSlot!.startTime,
      );

      if (!mounted) return;
      setState(() => isSubmitting = false);

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(result.message ?? 'Appointment confirmed successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        // Handle 409 Conflict (double booking)
        final msg = result.message ?? 'Failed to approve.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.orange,
          ),
        );
        // Refresh slots if it looks like a slot conflict
        setState(() => selectedSlot = null);
        if (selectedDate != null) {
          await _loadSlotsForDate(selectedDate!);
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to approve appointment.'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  void handleBack() => Navigator.of(context).pop();
}
