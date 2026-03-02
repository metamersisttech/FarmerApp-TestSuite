import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Health Status Dropdown Widget
class HealthStatusDropdown extends StatelessWidget {
  final String? healthStatus;
  final List<String> healthStatusOptions;
  final Function(String?) onHealthStatusSelected;
  final String Function(String) formatHealthStatus;

  const HealthStatusDropdown({
    super.key,
    required this.healthStatus,
    required this.healthStatusOptions,
    required this.onHealthStatusSelected,
    required this.formatHealthStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Only use healthStatus if it's in the valid options list, otherwise use null
    final validHealthStatus = healthStatus != null && healthStatusOptions.contains(healthStatus)
        ? healthStatus
        : null;
    
    return DropdownButtonFormField<String>(
      value: validHealthStatus, // Use value instead of initialValue
      hint: const Text('Select health status'),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.authPrimaryColor.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.authPrimaryColor.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.authPrimaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: healthStatusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(formatHealthStatus(status)),
        );
      }).toList(),
      onChanged: onHealthStatusSelected,
    );
  }
}
