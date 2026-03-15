/// Vehicle Form State Mixin
///
/// Provides form state and validation for vehicle registration.
library;

import 'package:flutter/material.dart';
import 'package:flutter_app/features/transport/models/vehicle_model.dart';

mixin VehicleFormStateMixin<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();

  final registrationController = TextEditingController();
  final makeController = TextEditingController();
  final modelController = TextEditingController();
  final maxWeightController = TextEditingController();
  final maxLengthController = TextEditingController();
  final maxWidthController = TextEditingController();
  final maxHeightController = TextEditingController();

  VehicleType? selectedVehicleType;
  int? selectedYear;
  String? rcDocumentPath;
  String? insuranceDocumentPath;
  List<String> vehicleImagePaths = [];

  bool isSubmitting = false;
  bool isEdit = false;
  int? editingVehicleId;

  // Alias controllers for compatibility
  TextEditingController get lengthController => maxLengthController;
  TextEditingController get widthController => maxWidthController;
  TextEditingController get heightController => maxHeightController;

  /// Vehicle type options
  List<VehicleType> get vehicleTypeOptions => VehicleType.values;

  /// Year options (last 25 years)
  List<int> get yearOptions {
    final currentYear = DateTime.now().year;
    return List.generate(25, (i) => currentYear - i);
  }

  /// Validate registration number
  String? validateRegistration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter registration number';
    }
    // Basic Indian vehicle registration format
    final pattern = RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{1,4}$');
    final normalized = value.trim().toUpperCase().replaceAll(' ', '');
    if (!pattern.hasMatch(normalized)) {
      return 'Please enter a valid registration number (e.g., MH12AB1234)';
    }
    return null;
  }

  /// Validate make
  String? validateMake(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter vehicle make';
    }
    if (value.trim().length < 2) {
      return 'Make must be at least 2 characters';
    }
    return null;
  }

  /// Validate model
  String? validateModel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter vehicle model';
    }
    return null;
  }

  /// Validate max weight
  String? validateMaxWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter max weight capacity';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      return 'Please enter a valid weight';
    }
    if (weight < 100) {
      return 'Weight must be at least 100 kg';
    }
    if (weight > 50000) {
      return 'Weight seems too high. Please verify.';
    }
    return null;
  }

  /// Validate optional dimension
  String? validateDimension(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final dimension = double.tryParse(value);
    if (dimension == null || dimension <= 0) {
      return 'Please enter a valid dimension';
    }
    return null;
  }

  /// Validate vehicle type
  String? validateVehicleType() {
    if (selectedVehicleType == null) {
      return 'Please select vehicle type';
    }
    return null;
  }

  /// Validate RC document (only required for new vehicles)
  String? validateRcDocument() {
    if (!isEdit && rcDocumentPath == null) {
      return 'Please upload RC document';
    }
    return null;
  }

  /// Validate insurance document (only required for new vehicles)
  String? validateInsuranceDocument() {
    if (!isEdit && insuranceDocumentPath == null) {
      return 'Please upload insurance document';
    }
    return null;
  }

  /// Validate all fields
  bool validateForm() {
    final formValid = formKey.currentState?.validate() ?? false;
    final typeValid = validateVehicleType() == null;
    final rcValid = validateRcDocument() == null;
    final insuranceValid = validateInsuranceDocument() == null;

    return formValid && typeValid && rcValid && insuranceValid;
  }

  /// Get form data
  Map<String, dynamic> getFormData() {
    return {
      'vehicleType': selectedVehicleType?.value,
      'registrationNumber': registrationController.text.trim().toUpperCase(),
      'make': makeController.text.trim(),
      'model': modelController.text.trim(),
      'year': selectedYear,
      'maxWeightKg': double.tryParse(maxWeightController.text.trim()),
      'maxLengthCm': double.tryParse(maxLengthController.text.trim()),
      'maxWidthCm': double.tryParse(maxWidthController.text.trim()),
      'maxHeightCm': double.tryParse(maxHeightController.text.trim()),
      'rcDocumentPath': rcDocumentPath,
      'insuranceDocumentPath': insuranceDocumentPath,
      'vehicleImagePaths': vehicleImagePaths,
    };
  }

  /// Set vehicle type
  void setVehicleType(VehicleType? type) {
    setState(() {
      selectedVehicleType = type;
    });
  }

  /// Set year
  void setYear(int? year) {
    setState(() {
      selectedYear = year;
    });
  }

  /// Set RC document
  void setRcDocument(String? path) {
    setState(() {
      rcDocumentPath = path;
    });
  }

  /// Set insurance document
  void setInsuranceDocument(String? path) {
    setState(() {
      insuranceDocumentPath = path;
    });
  }

  /// Add vehicle image
  void addVehicleImage(String path) {
    if (vehicleImagePaths.length < 5) {
      setState(() {
        vehicleImagePaths.add(path);
      });
    }
  }

  /// Remove vehicle image
  void removeVehicleImage(int index) {
    if (index >= 0 && index < vehicleImagePaths.length) {
      setState(() {
        vehicleImagePaths.removeAt(index);
      });
    }
  }

  /// Clear vehicle images
  void clearVehicleImages() {
    setState(() {
      vehicleImagePaths = [];
    });
  }

  /// Set submitting state
  void setSubmitting(bool value) {
    setState(() {
      isSubmitting = value;
    });
  }

  /// Initialize for editing
  void initForEdit(VehicleModel vehicle) {
    isEdit = true;
    editingVehicleId = vehicle.vehicleId;
    selectedVehicleType = vehicle.vehicleTypeEnum;
    registrationController.text = vehicle.registrationNumber;
    makeController.text = vehicle.make;
    modelController.text = vehicle.model;
    selectedYear = vehicle.year;
    maxWeightController.text = vehicle.maxWeightKg.toStringAsFixed(0);
    if (vehicle.maxLengthCm != null) {
      maxLengthController.text = vehicle.maxLengthCm!.toStringAsFixed(0);
    }
    if (vehicle.maxWidthCm != null) {
      maxWidthController.text = vehicle.maxWidthCm!.toStringAsFixed(0);
    }
    if (vehicle.maxHeightCm != null) {
      maxHeightController.text = vehicle.maxHeightCm!.toStringAsFixed(0);
    }
    // Note: Existing images are shown from model, not local paths
  }

  /// Reset form
  void resetForm() {
    registrationController.clear();
    makeController.clear();
    modelController.clear();
    maxWeightController.clear();
    maxLengthController.clear();
    maxWidthController.clear();
    maxHeightController.clear();
    setState(() {
      selectedVehicleType = null;
      selectedYear = null;
      rcDocumentPath = null;
      insuranceDocumentPath = null;
      vehicleImagePaths = [];
      isSubmitting = false;
      isEdit = false;
      editingVehicleId = null;
    });
    formKey.currentState?.reset();
  }

  /// Dispose form state (call in State.dispose before super.dispose)
  void disposeFormState() {
    registrationController.dispose();
    makeController.dispose();
    modelController.dispose();
    maxWeightController.dispose();
    maxLengthController.dispose();
    maxWidthController.dispose();
    maxHeightController.dispose();
  }
}
