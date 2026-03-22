import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/features/auth/controllers/email_login_controller.dart';
import 'package:flutter_app/features/auth/mixins/auth_state_mixin.dart';
import 'package:flutter_app/features/auth/services/auth_navigation_service.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/auth/auth_header_icon.dart';
import 'package:flutter_app/shared/widgets/auth/auth_primary_button.dart';
import 'package:flutter_app/shared/widgets/forms/text_field.dart';

/// Email Login Page
class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage>
    with AuthStateMixin, ToastMixin {
  late final EmailLoginController _loginController;
  late final TextEditingController _identifierController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _loginController = EmailLoginController(AuthService());
    _identifierController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _loginController.dispose();
    super.dispose();
  }

  /// Handle login button press
  Future<void> _handleLogin() async {
    // Validate form
    if (!validateForm()) return;

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    final result = await _loginController.loginWithEmail(
      identifier: identifier,
      password: password,
    );

    if (!mounted) return;

    // Update UI state
    setLoading(_loginController.isLoading);
    setError(_loginController.errorMessage);

    // Handle result
    if (result.success && result.user != null) {
      // Login successful - navigate to home
      showSuccessToast('Login successful!');
      
      // Navigate to home (language selection logic handled by backend if needed)
      AuthNavigationService.toHome(context, user: result.user);
    } else if (result.isUserNotFound) {
      // User not found - show error and navigate to register
      _showInvalidCredentialsDialog(
        'User not found',
        'This email/username is not registered. Would you like to create an account?',
        showRegisterButton: true,
      );
    } else if (result.isInvalidCredentials) {
      // Invalid password or email
      _showInvalidCredentialsDialog(
        'Invalid Credentials',
        result.errorMessage ?? 'Invalid password or email ID',
        showRegisterButton: false,
      );
    } else {
      // Other error
      showErrorToast(result.errorMessage ?? 'Login failed');
    }
  }

  /// Show dialog for invalid credentials
  void _showInvalidCredentialsDialog(
    String title,
    String message, {
    bool showRegisterButton = false,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
          if (showRegisterButton)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                AuthNavigationService.toRegister(context);
              },
              child: const Text(
                'Register',
                style: TextStyle(color: AppTheme.authPrimaryColor),
              ),
            ),
        ],
      ),
    );
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
                _buildHeader(),
                const SizedBox(height: 32),
                _buildFormFields(),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  buttonKey: const Key('login_btn'),
                  text: 'Login',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleLogin,
                ),
                const SizedBox(height: 16),
                _buildFooterLinks(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        AuthHeaderIcon(icon: Icons.email_outlined),
        SizedBox(height: 24),
        Text(
          'Login with Email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.authTextPrimary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Enter your email/username and password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.authTextSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        StyledTextField(
          controller: _identifierController,
          hintText: 'Email or Username',
          prefixIcon: Icons.person_outline_rounded,
          enabled: !isLoading,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter email or username';
            }
            return null;
          },
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        PasswordField(
          controller: _passwordController,
          hintText: 'Password',
          enabled: !isLoading,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      children: [
        TextButton(
          key: const Key('forgot_password_link'),
          onPressed: isLoading
              ? null
              : () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: AppTheme.authPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(color: AppTheme.authTextSecondary, fontSize: 14),
            ),
            TextButton(
              key: const Key('register_link'),
              onPressed: isLoading
                  ? null
                  : () => AuthNavigationService.toRegister(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Register',
                style: TextStyle(
                  color: AppTheme.authPrimaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

