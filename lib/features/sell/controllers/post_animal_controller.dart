import 'package:flutter_app/core/base/base_controller.dart';

/// Data class for animal listing
class AnimalListingData {
  // Listing ID (set after POST, used for PATCH)
  int? listingId;

  // Details tab (POST fields)
  String? title;
  String? description;
  String? animalType;
  String? breed;
  int? animalId; // Animal ID from catalog
  int? farmId;
  String? gender;
  int? ageMonths;
  double? weightKg;
  double? price;
  String? currency;
  String? priceType;

  // Health tab (PATCH fields)
  String? vaccinationStatus; // "vaccinated" | "not_vaccinated"
  String? healthStatus; // e.g., "healthy"
  String? vetCertificateKey; // GCS key from upload
  String? pashuAadhar; // Animal ID number
  String? color;
  double? heightCm;

  // Media tab (PATCH fields)
  List<String>? animalImageKeys; // GCS keys from upload
  List<String>? animalImageUrls; // Full URLs for display

  AnimalListingData({
    this.listingId,
    this.title,
    this.description,
    this.animalType,
    this.breed,
    this.animalId,
    this.farmId,
    this.gender,
    this.ageMonths,
    this.weightKg,
    this.price,
    this.currency,
    this.priceType,
    this.vaccinationStatus,
    this.healthStatus,
    this.vetCertificateKey,
    this.pashuAadhar,
    this.color,
    this.heightCm,
    this.animalImageKeys,
    this.animalImageUrls,
  });

  /// Check if listing is complete and ready to publish
  bool isComplete() {
    return listingId != null &&
        animalType != null &&
        breed != null &&
        gender != null &&
        ageMonths != null &&
        price != null;
  }

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'listing_id': listingId,
      'title': title,
      'description': description,
      'animal_type': animalType,
      'breed': breed,
      'animal': animalId,
      'farm': farmId,
      'gender': gender,
      'age_months': ageMonths,
      'weight_kg': weightKg,
      'price': price,
      'currency': currency,
      'price_type': priceType,
      'vaccination_status': vaccinationStatus,
      'health_status': healthStatus,
      'vet_certificate': vetCertificateKey,
      'pashu_aadhar': pashuAadhar,
      'color': color,
      'height_cm': heightCm,
      'animal_images': animalImageKeys,
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
    _listingData.listingId = id;
    notifyListeners();
  }

  /// Get listing ID
  int? get listingId => _listingData.listingId;

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

  /// Update listing data - Details tab
  void updateDetailsData({
    String? title,
    String? description,
    String? animalType,
    String? breed,
    int? animalId,
    int? farmId,
    String? gender,
    int? ageMonths,
    double? weightKg,
    double? price,
    String? currency,
    String? priceType,
  }) {
    if (title != null) _listingData.title = title;
    if (description != null) _listingData.description = description;
    if (animalType != null) _listingData.animalType = animalType;
    if (breed != null) _listingData.breed = breed;
    if (animalId != null) _listingData.animalId = animalId;
    if (farmId != null) _listingData.farmId = farmId;
    if (gender != null) _listingData.gender = gender;
    if (ageMonths != null) _listingData.ageMonths = ageMonths;
    if (weightKg != null) _listingData.weightKg = weightKg;
    if (price != null) _listingData.price = price;
    if (currency != null) _listingData.currency = currency;
    if (priceType != null) _listingData.priceType = priceType;

    notifyListeners();
  }

  /// Update listing data - Health tab
  void updateHealthData({
    String? vaccinationStatus,
    String? healthStatus,
    String? vetCertificateKey,
    String? pashuAadhar,
    String? color,
    double? heightCm,
  }) {
    if (vaccinationStatus != null) _listingData.vaccinationStatus = vaccinationStatus;
    if (healthStatus != null) _listingData.healthStatus = healthStatus;
    if (vetCertificateKey != null) _listingData.vetCertificateKey = vetCertificateKey;
    if (pashuAadhar != null) _listingData.pashuAadhar = pashuAadhar;
    if (color != null) _listingData.color = color;
    if (heightCm != null) _listingData.heightCm = heightCm;

    notifyListeners();
  }

  /// Update listing data - Media tab
  void updateMediaData({
    List<String>? animalImageKeys,
    List<String>? animalImageUrls,
  }) {
    if (animalImageKeys != null) _listingData.animalImageKeys = animalImageKeys;
    if (animalImageUrls != null) _listingData.animalImageUrls = animalImageUrls;

    notifyListeners();
  }

  /// Validate current step
  bool validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Details
        return _listingData.animalType != null &&
            _listingData.breed != null &&
            _listingData.gender != null &&
            _listingData.ageMonths != null &&
            _listingData.price != null;
      case 1: // Health
        return true; // Health tab is optional
      case 2: // Media
        return true; // Media is optional
      case 3: // Preview
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
      // TODO: Call API to publish listing if needed
      // For now, listing is already created via POST and updated via PATCH

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
    // Reset all listing data
    _listingData.listingId = null;
    _listingData.title = null;
    _listingData.description = null;
    _listingData.animalType = null;
    _listingData.breed = null;
    _listingData.animalId = null;
    _listingData.farmId = null;
    _listingData.gender = null;
    _listingData.ageMonths = null;
    _listingData.weightKg = null;
    _listingData.price = null;
    _listingData.currency = null;
    _listingData.priceType = null;
    _listingData.vaccinationStatus = null;
    _listingData.healthStatus = null;
    _listingData.vetCertificateKey = null;
    _listingData.pashuAadhar = null;
    _listingData.color = null;
    _listingData.heightCm = null;
    _listingData.animalImageKeys = null;
    _listingData.animalImageUrls = null;
    clearError();
    notifyListeners();
  }
}
