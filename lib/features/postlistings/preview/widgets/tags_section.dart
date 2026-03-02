import 'package:flutter/material.dart';

/// Tags Section Widget
class TagsSection extends StatelessWidget {
  final Map<String, dynamic> listingData;

  const TagsSection({
    super.key,
    required this.listingData,
  });

  @override
  Widget build(BuildContext context) {
    final vaccinationStatus = listingData['vaccination_status']?.toString();
    final pashuAadhar = listingData['pashu_aadhar']?.toString();
    final healthStatus = listingData['health_status']?.toString();

    final tags = <Widget>[];

    if (healthStatus != null && healthStatus.isNotEmpty && healthStatus != 'null') {
      tags.add(_buildTag(
        healthStatus[0].toUpperCase() + healthStatus.substring(1),
        Colors.blue,
      ));
    }

    if (vaccinationStatus != null &&
        vaccinationStatus.toLowerCase() == 'vaccinated') {
      tags.add(_buildTag('Vaccinated', Colors.green, icon: Icons.check_circle));
    }

    if (pashuAadhar != null && pashuAadhar.isNotEmpty && pashuAadhar != 'null') {
      tags.add(_buildTag('Pashu Aadhaar', Colors.orange, icon: Icons.credit_card));
    }

    if (tags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags,
      ),
    );
  }

  Widget _buildTag(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
