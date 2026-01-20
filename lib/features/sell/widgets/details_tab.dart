import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/animal_model.dart';
import 'package:flutter_app/data/repositories/animal_repository.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Details Tab - Animal type, breed, gender, etc.
class DetailsTab extends StatefulWidget {
  /// Callback when form is submitted successfully, passes the created listing ID
  final void Function(int listingId) onNext;
  final VoidCallback? onPrevious;

  const DetailsTab({
    super.key,
    required this.onNext,
    this.onPrevious,
  });

  @override
  State<DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> with ToastMixin {
  final AnimalRepository _animalRepository = AnimalRepository();
  final BackendHelper _backendHelper = BackendHelper();

  String? _selectedAnimalType;
  String? _selectedBreed;
  int? _selectedAnimalId; // Animal ID for API
  String? _selectedGender;
  String? _selectedAge;
  String? _selectedPriceType;
  int? _selectedFarmId;
  String? _selectedFarmName;

  // Farms data from API
  List<Map<String, dynamic>> _farms = [];
  bool _isLoadingFarms = false;

  // Form submission state
  bool _isSubmitting = false;

  final TextEditingController _animalSearchController = TextEditingController();
  final TextEditingController _breedSearchController = TextEditingController();
  final TextEditingController _farmSearchController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Error states for validation
  String? _farmError;
  String? _animalTypeError;
  String? _breedError;
  String? _genderError;
  String? _ageError;
  String? _weightError;
  String? _priceError;

  // API fetched data
  List<AnimalModel> _allAnimalModels = []; // Full animal data with IDs
  List<String> _allAnimals = []; // Species names for dropdown
  List<String> _allBreeds = [];
  bool _isLoadingAnimals = false;
  bool _isLoadingBreeds = false;

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
    _fetchFarms();
  }

  /// Fetch user's farms from API
  Future<void> _fetchFarms() async {
    setState(() => _isLoadingFarms = true);

    try {
      final farms = await _backendHelper.getFarms();

      if (!mounted) return;

      setState(() {
        _isLoadingFarms = false;
        _farms = farms.map((farm) => farm as Map<String, dynamic>).toList();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoadingFarms = false);
      showErrorToast(e.toString());
    }
  }

  /// Fetch animals (species) from API
  Future<void> _fetchAnimals() async {
    setState(() => _isLoadingAnimals = true);

    // Fetch full animal data (with IDs)
    final animalsResult = await _animalRepository.getAnimals();

    if (!mounted) return;

    if (animalsResult.success && animalsResult.data != null) {
      _allAnimalModels = animalsResult.data!;
    }

    // Fetch species list for dropdown
    final result = await _animalRepository.getSpeciesList();

    if (!mounted) return;

    setState(() => _isLoadingAnimals = false);

    if (result.success && result.data != null) {
      setState(() {
        _allAnimals = result.data!;
      });
    } else {
      showErrorToast(result.error ?? 'Failed to fetch animals');
    }
  }

  /// Fetch breeds for selected species
  Future<void> _fetchBreedsForSpecies(String species) async {
    setState(() => _isLoadingBreeds = true);

    final result = await _animalRepository.getBreedsForSpecies(species);

    if (!mounted) return;

    setState(() => _isLoadingBreeds = false);

    if (result.success && result.data != null) {
      setState(() {
        _allBreeds = result.data!;
        // Clear breed selection when species changes
        _selectedBreed = null;
        _breedSearchController.clear();
      });
    } else {
      showErrorToast(result.error ?? 'Failed to fetch breeds');
    }
  }

  @override
  void dispose() {
    _animalSearchController.dispose();
    _breedSearchController.dispose();
    _farmSearchController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Validate all required fields
  bool _validateForm() {
    bool isValid = true;

    setState(() {
      // Reset all errors
      _farmError = null;
      _animalTypeError = null;
      _breedError = null;
      _genderError = null;
      _ageError = null;
      _weightError = null;
      _priceError = null;

      // Farm is optional - no validation needed

      // Validate Animal Type (required)
      if (_selectedAnimalType == null || _selectedAnimalType!.isEmpty) {
        _animalTypeError = 'Please select an animal type';
        isValid = false;
      }

      // Validate Breed (required)
      if (_selectedBreed == null || _selectedBreed!.isEmpty) {
        _breedError = 'Please select a breed';
        isValid = false;
      }

      // Validate Gender (required)
      if (_selectedGender == null || _selectedGender!.isEmpty) {
        _genderError = 'Please select a gender';
        isValid = false;
      }

      // Age is optional - no validation needed

      // Weight is optional - only validate if provided
      final weight = _weightController.text.trim();
      if (weight.isNotEmpty) {
        final weightValue = double.tryParse(weight);
        if (weightValue == null || weightValue <= 0) {
          _weightError = 'Please enter a valid weight';
          isValid = false;
        }
      }

      // Validate Price (required)
      final price = _priceController.text.trim();
      if (price.isEmpty) {
        _priceError = 'Please enter price';
        isValid = false;
      } else {
        final priceValue = double.tryParse(price);
        if (priceValue == null || priceValue <= 0) {
          _priceError = 'Please enter a valid price';
          isValid = false;
        }
      }
    });

    return isValid;
  }

  /// Handle Next button press with validation and API call
  Future<void> _handleNext() async {
    if (!_validateForm()) {
      showErrorToast('Please fill all required fields');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final formData = getFormData();
      final response = await _backendHelper.postCreateListing(formData);

      if (!mounted) return;

      // Extract listing ID from response
      final listingId = response['listing_id'] ?? response['id'];
      if (listingId == null) {
        throw Exception('Failed to get listing ID from response');
      }

      setState(() => _isSubmitting = false);
      showSuccessToast('Listing created successfully!');

      // Proceed to next step with listing ID
      widget.onNext(listingId as int);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);
      showErrorToast(e.toString());
    }
  }

  /// Convert age string to months
  int _getAgeInMonths() {
    switch (_selectedAge) {
      case '1 Year':
        return 12;
      case '2 Years':
        return 24;
      case '3 Years':
        return 36;
      case '4 Years':
        return 48;
      case '5+ Years':
        return 60;
      default:
        return 0;
    }
  }

  /// Get form data as Map for API
  Map<String, dynamic> getFormData() {
    final ageMonths = _getAgeInMonths();
    final ageYears = ageMonths > 0 ? (ageMonths / 12).round() : 0;
    final weight = double.tryParse(_weightController.text.trim());

    // Generate title from form data
    String title = _selectedBreed ?? _selectedAnimalType ?? 'Animal';
    if (ageYears > 0) {
      title += ' - $ageYears ${ageYears == 1 ? 'Year' : 'Years'} Old';
    }

    // Generate description
    final descParts = <String>[];
    descParts.add('Healthy ${_selectedGender?.toLowerCase() ?? ''} ${_selectedBreed ?? _selectedAnimalType}.');
    if (ageYears > 0) {
      descParts.add('Age: $ageYears ${ageYears == 1 ? 'year' : 'years'}.');
    }
    if (weight != null && weight > 0) {
      descParts.add('Weight: ${weight.toStringAsFixed(0)} kg.');
    }
    final description = descParts.join(' ');

    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'animal': _selectedAnimalId, // Animal ID from selected breed
      'gender': _selectedGender?.toLowerCase(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
      'currency': 'INR',
    };

    // Add optional fields only if they have values
    if (_selectedFarmId != null) {
      data['farm'] = _selectedFarmId;
    }
    if (ageMonths > 0) {
      data['age_months'] = ageMonths;
    }
    if (weight != null && weight > 0) {
      data['weight_kg'] = weight;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Farm Selection
                _buildSectionTitle('Select Farm'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _farmError != null
                            ? Colors.red.withOpacity(0.1)
                            : AppTheme.authPrimaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildFarmDropdown(),
                ),
                if (_farmError != null) _buildFieldError(_farmError!),

                const SizedBox(height: 24),

                // Animal Type
                _buildSectionTitle('Animal Type', isRequired: true),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _animalTypeError != null
                            ? Colors.red.withOpacity(0.1)
                            : AppTheme.authPrimaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isLoadingAnimals
                      ? _buildLoadingIndicator('Loading animals...')
                      : _allAnimals.isEmpty
                          ? _buildInfoBox('No animals available in catalog')
                          : DropdownMenu<String>(
                              controller: _animalSearchController,
                              width: MediaQuery.of(context).size.width - 40,
                              hintText: 'Select or search animal type',
                              leadingIcon: const Icon(Icons.pets, size: 20),
                              menuHeight: 300,
                              enableFilter: true,
                              enableSearch: true,
                              requestFocusOnTap: true,
                              inputDecorationTheme: InputDecorationTheme(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: _animalTypeError != null
                                          ? Colors.red
                                          : AppTheme.authPrimaryColor,
                                      width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: _animalTypeError != null
                                          ? Colors.red
                                          : AppTheme.authPrimaryColor.withOpacity(0.5),
                                      width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: _animalTypeError != null
                                          ? Colors.red
                                          : AppTheme.authPrimaryColor,
                                      width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              dropdownMenuEntries: _allAnimals.map((animal) {
                                return DropdownMenuEntry<String>(
                                  value: animal,
                                  label: animal,
                                );
                              }).toList(),
                              onSelected: (value) {
                                setState(() {
                                  _selectedAnimalType = value;
                                  _animalTypeError = null; // Clear error on selection
                                  if (value != null) {
                                    _animalSearchController.text = value;
                                    // Fetch breeds for selected species
                                    _fetchBreedsForSpecies(value);
                                  }
                                });
                              },
                            ),
                ),
                if (_animalTypeError != null) _buildFieldError(_animalTypeError!),

                const SizedBox(height: 24),

                // Breed
                _buildSectionTitle('Breed', isRequired: true),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _breedError != null
                            ? Colors.red.withOpacity(0.1)
                            : AppTheme.authPrimaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _selectedAnimalType == null
                      ? _buildDisabledField('Please select animal type first')
                      : _isLoadingBreeds
                          ? _buildLoadingIndicator('Loading breeds...')
                          : _allBreeds.isEmpty
                              ? _buildErrorBox('No breeds available for this species')
                              : DropdownMenu<String>(
                                  controller: _breedSearchController,
                                  width: MediaQuery.of(context).size.width - 40,
                                  hintText: 'Select or search breed',
                                  menuHeight: 300,
                                  enableFilter: true,
                                  enableSearch: true,
                                  requestFocusOnTap: true,
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: _breedError != null
                                              ? Colors.red
                                              : AppTheme.authPrimaryColor,
                                          width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: _breedError != null
                                              ? Colors.red
                                              : AppTheme.authPrimaryColor.withOpacity(0.5),
                                          width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: _breedError != null
                                              ? Colors.red
                                              : AppTheme.authPrimaryColor,
                                          width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  dropdownMenuEntries: _allBreeds.map((breed) {
                                    return DropdownMenuEntry<String>(
                                      value: breed,
                                      label: breed,
                                    );
                                  }).toList(),
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedBreed = value;
                                      _breedError = null; // Clear error on selection
                                      if (value != null) {
                                        _breedSearchController.text = value;
                                        // Find and set the animal ID
                                        final animal = _allAnimalModels.firstWhere(
                                          (a) =>
                                              a.species.toLowerCase() == _selectedAnimalType?.toLowerCase() &&
                                              a.breed.toLowerCase() == value.toLowerCase(),
                                          orElse: () => AnimalModel(
                                            animalId: 0,
                                            species: '',
                                            breed: '',
                                            typicalLifeYears: 0,
                                          ),
                                        );
                                        _selectedAnimalId = animal.animalId > 0 ? animal.animalId : null;
                                      }
                                    });
                                  },
                                ),
                ),
                if (_breedError != null) _buildFieldError(_breedError!),

                const SizedBox(height: 24),

                // Gender
                _buildSectionTitle('Gender', isRequired: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderChip(
                        label: 'Male',
                        icon: Icons.male,
                        isSelected: _selectedGender == 'Male',
                        hasError: _genderError != null,
                        onTap: () => setState(() {
                          _selectedGender = 'Male';
                          _genderError = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGenderChip(
                        label: 'Female',
                        icon: Icons.female,
                        isSelected: _selectedGender == 'Female',
                        hasError: _genderError != null,
                        onTap: () => setState(() {
                          _selectedGender = 'Female';
                          _genderError = null;
                        }),
                      ),
                    ),
                  ],
                ),
                if (_genderError != null) _buildFieldError(_genderError!),

                const SizedBox(height: 16),

                // Age and Weight Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Age'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedAge,
                            decoration: InputDecoration(
                              hintText: 'Select age',
                              errorText: _ageError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: _ageError != null
                                        ? Colors.red
                                        : AppTheme.authPrimaryColor.withOpacity(0.5),
                                    width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: _ageError != null ? Colors.red : AppTheme.authPrimaryColor,
                                    width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: ['1 Year', '2 Years', '3 Years', '4 Years', '5+ Years']
                                .map((age) => DropdownMenuItem(value: age, child: Text(age)))
                                .toList(),
                            onChanged: (value) => setState(() {
                              _selectedAge = value;
                              _ageError = null;
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Weight (kg)'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'e.g. 350',
                              errorText: _weightError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: _weightError != null
                                        ? Colors.red
                                        : AppTheme.authPrimaryColor.withOpacity(0.5),
                                    width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: _weightError != null ? Colors.red : AppTheme.authPrimaryColor,
                                    width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (_) {
                              if (_weightError != null) {
                                setState(() => _weightError = null);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Price Type
                _buildSectionTitle('Price Type'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceTypeChip(
                        label: 'Fixed Price',
                        icon: '💰',
                        isSelected: _selectedPriceType == 'Fixed',
                        onTap: () => setState(() => _selectedPriceType = 'Fixed'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPriceTypeChip(
                        label: 'Auction',
                        icon: '🔨',
                        isSelected: _selectedPriceType == 'Auction',
                        onTap: () => setState(() => _selectedPriceType = 'Auction'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Enter Price
                _buildSectionTitle('Enter Price (₹)', isRequired: true),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _priceError != null
                            ? Colors.red.withOpacity(0.1)
                            : AppTheme.authPrimaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 50000',
                      errorText: _priceError,
                      prefixIcon: const Icon(Icons.currency_rupee, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: _priceError != null
                                ? Colors.red
                                : AppTheme.authPrimaryColor.withOpacity(0.5),
                            width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: _priceError != null ? Colors.red : AppTheme.authPrimaryColor,
                            width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) {
                      if (_priceError != null) {
                        setState(() => _priceError = null);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20), // Bottom padding for scroll
              ],
            ),
          ),
        ),

        // Fixed navigation buttons at bottom
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.onPrevious != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onPrevious,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
              if (widget.onPrevious != null) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authPrimaryColor,
                    disabledBackgroundColor: AppTheme.authPrimaryColor.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildFieldError(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 14, color: Colors.red.shade700),
          const SizedBox(width: 4),
          Text(
            error,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasError = false,
  }) {
    final borderColor = hasError && !isSelected
        ? Colors.red
        : isSelected
            ? AppTheme.authPrimaryColor
            : AppTheme.authPrimaryColor.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.authPrimaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppTheme.authPrimaryColor.withOpacity(0.2) : AppTheme.authPrimaryColor.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppTheme.authPrimaryColor : Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.authPrimaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTypeChip({
    required String label,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.authPrimaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.authPrimaryColor : AppTheme.authPrimaryColor.withOpacity(0.5),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppTheme.authPrimaryColor.withOpacity(0.2) : AppTheme.authPrimaryColor.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.authPrimaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading indicator widget
  Widget _buildLoadingIndicator(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.authPrimaryColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.authPrimaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error box widget
  Widget _buildErrorBox(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build info box widget (for non-error informational messages)
  Widget _buildInfoBox(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build disabled field widget
  Widget _buildDisabledField(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build no farms message with add button
  Widget _buildNoFarmsBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "You have no farms",
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _handleCreateFarm,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.authPrimaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build farm dropdown with "+ Create Farm" button
  Widget _buildFarmDropdown() {
    // Show loading indicator
    if (_isLoadingFarms) {
      return _buildLoadingIndicator('Loading farms...');
    }

    // Show message if no farms with add button
    if (_farms.isEmpty) {
      return _buildNoFarmsBox();
    }

    return DropdownMenu<int>(
      controller: _farmSearchController,
      width: MediaQuery.of(context).size.width - 40,
      hintText: 'Select or search farm',
      leadingIcon: const Icon(Icons.agriculture, size: 20),
      menuHeight: 300,
      enableFilter: true,
      enableSearch: true,
      requestFocusOnTap: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: _farmError != null ? Colors.red : AppTheme.authPrimaryColor,
              width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: _farmError != null
                  ? Colors.red
                  : AppTheme.authPrimaryColor.withOpacity(0.5),
              width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: _farmError != null ? Colors.red : AppTheme.authPrimaryColor,
              width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      dropdownMenuEntries: [
        // Farm items from API
        ..._farms
            .where((farm) => farm['farm_id'] != null) // Filter out farms with null id
            .map((farm) {
          final id = farm['farm_id'];
          final farmId = id is int ? id : int.tryParse(id.toString()) ?? 0;
          final farmName = farm['name']?.toString() ?? 'Farm $farmId';
          return DropdownMenuEntry<int>(
            value: farmId,
            label: farmName,
          );
        }),
        // Create Farm button (using -1 as special value)
        DropdownMenuEntry<int>(
          value: -1,
          label: 'Create Farm',
          leadingIcon: Icon(Icons.add_circle_outline,
              color: AppTheme.authPrimaryColor, size: 20),
          style: MenuItemButton.styleFrom(
            foregroundColor: AppTheme.authPrimaryColor,
          ),
        ),
      ],
      onSelected: (value) {
        if (value == -1) {
          // Reset the controller text since we don't want to show "Create Farm" as selected
          _farmSearchController.clear();
          _handleCreateFarm();
        } else if (value != null) {
          // Find the farm name for display
          final selectedFarm = _farms.firstWhere(
            (farm) {
              final id = farm['farm_id'];
              final farmId = id is int ? id : int.tryParse(id.toString()) ?? 0;
              return farmId == value;
            },
            orElse: () => {'name': 'Farm $value'},
          );
          setState(() {
            _selectedFarmId = value;
            _selectedFarmName = selectedFarm['name']?.toString();
            _farmError = null; // Clear error on selection
            _farmSearchController.text = _selectedFarmName ?? '';
          });
        }
      },
    );
  }

  /// Handle create farm action
  Future<void> _handleCreateFarm() async {
    // Navigate to create farm page and wait for result
    final result = await Navigator.pushNamed(context, AppRoutes.createFarm);

    // If a farm was created, refresh the farms list and select the new farm
    if (result != null && result is Map<String, dynamic>) {
      await _fetchFarms();

      // Auto-select the newly created farm (API returns farm_id)
      final farmId = result['farm_id'] ?? result['id'];
      if (mounted && farmId != null) {
        setState(() {
          _selectedFarmId = farmId is int ? farmId : int.tryParse(farmId.toString());
          _selectedFarmName = result['name']?.toString();
          _farmError = null;
          _farmSearchController.text = _selectedFarmName ?? '';
        });
      }
    }
  }
}

