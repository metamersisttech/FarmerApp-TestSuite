import 'package:flutter/material.dart';
import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/core/utils/validators.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_app/features/auth/screens/sendOtp_page.dart';
import 'package:flutter_app/features/auth/widgets/auth_footer_link.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/auth/auth_primary_button.dart';
import 'package:flutter_app/shared/widgets/auth/phone_number_field.dart';
import 'package:flutter_app/shared/widgets/common/page_header.dart';
import 'package:flutter_app/shared/widgets/feedback/message_box.dart';
import 'package:flutter_app/shared/widgets/forms/text_field.dart';

// Export SendOtpPage for easier imports
export 'package:flutter_app/features/auth/screens/sendOtp_page.dart' show SendOtpPage;

class RegisterPage extends StatefulWidget {
  final String? phoneNumber;
  
  const RegisterPage({super.key, this.phoneNumber});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Repository
  final _authRepository = AuthRepository();

  // State
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill phone number if provided
    if (widget.phoneNumber != null) {
      _phoneController.text = widget.phoneNumber!;
    }
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
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Send phone WITHOUT +91 prefix (just the number)
      await _authRepository.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please verify with OTP.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        // Navigate to SendOtpPage with isAfterRegistration flag
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SendOtpPage(isAfterRegistration: true)),
        );
      }
    } on NetworkException {
      setState(
        () => _errorMessage = 'No internet connection. Please try again.',
      );
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.authTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Header
                const PageHeader(
                  icon: Icons.person_add_rounded,
                  title: 'Create Account',
                  subtitle: 'Fill in your details to get started',
                ),
                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage != null) ...[
                  MessageBox.error(
                    message: _errorMessage!,
                    onDismiss: () => setState(() => _errorMessage = null),
                  ),
                  const SizedBox(height: 16),
                ],

                // Username
                StyledTextField(
                  controller: _usernameController,
                  hintText: 'Username',
                  prefixIcon: Icons.alternate_email_rounded,
                  enabled: !_isLoading,
                  validator: Validators.validateUsername,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // First & Last Name
                Row(
                  children: [
                    Expanded(
                      child: StyledTextField(
                        controller: _firstNameController,
                        hintText: 'First Name',
                        prefixIcon: Icons.person_outline_rounded,
                        enabled: !_isLoading,
                        validator: (v) =>
                            Validators.validateName(v, fieldName: 'First name'),
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
                        enabled: !_isLoading,
                        validator: (v) =>
                            Validators.validateName(v, fieldName: 'Last name'),
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Email
                StyledTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  enabled: !_isLoading,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // Phone
                PhoneNumberField(
                  controller: _phoneController,
                  enabled: !_isLoading && widget.phoneNumber == null,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 14),

                // Password
                PasswordField(
                  controller: _passwordController,
                  hintText: 'Password',
                  enabled: !_isLoading,
                  validator: Validators.validatePassword,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // Confirm Password
                PasswordField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  enabled: !_isLoading,
                  validator: (v) => Validators.validateConfirmPassword(
                    v,
                    _passwordController.text,
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: 24),

                // Register Button
                AuthPrimaryButton(
                  text: 'Register',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleRegister,
                ),
                const SizedBox(height: 20),

                // Footer Link
                AuthFooterLink(
                  text: 'Already have an account? ',
                  linkText: 'Sign In',
                  enabled: !_isLoading,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SendOtpPage()),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
