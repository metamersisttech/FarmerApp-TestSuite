/// Requester Request Detail Screen
///
/// Shows detailed view of a transport request with actions.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/requester_request_detail_controller.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/widgets/provider_info_card.dart';
import 'package:flutter_app/routes/app_routes.dart';

class RequesterRequestDetailScreen extends StatefulWidget {
  final int requestId;

  const RequesterRequestDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<RequesterRequestDetailScreen> createState() =>
      _RequesterRequestDetailScreenState();
}

class _RequesterRequestDetailScreenState
    extends State<RequesterRequestDetailScreen> {
  late RequesterRequestDetailController _controller;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = RequesterRequestDetailController();
    _controller.loadRequest(widget.requestId);
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
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop && _hasChanges) {
            Navigator.of(context).pop(true);
          }
        },
        child: Consumer<RequesterRequestDetailController>(
          builder: (context, controller, _) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  controller.request != null
                      ? 'Request #${controller.request!.requestId}'
                      : 'Request Details',
                ),
                actions: [
                  if (controller.request != null)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: controller.refreshRequest,
                      tooltip: 'Refresh',
                    ),
                ],
              ),
              body: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.errorMessage != null
                      ? _buildError(context, controller)
                      : controller.request != null
                          ? _buildContent(context, controller)
                          : const Center(child: Text('Request not found')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    RequesterRequestDetailController controller,
  ) {
    final request = controller.request!;

    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshRequest();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            _buildStatusHeader(context, request),

            const SizedBox(height: 24),

            // Fare approval banner (if needed)
            if (controller.needsFareApproval)
              _buildFareApprovalBanner(context, controller),

            // Provider info (if accepted)
            if (controller.hasProvider) ...[
              ProviderInfoCard(
                provider: request.transportProvider!,
                vehicle: request.vehicle,
                onChatTap: controller.canChat
                    ? () {
                        AppRoutes.navigateTo(
                          context,
                          AppRoutes.transportChat,
                          arguments: {
                            'requestId': request.requestId,
                            'otherUserName':
                                request.transportProvider!.user?.displayName ??
                                    'Provider',
                          },
                        );
                      }
                    : null,
              ),
              const SizedBox(height: 16),
            ],

            // Route card
            _buildRouteCard(context, request),

            const SizedBox(height: 16),

            // Details card
            _buildDetailsCard(context, request),

            const SizedBox(height: 16),

            // Fare card
            _buildFareCard(context, request),

            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildNotesCard(context, request),
            ],

            // Action buttons
            const SizedBox(height: 24),
            _buildActionButtons(context, controller),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, TransportRequestModel request) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: request.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: request.statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: request.statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(request.statusEnum),
              color: request.statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.statusDisplay,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: request.statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(request.statusEnum),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(TransportRequestStatus status) {
    switch (status) {
      case TransportRequestStatus.pending:
        return Icons.hourglass_empty;
      case TransportRequestStatus.accepted:
        return Icons.check_circle;
      case TransportRequestStatus.inProgress:
        return Icons.directions_car;
      case TransportRequestStatus.inTransit:
        return Icons.local_shipping;
      case TransportRequestStatus.completed:
        return Icons.done_all;
      case TransportRequestStatus.cancelled:
        return Icons.cancel;
      case TransportRequestStatus.expired:
        return Icons.timer_off;
    }
  }

  String _getStatusDescription(TransportRequestStatus status) {
    switch (status) {
      case TransportRequestStatus.pending:
        return 'Waiting for a provider to accept your request';
      case TransportRequestStatus.accepted:
        return 'A provider has accepted. Review the proposed fare.';
      case TransportRequestStatus.inProgress:
        return 'Provider is on the way to pickup location';
      case TransportRequestStatus.inTransit:
        return 'Your animals are being transported';
      case TransportRequestStatus.completed:
        return 'Delivery completed successfully';
      case TransportRequestStatus.cancelled:
        return 'This request has been cancelled';
      case TransportRequestStatus.expired:
        return 'This request has expired';
    }
  }

  Widget _buildFareApprovalBanner(
    BuildContext context,
    RequesterRequestDetailController controller,
  ) {
    final theme = Theme.of(context);
    final request = controller.request!;

    return Card(
      color: theme.colorScheme.errorContainer,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.price_check,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Fare Approval Required',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'The provider has proposed a fare of ${request.formattedProposedFare}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(context, controller),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onErrorContainer,
                      side: BorderSide(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    child: const Text('Cancel Request'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: controller.isApprovingFare
                        ? null
                        : () => _approveFare(context, controller),
                    child: controller.isApprovingFare
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Approve Fare'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, TransportRequestModel request) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.route, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Route',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.formattedDistance,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.shade700, width: 2),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.shade700, width: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.sourceAddress,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Delivery',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.destinationAddress,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, TransportRequestModel request) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              icon: Icons.pets,
              label: 'Cargo',
              value: request.cargoSummary,
            ),
            _buildDetailRow(
              context,
              icon: Icons.calendar_today,
              label: 'Pickup Date',
              value: request.formattedPickupDate,
            ),
            if (request.formattedPickupTime != null)
              _buildDetailRow(
                context,
                icon: Icons.access_time,
                label: 'Pickup Time',
                value: request.formattedPickupTime!,
              ),
            _buildDetailRow(
              context,
              icon: Icons.schedule,
              label: 'Created',
              value: _formatDateTime(request.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareCard(BuildContext context, TransportRequestModel request) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Fare',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              icon: Icons.calculate,
              label: 'Estimated',
              value: request.formattedFareRange,
            ),
            if (request.proposedFare != null)
              _buildDetailRow(
                context,
                icon: Icons.local_offer,
                label: 'Proposed',
                value: request.formattedProposedFare!,
              ),
            if (request.finalFare != null)
              _buildDetailRow(
                context,
                icon: Icons.check_circle,
                label: 'Final',
                value: request.formattedFinalFare!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, TransportRequestModel request) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Notes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              request.notes!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    RequesterRequestDetailController controller,
  ) {
    final request = controller.request!;

    // Determine which buttons to show based on status
    switch (request.statusEnum) {
      case TransportRequestStatus.pending:
        return FilledButton.tonalIcon(
          onPressed: controller.isCancelling
              ? null
              : () => _showCancelDialog(context, controller),
          icon: controller.isCancelling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cancel),
          label: const Text('Cancel Request'),
        );

      case TransportRequestStatus.accepted:
        // Fare approval banner handles this
        return const SizedBox.shrink();

      case TransportRequestStatus.inTransit:
        return FilledButton.icon(
          onPressed: () {
            AppRoutes.navigateTo(
              context,
              AppRoutes.transportDeliveryConfirmation,
              arguments: request.requestId,
            );
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('Confirm Delivery'),
        );

      case TransportRequestStatus.completed:
        if (request.providerRating == null) {
          return FilledButton.icon(
            onPressed: () {
              AppRoutes.navigateTo(
                context,
                AppRoutes.transportDeliveryConfirmation,
                arguments: request.requestId,
              );
            },
            icon: const Icon(Icons.star),
            label: const Text('Rate Provider'),
          );
        }
        return const SizedBox.shrink();

      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    RequesterRequestDetailController controller,
  ) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this request?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await controller.cancelRequest(
        reason: reasonController.text.isNotEmpty ? reasonController.text : null,
      );

      if (success && mounted) {
        _hasChanges = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (controller.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _approveFare(
    BuildContext context,
    RequesterRequestDetailController controller,
  ) async {
    final success = await controller.approveFare();

    if (success && mounted) {
      _hasChanges = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fare approved! The provider will begin the trip soon.'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (controller.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildError(
    BuildContext context,
    RequesterRequestDetailController controller,
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
              'Failed to Load Request',
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
              onPressed: () => controller.loadRequest(widget.requestId),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
