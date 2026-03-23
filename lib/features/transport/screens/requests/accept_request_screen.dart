/// Accept Request Screen
///
/// Allows provider to accept a request with vehicle selection.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/accept_request_controller.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/services/transport_navigation_service.dart';
import 'package:flutter_app/features/transport/widgets/vehicle_card.dart';

class AcceptRequestScreen extends StatefulWidget {
  final TransportRequestModel request;

  const AcceptRequestScreen({
    super.key,
    required this.request,
  });

  @override
  State<AcceptRequestScreen> createState() => _AcceptRequestScreenState();
}

class _AcceptRequestScreenState extends State<AcceptRequestScreen> {
  late AcceptRequestController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AcceptRequestController();
    _controller.setRequest(widget.request);
    _controller.loadVehicles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAccept() async {
    final result = await _controller.acceptRequest();
    if (result != null && mounted) {
      // Show success and navigate to trip progress
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      TransportNavigationService.navigateToTripProgress(
        context,
        result.requestId,
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Acceptance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'By accepting this request, you commit to completing this transport job.',
            ),
            const SizedBox(height: 16),
            if (_controller.capacityWarning != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _controller.capacityWarning!,
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAccept();
            },
            child: const Text('Accept Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<AcceptRequestController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Accept Request'),
            ),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Request summary
                      _buildRequestSummary(context),

                      const Divider(height: 1),

                      // Vehicle selection
                      Expanded(
                        child: _buildVehicleSelection(context, controller),
                      ),

                      // Error message
                      if (controller.errorMessage != null)
                        _buildError(context, controller.errorMessage!),
                    ],
                  ),
            bottomNavigationBar: _buildBottomBar(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildRequestSummary(BuildContext context) {
    final theme = Theme.of(context);
    final request = widget.request;

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.sourceAddress,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 3),
            child: Icon(Icons.arrow_downward, size: 16),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.destinationAddress,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Details row
          Row(
            children: [
              _InfoChip(icon: Icons.route, label: request.formattedDistance),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.scale, label: request.formattedWeight),
              const Spacer(),
              Text(
                request.formattedFareRange,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelection(
    BuildContext context,
    AcceptRequestController controller,
  ) {
    final theme = Theme.of(context);

    if (!controller.hasActiveVehicles) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_shipping,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Vehicles',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please add or activate a vehicle to accept requests.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    TransportNavigationService.navigateToVehicleList(context),
                icon: const Icon(Icons.add),
                label: const Text('Manage Vehicles'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Vehicle',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a vehicle for this transport job',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Vehicle list
          ...controller.activeVehicles.map((vehicle) {
            return VehicleSelectorCard(
              vehicle: vehicle,
              isSelected: controller.selectedVehicle?.vehicleId == vehicle.vehicleId,
              estimatedWeight: widget.request.estimatedWeightKg,
              onTap: () => controller.selectVehicle(vehicle),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    AcceptRequestController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: controller.hasSelectedVehicle && !controller.isAccepting
              ? _showConfirmationDialog
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isAccepting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Accept Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
