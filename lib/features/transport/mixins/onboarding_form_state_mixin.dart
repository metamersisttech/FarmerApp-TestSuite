/// Onboarding Form State Mixin
///
/// Provides form state and validation for transport onboarding.
library;

import 'package:flutter/material.dart';

mixin OnboardingFormStateMixin<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();

  final businessNameController = TextEditingController();
  final licenseNumberController = TextEditingController();

  int? selectedExperience;
  int? selectedServiceRadius;
  DateTime? selectedLicenseExpiry;
  String? drivingLicenseImagePath;
  String? vehicleRcImagePath;

  bool isSubmitting = false;

  // Alias getters for compatibility
  int? get selectedRadius => selectedServiceRadius;
  set selectedRadius(int? value) => selectedServiceRadius = value;
  String? get licenseImagePath => drivingLicenseImagePath;
  set licenseImagePath(String? value) => drivingLicenseImagePath = value;
  String? get rcImagePath => vehicleRcImagePath;
  set rcImagePath(String? value) => vehicleRcImagePath = value;

  /// Experience options
  final List<int> experienceOptions = [1, 2, 3, 4, 5, 7, 10, 15, 20];

  /// Service radius options (in km)
  final List<int> serviceRadiusOptions = [25, 50, 75, 100, 150, 200];

  /// Validate business name
  String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your business name';
    }
    if (value.trim().length < 3) {
      return 'Business name must be at least 3 characters';
    }
    return null;
  }

  /// Validate license number
  String? validateLicenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your driving license number';
    }
    // Basic format validation (Indian DL format)
    final pattern = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{4}[0-9]{7}$');
    if (!pattern.hasMatch(value.trim().toUpperCase().replaceAll(' ', ''))) {
      return 'Please enter a valid driving license number';
    }
    return null;
  }

  /// Validate experience selection
  String? validateExperience() {
    if (selectedExperience == null) {
      return 'Please select your years of experience';
    }
    return null;
  }

  /// Validate service radius selection
  String? validateServiceRadius() {
    if (selectedServiceRadius == null) {
      return 'Please select your service radius';
    }
    return null;
  }

  /// Validate license expiry date
  String? validateLicenseExpiry() {
    if (selectedLicenseExpiry == null) {
      return 'Please select license expiry date';
    }
    if (selectedLicenseExpiry!.isBefore(DateTime.now())) {
      return 'License has expired';
    }
    // Must be valid for at least 3 months
    final threeMonthsLater = DateTime.now().add(const Duration(days: 90));
    if (selectedLicenseExpiry!.isBefore(threeMonthsLater)) {
      return 'License must be valid for at least 3 months';
    }
    return null;
  }

  /// Validate driving license image
  String? validateDrivingLicenseImage() {
    if (drivingLicenseImagePath == null) {
      return 'Please upload your driving license';
    }
    return null;
  }

  /// Validate vehicle RC image
  String? validateVehicleRcImage() {
    if (vehicleRcImagePath == null) {
      return 'Please upload your vehicle RC';
    }
    return null;
  }

  /// Validate all fields
  bool validateForm() {
    final formValid = formKey.currentState?.validate() ?? false;
    final experienceValid = validateExperience() == null;
    final radiusValid = validateServiceRadius() == null;
    final expiryValid = validateLicenseExpiry() == null;
    final licenseImageValid = validateDrivingLicenseImage() == null;
    final rcImageValid = validateVehicleRcImage() == null;

    return formValid &&
        experienceValid &&
        radiusValid &&
        expiryValid &&
        licenseImageValid &&
        rcImageValid;
  }

  /// Get form data
  Map<String, dynamic> getFormData() {
    return {
      'businessName': businessNameController.text.trim(),
      'yearsOfExperience': selectedExperience,
      'serviceRadiusKm': selectedServiceRadius,
      'drivingLicenseNumber': licenseNumberController.text.trim().toUpperCase(),
      'drivingLicenseExpiry': selectedLicenseExpiry,
      'drivingLicenseImagePath': drivingLicenseImagePath,
      'vehicleRcImagePath': vehicleRcImagePath,
    };
  }

  /// Set experience
  void setExperience(int? experience) {
    setState(() {
      selectedExperience = experience;
    });
  }

  /// Set service radius
  void setServiceRadius(int? radius) {
    setState(() {
      selectedServiceRadius = radius;
    });
  }

  /// Set license expiry
  void setLicenseExpiry(DateTime? expiry) {
    setState(() {
      selectedLicenseExpiry = expiry;
    });
  }

  /// Set driving license image
  void setDrivingLicenseImage(String? path) {
    setState(() {
      drivingLicenseImagePath = path;
    });
  }

  /// Set vehicle RC image
  void setVehicleRcImage(String? path) {
    setState(() {
      vehicleRcImagePath = path;
    });
  }

  /// Set submitting state
  void setSubmitting(bool value) {
    setState(() {
      isSubmitting = value;
    });
  }

  /// Reset form
  void resetForm() {
    businessNameController.clear();
    licenseNumberController.clear();
    setState(() {
      selectedExperience = null;
      selectedServiceRadius = null;
      selectedLicenseExpiry = null;
      drivingLicenseImagePath = null;
      vehicleRcImagePath = null;
      isSubmitting = false;
    });
    formKey.currentState?.reset();
  }

  /// Dispose form state (call in State.dispose before super.dispose)
  void disposeFormState() {
    businessNameController.dispose();
    licenseNumberController.dispose();
  }
}
