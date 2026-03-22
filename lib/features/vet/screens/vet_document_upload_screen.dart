import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/shared/widgets/media/image_upload_picker.dart';
import 'package:flutter_app/features/vet/controllers/vet_onboarding_controller.dart';
import 'package:flutter_app/features/vet/mixins/vet_document_upload_state_mixin.dart';
import 'package:flutter_app/features/vet/models/vet_role_upgrade_request_model.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Screen for uploading vet credentials and documents
class VetDocumentUploadScreen extends StatefulWidget {
  const VetDocumentUploadScreen({super.key});

  @override
  State<VetDocumentUploadScreen> createState() =>
      _VetDocumentUploadScreenState();
}

class _VetDocumentUploadScreenState extends State<VetDocumentUploadScreen>
    with VetDocumentUploadStateMixin, ToastMixin {
  late final VetOnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VetOnboardingController();
    initializeDocumentUpload();
  }

  @override
  void dispose() {
    _controller.dispose();
    disposeDocumentUpload();
    super.dispose();
  }

  /// Handle vet certificate image pick and upload
  Future<void> _handleVetCertChanged(List<File> files) async {
    setVetCertificateFile(files);
    if (files.isEmpty) return;

    setVetCertUploading(true);
    final key = await _controller.uploadDocument(files.first.path);
    if (!mounted) return;

    if (key != null) {
      setVetCertUrl(key);
    } else {
      showErrorToast('Failed to upload vet certificate');
      setVetCertificateFile([]);
    }
    setVetCertUploading(false);
  }

  /// Handle degree certificate image pick and upload
  Future<void> _handleDegreeCertChanged(List<File> files) async {
    setDegreeCertificateFile(files);
    if (files.isEmpty) return;

    setDegreeCertUploading(true);
    final key = await _controller.uploadDocument(files.first.path);
    if (!mounted) return;

    if (key != null) {
      setDegreeCertUrl(key);
    } else {
      showErrorToast('Failed to upload degree certificate');
      setDegreeCertificateFile([]);
    }
    setDegreeCertUploading(false);
  }

  /// Submit the application
  Future<void> _handleSubmit() async {
    if (!formKey.currentState!.validate()) return;

    if (vetCertificateUrl == null || degreeCertificateUrl == null) {
      showErrorToast('Please upload both certificates');
      return;
    }

    setSubmitting(true);
    setSubmitError(null);

    final request = VetRoleUpgradeRequestModel(
      vetCertificate: vetCertificateUrl!,
      degreeCertificate: degreeCertificateUrl!,
      registrationNo: registrationNoController.text.trim(),
      qualifications: qualificationsController.text.trim(),
      clinicName: clinicNameController.text.trim(),
      collegeName: collegeNameController.text.trim(),
      specialization: specializationController.text.trim().isNotEmpty
          ? specializationController.text.trim()
          : null,
    );

    final result = await _controller.submitApplication(request);

    if (!mounted) return;
    setSubmitting(false);

    if (result.success) {
      showSuccessToast('Application submitted successfully!');
      Navigator.pushReplacementNamed(context, AppRoutes.vetVerificationStatus);
    } else {
      showErrorToast(result.message ?? 'Failed to submit application');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Vet Registration'),
        backgroundColor: AppTheme.authPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info banner
                        _buildInfoBanner(),
                        const SizedBox(height: 20),

                        // Vet Certificate Upload
                        _buildSectionLabel('Vet Certificate', isRequired: true),
                        const SizedBox(height: 8),
                        ImageUploadPicker(
                          selectedImages:
                              vetCertificateFile != null ? [vetCertificateFile!] : [],
                          onImagesChanged: _handleVetCertChanged,
                          maxImages: 1,
                          isLoading: isUploadingVetCert,
                          placeholderText: 'Upload Vet Certificate',
                          placeholderHint: 'Tap to upload certificate image',
                          bottomSheetTitle: 'Upload Vet Certificate',
                        ),
                        const SizedBox(height: 20),

                        // Degree Certificate Upload
                        _buildSectionLabel('Degree Certificate', isRequired: true),
                        const SizedBox(height: 8),
                        ImageUploadPicker(
                          selectedImages: degreeCertificateFile != null
                              ? [degreeCertificateFile!]
                              : [],
                          onImagesChanged: _handleDegreeCertChanged,
                          maxImages: 1,
                          isLoading: isUploadingDegreeCert,
                          placeholderText: 'Upload Degree Certificate',
                          placeholderHint: 'Tap to upload degree image',
                          bottomSheetTitle: 'Upload Degree Certificate',
                        ),
                        const SizedBox(height: 20),

                        // Registration Number
                        _buildSectionLabel('Registration Number', isRequired: true),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: registrationNoController,
                          hint: 'e.g., VET-MH-2024-12345',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Registration number is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Qualifications
                        _buildSectionLabel('Qualifications', isRequired: true),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: qualificationsController,
                          hint: 'e.g., BVSc, MVSc (Surgery)',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Qualifications are required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Clinic Name
                        _buildSectionLabel('Clinic Name', isRequired: true),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: clinicNameController,
                          hint: 'e.g., Green Valley Veterinary Clinic',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Clinic name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // College Name
                        _buildSectionLabel('College Name', isRequired: true),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: collegeNameController,
                          hint: 'e.g., Mumbai Veterinary College',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'College name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Specialization (Optional)
                        _buildSectionLabel('Specialization', isRequired: false),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: specializationController,
                          hint: 'e.g., Large Animals, Surgery',
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Fixed Submit Button at bottom
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: bottomPadding + 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    key: const Key('submit_for_verification_btn'),
                    onPressed: canSubmit ? _handleSubmit : null,
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
                      'Submit for Verification',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (isSubmitting)
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
                      'Submitting application...',
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

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.authPrimaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.authPrimaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.authPrimaryColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Upload clear photos of your documents. All fields marked with * are required.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.authPrimaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
