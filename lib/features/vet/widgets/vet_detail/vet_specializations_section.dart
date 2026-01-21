import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Specializations section displaying animal types and services
class VetSpecializationsSection extends StatelessWidget {
  final List<String> animalTypes;
  final List<String> services;

  const VetSpecializationsSection({
    super.key,
    this.animalTypes = const [],
    this.services = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (animalTypes.isEmpty && services.isEmpty) return const SizedBox.shrink();

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
                Icons.medical_services_outlined,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                'Specializations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          // Animal types
          if (animalTypes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Animals Treated',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: animalTypes.map((animal) {
                return _buildChip(animal, _getAnimalIcon(animal));
              }).toList(),
            ),
          ],
          // Services
          if (services.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Services Offered',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: services.map((service) {
                return _buildServiceChip(service);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  IconData _getAnimalIcon(String animal) {
    switch (animal.toLowerCase()) {
      case 'cow':
        return Icons.pets;
      case 'buffalo':
        return Icons.pets;
      case 'goat':
        return Icons.pets;
      case 'sheep':
        return Icons.pets;
      case 'horse':
        return Icons.pets;
      case 'poultry':
        return Icons.egg_outlined;
      default:
        return Icons.pets;
    }
  }
}
