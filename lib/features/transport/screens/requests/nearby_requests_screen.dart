/// Nearby Requests Screen
///
/// Displays pending transport requests in provider's area.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/nearby_requests_controller.dart';
import 'package:flutter_app/features/transport/services/transport_navigation_service.dart';
import 'package:flutter_app/features/transport/widgets/transport_request_card.dart';

class NearbyRequestsScreen extends StatefulWidget {
  const NearbyRequestsScreen({super.key});

  @override
  State<NearbyRequestsScreen> createState() => _NearbyRequestsScreenState();
}

class _NearbyRequestsScreenState extends State<NearbyRequestsScreen> {
  late NearbyRequestsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NearbyRequestsController();
    _controller.loadRequests();
    _controller.startAutoRefresh();
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
      child: Consumer<NearbyRequestsController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Nearby Requests'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.refreshRequests,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            body: Column(
              children: [
                // Filters
                _buildFilters(context, controller),

                // Content
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.errorMessage != null
                          ? _buildError(context, controller)
                          : controller.hasRequests
                              ? _buildRequestsList(context, controller)
                              : _buildEmptyState(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context, NearbyRequestsController controller) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distance filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DistanceFilter.values.map((filter) {
                final isSelected = controller.distanceFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    onSelected: (_) => controller.setDistanceFilter(filter),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Sort options
          Row(
            children: [
              Text(
                'Sort by:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              _SortChip(
                label: 'Distance',
                isSelected: controller.sortBy == RequestSortBy.distance,
                ascending: controller.sortAscending,
                onTap: () {
                  if (controller.sortBy == RequestSortBy.distance) {
                    controller.toggleSortDirection();
                  } else {
                    controller.setSortBy(RequestSortBy.distance, ascending: true);
                  }
                },
              ),
              const SizedBox(width: 8),
              _SortChip(
                label: 'Date',
                isSelected: controller.sortBy == RequestSortBy.pickupDate,
                ascending: controller.sortAscending,
                onTap: () {
                  if (controller.sortBy == RequestSortBy.pickupDate) {
                    controller.toggleSortDirection();
                  } else {
                    controller.setSortBy(RequestSortBy.pickupDate, ascending: true);
                  }
                },
              ),
              const SizedBox(width: 8),
              _SortChip(
                label: 'Fare',
                isSelected: controller.sortBy == RequestSortBy.fare,
                ascending: controller.sortAscending,
                onTap: () {
                  if (controller.sortBy == RequestSortBy.fare) {
                    controller.toggleSortDirection();
                  } else {
                    controller.setSortBy(RequestSortBy.fare, ascending: false);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context, NearbyRequestsController controller) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshRequests();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: controller.requests.length,
        itemBuilder: (context, index) {
          final request = controller.requests[index];
          return TransportRequestCard(
            request: request,
            onTap: () => TransportNavigationService.navigateToRequestDetail(
              context,
              request,
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
              Icons.search_off,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Requests Nearby',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new transport requests in your area.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _controller.refreshRequests,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, NearbyRequestsController controller) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Requests',
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
              onPressed: controller.loadRequests,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool ascending;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.ascending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                ascending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
