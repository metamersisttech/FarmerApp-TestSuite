import 'package:flutter/material.dart';

/// Location requirement banner showing location source status
class LocationRequirementBanner extends StatelessWidget {
  final bool hasLocationPermission;
  final bool hasFarm;
  final bool farmHasCoordinates;
  final bool isChecking;
  final bool hasManualLocation;
  final VoidCallback onEnableLocation;

  const LocationRequirementBanner({
    super.key,
    required this.hasLocationPermission,
    required this.hasFarm,
    required this.farmHasCoordinates,
    required this.isChecking,
    required this.hasManualLocation,
    required this.onEnableLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the actual location source status
    final isValid = (hasFarm && farmHasCoordinates) || 
                    hasLocationPermission || 
                    hasManualLocation;

    // Show loading state while checking permission
    if (isChecking) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              'Checking location access...',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Determine the status message
    String statusMessage;
    if (hasFarm && farmHasCoordinates) {
      statusMessage = 'Using farm location';
    } else if (hasFarm && !farmHasCoordinates && hasManualLocation) {
      statusMessage = 'Using selected location';
    } else if (hasFarm && !farmHasCoordinates && hasLocationPermission) {
      statusMessage = 'Farm has no location - using current location';
    } else if (hasFarm && !farmHasCoordinates) {
      statusMessage = 'Farm has no location - please select a location';
    } else if (hasLocationPermission) {
      statusMessage = 'Using current location';
    } else if (hasManualLocation) {
      statusMessage = 'Using selected location';
    } else {
      statusMessage = 'Select a farm or enable location access';
    }

    // Show warning state if farm lacks coordinates and no fallback
    final showWarning = hasFarm && 
                        !farmHasCoordinates && 
                        !hasLocationPermission && 
                        !hasManualLocation;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid 
                ? Icons.check_circle 
                : (showWarning ? Icons.warning : Icons.info_outline),
            color: isValid ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              statusMessage,
              style: TextStyle(
                fontSize: 13,
                color: isValid ? Colors.green.shade700 : Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!isValid && !hasLocationPermission)
            TextButton(
              onPressed: onEnableLocation,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Enable'),
            ),
        ],
      ),
    );
  }
}
