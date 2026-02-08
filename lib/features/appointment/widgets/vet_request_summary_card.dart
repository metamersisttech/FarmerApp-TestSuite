import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Compact request summary card for vet-side approve/reject/complete screens.
///
/// Shows requestor info, phone, animal, consultation mode, fee,
/// notes, and optional schedule (for confirmed appointments).
class VetRequestSummaryCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool showSchedule;

  const VetRequestSummaryCard({
    super.key,
    required this.appointment,
    this.showSchedule = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Requestor row
          _buildRequestorRow(),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Mode + fee
          _buildInfoRow(
            appointment.modeIcon,
            appointment.modeDisplay,
            trailing: appointment.formattedFee.isNotEmpty
                ? appointment.formattedFee
                : null,
          ),

          // Animal
          if (appointment.listing != null) ...[
            const SizedBox(height: 6),
            _buildInfoRow(Icons.pets, appointment.listing!.title),
          ],

          // Schedule (for confirmed appointments on complete screen)
          if (showSchedule && appointment.formattedSchedule != null) ...[
            const SizedBox(height: 6),
            _buildInfoRow(
                Icons.calendar_today, appointment.formattedSchedule!),
          ],

          // Notes
          if (appointment.notes != null &&
              appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              appointment.notes!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestorRow() {
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
        // Avatar
        Container(
          width: 44,
          height: 44,
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
                fontSize: 16,
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
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.phone, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: appointment.statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            appointment.displayStatus,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: appointment.statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {String? trailing}) {
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
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.primaryColor,
            ),
          ),
      ],
    );
  }
}
