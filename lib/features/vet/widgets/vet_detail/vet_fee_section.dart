import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Fee section displaying consultation fees
class VetFeeSection extends StatelessWidget {
  final double consultationFee;
  final double? videoCallFee;
  final double? homeVisitFee;

  const VetFeeSection({
    super.key,
    required this.consultationFee,
    this.videoCallFee,
    this.homeVisitFee,
  });

  @override
  Widget build(BuildContext context) {
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
                Icons.payments_outlined,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                'Consultation Fees',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fee items
          Row(
            children: [
              Expanded(
                child: _buildFeeItem(
                  icon: Icons.local_hospital,
                  label: 'Clinic Visit',
                  fee: consultationFee,
                  isPrimary: true,
                ),
              ),
              if (videoCallFee != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeeItem(
                    icon: Icons.videocam_outlined,
                    label: 'Video Call',
                    fee: videoCallFee!,
                  ),
                ),
              ],
              if (homeVisitFee != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeeItem(
                    icon: Icons.home_outlined,
                    label: 'Home Visit',
                    fee: homeVisitFee!,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem({
    required IconData icon,
    required String label,
    required double fee,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: isPrimary ? AppTheme.primaryColor : Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            '\u20B9${fee.toInt()}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isPrimary ? AppTheme.primaryColor : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
