import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Consultation mode selector with 3 selectable tiles
class ConsultationModeSelector extends StatelessWidget {
  final String selectedMode;
  final String consultationFee;
  final String? videoCallFee;
  final ValueChanged<String> onModeSelected;

  const ConsultationModeSelector({
    super.key,
    required this.selectedMode,
    required this.consultationFee,
    this.videoCallFee,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consultation Mode',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ModeTile(
                icon: Icons.person,
                label: 'In-Person',
                fee: consultationFee,
                isSelected: selectedMode == 'in_person',
                onTap: () => onModeSelected('in_person'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ModeTile(
                icon: Icons.videocam,
                label: 'Video',
                fee: videoCallFee ?? consultationFee,
                isSelected: selectedMode == 'video',
                onTap: () => onModeSelected('video'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ModeTile(
                icon: Icons.phone,
                label: 'Phone',
                fee: videoCallFee ?? consultationFee,
                isSelected: selectedMode == 'phone',
                onTap: () => onModeSelected('phone'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String fee;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTile({
    required this.icon,
    required this.label,
    required this.fee,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[500],
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              fee,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
