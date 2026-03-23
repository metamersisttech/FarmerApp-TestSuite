import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/core/utils/validators.dart';
import 'package:flutter_app/features/editprofile/controllers/edit_profile_controller.dart';
import 'package:flutter_app/features/editprofile/widgets/profile_picture_picker.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/forms/text_field.dart';

/// Date input formatter for DD-MM-YYYY format
/// Automatically adds slashes as user types
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final buffer = StringBuffer();
    int selectionIndex = newValue.selection.end;

    // Remove all non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');

    // Build formatted string DD-MM-YYYY
    for (int i = 0; i < digitsOnly.length && i < 8; i++) {
      if (i == 2 || i == 4) {
        buffer.write('-');
        if (i < selectionIndex) selectionIndex++;
      }
      buffer.write(digitsOnly[i]);
    }

    final formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: selectionIndex.clamp(0, formattedText.length),
      ),
    );
  }
}


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

    // Convert DOB from YYYY-MM-DD (backend) to DD-MM-YYYY (display)
    String? displayDob;
    if (widget.initialDob != null && widget.initialDob!.length == 10) {
      final parts = widget.initialDob!.split('-');
      if (parts.length == 3) {
        // Convert YYYY-MM-DD to DD-MM-YYYY
        displayDob = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    }

    // Initialize with provided data or defaults
    _fullNameController = TextEditingController(text: widget.initialFullName ?? '');
    _displayNameController = TextEditingController(text: widget.initialDisplayName ?? '');
    _dobController = TextEditingController(text: displayDob ?? widget.initialDob ?? '');
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

    // Convert DOB from DD-MM-YYYY to YYYY-MM-DD for backend
    String? formattedDob;
    if (_dobController.text.isNotEmpty && _dobController.text.length == 10) {
      final parts = _dobController.text.split('-');
      if (parts.length == 3) {
        // Convert DD-MM-YYYY to YYYY-MM-DD
        formattedDob = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    }

    // Update controller with current values
    _controller.updateFullName(_fullNameController.text.trim());
    _controller.updateDisplayName(_displayNameController.text.trim());
    _controller.updateDob(formattedDob ?? _dobController.text.trim());
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
    // Parse existing date from DD-MM-YYYY format
    DateTime? initialDate = DateTime(2000);
    if (_dobController.text.isNotEmpty && _dobController.text.length == 10) {
      final parts = _dobController.text.split('-');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          initialDate = DateTime(year, month, day);
        }
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        // Format as DD-MM-YYYY
        final day = picked.day.toString().padLeft(2, '0');
        final month = picked.month.toString().padLeft(2, '0');
        final year = picked.year.toString();
        _dobController.text = '$day-$month-$year';
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

        // Date of Birth field with calendar icon button
        StyledTextField(
          controller: _dobController,
          hintText: 'DD-MM-YYYY',
          prefixIcon: Icons.calendar_today_outlined,
          enabled: !_isLoading,
          keyboardType: TextInputType.datetime, // Use datetime instead of number
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8), // DDMMYYYY = 8 digits
            DateInputFormatter(), // Auto-format with dashes
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null; // Optional field
            }
            
            // Check format DD-MM-YYYY
            if (value.length != 10) {
              return 'Please enter complete date (DD-MM-YYYY)';
            }
            
            final parts = value.split('-');
            if (parts.length != 3) {
              return 'Invalid date format. Use DD-MM-YYYY';
            }
            
            final day = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final year = int.tryParse(parts[2]);
            
            if (day == null || month == null || year == null) {
              return 'Invalid date. Use numbers only';
            }
            
            // Validate ranges
            if (day < 1 || day > 31) {
              return 'Day must be between 01 and 31';
            }
            if (month < 1 || month > 12) {
              return 'Month must be between 01 and 12';
            }
            if (year < 1900) {
              return 'Year must be 1900 or later';
            }
            if (year > DateTime.now().year) {
              return 'Year cannot be in the future';
            }
            
            // Check if it's a valid calendar date
            try {
              final date = DateTime(year, month, day);
              
              // Verify the constructed date matches input (catches invalid dates like Feb 30)
              if (date.day != day || date.month != month || date.year != year) {
                return 'Invalid date (e.g., 30-02-2025 doesn\'t exist)';
              }
              
              // Check if date is in the future
              if (date.isAfter(DateTime.now())) {
                return 'Birth date cannot be in the future';
              }
            } catch (e) {
              return 'Invalid date';
            }
            
            return null;
          },
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_month, color: AppTheme.authPrimaryColor),
            onPressed: _isLoading ? null : _selectDate,
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
