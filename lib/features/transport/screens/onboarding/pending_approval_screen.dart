/// Pending Approval Screen
///
/// Shows application status, allows cancellation, and handles document re-upload.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/transport_onboarding_controller.dart';
import 'package:flutter_app/features/transport/models/onboarding_request_model.dart';
import 'package:flutter_app/features/transport/services/transport_navigation_service.dart';

class PendingApprovalScreen extends StatefulWidget {
  final int requestId;

  const PendingApprovalScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  late TransportOnboardingController _controller;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _controller = TransportOnboardingController();
    _controller.checkStatus(widget.requestId);

    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _controller.checkStatus(widget.requestId);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Application'),
        content: const Text(
          'Are you sure you want to cancel your transport provider application? You can apply again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep Application'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _controller.cancelApplication(widget.requestId);
      if (result.success && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application cancelled'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<TransportOnboardingController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Application Status'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => controller.checkStatus(widget.requestId),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            body: controller.isLoading && controller.onboardingRequest == null
                ? const Center(child: CircularProgressIndicator())
                : controller.onboardingRequest == null
                    ? _buildError(context, controller)
                    : _buildContent(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TransportOnboardingController controller,
  ) {
    final request = controller.onboardingRequest!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status card
          _buildStatusCard(context, request),
          const SizedBox(height: 24),

          // Submission details
          _buildDetailCard(
            context,
            title: 'Application Details',
            children: [
              _DetailRow(
                label: 'Business Name',
                value: request.businessName ?? 'N/A',
              ),
              _DetailRow(
                label: 'Submitted On',
                value: request.formattedCreatedAt,
              ),
              _DetailRow(
                label: 'Application ID',
                value: '#${request.requestId}',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rejection reason (if rejected)
          if (request.status == OnboardingStatus.rejected &&
              request.rejectionReason != null)
            _buildRejectionCard(context, request),

          // Document status
          if (request.status == OnboardingStatus.rejected)
            _buildDocumentStatusCard(context, request),

          const SizedBox(height: 24),

          // Actions
          if (request.status == OnboardingStatus.pending)
            OutlinedButton(
              onPressed: _handleCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
              child: const Text('Cancel Application'),
            ),

          if (request.status == OnboardingStatus.rejected)
            ElevatedButton(
              onPressed: () => TransportNavigationService.navigateToLicenseUpload(
                context,
                widget.requestId,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Re-upload Documents'),
            ),

          if (request.status == OnboardingStatus.approved)
            ElevatedButton(
              onPressed: () => TransportNavigationService.navigateToDashboard(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Go to Dashboard'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, OnboardingRequestModel request) {
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    switch (request.statusEnum) {
      case OnboardingStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Pending Review';
        statusDescription =
            'Your application is being reviewed. This usually takes 1-2 business days.';
      case OnboardingStatus.approved:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Approved!';
        statusDescription =
            'Congratulations! Your application has been approved. You can now start accepting transport jobs.';
      case OnboardingStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Needs Attention';
        statusDescription =
            'Your application needs some corrections. Please review the feedback below.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            statusIcon,
            size: 64,
            color: statusColor,
          ),
          const SizedBox(height: 16),
          Text(
            statusText,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
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
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRejectionCard(
    BuildContext context,
    OnboardingRequestModel request,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Feedback from Admin',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.rejectionReason!,
            style: TextStyle(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatusCard(
    BuildContext context,
    OnboardingRequestModel request,
  ) {
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
          Text(
            'Document Status',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _DocumentStatusItem(
            label: 'Driving License',
            isVerified: request.drivingLicenseVerified,
          ),
          const SizedBox(height: 8),
          _DocumentStatusItem(
            label: 'Vehicle RC',
            isVerified: false, // RC verification status from request
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    TransportOnboardingController controller,
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
              'Failed to Load Status',
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
              onPressed: () => controller.checkStatus(widget.requestId),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentStatusItem extends StatelessWidget {
  final String label;
  final bool isVerified;

  const _DocumentStatusItem({
    required this.label,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          isVerified ? Icons.check_circle : Icons.error,
          size: 20,
          color: isVerified ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          isVerified ? 'Verified' : 'Needs Re-upload',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isVerified ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
