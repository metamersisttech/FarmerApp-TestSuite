/// Transport Dashboard Screen
///
/// Main dashboard for transport providers showing availability, stats, and quick actions.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/transport_dashboard_controller.dart';
import 'package:flutter_app/features/transport/services/transport_navigation_service.dart';
import 'package:flutter_app/features/transport/widgets/availability_toggle.dart';

class TransportDashboardScreen extends StatefulWidget {
  const TransportDashboardScreen({super.key});

  @override
  State<TransportDashboardScreen> createState() => _TransportDashboardScreenState();
}

class _TransportDashboardScreenState extends State<TransportDashboardScreen> {
  late TransportDashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransportDashboardController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<TransportDashboardController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Transport Dashboard'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () => TransportNavigationService.navigateToProfile(context),
                  tooltip: 'Profile',
                ),
              ],
            ),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Profile header
                          if (controller.profile != null) _buildProfileHeader(context, controller),

                          const SizedBox(height: 20),

                          // Availability toggle
                          AvailabilityToggle(
                            isAvailable: controller.isAvailable,
                            isLoading: controller.isLoading,
                            onChanged: (_) => controller.toggleAvailability(),
                          ),

                          const SizedBox(height: 24),

                          // Stats cards
                          _buildStatsSection(context, controller),

                          const SizedBox(height: 24),

                          // Quick actions
                          _buildQuickActions(context),

                          const SizedBox(height: 24),

                          // Active jobs
                          if (controller.activeJobs.isNotEmpty) ...[
                            _buildSectionHeader(context, 'Active Jobs'),
                            const SizedBox(height: 12),
                            _buildActiveJobsList(context, controller),
                          ],

                          // Error message
                          if (controller.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            _buildErrorCard(context, controller.errorMessage!),
                          ],
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, TransportDashboardController controller) {
    final theme = Theme.of(context);
    final profile = controller.profile!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: profile.profileImageUrl != null
                  ? NetworkImage(profile.profileImageUrl!)
                  : null,
              child: profile.profileImageUrl == null
                  ? Text(
                      profile.initials,
                      style: theme.textTheme.titleLarge,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.formattedRating} rating',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${profile.totalTrips} trips',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (profile.isDocumentsVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, TransportDashboardController controller) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.work,
            value: '${controller.activeJobsCount}',
            label: 'Active Jobs',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.pending_actions,
            value: '${controller.pendingRequestsCount}',
            label: 'Pending',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            value: '${controller.completedTripsToday}',
            label: 'Today',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Quick Actions'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.search,
                label: 'View Requests',
                onTap: () => TransportNavigationService.navigateToNearbyRequests(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.local_shipping,
                label: 'My Vehicles',
                onTap: () => TransportNavigationService.navigateToVehicleList(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildActiveJobsList(BuildContext context, TransportDashboardController controller) {
    final theme = Theme.of(context);

    return Column(
      children: controller.activeJobs.take(3).map((job) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: job.statusColor.withValues(alpha: 0.2),
              child: Icon(
                Icons.local_shipping,
                color: job.statusColor,
              ),
            ),
            title: Text(
              job.routeDisplay,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(job.statusDisplay),
            trailing: Text(
              job.formattedFare,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            onTap: () => TransportNavigationService.navigateToTripProgress(
              context,
              job.requestId,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
