import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/mixins/appointment_detail_state_mixin.dart';
import 'package:flutter_app/features/appointment/widgets/appointment_status_header.dart';
import 'package:flutter_app/features/appointment/widgets/appointment_vet_info_card.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Appointment Detail Screen
///
/// Full detail view of a single appointment.
/// Shows status header, vet info, schedule, animal, notes,
/// rejection reason, prescription, and action buttons.
class AppointmentDetailScreen extends StatefulWidget {
  final int appointmentId;

  const AppointmentDetailScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen>
    with AppointmentDetailStateMixin {
  @override
  int get appointmentId => widget.appointmentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAppointmentDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: handleBackTap,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : errorMessage != null
                    ? _buildErrorState()
                    : _buildContent(),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.primaryColor),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Failed to load details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'An error occurred',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: handleBackTap,
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: loadAppointmentDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final appt = appointment;
    if (appt == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header banner
          AppointmentStatusHeader(appointment: appt),
          const SizedBox(height: 16),

          // Vet info card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppointmentVetInfoCard(
              name: appt.vet.name,
              clinicName: appt.vet.clinicName,
              phone: appt.vet.phone,
              showPhone: appt.isPhoneVisible,
              onCallTap: appt.isPhoneVisible ? handleCall : null,
            ),
          ),

          // Schedule card (if confirmed or completed)
          if (appt.formattedSchedule != null) ...[
            const SizedBox(height: 16),
            _buildDetailCard(
              icon: Icons.calendar_today,
              title: 'Schedule',
              content: appt.formattedSchedule!,
            ),
          ],

          // Mode card
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: appt.modeIcon,
            title: 'Consultation Mode',
            content: appt.modeDisplay,
          ),

          // Fee card
          if (appt.formattedFee.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailCard(
              icon: Icons.payments_outlined,
              title: 'Fee',
              content: appt.formattedFee,
            ),
          ],

          // Animal card (if linked)
          if (appt.listing != null) ...[
            const SizedBox(height: 16),
            _buildDetailCard(
              icon: Icons.pets,
              title: 'Animal',
              content: appt.listing!.title,
            ),
          ],

          // Notes section
          if (appt.notes != null && appt.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailCard(
              icon: Icons.notes,
              title: 'Notes',
              content: appt.notes!,
            ),
          ],

          // Rejection reason (if rejected)
          if (appt.status == 'REJECTED' && appt.rejectionReason != null) ...[
            const SizedBox(height: 16),
            _buildDetailCard(
              icon: Icons.block,
              title: 'Rejection Reason',
              content: appt.rejectionReason!,
              contentColor: Colors.red[700],
            ),
          ],

          // Prescription (if completed)
          if (appt.status == 'COMPLETED' && appt.prescription != null) ...[
            const SizedBox(height: 16),
            _buildDetailCard(
              icon: Icons.description,
              title: 'Prescription',
              content: appt.prescription!,
            ),
          ],

          // Completion notes (if completed)
          if (appt.status == 'COMPLETED' &&
              appt.completionNotes != null) ...[
            const SizedBox(height: 16),
            _buildDetailCard(
              icon: Icons.medical_information,
              title: 'Completion Notes',
              content: appt.completionNotes!,
            ),
          ],

          // Created date
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.access_time,
            title: 'Requested On',
            content: appt.formattedCreatedAt,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
    Color? contentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  color: contentColor ?? AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    final appt = appointment;
    if (appt == null) return const SizedBox.shrink();

    // Build action buttons based on status
    final actions = <Widget>[];

    if (appt.canChat) {
      actions.add(
        Expanded(
          child: OutlinedButton.icon(
            key: const Key('appointment_detail_chat_btn'),
            onPressed: handleChat,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    if (appt.canCancel) {
      if (actions.isNotEmpty) actions.add(const SizedBox(width: 12));
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            key: const Key('appointment_detail_cancel_btn'),
            onPressed: handleCancel,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12, // Add system nav bar padding
      ),
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
      child: Row(children: actions),
    );
  }
}
