import 'package:flutter/material.dart';

/// Animal Info Card Widget
class AnimalInfoCard extends StatelessWidget {
  final Map<String, dynamic> listingData;
  final double Function(dynamic) parseNumber;

  const AnimalInfoCard({
    super.key,
    required this.listingData,
    required this.parseNumber,
  });

  @override
  Widget build(BuildContext context) {
    final title = listingData['title']?.toString() ?? 'Animal Listing';
    final gender = listingData['gender']?.toString() ?? '';

    final ageMonths = parseNumber(listingData['age_months']);
    final weightKg = parseNumber(listingData['weight_kg']);

    final years = (ageMonths / 12).floor();
    final ageDisplay = years > 0 ? '$years Years' : '${ageMonths.toInt()} Months';

    final infoParts = <String>[];
    if (gender.isNotEmpty) {
      infoParts.add(gender[0].toUpperCase() + gender.substring(1));
    }
    if (ageMonths > 0) infoParts.add(ageDisplay);
    if (weightKg > 0) {
      infoParts.add(
          '${weightKg.toStringAsFixed(weightKg.truncateToDouble() == weightKg ? 0 : 1)} kg');
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (infoParts.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    infoParts.join(' • '),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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
