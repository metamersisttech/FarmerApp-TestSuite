import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Gender Selector Widget
class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final String? error;
  final Function(String?) onGenderSelected;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.error,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildGenderChip(
            label: 'Male',
            icon: Icons.male,
            isSelected: selectedGender == 'Male',
            hasError: error != null,
            onTap: () => onGenderSelected('Male'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGenderChip(
            label: 'Female',
            icon: Icons.female,
            isSelected: selectedGender == 'Female',
            hasError: error != null,
            onTap: () => onGenderSelected('Female'),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasError = false,
  }) {
    final borderColor = hasError && !isSelected
        ? Colors.red
        : isSelected
            ? AppTheme.authPrimaryColor
            : AppTheme.authPrimaryColor.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.authPrimaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
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
            Icon(icon,
                color: isSelected ? AppTheme.authPrimaryColor : Colors.grey[600],
                size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
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
