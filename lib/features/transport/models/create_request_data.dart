/// Create Request Data Model
///
/// Holds data collected during the create request wizard flow.
library;

import 'package:flutter/material.dart';
import 'package:flutter_app/features/transport/models/cargo_animal_model.dart';
import 'package:flutter_app/features/transport/models/fare_estimate_model.dart';
import 'package:flutter_app/features/transport/widgets/location_picker_widget.dart';

class CreateRequestData {
  // Step 1: Animal Selection
  final List<CargoAnimalModel> cargoAnimals;

  // Step 2: Location Selection
  final LocationData? sourceLocation;
  final LocationData? destinationLocation;

  // Step 3: Date/Time Selection
  final DateTime? pickupDate;
  final TimeOfDay? pickupTime;
  final String? notes;

  // Step 4: Fare Estimate (populated after API call)
  final FareEstimateModel? fareEstimate;

  const CreateRequestData({
    this.cargoAnimals = const [],
    this.sourceLocation,
    this.destinationLocation,
    this.pickupDate,
    this.pickupTime,
    this.notes,
    this.fareEstimate,
  });

  /// Check if step 1 (animals) is complete
  bool get isStep1Complete => cargoAnimals.isNotEmpty;

  /// Check if step 2 (locations) is complete
  bool get isStep2Complete =>
      sourceLocation != null && destinationLocation != null;

  /// Check if step 3 (date/time) is complete
  bool get isStep3Complete => pickupDate != null;

  /// Check if all steps are complete
  bool get isComplete => isStep1Complete && isStep2Complete && isStep3Complete;

  /// Get total animal count
  int get totalAnimalCount =>
      cargoAnimals.fold(0, (sum, c) => sum + c.count);

  /// Get cargo summary
  String get cargoSummary {
    if (cargoAnimals.isEmpty) return 'No animals selected';
    return cargoAnimals.map((c) => c.summary).join(', ');
  }

  /// Get formatted pickup date
  String? get formattedPickupDate {
    if (pickupDate == null) return null;
    return '${pickupDate!.day}/${pickupDate!.month}/${pickupDate!.year}';
  }

  /// Get formatted pickup time
  String? get formattedPickupTime {
    if (pickupTime == null) return null;
    final hour = pickupTime!.hourOfPeriod == 0 ? 12 : pickupTime!.hourOfPeriod;
    final period = pickupTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${pickupTime!.minute.toString().padLeft(2, '0')} $period';
  }

  CreateRequestData copyWith({
    List<CargoAnimalModel>? cargoAnimals,
    LocationData? sourceLocation,
    LocationData? destinationLocation,
    DateTime? pickupDate,
    TimeOfDay? pickupTime,
    String? notes,
    FareEstimateModel? fareEstimate,
    bool clearSourceLocation = false,
    bool clearDestinationLocation = false,
    bool clearPickupTime = false,
    bool clearNotes = false,
    bool clearFareEstimate = false,
  }) {
    return CreateRequestData(
      cargoAnimals: cargoAnimals ?? this.cargoAnimals,
      sourceLocation:
          clearSourceLocation ? null : (sourceLocation ?? this.sourceLocation),
      destinationLocation: clearDestinationLocation
          ? null
          : (destinationLocation ?? this.destinationLocation),
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTime: clearPickupTime ? null : (pickupTime ?? this.pickupTime),
      notes: clearNotes ? null : (notes ?? this.notes),
      fareEstimate:
          clearFareEstimate ? null : (fareEstimate ?? this.fareEstimate),
    );
  }

  /// Convert to API request body
  Map<String, dynamic> toRequestBody() {
    if (!isComplete) {
      throw StateError('CreateRequestData is not complete');
    }

    final data = <String, dynamic>{
      'source_address': sourceLocation!.address,
      'source_latitude': sourceLocation!.latitude,
      'source_longitude': sourceLocation!.longitude,
      'destination_address': destinationLocation!.address,
      'destination_latitude': destinationLocation!.latitude,
      'destination_longitude': destinationLocation!.longitude,
      'cargo_animals': cargoAnimals.map((c) => c.toJson()).toList(),
      'pickup_date': pickupDate!.toIso8601String().split('T')[0],
    };

    if (pickupTime != null) {
      data['pickup_time'] =
          '${pickupTime!.hour.toString().padLeft(2, '0')}:${pickupTime!.minute.toString().padLeft(2, '0')}';
    }

    if (notes != null && notes!.isNotEmpty) {
      data['notes'] = notes;
    }

    return data;
  }

  @override
  String toString() {
    return 'CreateRequestData(animals: $totalAnimalCount, '
        'source: ${sourceLocation?.address}, '
        'dest: ${destinationLocation?.address}, '
        'date: $formattedPickupDate)';
  }
}
