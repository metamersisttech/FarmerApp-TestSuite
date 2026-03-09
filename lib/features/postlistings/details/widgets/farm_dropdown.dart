import 'package:flutter/material.dart';
import 'package:flutter_app/features/postlistings/details/controllers/details_controller.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Farm Dropdown Widget
class FarmDropdown extends StatelessWidget {
  final DetailsController controller;
  final TextEditingController searchController;
  final int? selectedFarmId;
  final String? error;
  final Function(int? farmId, String? farmName) onFarmSelected;
  final Function(Map<String, dynamic>?) onFarmCreated;
  final Function(int farmId)? onFarmEdit;
  final Function(int farmId)? onFarmDelete;

  const FarmDropdown({
    super.key,
    required this.controller,
    required this.searchController,
    required this.selectedFarmId,
    required this.error,
    required this.onFarmSelected,
    required this.onFarmCreated,
    this.onFarmEdit,
    this.onFarmDelete,
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
    if (controller.isLoadingFarms) {
      return _buildLoadingIndicator('Loading farms...');
    }

    if (controller.farms.isEmpty) {
      return _buildNoFarmsBox(context);
    }

    return DropdownMenu<int>(
      controller: searchController,
      width: MediaQuery.of(context).size.width - 40,
      hintText: 'Select or search farm',
      leadingIcon: const Icon(Icons.agriculture, size: 20),
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
      dropdownMenuEntries: [
        ...controller.farms
            .where((farm) => farm['farm_id'] != null)
            .map((farm) {
          final id = farm['farm_id'];
          final farmId = id is int ? id : int.tryParse(id.toString()) ?? 0;
          final farmName = farm['name']?.toString() ?? 'Farm $farmId';
          return DropdownMenuEntry<int>(
            value: farmId,
            label: farmName,
            trailingIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 18,
                    color: AppTheme.authPrimaryColor,
                  ),
                  onPressed: () {
                    _handleEditFarm(context, farmId);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Edit farm',
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 18,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _handleDeleteFarm(context, farmId, farmName);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Delete farm',
                ),
              ],
            ),
          );
        }),
        DropdownMenuEntry<int>(
          value: -1,
          label: 'Create Farm',
          leadingIcon: Icon(Icons.add_circle_outline,
              color: AppTheme.authPrimaryColor, size: 20),
          style: MenuItemButton.styleFrom(
            foregroundColor: AppTheme.authPrimaryColor,
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == -1) {
          searchController.clear();
          final result = await Navigator.pushNamed(context, AppRoutes.createFarm);
          if (result != null && result is Map<String, dynamic>) {
            onFarmCreated(result);
          }
        } else if (value != null) {
          final selectedFarm = controller.farms.firstWhere(
            (farm) {
              final id = farm['farm_id'];
              final farmId = id is int ? id : int.tryParse(id.toString()) ?? 0;
              return farmId == value;
            },
            orElse: () => {'name': 'Farm $value'},
          );
          final farmName = selectedFarm['name']?.toString();
          onFarmSelected(value, farmName);
          searchController.text = farmName ?? '';
        }
      },
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

  Widget _buildNoFarmsBox(BuildContext context) {
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
              "You have no farms",
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
              final result = await Navigator.pushNamed(context, AppRoutes.createFarm);
              if (result != null && result is Map<String, dynamic>) {
                onFarmCreated(result);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.authPrimaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle edit farm action
  void _handleEditFarm(BuildContext context, int farmId) {
    if (onFarmEdit != null) {
      onFarmEdit!(farmId);
    } else {
      // Default behavior: navigate to edit farm page
      Navigator.pushNamed(
        context,
        AppRoutes.createFarm,
        arguments: {'farmId': farmId, 'isEdit': true},
      );
    }
  }

  /// Handle delete farm action
  void _handleDeleteFarm(BuildContext context, int farmId, String farmName) {
    if (onFarmDelete != null) {
      onFarmDelete!(farmId);
    } else {
      // Default behavior: show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Delete Farm'),
            content: Text('Are you sure you want to delete "$farmName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // Trigger delete action through callback
                  if (onFarmDelete != null) {
                    onFarmDelete!(farmId);
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    }
  }
}
