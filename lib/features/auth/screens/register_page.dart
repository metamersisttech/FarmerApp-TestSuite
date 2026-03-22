import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/core/utils/validators.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_app/features/auth/controllers/register_controller.dart';
import 'package:flutter_app/features/auth/mixins/auth_state_mixin.dart';
import 'package:flutter_app/features/auth/services/auth_navigation_service.dart';
import 'package:flutter_app/features/auth/widgets/auth_footer_link.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/auth/auth_primary_button.dart';
import 'package:flutter_app/shared/widgets/auth/phone_number_field.dart';
import 'package:flutter_app/shared/widgets/common/page_header.dart';
import 'package:flutter_app/shared/widgets/feedback/message_box.dart';
import 'package:flutter_app/shared/widgets/forms/text_field.dart';

class RegisterPage extends StatefulWidget {
  final String? phoneNumber;

  const RegisterPage({super.key, this.phoneNumber});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with AuthStateMixin, ToastMixin {
  late final RegisterController _registerController;
  late final TextEditingController _usernameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _registerController = RegisterController(AuthRepository());
    _usernameController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController(text: widget.phoneNumber);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _registerController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!validateForm()) return;

    final result = await _registerController.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    if (!mounted) return;

    setLoading(_registerController.isLoading);
    setError(_registerController.errorMessage);

    if (result.success) {
      showSuccessToast('Registration successful! Please verify with OTP.');
      AuthNavigationService.toSendOtp(context, isAfterRegistration: true, replace: true);
    } else {
      showErrorToast(result.errorMessage ?? 'Registration failed');
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                const PageHeader(
                  icon: Icons.person_add_rounded,
                  title: 'Create Account',
                  subtitle: 'Fill in your details to get started',
                ),
                const SizedBox(height: 24),
                if (errorMessage != null) ...[
                  MessageBox.error(
                    message: errorMessage!,
                    onDismiss: clearError,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildFormFields(),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  buttonKey: const Key('register_btn'),
                  text: 'Register',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleRegister,
                ),
                const SizedBox(height: 20),
                AuthFooterLink(
                  text: 'Already have an account? ',
                  linkText: 'Sign In',
                  enabled: !isLoading,
                  onTap: () => AuthNavigationService.toSendOtp(context, replace: true),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        StyledTextField(
          controller: _usernameController,
          hintText: 'Username',
          prefixIcon: Icons.alternate_email_rounded,
          enabled: !isLoading,
          validator: Validators.validateUsername,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: StyledTextField(
                controller: _firstNameController,
                hintText: 'First Name',
                prefixIcon: Icons.person_outline_rounded,
                enabled: !isLoading,
                validator: (v) => Validators.validateName(v, fieldName: 'First name'),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StyledTextField(
                controller: _lastNameController,
                hintText: 'Last Name',
                prefixIcon: Icons.person_outline_rounded,
                enabled: !isLoading,
                validator: (v) => Validators.validateName(v, fieldName: 'Last name'),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        StyledTextField(
          controller: _emailController,
          hintText: 'Email Address',
          prefixIcon: Icons.email_outlined,
          enabled: !isLoading,
          validator: Validators.validateEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        PhoneNumberField(
          controller: _phoneController,
          enabled: !isLoading && widget.phoneNumber == null,
          validator: Validators.validatePhone,
        ),
        const SizedBox(height: 14),
        PasswordField(
          controller: _passwordController,
          hintText: 'Password',
          enabled: !isLoading,
          validator: Validators.validatePassword,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        PasswordField(
          controller: _confirmPasswordController,
          hintText: 'Confirm Password',
          enabled: !isLoading,
          validator: (v) => Validators.validateConfirmPassword(v, _passwordController.text),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleRegister(),
        ),
      ],
    );
  }
}
