import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/mixins/approve_appointment_state_mixin.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/widgets/time_slot_grid.dart';
import 'package:flutter_app/features/appointment/widgets/vet_request_summary_card.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Approve Appointment Screen
///
/// Shows request summary, calendar date picker, time slot grid with legend,
/// and confirm button. The vet selects a date and available slot to approve.
class ApproveAppointmentScreen extends StatefulWidget {
  final AppointmentModel appointment;
  final int vetId;

  const ApproveAppointmentScreen({
    super.key,
    required this.appointment,
    required this.vetId,
  });

  @override
  State<ApproveAppointmentScreen> createState() =>
      _ApproveAppointmentScreenState();
}

class _ApproveAppointmentScreenState extends State<ApproveAppointmentScreen>
    with ApproveAppointmentStateMixin {
  @override
  void initState() {
    super.initState();
    initializeApproval(widget.appointment, id: widget.vetId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Approve Request'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: handleBack,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Request summary card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: VetRequestSummaryCard(appointment: appointment),
            ),
            const SizedBox(height: 20),

            // Section: Select Date
            _buildSectionHeader('Select Date'),
            const SizedBox(height: 8),
            _buildCalendar(),
            const SizedBox(height: 16),

            // Section: Select Time Slot
            if (selectedDate != null) ...[
              _buildSectionHeader(
                'Select Time Slot',
                subtitle: selectedDate != null
                    ? formatDate(selectedDate!)
                    : null,
              ),
              const SizedBox(height: 8),
              _buildSlotsSection(),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TimeSlotLegend(),
              ),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CalendarDatePicker(
        initialDate: selectedDate ?? now,
        firstDate: now,
        lastDate: now.add(const Duration(days: 60)),
        onDateChanged: onDateSelected,
      ),
    );
  }

  Widget _buildSlotsSection() {
    if (isLoadingSlots) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    if (slotsError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  slotsError!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (slotsResponse == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TimeSlotGrid(
        slots: slotsResponse!.slots,
        selectedSlot: selectedSlot,
        onSlotTap: onSlotSelected,
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            key: const Key('confirm_appointment_btn'),
            onPressed: canConfirm ? submitApproval : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              disabledBackgroundColor: Colors.grey[300],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Confirm Appointment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
