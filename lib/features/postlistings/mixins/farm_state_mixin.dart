import 'package:flutter/material.dart';
import 'package:flutter_app/features/location/models/location_model.dart';

/// Mixin for farm form state management
/// Provides common state and validation for create/edit farm forms
mixin FarmStateMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  LocationData? selectedLocation;

  @override
  void dispose() {
    nameController.dispose();
    areaController.dispose();
    addressController.dispose();
    locationController.dispose();
    super.dispose();
  }

  /// Validate farm name field
  String? validateFarmName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter farm name';
    }
    if (value.trim().length < 3) {
      return 'Farm name must be at least 3 characters';
    }
    return null;
  }

  /// Validate area field
  String? validateArea(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter area';
    }
    final area = double.tryParse(value.trim());
    if (area == null || area <= 0) {
      return 'Please enter a valid area';
    }
    return null;
  }

  /// Validate address field
  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter address';
    }
    if (value.trim().length < 10) {
      return 'Please enter a more detailed address';
    }
    return null;
  }

  /// Validate form
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Build farm data map from form fields
  Map<String, dynamic> buildFarmData() {
    return {
      'name': nameController.text.trim(),
      'area_sq_m': double.tryParse(areaController.text.trim()) ?? 0,
      'address': addressController.text.trim(),
      if (selectedLocation?.latitude != null)
        'latitude': selectedLocation!.latitude,
      if (selectedLocation?.longitude != null)
        'longitude': selectedLocation!.longitude,
    };
  }

  /// Update location
  void updateLocation(LocationData location) {
    setState(() {
      selectedLocation = location;
      locationController.text = location.displayLocation;
    });
  }

  /// Clear form fields
  void clearForm() {
    nameController.clear();
    areaController.clear();
    addressController.clear();
    locationController.clear();
    selectedLocation = null;
  }
}
