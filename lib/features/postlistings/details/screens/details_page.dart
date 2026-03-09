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
    initializeControllers();

    // Add listener to rebuild when controller state changes
    _controller.addListener(_onControllerChanged);

    _controller.fetchAnimals();
    _controller.fetchFarms();

    // Check location permission on load
    _checkLocationPermissionOnLoad();
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
    if (!validateForm()) {
      showErrorToast('Please fill all required fields');
      return;
    }

    setSubmitting(true);

    try {
      final formData = getFormData();

      // Location is already added by getFormData() if selectedLocation is set.
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
                _buildLocationRequirementBanner(),
                const SizedBox(height: 16),

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
                if (farmError != null) _buildFieldError(farmError!),

                const SizedBox(height: 24),

                // Location Field (only show if farm doesn't have lat/lng)
                if (isLocationRequired) ...[
                  _buildSectionTitle('Location', isRequired: true),
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
                  if (locationError != null) _buildFieldError(locationError!),
                  const SizedBox(height: 24),
                ],

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

  /// Build location requirement banner showing status
  Widget _buildLocationRequirementBanner() {
    final hasLocationPermission = _controller.isLocationPermissionGranted;
    final hasFarm = selectedFarmId != null;
    final farmHasCoords = selectedFarmHasCoordinates;
    final isChecking = _controller.isCheckingLocationPermission;

    // Determine the actual location source status
    // Valid if: (1) farm with coords, (2) location permission granted, (3) manual location selected
    final hasManualLocation = selectedLocation != null;
    final isValid = (hasFarm && farmHasCoords) || hasLocationPermission || hasManualLocation;

    // Show loading state while checking permission
    if (isChecking) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              'Checking location access...',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Determine the status message
    String statusMessage;
    if (hasFarm && farmHasCoords) {
      statusMessage = 'Using farm location';
    } else if (hasFarm && !farmHasCoords && hasManualLocation) {
      statusMessage = 'Using selected location';
    } else if (hasFarm && !farmHasCoords && hasLocationPermission) {
      statusMessage = 'Farm has no location - using current location';
    } else if (hasFarm && !farmHasCoords) {
      statusMessage = 'Farm has no location - please select a location';
    } else if (hasLocationPermission) {
      statusMessage = 'Using current location';
    } else if (hasManualLocation) {
      statusMessage = 'Using selected location';
    } else {
      statusMessage = 'Select a farm or enable location access';
    }

    // Show warning state if farm lacks coordinates and no fallback
    final showWarning = hasFarm && !farmHasCoords && !hasLocationPermission && !hasManualLocation;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid
            ? Colors.green.withOpacity(0.1)
            : (showWarning ? Colors.orange.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : (showWarning ? Icons.warning : Icons.info_outline),
            color: isValid ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              statusMessage,
              style: TextStyle(
                fontSize: 13,
                color: isValid ? Colors.green.shade700 : Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!isValid && !hasLocationPermission)
            TextButton(
              onPressed: _promptForLocationPermission,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Enable'),
            ),
        ],
      ),
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
