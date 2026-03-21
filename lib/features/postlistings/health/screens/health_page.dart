import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/postlistings/health/controllers/health_controller.dart';
import 'package:flutter_app/features/postlistings/health/mixins/health_state_mixin.dart';
import 'package:flutter_app/features/postlistings/health/widgets/health_form_input_decoration.dart';
import 'package:flutter_app/features/postlistings/health/widgets/health_status_dropdown.dart';
import 'package:flutter_app/features/postlistings/health/widgets/navigation_buttons.dart';
import 'package:flutter_app/features/postlistings/health/widgets/section_title.dart';
import 'package:flutter_app/features/postlistings/health/widgets/vaccination_selector.dart';
import 'package:flutter_app/features/postlistings/health/widgets/vet_certificate_picker.dart';

/// Health Page - Health information
class HealthPage extends StatefulWidget {
  final int listingId;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const HealthPage({
    super.key,
    required this.listingId,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage>
    with HealthStateMixin, ToastMixin {
  late final HealthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HealthController();
    initializeHealthController(
      _controller,
      onNext: widget.onNext,
      onShowSuccess: showSuccessToast,
      onShowError: showErrorToast,
    );
  }

  @override
  void dispose() {
    disposeHealthController();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

                // Vaccination Status
                const HealthSectionTitle(title: 'Vaccination Status'),
                const SizedBox(height: 12),
                VaccinationSelector(
                  vaccinationStatus: vaccinationStatus,
                  onVaccinationSelected: setVaccinationStatus,
                ),

                const SizedBox(height: 24),

                // Health Status
                const HealthSectionTitle(title: 'Health Status'),
                const SizedBox(height: 12),
                HealthStatusDropdown(
                  healthStatus: healthStatus,
                  healthStatusOptions: healthStatusOptions,
                  onHealthStatusSelected: setHealthStatus,
                  formatHealthStatus: _controller.formatHealthStatus,
                ),

                const SizedBox(height: 24),

                // Vet Certificate
                const HealthSectionTitle(title: 'Vet Certificate'),
                const SizedBox(height: 12),
                VetCertificatePicker(
                  vetCertificateFile: vetCertificateFile,
                  isUploading: _controller.isUploadingCertificate,
                  onPickCertificate: () => pickVetCertificate(context),
                  onClearCertificate: clearVetCertificate,
                ),

                const SizedBox(height: 24),

                // Pashu Aadhar
                const HealthSectionTitle(title: 'Pashu Aadhar'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pashuAadharController,
                  decoration: HealthFormInputDecoration.build(
                    hintText: 'Enter animal ID number',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  ),
                ),

                const SizedBox(height: 24),

                // Color and Height Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HealthSectionTitle(title: 'Color'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: colorController,
                            decoration: HealthFormInputDecoration.build(
                              hintText: 'e.g. Brown',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HealthSectionTitle(title: 'Height (cm)'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            decoration: HealthFormInputDecoration.build(
                              hintText: 'e.g. 140',
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
        HealthNavigationButtons(
          isSubmitting: isSubmitting,
          onPrevious: widget.onPrevious,
          onNext: () => handleNext(widget.listingId),
        ),
      ],
    );
  }
}
