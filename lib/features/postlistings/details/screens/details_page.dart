import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/animal_model.dart';
import 'package:flutter_app/features/postlistings/details/controllers/details_controller.dart';
import 'package:flutter_app/features/postlistings/details/mixins/details_state_mixin.dart';
import 'package:flutter_app/features/postlistings/details/widgets/animal_type_dropdown.dart';
import 'package:flutter_app/features/postlistings/details/widgets/breed_dropdown.dart';
import 'package:flutter_app/features/postlistings/details/widgets/farm_dropdown.dart';
import 'package:flutter_app/features/postlistings/details/widgets/gender_selector.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Details Page - Animal type, breed, gender, etc.
class DetailsPage extends StatefulWidget {
  final void Function(int listingId) onNext;
  final VoidCallback? onPrevious;

  const DetailsPage({
    super.key,
    required this.onNext,
    this.onPrevious,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>
    with DetailsStateMixin, ToastMixin {
  late final DetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DetailsController();
    initializeControllers();
    
    // Add listener to rebuild when controller state changes
    _controller.addListener(_onControllerChanged);
    
    _controller.fetchAnimals();
    _controller.fetchFarms();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    disposeControllers();
    _controller.dispose();
    super.dispose();
  }

  /// Handle controller state changes
  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        // Rebuild when controller state changes
      });
    }
  }

  /// Handle create farm result
  void _onFarmCreated(Map<String, dynamic>? result) {
    if (result != null) {
      _controller.fetchFarms();

      final farmId = result['farm_id'] ?? result['id'];
      if (farmId != null) {
        final farmName = result['name']?.toString();
        setSelectedFarm(
          farmId is int ? farmId : int.tryParse(farmId.toString()),
          farmName,
        );
      }
    }
  }

  /// Handle Next button press
  Future<void> _handleNext() async {
    if (!validateForm()) {
      showErrorToast('Please fill all required fields');
      return;
    }

    setSubmitting(true);

    try {
      final formData = getFormData();
      final result = await _controller.createListing(formData);

      if (!mounted) return;

      if (result.success && result.listingId != null) {
        setSubmitting(false);
        showSuccessToast('Listing created successfully!');
        widget.onNext(result.listingId!);
      } else {
        setSubmitting(false);
        showErrorToast(result.errorMessage ?? 'Failed to create listing');
      }
    } catch (e) {
      if (!mounted) return;
      setSubmitting(false);
      showErrorToast(e.toString());
    }
  }

  /// Handle animal type selection
  void _onAnimalTypeSelected(String? value) {
    setSelectedAnimal(value);
    _controller.setSelectedAnimalType(value);

    if (value != null) {
      // Clear breed selection and fetch new breeds
      setSelectedBreed(null, null);
      breedSearchController.clear();
      _controller.fetchBreedsForSpecies(value);
    }
  }

  /// Handle breed selection
  void _onBreedSelected(String? value) {
    if (value != null) {
      // Find and set the animal ID
      final animal = _controller.allAnimalModels.firstWhere(
        (a) =>
            a.species.toLowerCase() == selectedAnimalType?.toLowerCase() &&
            a.breed.toLowerCase() == value.toLowerCase(),
        orElse: () => AnimalModel(
          animalId: 0,
          species: '',
          breed: '',
          typicalLifeYears: 0,
        ),
      );
      final animalId = animal.animalId > 0 ? animal.animalId : null;
      setSelectedBreed(value, animalId);
      _controller.setSelectedBreed(value);
      _controller.setSelectedAnimalId(animalId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Farm Selection
                _buildSectionTitle('Select Farm'),
                const SizedBox(height: 12),
                FarmDropdown(
                  controller: _controller,
                  searchController: farmSearchController,
                  selectedFarmId: selectedFarmId,
                  error: farmError,
                  onFarmSelected: (farmId, farmName) {
                    setSelectedFarm(farmId, farmName);
                    _controller.setSelectedFarmId(farmId);
                  },
                  onFarmCreated: _onFarmCreated,
                ),
                if (farmError != null) _buildFieldError(farmError!),

                const SizedBox(height: 24),

                // Animal Type
                _buildSectionTitle('Animal Type', isRequired: true),
                const SizedBox(height: 12),
                AnimalTypeDropdown(
                  controller: _controller,
                  searchController: animalSearchController,
                  selectedAnimalType: selectedAnimalType,
                  error: animalTypeError,
                  onAnimalTypeSelected: _onAnimalTypeSelected,
                ),
                if (animalTypeError != null) _buildFieldError(animalTypeError!),

                const SizedBox(height: 24),

                // Breed
                _buildSectionTitle('Breed', isRequired: true),
                const SizedBox(height: 12),
                BreedDropdown(
                  controller: _controller,
                  searchController: breedSearchController,
                  selectedBreed: selectedBreed,
                  selectedAnimalType: selectedAnimalType,
                  error: breedError,
                  onBreedSelected: _onBreedSelected,
                ),
                if (breedError != null) _buildFieldError(breedError!),

                const SizedBox(height: 24),

                // Gender
                _buildSectionTitle('Gender', isRequired: true),
                const SizedBox(height: 12),
                GenderSelector(
                  selectedGender: selectedGender,
                  error: genderError,
                  onGenderSelected: setSelectedGender,
                ),
                if (genderError != null) _buildFieldError(genderError!),

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
                            initialValue: selectedAge,
                            decoration: _buildInputDecoration(
                              hintText: 'Select age',
                              error: ageError,
                            ),
                            items: ['1 Year', '2 Years', '3 Years', '4 Years', '5+ Years']
                                .map((age) => DropdownMenuItem(value: age, child: Text(age)))
                                .toList(),
                            onChanged: setSelectedAge,
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
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration(
                              hintText: 'e.g. 350',
                              error: weightError,
                            ),
                            onChanged: (_) {
                              if (weightError != null) {
                                setFieldError('weight', null);
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
                        isSelected: selectedPriceType == 'Fixed',
                        onTap: () => setSelectedPriceType('Fixed'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPriceTypeChip(
                        label: 'Auction',
                        icon: '🔨',
                        isSelected: selectedPriceType == 'Auction',
                        onTap: () => setSelectedPriceType('Auction'),
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
                        color: priceError != null
                            ? Colors.red.withOpacity(0.1)
                            : AppTheme.authPrimaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration(
                      hintText: 'e.g. 50000',
                      error: priceError,
                      prefixIcon: const Icon(Icons.currency_rupee, size: 20),
                      filled: true,
                    ),
                    onChanged: (_) {
                      if (priceError != null) {
                        setFieldError('price', null);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Fixed navigation buttons at bottom
        Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).padding.bottom + 20, // Add system nav bar padding
          ),
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
                  onPressed: isSubmitting ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authPrimaryColor,
                    disabledBackgroundColor: AppTheme.authPrimaryColor.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isSubmitting
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
              color: isSelected
                  ? AppTheme.authPrimaryColor.withOpacity(0.2)
                  : AppTheme.authPrimaryColor.withOpacity(0.1),
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

  InputDecoration _buildInputDecoration({
    required String hintText,
    String? error,
    Widget? prefixIcon,
    bool filled = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      errorText: error,
      prefixIcon: prefixIcon,
      filled: filled,
      fillColor: filled ? Colors.white : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: error != null ? Colors.red : AppTheme.authPrimaryColor,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: error != null ? Colors.red : AppTheme.authPrimaryColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: error != null ? Colors.red : AppTheme.authPrimaryColor,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    );
  }
}
