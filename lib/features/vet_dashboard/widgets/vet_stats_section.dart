import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Dashboard stats section showing appointment metric cards.
class VetStatsSection extends StatelessWidget {
  final int pendingCount;
  final int confirmedCount;
  final int completedCount;

  const VetStatsSection({
    super.key,
    required this.pendingCount,
    required this.confirmedCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.pending_actions,
            count: pendingCount,
            label: 'Pending',
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.check_circle_outline,
            count: confirmedCount,
            label: 'Confirmed',
            color: AppTheme.authPrimaryColor,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.task_alt,
            count: completedCount,
            label: 'Completed',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
