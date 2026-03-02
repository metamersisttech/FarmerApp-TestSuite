import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';

/// Mixin for edit health page: same state as postlistings health + pre-fill.
mixin EditHealthStateMixin<T extends StatefulWidget> on State<T> {
  late TextEditingController pashuAadharController;
  late TextEditingController colorController;
  late TextEditingController heightController;

  String? vaccinationStatus;
  String? healthStatus;
  File? vetCertificateFile;
  String? vetCertificateKey;
  String? vetCertificateUrl; // Add URL for displaying existing certificate

  bool isSubmitting = false;

  final List<String> healthStatusOptions = [
    'healthy',
    'sick',
    'recovering',
    'under_treatment',
  ];

  void initializeControllers() {
    pashuAadharController = TextEditingController();
    colorController = TextEditingController();
    heightController = TextEditingController();
  }

  void disposeControllers() {
    pashuAadharController.dispose();
    colorController.dispose();
    heightController.dispose();
  }

  void setVaccinationStatus(String? status) {
    if (mounted) setState(() => vaccinationStatus = status);
  }

  void setHealthStatus(String? status) {
    if (mounted) setState(() => healthStatus = status);
  }

  void setVetCertificateFile(File? file) {
    if (mounted) {
      setState(() {
        vetCertificateFile = file;
        if (file != null) vetCertificateKey = null;
      });
    }
  }

  void clearVetCertificate() {
    if (mounted) {
      setState(() {
        vetCertificateFile = null;
        vetCertificateKey = null;
        vetCertificateUrl = null; // Clear URL as well
      });
    }
  }

  void setSubmitting(bool submitting) {
    if (mounted) setState(() => isSubmitting = submitting);
  }

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
      if (pickedFile != null) setVetCertificateFile(File(pickedFile.path));
    } catch (e) {
      rethrow;
    }
  }

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

  String formatHealthStatus(String status) {
    return status
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

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
    if (pashuAadhar.isNotEmpty) patchData['pashu_aadhar'] = pashuAadhar;
    final color = colorController.text.trim();
    if (color.isNotEmpty) patchData['color'] = color;
    final height = double.tryParse(heightController.text.trim());
    if (height != null && height > 0) patchData['height_cm'] = height;
    return patchData;
  }

  /// Pre-fill from listing API response
  void preFillFromListing(Map<String, dynamic> listing) {
    if (!mounted) return;
    setState(() {
      vaccinationStatus = listing['vaccination_status']?.toString();
      healthStatus = listing['health_status']?.toString();
      vetCertificateKey = listing['vet_certificate']?.toString();
      
      // Load existing vet certificate URL
      if (vetCertificateKey != null && vetCertificateKey!.isNotEmpty) {
        vetCertificateUrl = CommonHelper.getImageUrl(vetCertificateKey!);
      }
      
      final pashu = listing['pashu_aadhar']?.toString();
      if (pashu != null && pashu.isNotEmpty) {
        pashuAadharController.text = pashu;
      }
      final color = listing['color']?.toString();
      if (color != null && color.isNotEmpty) {
        colorController.text = color;
      }
      final height = listing['height_cm'];
      if (height != null) {
        final h = height is num ? height.toDouble() : double.tryParse(height.toString());
        if (h != null && h > 0) heightController.text = h.toStringAsFixed(0);
      }
    });
  }
}
