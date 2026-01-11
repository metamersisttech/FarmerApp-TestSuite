import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/core/utils/validators.dart';
import 'package:flutter_app/features/editprofile/controllers/edit_profile_controller.dart';
import 'package:flutter_app/features/editprofile/widgets/profile_picture_picker.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/forms/text_field.dart';

/// Edit Profile Page
class EditProfilePage extends StatefulWidget {
  // Optional initial data
  final String? initialFullName;
  final String? initialDisplayName;
  final String? initialDob;
  final String? initialAddress;
  final String? initialState;
  final String? initialDistrict;
  final String? initialVillage;
  final String? initialPincode;
  final String? initialLatitude;
  final String? initialLongitude;
  final String? initialAbout;
  final String? initialProfileImageUrl;

  const EditProfilePage({
    super.key,
    this.initialFullName,
    this.initialDisplayName,
    this.initialDob,
    this.initialAddress,
    this.initialState,
    this.initialDistrict,
    this.initialVillage,
    this.initialPincode,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAbout,
    this.initialProfileImageUrl,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with ToastMixin {
  late final EditProfileController _controller;
  late final TextEditingController _fullNameController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _dobController;
  late final TextEditingController _addressController;
  late final TextEditingController _stateController;
  late final TextEditingController _districtController;
  late final TextEditingController _villageController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _aboutController;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController();

    // Initialize with provided data or defaults
    _fullNameController = TextEditingController(text: widget.initialFullName ?? '');
    _displayNameController = TextEditingController(text: widget.initialDisplayName ?? '');
    _dobController = TextEditingController(text: widget.initialDob ?? '');
    _addressController = TextEditingController(text: widget.initialAddress ?? '');
    _stateController = TextEditingController(text: widget.initialState ?? '');
    _districtController = TextEditingController(text: widget.initialDistrict ?? '');
    _villageController = TextEditingController(text: widget.initialVillage ?? '');
    _pincodeController = TextEditingController(text: widget.initialPincode ?? '');
    _latitudeController = TextEditingController(text: widget.initialLatitude ?? '');
    _longitudeController = TextEditingController(text: widget.initialLongitude ?? '');
    _aboutController = TextEditingController(text: widget.initialAbout ?? '');

    _controller.initializeProfile(
      fullName: widget.initialFullName,
      displayName: widget.initialDisplayName,
      dob: widget.initialDob,
      address: widget.initialAddress,
      state: widget.initialState,
      district: widget.initialDistrict,
      village: widget.initialVillage,
      pincode: widget.initialPincode,
      latitude: widget.initialLatitude,
      longitude: widget.initialLongitude,
      about: widget.initialAbout,
      profileImageGcs: widget.initialProfileImageUrl,
    );

    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _fullNameController.dispose();
    _displayNameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _pincodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {
        _isLoading = _controller.isLoading;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Update controller with current values
    _controller.updateFullName(_fullNameController.text.trim());
    _controller.updateDisplayName(_displayNameController.text.trim());
    _controller.updateDob(_dobController.text.trim());
    _controller.updateAddress(_addressController.text.trim());
    _controller.updateState(_stateController.text.trim());
    _controller.updateDistrict(_districtController.text.trim());
    _controller.updateVillage(_villageController.text.trim());
    _controller.updatePincode(_pincodeController.text.trim());
    _controller.updateLatitude(_latitudeController.text.trim());
    _controller.updateLongitude(_longitudeController.text.trim());
    _controller.updateAbout(_aboutController.text.trim());

    final success = await _controller.saveProfile();

    if (!mounted) return;

    if (success) {
      showSuccessToast('Profile updated successfully!');
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      showErrorToast(_controller.errorMessage ?? 'Failed to save profile');
    }
  }

  void _handleImageSelected(File image) {
    _controller.updateProfileImage(image);
  }

  void _handleRemoveImage() {
    _controller.removeProfileImage();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dobController.text.isNotEmpty 
          ? DateTime.tryParse(_dobController.text) ?? DateTime(2000)
          : DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _dobController.text = picked.toIso8601String().split('T')[0]; // Format: YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.authBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.authTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppTheme.authTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.authPrimaryColor),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppTheme.authPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                Center(
                  child: ProfilePicturePicker(
                    currentImageUrl: _controller.profileImageGcs,
                    localImage: _controller.localProfileImage,
                    onImageSelected: _handleImageSelected,
                    onRemoveImage: _handleRemoveImage,
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(height: 32),

                // Section: Basic Information
                _buildSectionTitle('Basic Information'),
                const SizedBox(height: 16),
                _buildBasicInformationSection(),
                const SizedBox(height: 32),

                // Section: Location Information
                _buildSectionTitle('Location Information'),
                const SizedBox(height: 16),
                _buildLocationInformationSection(),
                const SizedBox(height: 32),

                // Section: Coordinates (Optional)
                _buildSectionTitle('Coordinates (Optional)'),
                const SizedBox(height: 16),
                _buildCoordinatesSection(),
                const SizedBox(height: 32),

                // Section: About
                _buildSectionTitle('About'),
                const SizedBox(height: 16),
                _buildAboutSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.authTextPrimary,
      ),
    );
  }

  Widget _buildBasicInformationSection() {
    return Column(
      children: [
        // Full Name field
        StyledTextField(
          controller: _fullNameController,
          hintText: 'Enter your full name',
          prefixIcon: Icons.person_outline_rounded,
          enabled: !_isLoading,
          validator: (v) => Validators.validateName(v, fieldName: 'Full name'),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 14),

        // Display Name field
        StyledTextField(
          controller: _displayNameController,
          hintText: 'Enter your display name',
          prefixIcon: Icons.badge_outlined,
          enabled: !_isLoading,
          validator: (v) => Validators.validateName(v, fieldName: 'Display name'),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 14),

        // Date of Birth field
        GestureDetector(
          onTap: _isLoading ? null : _selectDate,
          child: AbsorbPointer(
            child: StyledTextField(
              controller: _dobController,
              hintText: 'Select your date of birth (YYYY-MM-DD)',
              prefixIcon: Icons.calendar_today_outlined,
              enabled: !_isLoading,
              textInputAction: TextInputAction.next,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInformationSection() {
    return Column(
      children: [
        // Address field (multi-line)
        TextFormField(
          controller: _addressController,
          enabled: !_isLoading,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          maxLines: 2,
          style: const TextStyle(fontSize: 16, color: AppTheme.authTextPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your address',
            hintStyle: const TextStyle(fontSize: 15, color: AppTheme.authTextSecondary),
            filled: true,
            fillColor: AppTheme.authFieldFillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.0),
              borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 12, top: 12),
              child: Icon(Icons.home_outlined, color: AppTheme.authTextSecondary, size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
        const SizedBox(height: 14),

        // State field
        StyledTextField(
          controller: _stateController,
          hintText: 'Enter your state',
          prefixIcon: Icons.location_city_outlined,
          enabled: !_isLoading,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 14),

        // District field
        StyledTextField(
          controller: _districtController,
          hintText: 'Enter your district',
          prefixIcon: Icons.map_outlined,
          enabled: !_isLoading,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 14),

        // Village field
        StyledTextField(
          controller: _villageController,
          hintText: 'Enter your village',
          prefixIcon: Icons.landscape_outlined,
          enabled: !_isLoading,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 14),

        // Pincode field
        StyledTextField(
          controller: _pincodeController,
          hintText: 'Enter your pincode',
          prefixIcon: Icons.pin_outlined,
          enabled: !_isLoading,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildCoordinatesSection() {
    return Column(
      children: [
        // Latitude field
        StyledTextField(
          controller: _latitudeController,
          hintText: 'Enter latitude (e.g., 19.0760)',
          prefixIcon: Icons.my_location_outlined,
          enabled: !_isLoading,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),

        // Longitude field
        StyledTextField(
          controller: _longitudeController,
          hintText: 'Enter longitude (e.g., 72.8777)',
          prefixIcon: Icons.explore_outlined,
          enabled: !_isLoading,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return TextFormField(
      controller: _aboutController,
      enabled: !_isLoading,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 4,
      onFieldSubmitted: (_) => _handleSave(),
      style: const TextStyle(fontSize: 16, color: AppTheme.authTextPrimary),
      decoration: InputDecoration(
        hintText: 'Tell us about yourself',
        hintStyle: const TextStyle(fontSize: 15, color: AppTheme.authTextSecondary),
        filled: true,
        fillColor: AppTheme.authFieldFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: const BorderSide(color: AppTheme.authPrimaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16, right: 12, top: 12),
          child: Icon(Icons.info_outline_rounded, color: AppTheme.authTextSecondary, size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
