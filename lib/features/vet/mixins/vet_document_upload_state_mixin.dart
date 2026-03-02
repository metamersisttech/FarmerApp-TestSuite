import 'dart:io';
import 'package:flutter/material.dart';

/// State mixin for the vet document upload screen
mixin VetDocumentUploadStateMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form field controllers
  late TextEditingController registrationNoController;
  late TextEditingController qualificationsController;
  late TextEditingController clinicNameController;
  late TextEditingController collegeNameController;
  late TextEditingController specializationController;

  // Upload state for vet certificate
  File? vetCertificateFile;
  String? vetCertificateUrl;
  bool isUploadingVetCert = false;

  // Upload state for degree certificate
  File? degreeCertificateFile;
  String? degreeCertificateUrl;
  bool isUploadingDegreeCert = false;

  // Overall state
  bool isSubmitting = false;
  String? submitError;

  void initializeDocumentUpload() {
    registrationNoController = TextEditingController();
    qualificationsController = TextEditingController();
    clinicNameController = TextEditingController();
    collegeNameController = TextEditingController();
    specializationController = TextEditingController();
  }

  void disposeDocumentUpload() {
    registrationNoController.dispose();
    qualificationsController.dispose();
    clinicNameController.dispose();
    collegeNameController.dispose();
    specializationController.dispose();
  }

  void setVetCertificateFile(List<File> files) {
    if (mounted) {
      setState(() {
        vetCertificateFile = files.isNotEmpty ? files.first : null;
        if (files.isEmpty) vetCertificateUrl = null;
      });
    }
  }

  void setDegreeCertificateFile(List<File> files) {
    if (mounted) {
      setState(() {
        degreeCertificateFile = files.isNotEmpty ? files.first : null;
        if (files.isEmpty) degreeCertificateUrl = null;
      });
    }
  }

  void setVetCertUploading(bool value) {
    if (mounted) setState(() => isUploadingVetCert = value);
  }

  void setDegreeCertUploading(bool value) {
    if (mounted) setState(() => isUploadingDegreeCert = value);
  }

  void setVetCertUrl(String? url) {
    if (mounted) setState(() => vetCertificateUrl = url);
  }

  void setDegreeCertUrl(String? url) {
    if (mounted) setState(() => degreeCertificateUrl = url);
  }

  void setSubmitting(bool value) {
    if (mounted) setState(() => isSubmitting = value);
  }

  void setSubmitError(String? error) {
    if (mounted) setState(() => submitError = error);
  }

  bool get isFormValid {
    return formKey.currentState?.validate() == true &&
        vetCertificateUrl != null &&
        degreeCertificateUrl != null;
  }

  bool get canSubmit {
    return !isSubmitting &&
        !isUploadingVetCert &&
        !isUploadingDegreeCert &&
        vetCertificateUrl != null &&
        degreeCertificateUrl != null;
  }
}
