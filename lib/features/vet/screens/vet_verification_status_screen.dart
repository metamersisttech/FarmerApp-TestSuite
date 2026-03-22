import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/vet/controllers/vet_onboarding_controller.dart';
import 'package:flutter_app/features/vet/models/vet_verification_status_model.dart';
import 'package:flutter_app/features/vet/mixins/vet_verification_status_state_mixin.dart';
import 'package:flutter_app/features/vet/widgets/verification/vet_document_status_card.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Screen displaying current vet verification status
/// Shows different UI for PENDING, APPROVED, and REJECTED states
class VetVerificationStatusScreen extends StatefulWidget {
  const VetVerificationStatusScreen({super.key});

  @override
  State<VetVerificationStatusScreen> createState() =>
      _VetVerificationStatusScreenState();
}

class _VetVerificationStatusScreenState
    extends State<VetVerificationStatusScreen>
    with VetVerificationStatusStateMixin, ToastMixin {
  late final VetOnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VetOnboardingController();
    _loadStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setStatusLoading(true);
    setStatusError(null);

    final result = await _controller.checkVerificationStatus();

    if (!mounted) return;

    if (result.success && result.verificationStatus != null) {
      setVerificationStatus(result.verificationStatus);
    } else {
      setStatusError(result.message ?? 'Failed to load status');
      showErrorToast(result.message ?? 'Failed to load status');
    }

    setStatusLoading(false);
  }

  void _handleResubmit() {
    if (verificationStatus == null) return;
    Navigator.pushNamed(
      context,
      AppRoutes.vetDocumentReupload,
      arguments: verificationStatus!,
    ).then((_) => _loadStatus());
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _handleBackToProfile() {
    Navigator.popUntil(context, (route) => route.isFirst || route.settings.name == '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Verification Status'),
        backgroundColor: AppTheme.authPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null && verificationStatus == null
              ? _buildErrorState()
              : verificationStatus != null
                  ? _buildStatusContent()
                  : const SizedBox.shrink(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadStatus,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusContent() {
    final status = verificationStatus!;

    if (status.isPending) return _buildPendingState(status);
    if (status.isApproved) return _buildApprovedState();
    if (status.isRejected) return _buildRejectedState(status);

    return _buildPendingState(status);
  }

  // ─── PENDING STATE ───

  Widget _buildPendingState(VetVerificationStatusModel status) {
    final submittedDate = status.submittedAt != null
        ? _formatDate(status.submittedAt!)
        : 'Recently';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Animated icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 48,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'Documents Under Review',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Our team is reviewing your documents.\nThis usually takes 1-2 business days.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[500]),
                const SizedBox(width: 12),
                Text(
                  'Submitted on $submittedDate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Back button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              key: const Key('verification_back_to_profile_btn'),
              onPressed: _handleBackToProfile,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.authPrimaryColor,
                side: BorderSide(color: AppTheme.authPrimaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Back to Profile',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── APPROVED STATE ───

  Widget _buildApprovedState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Success icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 56,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'You are now a verified vet on our platform.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Benefits list
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What you can do now:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBenefitItem(
                  Icons.calendar_month,
                  'Receive appointment requests from farmers',
                ),
                _buildBenefitItem(
                  Icons.schedule,
                  'Set your weekly availability',
                ),
                _buildBenefitItem(
                  Icons.medical_information,
                  'Manage your consultations',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action buttons
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: const Key('set_up_availability_btn'),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.vetProfile);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.authPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Set Up Availability',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _handleBackToProfile,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.authPrimaryColor,
                side: BorderSide(color: AppTheme.authPrimaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Go to Profile',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.authPrimaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── REJECTED STATE ───

  Widget _buildRejectedState(VetVerificationStatusModel status) {
    final docs = status.documents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Warning header
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Action Required',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Some documents need to be resubmitted.',
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Admin remarks
          if (status.adminRemarks != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.comment, size: 16, color: Colors.red[400]),
                      const SizedBox(width: 8),
                      Text(
                        'Admin Remarks',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status.adminRemarks!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[800],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Document status cards
          const Text(
            'Document Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          VetDocumentStatusCard(
            documentLabel: 'Vet Certificate',
            documentUrl: docs?['vet_certificate'] as String?,
            isRejected: status.isDocumentRejected('vet_certificate'),
            rejectionReason:
                status.getDocumentRejectionReason('vet_certificate'),
          ),

          VetDocumentStatusCard(
            documentLabel: 'Degree Certificate',
            documentUrl: docs?['degree_certificate'] as String?,
            isRejected: status.isDocumentRejected('degree_certificate'),
            rejectionReason:
                status.getDocumentRejectionReason('degree_certificate'),
          ),

          const SizedBox(height: 28),

          // Resubmit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: const Key('resubmit_documents_btn'),
              onPressed: _handleResubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.authPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Resubmit Documents',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _handleBackToProfile,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Back to Profile',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
