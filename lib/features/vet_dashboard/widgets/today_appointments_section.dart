import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/widgets/vet_appointment_card.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Section showing today's appointments on the vet dashboard.
/// Reuses VetAppointmentCard widget.
class TodayAppointmentsSection extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final bool isLoading;
  final VoidCallback? onViewAllTap;
  final void Function(AppointmentModel)? onAppointmentTap;

  const TodayAppointmentsSection({
    super.key,
    required this.appointments,
    this.isLoading = false,
    this.onViewAllTap,
    this.onAppointmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Appointments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.authTextPrimary,
                ),
              ),
              if (onViewAllTap != null)
                GestureDetector(
                  key: const Key('view_all_appointments_btn'),
                  onTap: onViewAllTap,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.authPrimaryColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (appointments.isEmpty)
            _buildEmptyState()
          else
            ...appointments.take(5).map((appointment) {
              return VetAppointmentCard(
                appointment: appointment,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              'No appointments yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'New appointment requests will appear here',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
