import 'package:flutter/material.dart';
import 'package:flutter_app/features/postlistings/details/controllers/details_controller.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Animal Type Dropdown Widget
class AnimalTypeDropdown extends StatelessWidget {
  final DetailsController controller;
  final TextEditingController searchController;
  final String? selectedAnimalType;
  final String? error;
  final Function(String?) onAnimalTypeSelected;

  const AnimalTypeDropdown({
    super.key,
    required this.controller,
    required this.searchController,
    required this.selectedAnimalType,
    required this.error,
    required this.onAnimalTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: error != null
                ? Colors.red.withOpacity(0.1)
                : AppTheme.authPrimaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildDropdownContent(context),
    );
  }

  Widget _buildDropdownContent(BuildContext context) {
    if (controller.isLoadingAnimals) {
      return _buildLoadingIndicator('Loading animals...');
    }

    if (controller.allAnimals.isEmpty) {
      return _buildInfoBox('No animals available in catalog');
    }

    return DropdownMenu<String>(
      controller: searchController,
      width: MediaQuery.of(context).size.width - 40,
      hintText: 'Select or search animal type',
      leadingIcon: const Icon(Icons.pets, size: 20),
      menuHeight: 300,
      enableFilter: true,
      enableSearch: true,
      requestFocusOnTap: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: error != null ? Colors.red : AppTheme.authPrimaryColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: error != null ? Colors.red : AppTheme.authPrimaryColor.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: error != null ? Colors.red : AppTheme.authPrimaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      dropdownMenuEntries: controller.allAnimals.map((animal) {
        return DropdownMenuEntry<String>(
          value: animal,
          label: animal,
        );
      }).toList(),
      onSelected: onAnimalTypeSelected,
    );
  }

  Widget _buildLoadingIndicator(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.authPrimaryColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.authPrimaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
