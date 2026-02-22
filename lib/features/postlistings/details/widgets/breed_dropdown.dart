import 'package:flutter/material.dart';
import 'package:flutter_app/features/postlistings/details/controllers/details_controller.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Breed Dropdown Widget
class BreedDropdown extends StatelessWidget {
  final DetailsController controller;
  final TextEditingController searchController;
  final String? selectedBreed;
  final String? selectedAnimalType;
  final String? error;
  final Function(String?) onBreedSelected;

  const BreedDropdown({
    super.key,
    required this.controller,
    required this.searchController,
    required this.selectedBreed,
    required this.selectedAnimalType,
    required this.error,
    required this.onBreedSelected,
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
    if (selectedAnimalType == null) {
      return _buildDisabledField('Please select animal type first');
    }

    if (controller.isLoadingBreeds) {
      return _buildLoadingIndicator('Loading breeds...');
    }

    if (controller.allBreeds.isEmpty) {
      return _buildErrorBox('No breeds available for this species');
    }

    return DropdownMenu<String>(
      controller: searchController,
      width: MediaQuery.of(context).size.width - 40,
      hintText: 'Select or search breed',
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
      dropdownMenuEntries: controller.allBreeds.map((breed) {
        return DropdownMenuEntry<String>(
          value: breed,
          label: breed,
        );
      }).toList(),
      onSelected: onBreedSelected,
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

  Widget _buildErrorBox(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledField(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
