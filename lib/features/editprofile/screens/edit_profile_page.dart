import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/core/utils/validators.dart';
import 'package:flutter_app/features/editprofile/controllers/edit_profile_controller.dart';
import 'package:flutter_app/features/editprofile/widgets/profile_picture_picker.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/auth/phone_number_field.dart';
import 'package:flutter_app/shared/widgets/forms/text_field.dart';

/// Edit Profile Page
class EditProfilePage extends StatefulWidget {
  // Optional initial data
  final String? initialUsername;
  final String? initialFirstName;
  final String? initialLastName;
  final String? initialPhoneNumber;
  final String? initialEmail;
  final String? initialProfileImageUrl;

  const EditProfilePage({
    super.key,
    this.initialUsername,
    this.initialFirstName,
    this.initialLastName,
    this.initialPhoneNumber,
    this.initialEmail,
    this.initialProfileImageUrl,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with ToastMixin {
  late final EditProfileController _controller;
  late final TextEditingController _usernameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController();

    // Initialize with provided data or defaults
    _usernameController = TextEditingController(text: widget.initialUsername ?? '');
    _firstNameController = TextEditingController(text: widget.initialFirstName ?? '');
    _lastNameController = TextEditingController(text: widget.initialLastName ?? '');
    _phoneController = TextEditingController(text: widget.initialPhoneNumber ?? '');
    _emailController = TextEditingController(text: widget.initialEmail ?? '');

    _controller.initializeProfile(
      username: widget.initialUsername ?? '',
      firstName: widget.initialFirstName ?? '',
      lastName: widget.initialLastName ?? '',
      phoneNumber: widget.initialPhoneNumber ?? '',
      email: widget.initialEmail ?? '',
      profileImageUrl: widget.initialProfileImageUrl,
    );

    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
    _controller.updateUsername(_usernameController.text.trim());
    _controller.updateFirstName(_firstNameController.text.trim());
    _controller.updateLastName(_lastNameController.text.trim());
    _controller.updatePhoneNumber(_phoneController.text.trim());
    _controller.updateEmail(_emailController.text.trim());

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
                // Section: Basic Information
                _buildSectionTitle('Basic Information'),
                const SizedBox(height: 16),
                _buildBasicInformationSection(),
                const SizedBox(height: 32),

                // Section: Contact Information
                _buildSectionTitle('Contact Information'),
                const SizedBox(height: 16),
                _buildContactInformationSection(),
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
        // Profile picture and username/name fields in a row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture on the left
            ProfilePicturePicker(
              currentImageUrl: _controller.profileImageUrl,
              localImage: _controller.localProfileImage,
              onImageSelected: _handleImageSelected,
              onRemoveImage: _handleRemoveImage,
              enabled: !_isLoading,
            ),
            const SizedBox(width: 16),

            // Fields on the right
            Expanded(
              child: Column(
                children: [
                  // Username field
                  StyledTextField(
                    controller: _usernameController,
                    hintText: 'Enter your username',
                    prefixIcon: Icons.alternate_email_rounded,
                    enabled: !_isLoading,
                    validator: Validators.validateUsername,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  // First Name field
                  StyledTextField(
                    controller: _firstNameController,
                    hintText: 'Enter your firstname',
                    prefixIcon: Icons.person_outline_rounded,
                    enabled: !_isLoading,
                    validator: (v) => Validators.validateName(v, fieldName: 'First name'),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),

                  // Last Name field
                  StyledTextField(
                    controller: _lastNameController,
                    hintText: 'Enter your lastname',
                    prefixIcon: Icons.person_outline_rounded,
                    enabled: !_isLoading,
                    validator: (v) => Validators.validateName(v, fieldName: 'Last name'),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInformationSection() {
    return Column(
      children: [
        // Phone Number field
        PhoneNumberField(
          controller: _phoneController,
          enabled: !_isLoading,
          validator: Validators.validatePhone,
        ),
        const SizedBox(height: 14),

        // Email field
        StyledTextField(
          controller: _emailController,
          hintText: 'Enter your email',
          prefixIcon: Icons.email_outlined,
          enabled: !_isLoading,
          validator: Validators.validateEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSave(),
        ),
      ],
    );
  }
}

