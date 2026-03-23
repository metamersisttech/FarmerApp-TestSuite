/// My Requests Screen
///
/// Dashboard showing requester's transport requests with status tabs.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/my_requests_controller.dart';
import 'package:flutter_app/features/transport/widgets/requester_request_card.dart';
import 'package:flutter_app/routes/app_routes.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  late MyRequestsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MyRequestsController();
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
      child: Consumer<MyRequestsController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Requests'),
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
                // Filter tabs
                _buildFilterTabs(context, controller),

                // Content
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.errorMessage != null
                          ? _buildError(context, controller)
                          : controller.hasRequests
                              ? _buildRequestsList(context, controller)
                              : _buildEmptyState(context, controller),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                AppRoutes.navigateTo(context, AppRoutes.transportCreateRequest);
              },
              icon: const Icon(Icons.add),
              label: const Text('New Request'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs(
    BuildContext context,
    MyRequestsController controller,
  ) {
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: MyRequestsFilter.values.map((filter) {
            final isSelected = controller.filter == filter;
            final count = _getFilterCount(controller, filter);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(filter.label),
                    if (count > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.2)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => controller.setFilter(filter),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  int _getFilterCount(MyRequestsController controller, MyRequestsFilter filter) {
    switch (filter) {
      case MyRequestsFilter.all:
        return controller.allRequests.length;
      case MyRequestsFilter.active:
        return controller.activeCount;
      case MyRequestsFilter.completed:
        return controller.completedCount;
      case MyRequestsFilter.cancelled:
        return controller.cancelledCount;
    }
  }

  Widget _buildRequestsList(
    BuildContext context,
    MyRequestsController controller,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshRequests();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: controller.requests.length,
        itemBuilder: (context, index) {
          final request = controller.requests[index];
          return RequesterRequestCard(
            request: request,
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.transportRequesterRequestDetail,
                arguments: request.requestId,
              );

              // Refresh if request was modified
              if (result == true) {
                controller.refreshRequests();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    MyRequestsController controller,
  ) {
    final theme = Theme.of(context);

    String title;
    String message;
    IconData icon;

    switch (controller.filter) {
      case MyRequestsFilter.all:
        title = 'No Requests Yet';
        message = 'Create your first transport request to get started.';
        icon = Icons.local_shipping_outlined;
        break;
      case MyRequestsFilter.active:
        title = 'No Active Requests';
        message = 'You don\'t have any active transport requests.';
        icon = Icons.pending_outlined;
        break;
      case MyRequestsFilter.completed:
        title = 'No Completed Requests';
        message = 'Your completed transport requests will appear here.';
        icon = Icons.check_circle_outline;
        break;
      case MyRequestsFilter.cancelled:
        title = 'No Cancelled Requests';
        message = 'You don\'t have any cancelled requests.';
        icon = Icons.cancel_outlined;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (controller.filter == MyRequestsFilter.all) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  AppRoutes.navigateTo(context, AppRoutes.transportCreateRequest);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Request'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    MyRequestsController controller,
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
