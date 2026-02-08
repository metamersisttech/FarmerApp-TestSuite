import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/shared/widgets/media/image_upload_picker.dart';
import 'package:flutter_app/features/vet/controllers/vet_onboarding_controller.dart';
import 'package:flutter_app/features/vet/models/vet_verification_status_model.dart';
import 'package:flutter_app/features/vet/screens/vet_verification_status_screen.dart';

/// Screen for re-uploading rejected documents
class VetDocumentReuploadScreen extends StatefulWidget {
  final VetVerificationStatusModel verificationStatus;

  const VetDocumentReuploadScreen({
    super.key,
    required this.verificationStatus,
  });

  @override
  State<VetDocumentReuploadScreen> createState() =>
      _VetDocumentReuploadScreenState();
}

class _VetDocumentReuploadScreenState extends State<VetDocumentReuploadScreen>
    with ToastMixin {
  late final VetOnboardingController _controller;

  // Per-document state
  File? _newVetCertFile;
  String? _newVetCertUrl;
  bool _isUploadingVetCert = false;

  File? _newDegreeCertFile;
  String? _newDegreeCertUrl;
  bool _isUploadingDegreeCert = false;

  bool _isSubmitting = false;

  bool get _vetCertRejected =>
      widget.verificationStatus.isDocumentRejected('vet_certificate');
  bool get _degreeCertRejected =>
      widget.verificationStatus.isDocumentRejected('degree_certificate');

  bool get _canSubmit {
    if (_isSubmitting || _isUploadingVetCert || _isUploadingDegreeCert) {
      return false;
    }
    // At least one rejected document must have a new upload
    if (_vetCertRejected && _newVetCertUrl == null) return false;
    if (_degreeCertRejected && _newDegreeCertUrl == null) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _controller = VetOnboardingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleVetCertChanged(List<File> files) async {
    setState(() {
      _newVetCertFile = files.isNotEmpty ? files.first : null;
      if (files.isEmpty) _newVetCertUrl = null;
    });
    if (files.isEmpty) return;

    setState(() => _isUploadingVetCert = true);
    final key = await _controller.uploadDocument(files.first.path);
    if (!mounted) return;

    if (key != null) {
      setState(() => _newVetCertUrl = key);
    } else {
      showErrorToast('Failed to upload vet certificate');
      setState(() {
        _newVetCertFile = null;
        _newVetCertUrl = null;
      });
    }
    setState(() => _isUploadingVetCert = false);
  }

  Future<void> _handleDegreeCertChanged(List<File> files) async {
    setState(() {
      _newDegreeCertFile = files.isNotEmpty ? files.first : null;
      if (files.isEmpty) _newDegreeCertUrl = null;
    });
    if (files.isEmpty) return;

    setState(() => _isUploadingDegreeCert = true);
    final key = await _controller.uploadDocument(files.first.path);
    if (!mounted) return;

    if (key != null) {
      setState(() => _newDegreeCertUrl = key);
    } else {
      showErrorToast('Failed to upload degree certificate');
      setState(() {
        _newDegreeCertFile = null;
        _newDegreeCertUrl = null;
      });
    }
    setState(() => _isUploadingDegreeCert = false);
  }

  Future<void> _handleSubmit() async {
    final requestId = widget.verificationStatus.requestId;
    if (requestId == null) {
      showErrorToast('Missing request ID');
      return;
    }

    // Build updated fields map with only re-uploaded documents
    final updatedFields = <String, dynamic>{};
    if (_vetCertRejected && _newVetCertUrl != null) {
      updatedFields['vet_certificate'] = _newVetCertUrl;
    }
    if (_degreeCertRejected && _newDegreeCertUrl != null) {
      updatedFields['degree_certificate'] = _newDegreeCertUrl;
    }

    if (updatedFields.isEmpty) {
      showErrorToast('Please upload the rejected documents');
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await _controller.resubmitDocuments(
      requestId,
      updatedFields,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      showSuccessToast('Documents resubmitted successfully!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const VetVerificationStatusScreen(),
        ),
      );
    } else {
      showErrorToast(result.message ?? 'Failed to resubmit documents');
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = widget.verificationStatus.documents;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Resubmit Documents'),
        backgroundColor: AppTheme.authPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Only rejected documents need to be re-uploaded. Accepted documents are shown below for reference.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Vet Certificate
                _buildDocumentSection(
                  label: 'Vet Certificate',
                  documentKey: 'vet_certificate',
                  existingUrl: docs?['vet_certificate'] as String?,
                  isRejected: _vetCertRejected,
                  rejectionReason: widget.verificationStatus
                      .getDocumentRejectionReason('vet_certificate'),
                  newFile: _newVetCertFile,
                  isUploading: _isUploadingVetCert,
                  onFilesChanged: _handleVetCertChanged,
                ),
                const SizedBox(height: 20),

                // Degree Certificate
                _buildDocumentSection(
                  label: 'Degree Certificate',
                  documentKey: 'degree_certificate',
                  existingUrl: docs?['degree_certificate'] as String?,
                  isRejected: _degreeCertRejected,
                  rejectionReason: widget.verificationStatus
                      .getDocumentRejectionReason('degree_certificate'),
                  newFile: _newDegreeCertFile,
                  isUploading: _isUploadingDegreeCert,
                  onFilesChanged: _handleDegreeCertChanged,
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _handleSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.authPrimaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Submit Updated Documents',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Loading overlay
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Resubmitting documents...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection({
    required String label,
    required String documentKey,
    String? existingUrl,
    required bool isRejected,
    String? rejectionReason,
    File? newFile,
    required bool isUploading,
    required Function(List<File>) onFilesChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRejected
              ? Colors.red.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isRejected
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isRejected ? 'Rejected' : 'Accepted',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isRejected ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),

          // Rejection reason
          if (isRejected && rejectionReason != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                rejectionReason,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red[700],
                  height: 1.4,
                ),
              ),
            ),
          ],

          // Existing image (for accepted) or upload picker (for rejected)
          if (isRejected) ...[
            const SizedBox(height: 12),
            const Text(
              'Upload new document:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ImageUploadPicker(
              selectedImages: newFile != null ? [newFile] : [],
              onImagesChanged: onFilesChanged,
              maxImages: 1,
              isLoading: isUploading,
              placeholderText: 'Tap to upload new $label',
              placeholderHint: 'Choose a clear image',
              bottomSheetTitle: 'Upload $label',
            ),
          ] else if (existingUrl != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                CommonHelper.getImageUrl(existingUrl),
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Document accepted',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
