/// Delivery Confirmation Screen
///
/// Allows requester to confirm delivery and rate the transport provider.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/delivery_confirmation_controller.dart';
import 'package:flutter_app/features/transport/widgets/star_rating_widget.dart';
import 'package:flutter_app/routes/app_routes.dart';

class DeliveryConfirmationScreen extends StatefulWidget {
  final int requestId;

  const DeliveryConfirmationScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<DeliveryConfirmationScreen> createState() =>
      _DeliveryConfirmationScreenState();
}

class _DeliveryConfirmationScreenState
    extends State<DeliveryConfirmationScreen> {
  late DeliveryConfirmationController _controller;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = DeliveryConfirmationController();
    _controller.loadRequest(widget.requestId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<DeliveryConfirmationController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Confirm Delivery'),
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
    );
  }

  Widget _buildContent(
    BuildContext context,
    DeliveryConfirmationController controller,
  ) {
    final theme = Theme.of(context);
    final request = controller.request!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Success icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green.shade600,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Delivery Complete!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Your animals have been delivered safely.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Request summary
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    label: 'Request',
                    value: '#${request.requestId}',
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    context,
                    label: 'Cargo',
                    value: request.cargoSummary,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    context,
                    label: 'Final Fare',
                    value: request.formattedFare,
                    valueStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (request.transportProvider != null) ...[
                    const Divider(height: 24),
                    _buildSummaryRow(
                      context,
                      label: 'Provider',
                      value: request.transportProvider!.user?.displayName ??
                          request.transportProvider!.user?.fullName ??
                          'Provider',
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Rating section
          Text(
            'Rate your experience',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          StarRatingWidget(
            rating: controller.rating,
            onRatingChanged: controller.setRating,
            size: 48,
          ),

          const SizedBox(height: 8),

          Text(
            _getRatingLabel(controller.rating),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          // Review text field
          TextFormField(
            controller: _reviewController,
            decoration: InputDecoration(
              labelText: 'Write a review (optional)',
              hintText: 'Share your experience with this provider...',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
              suffixIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Optional',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            maxLines: 4,
            onChanged: controller.setReview,
          ),

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: controller.canSubmit
                  ? () => _submitConfirmation(context, controller)
                  : null,
              child: controller.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Confirm & Rate'),
            ),
          ),

          const SizedBox(height: 16),

          // Skip button
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap to rate';
    }
  }

  Future<void> _submitConfirmation(
    BuildContext context,
    DeliveryConfirmationController controller,
  ) async {
    final success = await controller.confirmDelivery();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to my requests
      AppRoutes.navigateAndRemoveAll(context, AppRoutes.transportMyRequests);
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
    DeliveryConfirmationController controller,
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
}
