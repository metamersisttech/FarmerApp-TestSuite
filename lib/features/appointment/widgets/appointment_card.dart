import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Appointment card widget for the appointments list
class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;
  final VoidCallback? onCancelTap;
  final VoidCallback? onChatTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onCancelTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('appointment_card'),
      onTap: onTap,
      child: Container(
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

            // Vet info
            _buildVetInfo(),

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

            // Phone (if visible)
            if (appointment.isPhoneVisible &&
                appointment.vet.phone != null) ...[
              const SizedBox(height: 6),
              _buildInfoChip(Icons.phone, appointment.vet.phone!),
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
            if (appointment.canCancel || appointment.canChat) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _buildActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Status badge
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
        // Date
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

  Widget _buildVetInfo() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              appointment.vet.name
                  .split(' ')
                  .map((e) => e.isNotEmpty ? e[0] : '')
                  .take(2)
                  .join()
                  .toUpperCase(),
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
                appointment.vet.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (appointment.vet.clinicName.isNotEmpty)
                Text(
                  appointment.vet.clinicName,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
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
        if (appointment.canChat && onChatTap != null)
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Chat',
            color: AppTheme.primaryColor,
            onTap: onChatTap!,
          ),
        if (appointment.canChat && appointment.canCancel)
          const SizedBox(width: 12),
        if (appointment.canCancel && onCancelTap != null)
          _ActionButton(
            icon: Icons.cancel_outlined,
            label: 'Cancel',
            color: Colors.red,
            onTap: onCancelTap!,
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
