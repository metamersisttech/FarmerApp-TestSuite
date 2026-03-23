/// Create Request Controller
///
/// Manages the create transport request wizard state and submission.
library;

import 'package:flutter/material.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/cargo_animal_model.dart';
import 'package:flutter_app/features/transport/models/create_request_data.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/services/requester_transport_service.dart';
import 'package:flutter_app/features/transport/widgets/location_picker_widget.dart';

class CreateRequestController extends BaseController {
  final RequesterTransportService _transportService;

  CreateRequestData _data = const CreateRequestData();
  int _currentStep = 0;
  bool _isEstimating = false;
  bool _isSubmitting = false;
  TransportRequestModel? _createdRequest;

  CreateRequestData get data => _data;
  int get currentStep => _currentStep;
  bool get isEstimating => _isEstimating;
  bool get isSubmitting => _isSubmitting;
  TransportRequestModel? get createdRequest => _createdRequest;

  /// Total number of steps in the wizard
  static const int totalSteps = 4;

  /// Step labels
  static const List<String> stepLabels = [
    'Animals',
    'Location',
    'Date',
    'Confirm',
  ];

  CreateRequestController({
    RequesterTransportService? transportService,
  }) : _transportService = transportService ?? RequesterTransportService();

  /// Check if can proceed to next step
  bool get canProceed {
    switch (_currentStep) {
      case 0:
        return _data.isStep1Complete;
      case 1:
        return _data.isStep2Complete;
      case 2:
        return _data.isStep3Complete;
      case 3:
        return _data.fareEstimate != null;
      default:
        return false;
    }
  }

  /// Check if on last step
  bool get isLastStep => _currentStep == totalSteps - 1;

  /// Check if on first step
  bool get isFirstStep => _currentStep == 0;

  // ============ Step Navigation ============

  /// Go to next step
  void nextStep() {
    if (!canProceed || _currentStep >= totalSteps - 1) return;

    _currentStep++;
    notifyListeners();

    // When moving to fare estimate step, fetch estimate
    if (_currentStep == 3 && _data.fareEstimate == null) {
      getFareEstimate();
    }
  }

  /// Go to previous step
  void previousStep() {
    if (_currentStep <= 0) return;

    _currentStep--;
    notifyListeners();
  }

  /// Go to specific step
  void goToStep(int step) {
    if (step < 0 || step >= totalSteps) return;

    // Only allow going to a step if all previous steps are complete
    switch (step) {
      case 0:
        break; // Always allowed
      case 1:
        if (!_data.isStep1Complete) return;
        break;
      case 2:
        if (!_data.isStep1Complete || !_data.isStep2Complete) return;
        break;
      case 3:
        if (!_data.isComplete) return;
        break;
    }

    _currentStep = step;
    notifyListeners();
  }

  // ============ Step 1: Animal Selection ============

  /// Update cargo animals
  void setCargoAnimals(List<CargoAnimalModel> animals) {
    _data = _data.copyWith(
      cargoAnimals: animals,
      clearFareEstimate: true, // Clear estimate when animals change
    );
    notifyListeners();
  }

  /// Add a cargo animal
  void addCargoAnimal(CargoAnimalModel animal) {
    final newList = List<CargoAnimalModel>.from(_data.cargoAnimals)..add(animal);
    setCargoAnimals(newList);
  }

  /// Remove a cargo animal
  void removeCargoAnimal(int index) {
    if (index < 0 || index >= _data.cargoAnimals.length) return;

    final newList = List<CargoAnimalModel>.from(_data.cargoAnimals)
      ..removeAt(index);
    setCargoAnimals(newList);
  }

  /// Update cargo animal at index
  void updateCargoAnimal(int index, CargoAnimalModel animal) {
    if (index < 0 || index >= _data.cargoAnimals.length) return;

    final newList = List<CargoAnimalModel>.from(_data.cargoAnimals);
    newList[index] = animal;
    setCargoAnimals(newList);
  }

  // ============ Step 2: Location Selection ============

  /// Set source location
  void setSourceLocation(LocationData? location) {
    _data = _data.copyWith(
      sourceLocation: location,
      clearSourceLocation: location == null,
      clearFareEstimate: true,
    );
    notifyListeners();
  }

  /// Set destination location
  void setDestinationLocation(LocationData? location) {
    _data = _data.copyWith(
      destinationLocation: location,
      clearDestinationLocation: location == null,
      clearFareEstimate: true,
    );
    notifyListeners();
  }

  // ============ Step 3: Date/Time Selection ============

  /// Set pickup date
  void setPickupDate(DateTime? date) {
    _data = _data.copyWith(pickupDate: date);
    notifyListeners();
  }

  /// Set pickup time
  void setPickupTime(TimeOfDay? time) {
    _data = _data.copyWith(
      pickupTime: time,
      clearPickupTime: time == null,
    );
    notifyListeners();
  }

  /// Set notes
  void setNotes(String? notes) {
    _data = _data.copyWith(
      notes: notes,
      clearNotes: notes == null || notes.isEmpty,
    );
    notifyListeners();
  }

  // ============ Step 4: Fare Estimate ============

  /// Get fare estimate from API
  Future<void> getFareEstimate() async {
    if (!_data.isComplete) return;

    if (isDisposed) return;

    _isEstimating = true;
    clearError();
    notifyListeners();

    try {
      final result = await _transportService.estimateFare(
        sourceLatitude: _data.sourceLocation!.latitude,
        sourceLongitude: _data.sourceLocation!.longitude,
        destinationLatitude: _data.destinationLocation!.latitude,
        destinationLongitude: _data.destinationLocation!.longitude,
        cargoAnimals: _data.cargoAnimals,
      );

      if (isDisposed) return;

      if (result.success && result.estimate != null) {
        _data = _data.copyWith(fareEstimate: result.estimate);
      } else {
        setError(result.errorMessage ?? 'Failed to get fare estimate');
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to get fare estimate: $e');
      }
    } finally {
      if (!isDisposed) {
        _isEstimating = false;
        notifyListeners();
      }
    }
  }

  // ============ Submit Request ============

  /// Submit the transport request
  Future<bool> submitRequest() async {
    if (!_data.isComplete || _data.fareEstimate == null) return false;

    if (isDisposed) return false;

    _isSubmitting = true;
    clearError();
    notifyListeners();

    try {
      final result = await _transportService.createRequest(
        sourceAddress: _data.sourceLocation!.address,
        sourceLatitude: _data.sourceLocation!.latitude,
        sourceLongitude: _data.sourceLocation!.longitude,
        destinationAddress: _data.destinationLocation!.address,
        destinationLatitude: _data.destinationLocation!.latitude,
        destinationLongitude: _data.destinationLocation!.longitude,
        cargoAnimals: _data.cargoAnimals,
        pickupDate: _data.pickupDate!,
        pickupTime: _data.pickupTime,
        notes: _data.notes,
      );

      if (isDisposed) return false;

      if (result.success && result.request != null) {
        _createdRequest = result.request;
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to create request');
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to create request: $e');
      }
      return false;
    } finally {
      if (!isDisposed) {
        _isSubmitting = false;
        notifyListeners();
      }
    }
  }

  // ============ Reset ============

  /// Reset the wizard to initial state
  void reset() {
    _data = const CreateRequestData();
    _currentStep = 0;
    _isEstimating = false;
    _isSubmitting = false;
    _createdRequest = null;
    clearError();
    notifyListeners();
  }
}
