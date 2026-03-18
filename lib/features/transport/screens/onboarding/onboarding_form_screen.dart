/// Onboarding Form Screen
///
/// Captures business details and documents for transport provider onboarding.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/features/transport/controllers/transport_onboarding_controller.dart';
import 'package:flutter_app/features/transport/services/transport_navigation_service.dart';

class OnboardingFormScreen extends StatefulWidget {
  const OnboardingFormScreen({super.key});

  @override
  State<OnboardingFormScreen> createState() => _OnboardingFormScreenState();
}

class _OnboardingFormScreenState extends State<OnboardingFormScreen> {
  late TransportOnboardingController _controller;
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  int? _selectedExperience;
  int? _selectedRadius;
  DateTime? _selectedLicenseExpiry;
  String? _licenseImagePath;
  String? _rcImagePath;

  final List<int> _experienceYears = [1, 2, 3, 5, 10, 15, 20];
  final List<int> _radiusOptions = [25, 50, 75, 100];

  @override
  void initState() {
    super.initState();
    _controller = TransportOnboardingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _businessNameController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;
    if (_selectedExperience == null) {
      _showError('Please select years of experience');
      return false;
    }
    if (_selectedRadius == null) {
      _showError('Please select service radius');
      return false;
    }
    if (_selectedLicenseExpiry == null) {
      _showError('Please select license expiry date');
      return false;
    }
    if (_licenseImagePath == null) {
      _showError('Please upload your driving license');
      return false;
    }
    if (_rcImagePath == null) {
      _showError('Please upload your vehicle RC');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    // First upload the images
    final licenseUploaded = await _controller.uploadDrivingLicense(_licenseImagePath!);
    if (!licenseUploaded || !mounted) {
      _showError(_controller.errorMessage ?? 'Failed to upload license');
      return;
    }

    final rcUploaded = await _controller.uploadVehicleRc(_rcImagePath!);
    if (!rcUploaded || !mounted) {
      _showError(_controller.errorMessage ?? 'Failed to upload RC');
      return;
    }

    // Now submit the form
    final success = await _controller.submitOnboarding(
      businessName: _businessNameController.text.trim(),
      yearsOfExperience: _selectedExperience ?? 1,
      serviceRadiusKm: _selectedRadius ?? 50,
      drivingLicenseNumber: _licenseNumberController.text.trim(),
      drivingLicenseExpiry: _selectedLicenseExpiry!,
    );

    if (success && mounted) {
      final requestId = _controller.request?.requestId;
      if (requestId != null) {
        TransportNavigationService.navigateToPendingApproval(context, requestId);
      }
    } else if (mounted) {
      _showError(_controller.errorMessage ?? 'Failed to submit application');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<TransportOnboardingController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Provider Application'),
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Business Details Section
                    _buildSectionHeader(context, 'Business Details'),
                    const SizedBox(height: 16),

                    // Business name
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        hintText: 'Enter your business name',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Business name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Years of experience
                    DropdownButtonFormField<int>(
                      value: _selectedExperience,
                      decoration: const InputDecoration(
                        labelText: 'Years of Experience',
                        prefixIcon: Icon(Icons.work_history),
                      ),
                      items: _experienceYears.map((years) {
                        return DropdownMenuItem(
                          value: years,
                          child: Text('$years+ years'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedExperience = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select experience';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Service radius
                    DropdownButtonFormField<int>(
                      value: _selectedRadius,
                      decoration: const InputDecoration(
                        labelText: 'Service Radius',
                        prefixIcon: Icon(Icons.radar),
                      ),
                      items: _radiusOptions.map((radius) {
                        return DropdownMenuItem(
                          value: radius,
                          child: Text('$radius km'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRadius = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select service radius';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Driving License Section
                    _buildSectionHeader(context, 'Driving License'),
                    const SizedBox(height: 16),

                    // License image
                    _buildImagePicker(
                      context,
                      label: 'License Photo',
                      imagePath: _licenseImagePath,
                      onPick: () => _pickImage(isLicense: true),
                      onRemove: () {
                        setState(() {
                          _licenseImagePath = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // License number
                    TextFormField(
                      controller: _licenseNumberController,
                      decoration: const InputDecoration(
                        labelText: 'License Number',
                        hintText: 'e.g., MH12 20190012345',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'License number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // License expiry
                    InkWell(
                      onTap: () => _selectDate(),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'License Expiry Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedLicenseExpiry != null
                              ? '${_selectedLicenseExpiry!.day}/${_selectedLicenseExpiry!.month}/${_selectedLicenseExpiry!.year}'
                              : 'Select date',
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Vehicle RC Section
                    _buildSectionHeader(context, 'Vehicle RC Document'),
                    const SizedBox(height: 16),

                    // RC image
                    _buildImagePicker(
                      context,
                      label: 'RC Document Photo',
                      imagePath: _rcImagePath,
                      onPick: () => _pickImage(isLicense: false),
                      onRemove: () {
                        setState(() {
                          _rcImagePath = null;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Error message
                    if (controller.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Submit button
                    ElevatedButton(
                      onPressed: controller.isLoading || controller.isUploading
                          ? null
                          : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading || controller.isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Submit Application',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildImagePicker(
    BuildContext context, {
    required String label,
    required String? imagePath,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final theme = Theme.of(context);

    if (imagePath != null) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 48, color: theme.colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(imagePath.split('/').last),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to upload',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage({required bool isLicense}) async {
    // TODO: Implement image picker using image_picker package
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isLicense ? 'Upload License' : 'Upload RC Document'),
        content: const Text('Image picker will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'selected_image.jpg'),
            child: const Text('Select'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        if (isLicense) {
          _licenseImagePath = result;
        } else {
          _rcImagePath = result;
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 20)),
    );

    if (picked != null) {
      setState(() {
        _selectedLicenseExpiry = picked;
      });
    }
  }
}
