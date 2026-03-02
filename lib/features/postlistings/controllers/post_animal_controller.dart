import 'package:flutter_app/core/base/base_controller.dart';

/// Controller for post animal form operations (orchestrator)
class PostAnimalController extends BaseController {
  int _currentStep = 0;
  int? _listingId;

  /// Current step in the form
  int get currentStep => _currentStep;

  /// Listing ID
  int? get listingId => _listingId;

  /// Total number of steps (Details, Health, Media, Preview)
  static const int totalSteps = 4;

  /// Step labels
  static const List<String> stepLabels = [
    'Details',
    'Health',
    'Media',
    'Preview',
  ];

  /// Set listing ID (called after POST creates listing)
  void setListingId(int id) {
    _listingId = id;
    notifyListeners();
  }

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  /// Go to next step
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Go to previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Reset form
  void reset() {
    _currentStep = 0;
    _listingId = null;
    clearError();
    notifyListeners();
  }
}
