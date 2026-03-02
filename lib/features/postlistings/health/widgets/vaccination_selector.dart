import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Vaccination Selector Widget
class VaccinationSelector extends StatelessWidget {
  final String? vaccinationStatus;
  final Function(String?) onVaccinationSelected;

  const VaccinationSelector({
    super.key,
    required this.vaccinationStatus,
    required this.onVaccinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildVaccinationChip(
            label: 'Vaccinated',
            icon: Icons.check_circle_outline,
            isSelected: vaccinationStatus == 'vaccinated',
            onTap: () => onVaccinationSelected('vaccinated'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildVaccinationChip(
            label: 'Not Vaccinated',
            icon: Icons.cancel_outlined,
            isSelected: vaccinationStatus == 'not_vaccinated',
            onTap: () => onVaccinationSelected('not_vaccinated'),
          ),
        ),
      ],
    );
  }

  Widget _buildVaccinationChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.authPrimaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.authPrimaryColor : AppTheme.authPrimaryColor.withOpacity(0.5),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.authPrimaryColor.withOpacity(0.2)
                  : AppTheme.authPrimaryColor.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.authPrimaryColor : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.authPrimaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
