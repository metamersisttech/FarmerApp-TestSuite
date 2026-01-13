import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Health Tab - Health information with PATCH integration
class HealthTab extends StatefulWidget {
  final int listingId;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const HealthTab({
    super.key,
    required this.listingId,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> with ToastMixin {
  final BackendHelper _backendHelper = BackendHelper();
  final ImagePicker _imagePicker = ImagePicker();

  // Form state
  String? _vaccinationStatus; // "vaccinated" | "not_vaccinated"
  String? _healthStatus;
  String? _pashuAadhar;
  String? _color;

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _pashuAadharController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  // Vet certificate
  File? _vetCertificateFile;
  String? _vetCertificateKey;
  bool _isUploadingCertificate = false;

  bool _isSubmitting = false;

  // Health status options
  final List<String> _healthStatusOptions = [
    'healthy',
    'sick',
    'recovering',
    'under_treatment',
  ];

  @override
  void dispose() {
    _heightController.dispose();
    _pashuAadharController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  /// Pick vet certificate image
  Future<void> _pickVetCertificate() async {
    try {
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _vetCertificateFile = File(pickedFile.path);
          _vetCertificateKey = null; // Reset uploaded key
        });
      }
    } catch (e) {
      showErrorToast('Failed to pick image');
    }
  }

  /// Show image source selection dialog
  Future<ImageSource?> _showImageSourceDialog() async {
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

  /// Handle Next button press
  Future<void> _handleNext() async {
    setState(() => _isSubmitting = true);

    try {
      // Upload vet certificate if selected but not uploaded
      if (_vetCertificateFile != null && _vetCertificateKey == null) {
        setState(() => _isUploadingCertificate = true);
        final uploadResult = await _backendHelper.postUploadFile(
          _vetCertificateFile!.path,
          'vet_certificates',
        );
        _vetCertificateKey = uploadResult['key'] as String?;
        setState(() => _isUploadingCertificate = false);
      }

      // Build PATCH data - only include non-null fields
      final patchData = <String, dynamic>{};

      if (_vaccinationStatus != null) {
        patchData['vaccination_status'] = _vaccinationStatus;
      }
      if (_healthStatus != null) {
        patchData['health_status'] = _healthStatus;
      }
      if (_vetCertificateKey != null) {
        patchData['vet_certificate'] = _vetCertificateKey;
      }

      final pashuAadhar = _pashuAadharController.text.trim();
      if (pashuAadhar.isNotEmpty) {
        patchData['pashu_aadhar'] = pashuAadhar;
      }

      final color = _colorController.text.trim();
      if (color.isNotEmpty) {
        patchData['color'] = color;
      }

      final height = double.tryParse(_heightController.text.trim());
      if (height != null && height > 0) {
        patchData['height_cm'] = height;
      }

      // Only call PATCH if there's data to update
      if (patchData.isNotEmpty) {
        await _backendHelper.patchUpdateListing(widget.listingId, patchData);
        if (!mounted) return;
        showSuccessToast('Health information saved!');
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      widget.onNext();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isUploadingCertificate = false;
      });
      showErrorToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Health Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Provide health details of the animal (optional)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Vaccination Status
                _buildSectionTitle('Vaccination Status'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildVaccinationChip(
                        label: 'Vaccinated',
                        icon: Icons.check_circle_outline,
                        isSelected: _vaccinationStatus == 'vaccinated',
                        onTap: () => setState(() => _vaccinationStatus = 'vaccinated'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildVaccinationChip(
                        label: 'Not Vaccinated',
                        icon: Icons.cancel_outlined,
                        isSelected: _vaccinationStatus == 'not_vaccinated',
                        onTap: () => setState(() => _vaccinationStatus = 'not_vaccinated'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Health Status
                _buildSectionTitle('Health Status'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _healthStatus,
                  hint: const Text('Select health status'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.authPrimaryColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.authPrimaryColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.authPrimaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _healthStatusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_formatHealthStatus(status)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _healthStatus = value),
                ),

                const SizedBox(height: 24),

                // Vet Certificate
                _buildSectionTitle('Vet Certificate'),
                const SizedBox(height: 12),
                _buildVetCertificatePicker(),

                const SizedBox(height: 24),

                // Pashu Aadhar
                _buildSectionTitle('Pashu Aadhar'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pashuAadharController,
                  decoration: InputDecoration(
                    hintText: 'Enter animal ID number',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.authPrimaryColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.authPrimaryColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.authPrimaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Color and Height Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Color
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Color'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _colorController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Brown',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.authPrimaryColor.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.authPrimaryColor.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.authPrimaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Height
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Height (cm)'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'e.g. 140',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.authPrimaryColor.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.authPrimaryColor.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.authPrimaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Fixed navigation buttons at bottom
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authPrimaryColor,
                    disabledBackgroundColor: AppTheme.authPrimaryColor.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Next',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildVaccinationChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.authPrimaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.authPrimaryColor : AppTheme.authPrimaryColor.withOpacity(0.5),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.authPrimaryColor.withOpacity(0.2)
                  : AppTheme.authPrimaryColor.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.authPrimaryColor : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.authPrimaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVetCertificatePicker() {
    if (_vetCertificateFile != null) {
      return Stack(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.authPrimaryColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    _vetCertificateFile!,
                    fit: BoxFit.cover,
                  ),
                  if (_isUploadingCertificate)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Uploading...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _vetCertificateFile = null;
                  _vetCertificateKey = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickVetCertificate,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.authPrimaryColor.withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_file_outlined,
                size: 40,
                color: AppTheme.authPrimaryColor.withOpacity(0.6),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload Vet Certificate',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'JPG, PNG (Max 5MB)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatHealthStatus(String status) {
    return status
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
