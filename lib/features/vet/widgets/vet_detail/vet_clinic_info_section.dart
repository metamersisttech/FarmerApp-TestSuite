import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Clinic info section displaying clinic name, address, and working hours
class VetClinicInfoSection extends StatelessWidget {
  final String? clinicName;
  final String? clinicAddress;
  final String? workingHours;

  const VetClinicInfoSection({
    super.key,
    this.clinicName,
    this.clinicAddress,
    this.workingHours,
  });

  @override
  Widget build(BuildContext context) {
    if (clinicName == null && clinicAddress == null && workingHours == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Section title
          const Row(
            children: [
              Icon(
                Icons.local_hospital_outlined,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                'Clinic Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Clinic name
          if (clinicName != null) ...[
            _buildInfoRow(
              icon: Icons.business,
              label: 'Clinic Name',
              value: clinicName!,
            ),
            const SizedBox(height: 12),
          ],
          // Address
          if (clinicAddress != null) ...[
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: clinicAddress!,
            ),
            const SizedBox(height: 12),
          ],
          // Working hours
          if (workingHours != null)
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Working Hours',
              value: workingHours!,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
