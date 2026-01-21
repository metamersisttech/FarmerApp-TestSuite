import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Stats row displaying rating, reviews, experience, and distance
class VetStatsRow extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final double distanceKm;

  const VetStatsRow({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.star,
            iconColor: Colors.amber,
            value: rating.toString(),
            label: 'Rating',
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.rate_review_outlined,
            iconColor: AppTheme.primaryColor,
            value: reviewCount.toString(),
            label: 'Reviews',
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.work_outline,
            iconColor: Colors.blue,
            value: '$experienceYears yrs',
            label: 'Experience',
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.location_on_outlined,
            iconColor: Colors.red[400]!,
            value: '$distanceKm km',
            label: 'Distance',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey[200],
    );
  }
}
