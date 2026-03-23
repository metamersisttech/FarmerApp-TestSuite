/// Trip Progress Screen
///
/// Manages trip lifecycle: fare negotiation, pickup, transit.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/trip_progress_controller.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/mixins/fare_proposal_state_mixin.dart';
import 'package:flutter_app/features/transport/services/transport_navigation_service.dart';

class TripProgressScreen extends StatefulWidget {
  final int requestId;

  const TripProgressScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<TripProgressScreen> createState() => _TripProgressScreenState();
}

class _TripProgressScreenState extends State<TripProgressScreen>
    with FareProposalStateMixin {
  late TripProgressController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TripProgressController();
    _controller.initializeWithRequestId(widget.requestId);
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
      child: Consumer<TripProgressController>(
        builder: (context, controller, _) {
          // Initialize fare range when request loads
          if (controller.request != null) {
            setFareRange(
              controller.request!.estimatedFareMin,
              controller.request!.estimatedFareMax,
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Trip Progress'),
              actions: [
                if (controller.hasRequest)
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () => TransportNavigationService.navigateToChat(
                      context,
                      controller.request!.requestId,
                    ),
                    tooltip: 'Chat',
                  ),
              ],
            ),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.hasRequest
                    ? _buildContent(context, controller)
                    : _buildErrorState(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TripProgressController controller) {
    final request = controller.request!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status badge
          _buildStatusBadge(context, request),

          const SizedBox(height: 20),

          // Route summary
          _buildRouteSummary(context, request),

          const SizedBox(height: 20),

          // Status-specific content
          _buildStatusContent(context, controller, request),

          // Error message
          if (controller.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildError(context, controller.errorMessage!),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, TransportRequestModel request) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: request.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: request.statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(request.statusEnum),
            color: request.statusColor,
          ),
          const SizedBox(width: 8),
          Text(
            request.statusDisplay,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: request.statusColor,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(TransportRequestStatus status) {
    switch (status) {
      case TransportRequestStatus.pending:
        return Icons.pending;
      case TransportRequestStatus.accepted:
        return Icons.check_circle;
      case TransportRequestStatus.inProgress:
        return Icons.local_shipping;
      case TransportRequestStatus.inTransit:
        return Icons.local_shipping;
      case TransportRequestStatus.completed:
        return Icons.task_alt;
      case TransportRequestStatus.cancelled:
        return Icons.cancel;
      case TransportRequestStatus.expired:
        return Icons.timer_off;
    }
  }

  Widget _buildRouteSummary(BuildContext context, TransportRequestModel request) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.shade700, width: 2),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.shade700, width: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.sourceAddress,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        request.destinationAddress,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(Icons.route, request.formattedDistance),
                _buildInfoItem(Icons.scale, request.formattedWeight),
                _buildInfoItem(Icons.calendar_today, request.formattedPickupDate),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusContent(
    BuildContext context,
    TripProgressController controller,
    TransportRequestModel request,
  ) {
    switch (request.statusEnum) {
      case TransportRequestStatus.accepted:
        if (controller.canProposeFare) {
          return _buildFareProposalSection(context, controller);
        } else if (controller.isWaitingForFareApproval) {
          return _buildWaitingForApprovalSection(context, request);
        } else if (request.isFareAgreed) {
          return _buildReadyForPickupSection(context, controller);
        }
        return const SizedBox.shrink();

      case TransportRequestStatus.inProgress:
        return _buildReadyForPickupSection(context, controller);

      case TransportRequestStatus.inTransit:
        return _buildInTransitSection(context, request);

      case TransportRequestStatus.completed:
        return _buildCompletedSection(context, request);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFareProposalSection(
    BuildContext context,
    TripProgressController controller,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Propose Your Fare',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Suggested range: $formattedFareRange',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: fareController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Your Fare',
                  prefixText: '\u20B9 ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: validateFare,
              ),
              const SizedBox(height: 16),

              // Quick adjust buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => decreaseFare(500),
                      child: const Text('-500'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: setToSuggestedFare,
                      child: const Text('Suggested'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => increaseFare(500),
                      child: const Text('+500'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isProposingFare
                      ? null
                      : () async {
                          if (validateForm()) {
                            final fare = getFare();
                            if (fare != null) {
                              await controller.proposeFare(fare);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isProposingFare
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Propose Fare'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingForApprovalSection(
    BuildContext context,
    TransportRequestModel request,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Waiting for Customer Approval',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your proposed fare: ${request.formattedProposedFare}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The customer will review and approve your fare proposal.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyForPickupSection(
    BuildContext context,
    TripProgressController controller,
  ) {
    final theme = Theme.of(context);
    final request = controller.request!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'Ready for Pickup',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agreed Fare: ${request.formattedProposedFare}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.isConfirmingPickup
                    ? null
                    : () => _showPickupConfirmation(controller),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                icon: controller.isConfirmingPickup
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.local_shipping, color: Colors.white),
                label: const Text(
                  'Confirm Pickup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickupConfirmation(TripProgressController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Pickup'),
        content: const Text(
          'Have you picked up the livestock? This will start the trip.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.confirmPickup();
            },
            child: const Text('Confirm Pickup'),
          ),
        ],
      ),
    );
  }

  Widget _buildInTransitSection(BuildContext context, TransportRequestModel request) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.local_shipping,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'In Transit',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for customer to confirm delivery',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Fare: ${request.formattedProposedFare}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedSection(BuildContext context, TransportRequestModel request) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'Trip Completed!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Earned: ${request.formattedFinalFare ?? request.formattedProposedFare}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => TransportNavigationService.navigateToDashboard(context),
                child: const Text('Back to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Container(
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

  Widget _buildErrorState(BuildContext context, TripProgressController controller) {
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
              'Failed to Load Trip',
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
              onPressed: () => controller.initializeWithRequestId(widget.requestId),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
