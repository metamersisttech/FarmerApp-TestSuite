import 'package:flutter_app/core/base/base_controller.dart';

/// Data class for animal listing
class AnimalListingData {
  // Details tab
  String? animalType;
  String? breed;
  String? gender;
  String? age;
  String? weight;
  String? priceType;
  String? price;

  // Health tab
  bool? isVaccinated;
  String? lastVaccinationDate;
  String? healthNotes;

  // Location tab
  String? state;
  String? city;
  String? pincode;
  String? address;

  // Media tab
  List<String>? imageUrls;
  List<String>? videoUrls;

  AnimalListingData({
    this.animalType,
    this.breed,
    this.gender,
    this.age,
    this.weight,
    this.priceType,
    this.price,
    this.isVaccinated,
    this.lastVaccinationDate,
    this.healthNotes,
    this.state,
    this.city,
    this.pincode,
    this.address,
    this.imageUrls,
    this.videoUrls,
  });

  /// Check if listing is complete and ready to publish
  bool isComplete() {
    return animalType != null &&
        breed != null &&
        gender != null &&
        age != null &&
        price != null &&
        state != null &&
        city != null;
  }

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'animal_type': animalType,
      'breed': breed,
      'gender': gender,
      'age': age,
      'weight': weight,
      'price_type': priceType,
      'price': price,
      'is_vaccinated': isVaccinated,
      'last_vaccination_date': lastVaccinationDate,
      'health_notes': healthNotes,
      'state': state,
      'city': city,
      'pincode': pincode,
      'address': address,
      'image_urls': imageUrls,
      'video_urls': videoUrls,
    };
  }
}

/// Controller for post animal form operations
class PostAnimalController extends BaseController {
  int _currentStep = 0;
  final AnimalListingData _listingData = AnimalListingData();

  /// Current step in the form
  int get currentStep => _currentStep;

  /// Listing data
  AnimalListingData get listingData => _listingData;

  /// Total number of steps
  static const int totalSteps = 5;

  /// Step labels
  static const List<String> stepLabels = [
    'Details',
    'Health',
    'Location',
    'Media',
    'Preview',
  ];

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

  /// Update listing data
  void updateListingData({
    String? animalType,
    String? breed,
    String? gender,
    String? age,
    String? weight,
    String? priceType,
    String? price,
    bool? isVaccinated,
    String? lastVaccinationDate,
    String? healthNotes,
    String? state,
    String? city,
    String? pincode,
    String? address,
    List<String>? imageUrls,
    List<String>? videoUrls,
  }) {
    if (animalType != null) _listingData.animalType = animalType;
    if (breed != null) _listingData.breed = breed;
    if (gender != null) _listingData.gender = gender;
    if (age != null) _listingData.age = age;
    if (weight != null) _listingData.weight = weight;
    if (priceType != null) _listingData.priceType = priceType;
    if (price != null) _listingData.price = price;
    if (isVaccinated != null) _listingData.isVaccinated = isVaccinated;
    if (lastVaccinationDate != null) _listingData.lastVaccinationDate = lastVaccinationDate;
    if (healthNotes != null) _listingData.healthNotes = healthNotes;
    if (state != null) _listingData.state = state;
    if (city != null) _listingData.city = city;
    if (pincode != null) _listingData.pincode = pincode;
    if (address != null) _listingData.address = address;
    if (imageUrls != null) _listingData.imageUrls = imageUrls;
    if (videoUrls != null) _listingData.videoUrls = videoUrls;
    
    notifyListeners();
  }

  /// Validate current step
  bool validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Details
        return _listingData.animalType != null &&
            _listingData.breed != null &&
            _listingData.gender != null &&
            _listingData.age != null;
      case 1: // Health
        return true; // Health tab is optional
      case 2: // Location
        return _listingData.state != null && _listingData.city != null;
      case 3: // Media
        return true; // Media is optional
      case 4: // Preview
        return _listingData.isComplete();
      default:
        return false;
    }
  }

  /// Publish listing
  Future<bool> publishListing() async {
    if (!_listingData.isComplete()) {
      setError('Please complete all required fields');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      // TODO: Call API to publish listing
      // await _sellService.publishListing(_listingData.toJson());
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      setLoading(false);
      return true;
    } catch (e) {
      setError('Failed to publish listing. Please try again.');
      setLoading(false);
      return false;
    }
  }

  /// Reset form
  void reset() {
    _currentStep = 0;
    _listingData.animalType = null;
    _listingData.breed = null;
    _listingData.gender = null;
    _listingData.age = null;
    _listingData.weight = null;
    _listingData.priceType = null;
    _listingData.price = null;
    _listingData.isVaccinated = null;
    _listingData.lastVaccinationDate = null;
    _listingData.healthNotes = null;
    _listingData.state = null;
    _listingData.city = null;
    _listingData.pincode = null;
    _listingData.address = null;
    _listingData.imageUrls = null;
    _listingData.videoUrls = null;
    clearError();
    notifyListeners();
  }
}

