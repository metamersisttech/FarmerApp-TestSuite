import 'package:flutter/material.dart';

class LocationRequirementBanner extends StatelessWidget {
  final bool hasLocationPermission;
  final bool hasFarm;
  final bool farmHasCoordinates;
  final bool isChecking;
  final bool hasManualLocation;
  final VoidCallback? onEnableLocation;

  const LocationRequirementBanner({
    super.key,
    required this.hasLocationPermission,
    required this.hasFarm,
    required this.farmHasCoordinates,
    required this.isChecking,
    required this.hasManualLocation,
    this.onEnableLocation,
  });

  @override
  Widget build(BuildContext context) {
    if (isChecking) return const SizedBox.shrink();
    if (hasLocationPermission || farmHasCoordinates || hasManualLocation) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Location access helps buyers find your listing.',
              style: TextStyle(color: Colors.amber.shade800, fontSize: 13),
            ),
          ),
          if (onEnableLocation != null)
            TextButton(
              onPressed: onEnableLocation,
              child: const Text('Enable'),
            ),
        ],
      ),
    );
  }
}
