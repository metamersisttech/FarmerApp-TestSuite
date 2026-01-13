import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Animal Stats Row for Animal Detail Page
///
/// Displays 4 columns: Age, Weight, Milk/Day, Lactation.
class AnimalStatsRow extends StatelessWidget {
  final String? age;
  final String? weight;
  final String? milkPerDay;
  final String? lactation;

  const AnimalStatsRow({
    super.key,
    this.age,
    this.weight,
    this.milkPerDay,
    this.lactation,
  });

  @override
  Widget build(BuildContext context) {
    final stats = <_StatItem>[];

    if (age != null) {
      stats.add(_StatItem(value: age!, label: 'Age'));
    }
    if (weight != null) {
      stats.add(_StatItem(value: weight!, label: 'Weight'));
    }
    if (milkPerDay != null) {
      stats.add(_StatItem(value: milkPerDay!, label: 'Milk/Day'));
    }
    if (lactation != null) {
      stats.add(_StatItem(value: lactation!, label: 'Lactation'));
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: stats.map((stat) {
          return Expanded(
            child: _StatBox(item: stat),
          );
        }).toList(),
      ),
    );
  }
}

/// Data class for a stat item
class _StatItem {
  final String value;
  final String label;

  _StatItem({required this.value, required this.label});
}

/// Individual stat box widget
class _StatBox extends StatelessWidget {
  final _StatItem item;

  const _StatBox({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
