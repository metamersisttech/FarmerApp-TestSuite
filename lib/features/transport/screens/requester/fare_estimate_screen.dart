/// Fare Estimate Screen
///
/// Step 4: Review fare estimate and confirm transport request.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/create_request_controller.dart';
import 'package:flutter_app/features/transport/widgets/fare_estimate_card.dart';

class FareEstimateScreen extends StatefulWidget {
  const FareEstimateScreen({super.key});

  @override
  State<FareEstimateScreen> createState() => _FareEstimateScreenState();
}

class _FareEstimateScreenState extends State<FareEstimateScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch fare estimate when screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<CreateRequestController>();
      if (controller.data.fareEstimate == null && !controller.isEstimating) {
        controller.getFareEstimate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CreateRequestController>(
      builder: (context, controller, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Review & Confirm',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review your transport request details before confirming.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 24),

              // Loading state
              if (controller.isEstimating)
                _buildLoadingState(context)
              // Error state
              else if (controller.errorMessage != null)
                _buildErrorState(context, controller)
              // Fare estimate card
              else if (controller.data.fareEstimate != null)
                Column(
                  children: [
                    FareEstimateCard(
                      estimate: controller.data.fareEstimate!,
                      sourceAddress: controller.data.sourceLocation?.address,
                      destinationAddress:
                          controller.data.destinationLocation?.address,
                      animalCount: controller.data.totalAnimalCount,
                      cargoSummary: controller.data.cargoSummary,
                      pickupDate: controller.data.pickupDate,
                      pickupTime: controller.data.pickupTime,
                    ),

                    const SizedBox(height: 24),

                    // Request summary
                    _buildRequestSummary(context, controller),

                    const SizedBox(height: 24),

                    // How it works
                    _buildHowItWorks(context),
                  ],
                )
              else
                _buildLoadingState(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Calculating fare estimate...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    CreateRequestController controller,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to get estimate',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
            FilledButton.icon(
              onPressed: controller.getFareEstimate,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSummary(
    BuildContext context,
    CreateRequestController controller,
  ) {
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
                Icon(
                  Icons.checklist,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Request Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              label: 'Animals',
              value: controller.data.cargoSummary,
              icon: Icons.pets,
            ),
            _buildSummaryRow(
              context,
              label: 'Date',
              value: controller.data.formattedPickupDate ?? 'Not set',
              icon: Icons.calendar_today,
            ),
            if (controller.data.pickupTime != null)
              _buildSummaryRow(
                context,
                label: 'Time',
                value: controller.data.formattedPickupTime!,
                icon: Icons.access_time,
              ),
            if (controller.data.notes != null &&
                controller.data.notes!.isNotEmpty)
              _buildSummaryRow(
                context,
                label: 'Notes',
                value: controller.data.notes!,
                icon: Icons.note,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
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

  Widget _buildHowItWorks(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'What happens next?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStep(
              context,
              number: '1',
              text: 'Your request will be sent to nearby transport providers',
            ),
            _buildStep(
              context,
              number: '2',
              text: 'A provider will accept and propose a final fare',
            ),
            _buildStep(
              context,
              number: '3',
              text: 'You approve the fare and coordinate pickup',
            ),
            _buildStep(
              context,
              number: '4',
              text: 'Rate your experience after delivery',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String number,
    required String text,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
