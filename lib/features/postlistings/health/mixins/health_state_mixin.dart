import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/postlistings/health/controllers/health_controller.dart';
import 'package:image_picker/image_picker.dart';

/// Mixin for health page state management
mixin HealthStateMixin<T extends StatefulWidget> on State<T> {
  late HealthController healthController;

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

  /// Initialize controller and text controllers
  void initializeHealthController(
    HealthController controller, {
    VoidCallback? onNext,
    Function(String)? onShowSuccess,
    Function(String)? onShowError,
  }) {
    healthController = controller;
    _onNext = onNext;
    _onShowSuccess = onShowSuccess;
    _onShowError = onShowError;

    // Listen to controller changes
    healthController.addListener(_onControllerChanged);

    // Initialize text controllers
    pashuAadharController = TextEditingController();
    colorController = TextEditingController();
    heightController = TextEditingController();
  }

  // Callbacks
  VoidCallback? _onNext;
  Function(String)? _onShowSuccess;
  Function(String)? _onShowError;

  /// Handle controller changes
  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Default toast implementations
  void _defaultShowSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  void _defaultShowError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  /// Dispose controller and text controllers
  void disposeHealthController() {
    healthController.removeListener(_onControllerChanged);
    pashuAadharController.dispose();
    colorController.dispose();
    heightController.dispose();
  }

  /// Handle Next button press (coordinated in mixin)
  Future<void> handleNext(int listingId) async {
    setSubmitting(true);

    try {
      // Upload vet certificate if selected but not uploaded
      if (vetCertificateFile != null && vetCertificateKey == null) {
        final uploadResult =
            await healthController.uploadVetCertificate(vetCertificateFile!.path);

        if (!mounted) return;

        if (uploadResult.success && uploadResult.fileKey != null) {
          setState(() {
            vetCertificateKey = uploadResult.fileKey;
          });
        } else {
          setSubmitting(false);
          (_onShowError ?? _defaultShowError)(
              uploadResult.errorMessage ?? 'Failed to upload certificate');
          return;
        }
      }

      // Build PATCH data using controller
      final healthData = healthController.prepareHealthData(
        vaccinationStatus: vaccinationStatus,
        healthStatus: healthStatus,
        vetCertificateKey: vetCertificateKey,
        pashuAadhar: pashuAadharController.text,
        color: colorController.text,
        height: heightController.text,
      );

      // Only call PATCH if there's data to update
      if (healthData.isNotEmpty) {
        final result = await healthController.updateHealthInfo(listingId, healthData);

        if (!mounted) return;

        if (result.success) {
          setSubmitting(false);
          (_onShowSuccess ?? _defaultShowSuccess)('Health information saved!');
          _onNext?.call();
        } else {
          setSubmitting(false);
          (_onShowError ?? _defaultShowError)(
              result.errorMessage ?? 'Failed to save health information');
        }
      } else {
        // No data to update, just proceed
        if (!mounted) return;
        setSubmitting(false);
        _onNext?.call();
      }
    } catch (e) {
      if (!mounted) return;
      setSubmitting(false);
      (_onShowError ?? _defaultShowError)(e.toString());
    }
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
}
