import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/animal_model.dart';
import 'package:flutter_app/data/services/location_service.dart';
import 'package:flutter_app/features/editfarms/screens/edit_farm_page.dart';
import 'package:flutter_app/features/postlistings/details/controllers/details_controller.dart';
import 'package:flutter_app/features/postlistings/details/mixins/details_state_mixin.dart';
import 'package:flutter_app/features/postlistings/details/widgets/animal_type_dropdown.dart';
import 'package:flutter_app/features/postlistings/details/widgets/breed_dropdown.dart';
import 'package:flutter_app/features/postlistings/details/widgets/farm_dropdown.dart';
import 'package:flutter_app/features/postlistings/details/widgets/gender_selector.dart';
import 'package:flutter_app/features/postlistings/details/widgets/location_requirement_banner.dart';
import 'package:flutter_app/features/postlistings/details/widgets/section_title.dart';
import 'package:flutter_app/features/postlistings/details/widgets/field_error.dart';
import 'package:flutter_app/features/postlistings/details/widgets/price_type_chip.dart';
import 'package:flutter_app/features/postlistings/details/widgets/form_input_decoration_helper.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/features/location/models/location_model.dart';
import 'package:flutter_app/features/location/screens/location_page.dart';

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
    initializeDetailsController(_controller);

    _controller.fetchAnimals();
    _controller.fetchFarms();

    // Check location permission on load
    _checkLocationPermissionOnLoad();
  }

  @override
  void dispose() {
    disposeDetailsController();
    _controller.dispose();
    super.dispose();
  }

  /// Check location permission on page load
  Future<void> _checkLocationPermissionOnLoad() async {
    final hasPermission = await _controller.checkLocationPermissionStatus();

    if (hasPermission) {
      await _autoPopulateLocation();
    } else {
      // Schedule dialog to show after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _promptForLocationPermission();
        }
      });
    }
  }

  /// Auto-populate location from device GPS
  Future<void> _autoPopulateLocation() async {
    final location = await _controller.fetchCurrentLocation();

    if (location != null && mounted) {
      // Only set hasValidLocationSource = true AFTER we successfully get location
      setHasValidLocationSource(true);
      setSelectedLocation(location);
      showSuccessToast('Location detected: ${location.displayLocation}');
    } else if (mounted) {
      // Location fetch failed - only set valid source if we already have a farm with coords
      if (!selectedFarmHasCoordinates) {
        setHasValidLocationSource(false);
      }
      showInfoToast('Could not detect location - please select manually');
    }
  }

  /// Prompt user for location permission
  Future<void> _promptForLocationPermission() async {
    if (!mounted) return;

    final shouldEnable = await LocationService.showLocationPermissionDialog(context);

    if (shouldEnable && mounted) {
      final granted = await _controller.requestLocationPermission();

      if (granted) {
        // Try to auto-populate location - hasValidLocationSource will be set
        // only if location fetch succeeds
        await _autoPopulateLocation();
      } else {
        showInfoToast('Please select a farm to continue');
      }
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

        // Check if farm has lat/lng and update location requirement
        final farmHasCoords = _checkFarmLocation(result);

        // Set valid source based on farm coords or location permission
        if (farmHasCoords || _controller.isLocationPermissionGranted) {
          setHasValidLocationSource(true);
        } else {
          setHasValidLocationSource(false);
        }
      }
    }
  }

  /// Check if selected farm has location data
  /// Returns true if farm has coordinates, false otherwise
  bool _checkFarmLocation(Map<String, dynamic> farm) {
    // Handle empty map (farm not found)
    if (farm.isEmpty) {
      setLocationRequired(true);
      setSelectedFarmHasCoordinates(false);
      return false;
    }

    final lat = farm['latitude'];
    final lng = farm['longitude'];

    // If farm has both lat and lng, don't require location field
    if (lat != null && lng != null) {
      setLocationRequired(false);
      setSelectedFarmHasCoordinates(true);
      clearLocationSelection();
      return true;
    } else {
      setLocationRequired(true);
      setSelectedFarmHasCoordinates(false);
      return false;
    }
  }

  /// Handle location selection
  Future<void> _handleLocationSelection() async {
    final result = await Navigator.push<LocationData>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPage(),
      ),
    );

    if (result != null) {
      setSelectedLocation(result);
    }
  }

  /// Handle edit farm action
  Future<void> _handleEditFarm(int farmId) async {
    // Find the farm data
    final farm = _controller.farms.firstWhere(
      (f) {
        final id = f['farm_id'];
        final fId = id is int ? id : int.tryParse(id.toString()) ?? 0;
        return fId == farmId;
      },
      orElse: () => {},
    );

    if (farm.isEmpty) {
      showErrorToast('Farm not found');
      return;
    }

    // Navigate to edit farm page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFarmPage(
          farmId: farmId,
          farmData: farm,
        ),
      ),
    );

    // Refresh farms list if edit was successful
    if (result != null) {
      await _controller.fetchFarms();
      
      // Update selected farm if it was the one edited
      if (selectedFarmId == farmId) {
        final updatedFarmName = result['name']?.toString();
        setSelectedFarm(farmId, updatedFarmName);
      }
      
      showSuccessToast('Farm updated successfully!');
    }
  }

  /// Handle delete farm action
  Future<void> _handleDeleteFarm(int farmId) async {
    // Find the farm data
    final farm = _controller.farms.firstWhere(
      (f) {
        final id = f['farm_id'];
        final fId = id is int ? id : int.tryParse(id.toString()) ?? 0;
        return fId == farmId;
      },
      orElse: () => {},
    );

    if (farm.isEmpty) {
      showErrorToast('Farm not found');
      return;
    }

    final farmName = farm['name']?.toString() ?? 'this farm';

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Farm'),
          content: Text('Are you sure you want to delete "$farmName"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Proceed with deletion
    try {
      await _controller.deleteFarm(farmId);

      if (!mounted) return;

      // If the deleted farm was selected, clear selection
      if (selectedFarmId == farmId) {
        setSelectedFarm(null, null);
        _controller.setSelectedFarmId(null);
      }

      // Refresh farms list
      await _controller.fetchFarms();

      showSuccessToast('Farm deleted successfully!');
    } catch (e) {
      if (!mounted) return;
      showErrorToast(e.toString());
    }
  }

  /// Handle Next button press
  Future<void> _handleNext() async {
    // Validate form using controller
    final isValid = _controller.validateFormData(
      hasValidLocationSource: hasValidLocationSource,
      isLocationRequired: isLocationRequired,
      selectedLocation: selectedLocation,
      selectedAnimalType: selectedAnimalType,
      selectedBreed: selectedBreed,
      selectedGender: selectedGender,
      weightText: weightController.text,
      priceText: priceController.text,
    );

    if (!isValid) {
      showErrorToast('Please fill all required fields');
      return;
    }

    setSubmitting(true);

    try {
      // Prepare form data using controller
      final formData = _controller.prepareFormData(
        selectedAnimalId: selectedAnimalId,
        selectedGender: selectedGender,
        selectedAge: selectedAge,
        selectedFarmId: selectedFarmId,
        selectedLocation: selectedLocation,
        selectedBreed: selectedBreed,
        selectedAnimalType: selectedAnimalType,
        weightText: weightController.text,
        priceText: priceController.text,
      );

      // Location is already added by prepareFormData() if selectedLocation is set.
      // This includes both manual selection and auto-detected location
      // (which was stored via setSelectedLocation in _autoPopulateLocation).

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
                // Location Requirement Banner
                LocationRequirementBanner(
                  hasLocationPermission: _controller.isLocationPermissionGranted,
                  hasFarm: selectedFarmId != null,
                  farmHasCoordinates: selectedFarmHasCoordinates,
                  isChecking: _controller.isCheckingLocationPermission,
                  hasManualLocation: selectedLocation != null,
                  onEnableLocation: _promptForLocationPermission,
                ),
                const SizedBox(height: 16),

                // Farm Selection
                const SectionTitle(title: 'Select Farm'),
                const SizedBox(height: 12),
                FarmDropdown(
                  controller: _controller,
                  searchController: farmSearchController,
                  selectedFarmId: selectedFarmId,
                  error: farmError,
                  onFarmSelected: (farmId, farmName) {
                    setSelectedFarm(farmId, farmName);
                    _controller.setSelectedFarmId(farmId);

                    if (farmId != null) {
                      // Find the selected farm
                      final selectedFarm = _controller.farms.firstWhere(
                        (farm) {
                          final id = farm['farm_id'];
                          final fId = id is int ? id : int.tryParse(id.toString()) ?? 0;
                          return fId == farmId;
                        },
                        orElse: () => <String, dynamic>{},
                      );

                      // Check if farm has coordinates
                      final farmHasCoords = _checkFarmLocation(selectedFarm);

                      // Farm with coordinates OR location permission = valid source
                      // If farm lacks coords but we have location permission, still valid
                      // (auto-detected location will be used)
                      if (farmHasCoords || _controller.isLocationPermissionGranted) {
                        setHasValidLocationSource(true);
                      } else {
                        // Farm without coords and no permission - need manual location
                        setHasValidLocationSource(false);
                      }
                    } else {
                      // No farm selected - check if we have location permission as fallback
                      setHasValidLocationSource(_controller.isLocationPermissionGranted);
                      setSelectedFarmHasCoordinates(false);
                      setLocationRequired(false);
                    }
                  },
                  onFarmCreated: _onFarmCreated,
                  onFarmEdit: (farmId) {
                    _handleEditFarm(farmId);
                  },
                  onFarmDelete: (farmId) {
                    _handleDeleteFarm(farmId);
                  },
                ),
                if (farmError != null) FieldError(error: farmError!),

                const SizedBox(height: 24),

                // Location Field (only show if farm doesn't have lat/lng)
                if (isLocationRequired) ...[
                  const SectionTitle(title: 'Location', isRequired: true),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _handleLocationSelection,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: locationController,
                        decoration: InputDecoration(
                          hintText: 'Select location',
                          prefixIcon: const Icon(Icons.location_on, size: 20),
                          suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: locationError != null ? Colors.red : AppTheme.authPrimaryColor,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: locationError != null ? Colors.red : AppTheme.authPrimaryColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: locationError != null ? Colors.red : AppTheme.authPrimaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 1.5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (locationError != null) FieldError(error: locationError!),
                  const SizedBox(height: 24),
                ],

                // Animal Type
                const SectionTitle(title: 'Animal Type', isRequired: true),
                const SizedBox(height: 12),
                AnimalTypeDropdown(
                  controller: _controller,
                  searchController: animalSearchController,
                  selectedAnimalType: selectedAnimalType,
                  error: animalTypeError,
                  onAnimalTypeSelected: _onAnimalTypeSelected,
                ),
                if (animalTypeError != null) FieldError(error: animalTypeError!),

                const SizedBox(height: 24),

                // Breed
                const SectionTitle(title: 'Breed', isRequired: true),
                const SizedBox(height: 12),
                BreedDropdown(
                  controller: _controller,
                  searchController: breedSearchController,
                  selectedBreed: selectedBreed,
                  selectedAnimalType: selectedAnimalType,
                  error: breedError,
                  onBreedSelected: _onBreedSelected,
                ),
                if (breedError != null) FieldError(error: breedError!),

                const SizedBox(height: 24),

                // Gender
                const SectionTitle(title: 'Gender', isRequired: true),
                const SizedBox(height: 12),
                GenderSelector(
                  selectedGender: selectedGender,
                  error: genderError,
                  onGenderSelected: setSelectedGender,
                ),
                if (genderError != null) FieldError(error: genderError!),

                const SizedBox(height: 16),

                // Age and Weight Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(title: 'Age'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: selectedAge,
                            decoration: FormInputDecorationHelper.build(
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
                          const SectionTitle(title: 'Weight (kg)'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: FormInputDecorationHelper.build(
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
                const SectionTitle(title: 'Price Type'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PriceTypeChip(
                        label: 'Fixed Price',
                        icon: '💰',
                        isSelected: selectedPriceType == 'Fixed',
                        onTap: () => setSelectedPriceType('Fixed'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PriceTypeChip(
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
                const SectionTitle(title: 'Enter Price (₹)', isRequired: true),
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
                    decoration: FormInputDecorationHelper.build(
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
}
