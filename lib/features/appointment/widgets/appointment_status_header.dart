import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';

/// Color-coded full-width status banner for appointment detail screen
class AppointmentStatusHeader extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentStatusHeader({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: appointment.statusColor.withValues(alpha: 0.12),
        border: Border(
          bottom: BorderSide(
            color: appointment.statusColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            appointment.statusIcon,
            size: 20,
            color: appointment.statusColor,
          ),
          const SizedBox(width: 8),
          Text(
            appointment.displayStatus,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: appointment.statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
