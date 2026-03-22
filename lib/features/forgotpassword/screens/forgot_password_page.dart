import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/core/utils/validators.dart';
import 'package:flutter_app/features/forgotpassword/controllers/forgot_password_controller.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/auth/auth_header_icon.dart';
import 'package:flutter_app/shared/widgets/auth/auth_primary_button.dart';
import 'package:flutter_app/shared/widgets/forms/text_field.dart';

/// Forgot Password Page
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with ToastMixin {
  late final ForgotPasswordController _controller;
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController();
    _emailController = TextEditingController();
    
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
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

  /// Handle send reset email button press
  Future<void> _handleSendResetEmail() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    final result = await _controller.requestPasswordReset(email: email);

    if (!mounted) return;

    // Handle result
    if (result.success) {
      // Show success dialog with token if in mock mode
      _showSuccessDialog(
        message: result.message ?? 'Password reset email sent successfully.',
        token: result.token,
      );
    } else {
      // Show error toast
      showErrorToast(result.errorMessage ?? 'Failed to send reset email');
    }
  }

  /// Show success dialog
  void _showSuccessDialog({
    required String message,
    String? token,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Success'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (token != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Reset Token (Mock Mode):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.authFieldFillColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  token,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Copy this token to reset your password.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          if (token != null)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Navigate to reset password page with token
                Navigator.pushNamed(
                  context,
                  AppRoutes.resetPassword,
                  arguments: {'token': token},
                );
              },
              child: const Text(
                'Reset Now',
                style: TextStyle(color: AppTheme.authPrimaryColor),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (token == null) {
                Navigator.pop(context); // Go back to login page
              }
            },
            child: Text(
              token != null ? 'Later' : 'OK',
              style: TextStyle(
                color: token != null
                    ? AppTheme.authTextSecondary
                    : AppTheme.authPrimaryColor,
              ),
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
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildEmailField(),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  buttonKey: const Key('send_reset_email_btn'),
                  text: 'Send Reset Email',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSendResetEmail,
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
        AuthHeaderIcon(icon: Icons.lock_reset),
        SizedBox(height: 24),
        Text(
          'Forgot Password?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.authTextPrimary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Enter your email and we'll send you instructions to reset your password",
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

  Widget _buildEmailField() {
    return StyledTextField(
      controller: _emailController,
      hintText: 'Email Address',
      prefixIcon: Icons.email_outlined,
      enabled: !_isLoading,
      validator: Validators.validateEmail,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSendResetEmail(),
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Remember your password? ",
          style: TextStyle(color: AppTheme.authTextSecondary, fontSize: 14),
        ),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Back to Login',
            style: TextStyle(
              color: AppTheme.authPrimaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

