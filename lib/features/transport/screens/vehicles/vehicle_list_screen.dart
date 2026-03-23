/// Vehicle List Screen
///
/// Displays all vehicles for a transport provider.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/vehicle_controller.dart';
import 'package:flutter_app/features/transport/services/transport_navigation_service.dart';
import 'package:flutter_app/features/transport/widgets/vehicle_card.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  late VehicleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VehicleController();
    _controller.loadVehicles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDelete(int vehicleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text(
          'Are you sure you want to delete this vehicle? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _controller.deleteVehicle(vehicleId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<VehicleController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Vehicles'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.refreshVehicles,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.errorMessage != null
                    ? _buildError(context, controller)
                    : controller.hasVehicles
                        ? _buildVehiclesList(context, controller)
                        : _buildEmptyState(context),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  '/transport/vehicles/form',
                );
                // Refresh list when returning
                controller.refreshVehicles();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehiclesList(BuildContext context, VehicleController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshVehicles,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: controller.vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = controller.vehicles[index];
          return VehicleCard(
            vehicle: vehicle,
            onTap: () => TransportNavigationService.navigateToEditVehicle(
              context,
              vehicle.vehicleId,
            ),
            onEdit: () => TransportNavigationService.navigateToEditVehicle(
              context,
              vehicle.vehicleId,
            ),
            onDelete: () => _handleDelete(vehicle.vehicleId),
            onToggleActive: (value) => controller.toggleVehicleActive(
              vehicle.vehicleId,
              value,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Vehicles Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a vehicle to start accepting transport requests.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => TransportNavigationService.navigateToAddVehicle(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, VehicleController controller) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Vehicles',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.loadVehicles,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
