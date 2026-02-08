import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Appointment card for the vet dashboard.
///
/// Shows requestor name + phone (always visible), animal, mode, notes,
/// schedule. Actions differ by status:
/// - REQUESTED: Approve / Reject
/// - CONFIRMED: Chat / Complete
class VetAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onApproveTap;
  final VoidCallback? onRejectTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onCompleteTap;

  const VetAppointmentCard({
    super.key,
    required this.appointment,
    this.onApproveTap,
    this.onRejectTap,
    this.onChatTap,
    this.onCompleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Status badge row
          _buildStatusRow(),
          const SizedBox(height: 10),

          // Requestor info
          _buildRequestorInfo(),

          // Mode
          const SizedBox(height: 8),
          _buildInfoChip(appointment.modeIcon, appointment.modeDisplay),

          // Animal (if linked)
          if (appointment.listing != null) ...[
            const SizedBox(height: 6),
            _buildInfoChip(Icons.pets, appointment.listing!.title),
          ],

          // Schedule (if confirmed/completed)
          if (appointment.formattedSchedule != null) ...[
            const SizedBox(height: 6),
            _buildInfoChip(
                Icons.calendar_today, appointment.formattedSchedule!),
          ],

          // Notes preview
          if (appointment.notes != null &&
              appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              appointment.notes!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Action buttons
          if (_hasActions) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  bool get _hasActions =>
      appointment.canApprove ||
      appointment.canReject ||
      appointment.canComplete ||
      appointment.canChat;

  Widget _buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: appointment.statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                appointment.statusIcon,
                size: 14,
                color: appointment.statusColor,
              ),
              const SizedBox(width: 4),
              Text(
                appointment.displayStatus,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: appointment.statusColor,
                ),
              ),
            ],
          ),
        ),
        Text(
          appointment.formattedCreatedAt,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestorInfo() {
    final name = appointment.requestor?.name ?? 'Unknown';
    final phone = appointment.requestor?.phone ?? '';
    final initials = name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (phone.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.phone, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // Fee
        if (appointment.formattedFee.isNotEmpty)
          Text(
            appointment.formattedFee,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppTheme.primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // REQUESTED: Approve / Reject
        if (appointment.canApprove && onApproveTap != null)
          _ActionButton(
            icon: Icons.check_circle_outline,
            label: 'Approve',
            color: Colors.green,
            onTap: onApproveTap!,
          ),
        if (appointment.canApprove && appointment.canReject)
          const SizedBox(width: 12),
        if (appointment.canReject && onRejectTap != null)
          _ActionButton(
            icon: Icons.cancel_outlined,
            label: 'Reject',
            color: Colors.red,
            onTap: onRejectTap!,
          ),

        // CONFIRMED: Chat / Complete
        if (appointment.canChat && onChatTap != null)
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Chat',
            color: AppTheme.primaryColor,
            onTap: onChatTap!,
          ),
        if (appointment.canChat && appointment.canComplete)
          const SizedBox(width: 12),
        if (appointment.canComplete && onCompleteTap != null)
          _ActionButton(
            icon: Icons.task_alt,
            label: 'Complete',
            color: Colors.blue,
            onTap: onCompleteTap!,
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
