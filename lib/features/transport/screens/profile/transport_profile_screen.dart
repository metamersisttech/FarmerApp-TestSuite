/// Transport Profile Screen
///
/// View and edit transport provider profile.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/transport_profile_controller.dart';
import 'package:flutter_app/features/transport/services/transport_navigation_service.dart';

class TransportProfileScreen extends StatefulWidget {
  const TransportProfileScreen({super.key});

  @override
  State<TransportProfileScreen> createState() => _TransportProfileScreenState();
}

class _TransportProfileScreenState extends State<TransportProfileScreen> {
  late TransportProfileController _controller;
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _bioController = TextEditingController();
  int? _selectedRadius;
  bool _isEditing = false;

  final List<int> _radiusOptions = [25, 50, 75, 100];

  @override
  void initState() {
    super.initState();
    _controller = TransportProfileController();
    _controller.loadProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    _businessNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _populateForm() {
    final profile = _controller.profile;
    if (profile != null) {
      _businessNameController.text = profile.businessName;
      _bioController.text = profile.bio ?? '';
      _selectedRadius = profile.serviceRadiusKm;
    }
  }

  void _toggleEdit() {
    if (!_isEditing) {
      _populateForm();
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.updateProfile(
      businessName: _businessNameController.text.trim(),
      bio: _bioController.text.trim(),
      serviceRadiusKm: _selectedRadius ?? 50,
    );

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<TransportProfileController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              actions: [
                if (controller.profile != null)
                  IconButton(
                    icon: Icon(_isEditing ? Icons.close : Icons.edit),
                    onPressed: _toggleEdit,
                    tooltip: _isEditing ? 'Cancel' : 'Edit',
                  ),
              ],
            ),
            body: controller.isLoading && controller.profile == null
                ? const Center(child: CircularProgressIndicator())
                : controller.profile == null
                    ? _buildError(context, controller)
                    : _isEditing
                        ? _buildEditMode(context, controller)
                        : _buildViewMode(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildViewMode(
    BuildContext context,
    TransportProfileController controller,
  ) {
    final profile = controller.profile!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    profile.businessName.isNotEmpty
                        ? profile.businessName[0].toUpperCase()
                        : 'T',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.businessName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.local_shipping,
                      size: 20,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.totalTrips} trips',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Business info
          _buildInfoSection(
            context,
            title: 'Business Information',
            children: [
              _InfoRow(
                icon: Icons.business,
                label: 'Business Name',
                value: profile.businessName,
              ),
              if (profile.bio != null && profile.bio!.isNotEmpty)
                _InfoRow(
                  icon: Icons.description,
                  label: 'About',
                  value: profile.bio!,
                ),
              _InfoRow(
                icon: Icons.radar,
                label: 'Service Radius',
                value: '${profile.serviceRadiusKm} km',
              ),
              _InfoRow(
                icon: Icons.circle,
                label: 'Status',
                value: profile.available ? 'Available' : 'Offline',
                valueColor: profile.available ? Colors.green : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Documents section
          _buildInfoSection(
            context,
            title: 'Documents',
            children: [
              _DocumentRow(
                label: 'Driving License',
                number: profile.drivingLicenseNumber ?? 'Not provided',
                expiry: profile.drivingLicenseExpiry,
                isVerified: profile.drivingLicenseVerified,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    profile.isDocumentsVerified
                        ? Icons.verified
                        : Icons.pending,
                    color: profile.isDocumentsVerified
                        ? Colors.green
                        : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    profile.isDocumentsVerified
                        ? 'All documents verified'
                        : 'Documents pending verification',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: profile.isDocumentsVerified
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Vehicles section
          _buildInfoSection(
            context,
            title: 'Vehicles',
            trailing: TextButton(
              onPressed: () =>
                  TransportNavigationService.navigateToVehicleList(context),
              child: const Text('Manage'),
            ),
            children: [
              if (profile.vehicles.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No vehicles added yet'),
                  ),
                )
              else
                ...profile.vehicles.take(3).map((vehicle) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_shipping,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      '${vehicle.make} ${vehicle.model}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(vehicle.registrationNumber),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: vehicle.isActive
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        vehicle.isActive ? 'Active' : 'Inactive',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: vehicle.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }),
              if (profile.vehicles.length > 3)
                TextButton(
                  onPressed: () =>
                      TransportNavigationService.navigateToVehicleList(context),
                  child: Text('View all ${profile.vehicles.length} vehicles'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode(
    BuildContext context,
    TransportProfileController controller,
  ) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Business name
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                labelText: 'Business Name',
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Business name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'About (Optional)',
                hintText: 'Tell customers about your service...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Service radius
            DropdownButtonFormField<int>(
              value: _selectedRadius,
              decoration: const InputDecoration(
                labelText: 'Service Radius',
                prefixIcon: Icon(Icons.radar),
              ),
              items: _radiusOptions.map((radius) {
                return DropdownMenuItem(
                  value: radius,
                  child: Text('$radius km'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRadius = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select service radius';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Error message
            if (controller.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Save button
            ElevatedButton(
              onPressed: controller.isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    TransportProfileController controller,
  ) {
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
              'Failed to Load Profile',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage ?? 'An error occurred',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final String label;
  final String number;
  final DateTime? expiry;
  final bool isVerified;

  const _DocumentRow({
    required this.label,
    required this.number,
    this.expiry,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.description,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                number,
                style: theme.textTheme.bodyMedium,
              ),
              if (expiry != null)
                Text(
                  'Expires: ${expiry!.day}/${expiry!.month}/${expiry!.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isVerified
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVerified ? Icons.verified : Icons.pending,
                size: 14,
                color: isVerified ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                isVerified ? 'Verified' : 'Pending',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isVerified ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
