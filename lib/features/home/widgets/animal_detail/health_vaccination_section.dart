import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/animal_detail_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Health & Vaccination Section for Animal Detail Page
///
/// Displays list of vaccinations with checkmarks, names, and dates.
class HealthVaccinationSection extends StatelessWidget {
  final List<VaccinationRecord> vaccinations;
  final String? healthStatus;

  const HealthVaccinationSection({
    super.key,
    required this.vaccinations,
    this.healthStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (vaccinations.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Health & Vaccination',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Vaccination List
          ...vaccinations.map((vaccination) => _VaccinationItem(
                vaccination: vaccination,
              )),
        ],
      ),
    );
  }
}

/// Individual vaccination item
class _VaccinationItem extends StatelessWidget {
  final VaccinationRecord vaccination;

  const _VaccinationItem({required this.vaccination});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Checkmark Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: vaccination.isCompleted
                  ? AppTheme.authPrimaryColor.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              vaccination.isCompleted
                  ? Icons.check
                  : Icons.schedule,
              color: vaccination.isCompleted
                  ? AppTheme.authPrimaryColor
                  : Colors.orange,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Name and Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccination.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: vaccination.isCompleted
                        ? AppTheme.textPrimary
                        : Colors.orange.shade700,
                  ),
                ),
                if (vaccination.formattedDate.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    vaccination.formattedDate,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
