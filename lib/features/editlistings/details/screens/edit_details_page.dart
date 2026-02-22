import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/animal_model.dart';
import 'package:flutter_app/features/editlistings/details/controllers/edit_details_controller.dart';
import 'package:flutter_app/features/editlistings/details/mixins/edit_details_state_mixin.dart';
import 'package:flutter_app/features/postlistings/details/mixins/details_state_mixin.dart';
import 'package:flutter_app/features/postlistings/details/widgets/animal_type_dropdown.dart';
import 'package:flutter_app/features/postlistings/details/widgets/breed_dropdown.dart';
import 'package:flutter_app/features/postlistings/details/widgets/farm_dropdown.dart';
import 'package:flutter_app/features/postlistings/details/widgets/gender_selector.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Edit listing details page: same form as postlistings details, pre-filled
/// from listing and submits via PATCH.
/// When [embeddedInFlow] is true, used as step 0 in EditListingPage (no Scaffold).
/// When [onNext] is non-null, shows Previous/Next; otherwise shows Cancel/Update.
class EditDetailsPage extends StatefulWidget {
  final int listingId;
  final Map<String, dynamic>? initialListing;
  /// When true, build only the form content (no Scaffold) for use in step flow
  final bool embeddedInFlow;
  /// When set, show Previous/Next and call onNext after successful update
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const EditDetailsPage({
    super.key,
    required this.listingId,
    this.initialListing,
    this.embeddedInFlow = false,
    this.onNext,
    this.onPrevious,
  });

  @override
  State<EditDetailsPage> createState() => _EditDetailsPageState();
}

class _EditDetailsPageState extends State<EditDetailsPage>
    with DetailsStateMixin<EditDetailsPage>, EditDetailsStateMixin<EditDetailsPage>, ToastMixin {
  late final EditDetailsController _controller;
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    _controller = EditDetailsController(listingId: widget.listingId);
    initializeControllers();
    _controller.addListener(_onControllerChanged);
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    _controller.fetchAnimals();
    _controller.fetchFarms();

    final listing = widget.initialListing ?? await _controller.loadListing();
    if (!mounted) return;
    if (listing != null) {
      preFillFromListing(listing);
      final species = listing['species']?.toString() ??
          (listing['animal'] is Map
              ? (listing['animal'] as Map)['species']?.toString()
              : null);
      if (species != null) {
        await _controller.fetchBreedsForSpecies(species);
      }
    }
    if (mounted) {
      setState(() => _initialLoadDone = true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    disposeControllers();
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

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

  Future<void> _handleUpdate() async {
    if (!validateForm()) {
      showErrorToast('Please fill all required fields');
      return;
    }
    setSubmitting(true);
    try {
      final formData = getFormData();
      final result = await _controller.updateListing(formData);
      if (!mounted) return;
      setSubmitting(false);
      if (result.success) {
        showSuccessToast('Listing updated successfully!');
        if (widget.onNext != null) {
          widget.onNext!();
        } else {
          Navigator.of(context).pop(true);
        }
      } else {
        showErrorToast(result.errorMessage ?? 'Failed to update listing');
      }
    } catch (e) {
      if (!mounted) return;
      setSubmitting(false);
      showErrorToast(e.toString());
    }
  }

  void _onAnimalTypeSelected(String? value) {
    setSelectedAnimal(value);
    _controller.setSelectedAnimalType(value);
    if (value != null) {
      setSelectedBreed(null, null);
      breedSearchController.clear();
      _controller.fetchBreedsForSpecies(value);
    }
  }

  void _onBreedSelected(String? value) {
    if (value != null) {
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
    final content = !_initialLoadDone
        ? const Center(child: CircularProgressIndicator())
        : _buildFormContent();

    if (!widget.embeddedInFlow) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit listing details'),
          backgroundColor: AppTheme.authPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: content,
      );
    }
    return content;
  }

  Widget _buildFormContent() {
    return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        _buildSectionTitle('Gender', isRequired: true),
                        const SizedBox(height: 12),
                        GenderSelector(
                          selectedGender: selectedGender,
                          error: genderError,
                          onGenderSelected: setSelectedGender,
                        ),
                        if (genderError != null) _buildFieldError(genderError!),
                        const SizedBox(height: 16),
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
                                      if (weightError != null) setFieldError('weight', null);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
                              if (priceError != null) setFieldError('price', null);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
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
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onNext != null
                              ? (isSubmitting ? null : widget.onPrevious)
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            widget.onNext != null ? 'Previous' : 'Cancel',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _handleUpdate,
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
                              : Text(
                                  widget.onNext != null ? 'Next' : 'Update',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            style: TextStyle(fontSize: 12, color: Colors.red.shade700),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
