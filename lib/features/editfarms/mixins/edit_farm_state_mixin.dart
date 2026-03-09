import 'package:flutter/material.dart';
import 'package:flutter_app/features/location/models/location_model.dart';
import 'package:flutter_app/features/postlistings/mixins/farm_state_mixin.dart';

/// Mixin for edit farm page: adds pre-fill from API farm response
mixin EditFarmStateMixin<T extends StatefulWidget> on State<T>, FarmStateMixin<T> {
  /// Pre-fill form from farm API response (getFarmById)
  void preFillFromFarm(Map<String, dynamic> farm) {
    if (!mounted) return;

    setState(() {
      nameController.text = farm['name']?.toString() ?? '';
      
      // Handle area_sq_m - can be empty string or numeric value
      final areaSqM = farm['area_sq_m'];
      if (areaSqM != null && areaSqM.toString().isNotEmpty) {
        areaController.text = areaSqM.toString();
      }
      
      addressController.text = farm['address']?.toString() ?? '';

      // Set location if available - latitude and longitude are strings
      final lat = farm['latitude'];
      final lng = farm['longitude'];
      if (lat != null && lng != null && 
          lat.toString().isNotEmpty && lng.toString().isNotEmpty) {
        final latitude = _parseDouble(lat);
        final longitude = _parseDouble(lng);
        
      if (latitude != null && longitude != null) {
        selectedLocation = LocationData(
          fullAddress: farm['address']?.toString(),
          latitude: latitude,
          longitude: longitude,
        );
        locationController.text = farm['address']?.toString() ?? selectedLocation!.displayLocation;
      }
      }
    });
  }

  /// Parse dynamic value to double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleaned);
    }
    return null;
  }
}
