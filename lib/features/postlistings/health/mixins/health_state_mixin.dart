import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Mixin for health page state management
mixin HealthStateMixin<T extends StatefulWidget> on State<T> {
  // Text controllers
  late TextEditingController pashuAadharController;
  late TextEditingController colorController;
  late TextEditingController heightController;

  // Selected values
  String? vaccinationStatus;
  String? healthStatus;
  File? vetCertificateFile;
  String? vetCertificateKey;

  // Loading states
  bool isSubmitting = false;

  // Health status options
  final List<String> healthStatusOptions = [
    'healthy',
    'sick',
    'recovering',
    'under_treatment',
  ];

  /// Initialize text controllers
  void initializeControllers() {
    pashuAadharController = TextEditingController();
    colorController = TextEditingController();
    heightController = TextEditingController();
  }

  /// Dispose text controllers
  void disposeControllers() {
    pashuAadharController.dispose();
    colorController.dispose();
    heightController.dispose();
  }

  /// Set vaccination status
  void setVaccinationStatus(String? status) {
    if (mounted) {
      setState(() {
        vaccinationStatus = status;
      });
    }
  }

  /// Set health status
  void setHealthStatus(String? status) {
    if (mounted) {
      setState(() {
        healthStatus = status;
      });
    }
  }

  /// Set vet certificate file
  void setVetCertificateFile(File? file) {
    if (mounted) {
      setState(() {
        vetCertificateFile = file;
        if (file != null) {
          vetCertificateKey = null; // Reset uploaded key when new file is selected
        }
      });
    }
  }

  /// Clear vet certificate
  void clearVetCertificate() {
    if (mounted) {
      setState(() {
        vetCertificateFile = null;
        vetCertificateKey = null;
      });
    }
  }

  /// Set submitting state
  void setSubmitting(bool submitting) {
    if (mounted) {
      setState(() {
        isSubmitting = submitting;
      });
    }
  }

  /// Pick vet certificate image
  Future<void> pickVetCertificate(BuildContext context) async {
    try {
      final source = await showImageSourceDialog(context);
      if (source == null) return;

      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setVetCertificateFile(File(pickedFile.path));
      }
    } catch (e) {
      // Error will be handled by parent
      rethrow;
    }
  }

  /// Show image source selection dialog
  Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Certificate',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a picture'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Select from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// Format health status for display
  String formatHealthStatus(String status) {
    return status
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Build health data for API
  Map<String, dynamic> getHealthData() {
    final patchData = <String, dynamic>{};

    if (vaccinationStatus != null) {
      patchData['vaccination_status'] = vaccinationStatus;
    }
    if (healthStatus != null) {
      patchData['health_status'] = healthStatus;
    }
    if (vetCertificateKey != null) {
      patchData['vet_certificate'] = vetCertificateKey;
    }

    final pashuAadhar = pashuAadharController.text.trim();
    if (pashuAadhar.isNotEmpty) {
      patchData['pashu_aadhar'] = pashuAadhar;
    }

    final color = colorController.text.trim();
    if (color.isNotEmpty) {
      patchData['color'] = color;
    }

    final height = double.tryParse(heightController.text.trim());
    if (height != null && height > 0) {
      patchData['height_cm'] = height;
    }

    return patchData;
  }
}
