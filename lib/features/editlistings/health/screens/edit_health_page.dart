import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/editlistings/health/controllers/edit_health_controller.dart';
import 'package:flutter_app/features/editlistings/health/mixins/edit_health_state_mixin.dart';
import 'package:flutter_app/features/postlistings/health/widgets/health_status_dropdown.dart';
import 'package:flutter_app/features/postlistings/health/widgets/vaccination_selector.dart';
import 'package:flutter_app/features/postlistings/health/widgets/vet_certificate_picker.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Edit listing health page: same UI as postlistings HealthPage, pre-fills from listing.
class EditHealthPage extends StatefulWidget {
  final int listingId;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const EditHealthPage({
    super.key,
    required this.listingId,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<EditHealthPage> createState() => _EditHealthPageState();
}

class _EditHealthPageState extends State<EditHealthPage>
    with EditHealthStateMixin, ToastMixin {
  late final EditHealthController _controller;
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    _controller = EditHealthController();
    initializeControllers();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final listing = await _controller.loadListing(widget.listingId);
    if (!mounted) return;
    if (listing != null) {
      preFillFromListing(listing);
    }
    if (mounted) setState(() => _initialLoadDone = true);
  }

  @override
  void dispose() {
    disposeControllers();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    setSubmitting(true);
    try {
      if (vetCertificateFile != null && vetCertificateKey == null) {
        final uploadResult =
            await _controller.uploadVetCertificate(vetCertificateFile!.path);
        if (!mounted) return;
        if (uploadResult.success && uploadResult.fileKey != null) {
          setState(() => vetCertificateKey = uploadResult.fileKey);
        } else {
          setSubmitting(false);
          showErrorToast(uploadResult.errorMessage ?? 'Failed to upload certificate');
          return;
        }
      }
      final healthData = getHealthData();
      if (healthData.isNotEmpty) {
        final result = await _controller.updateHealthInfo(widget.listingId, healthData);
        if (!mounted) return;
        if (result.success) {
          setSubmitting(false);
          showSuccessToast('Health information saved!');
          widget.onNext();
        } else {
          setSubmitting(false);
          showErrorToast(result.errorMessage ?? 'Failed to save health information');
        }
      } else {
        if (!mounted) return;
        setSubmitting(false);
        widget.onNext();
      }
    } catch (e) {
      if (!mounted) return;
      setSubmitting(false);
      showErrorToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialLoadDone) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
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
                _buildSectionTitle('Vaccination Status'),
                const SizedBox(height: 12),
                VaccinationSelector(
                  vaccinationStatus: vaccinationStatus,
                  onVaccinationSelected: setVaccinationStatus,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Health Status'),
                const SizedBox(height: 12),
                HealthStatusDropdown(
                  healthStatus: healthStatus,
                  healthStatusOptions: healthStatusOptions,
                  onHealthStatusSelected: setHealthStatus,
                  formatHealthStatus: formatHealthStatus,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Vet Certificate'),
                const SizedBox(height: 12),
                VetCertificatePicker(
                  vetCertificateFile: vetCertificateFile,
                  vetCertificateUrl: vetCertificateUrl, // Pass existing certificate URL
                  isUploading: _controller.isUploadingCertificate,
                  onPickCertificate: () => pickVetCertificate(context),
                  onClearCertificate: clearVetCertificate,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Pashu Aadhar'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pashuAadharController,
                  decoration: _buildInputDecoration(
                    hintText: 'Enter animal ID number',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Color'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: colorController,
                            decoration: _buildInputDecoration(hintText: 'e.g. Brown'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Height (cm)'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration(hintText: 'e.g. 140'),
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
        Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).padding.bottom + 20, // Add system nav bar padding
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : widget.onPrevious,
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
                  onPressed: isSubmitting ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authPrimaryColor,
                    disabledBackgroundColor: AppTheme.authPrimaryColor.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isSubmitting
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

  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
