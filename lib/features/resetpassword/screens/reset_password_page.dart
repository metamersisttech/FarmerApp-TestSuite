import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/core/utils/validators.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/features/resetPassword/controllers/reset_password_controller.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/auth/auth_header_icon.dart';
import 'package:flutter_app/shared/widgets/auth/auth_primary_button.dart';
import 'package:flutter_app/shared/widgets/forms/text_field.dart';

/// Reset Password Page
class ResetPasswordPage extends StatefulWidget {
  final String? token; // Token from forgot password (optional)

  const ResetPasswordPage({super.key, this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with ToastMixin {
  late final ResetPasswordController _controller;
  late final TextEditingController _tokenController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = ResetPasswordController(AuthService());
    _tokenController = TextEditingController(text: widget.token ?? '');
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {
        _isLoading = _controller.isLoading;
      });
    }
  }

  /// Handle reset password button press
  Future<void> _handleResetPassword() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    final token = _tokenController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final result = await _controller.confirmPasswordReset(
      token: token,
      newPassword: newPassword,
      newPasswordConfirm: confirmPassword,
    );

    if (!mounted) return;

    // Handle result
    if (result.success) {
      // Show success dialog
      _showSuccessDialog(
        message: result.message ?? 'Password reset successfully.',
      );
    } else {
      // Show error toast
      showErrorToast(result.errorMessage ?? 'Failed to reset password');
    }
  }

  /// Show success dialog and navigate to email login
  void _showSuccessDialog({required String message}) {
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
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Navigate to email login page
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.emailLogin,
                (route) => route.settings.name == AppRoutes.welcome,
              );
            },
            child: const Text(
              'Go to Login',
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
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildFormFields(),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  text: 'Reset Password',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleResetPassword,
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
          'Reset Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.authTextPrimary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Enter your reset token and new password',
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
          controller: _tokenController,
          hintText: 'Reset Token',
          prefixIcon: Icons.vpn_key_outlined,
          enabled: !_isLoading,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter reset token';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        PasswordField(
          controller: _newPasswordController,
          hintText: 'New Password',
          enabled: !_isLoading,
          validator: Validators.validatePassword,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        PasswordField(
          controller: _confirmPasswordController,
          hintText: 'Confirm New Password',
          enabled: !_isLoading,
          validator: (value) => Validators.validateConfirmPassword(
            value,
            _newPasswordController.text,
          ),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleResetPassword(),
        ),
      ],
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have a token? ",
          style: TextStyle(color: AppTheme.authTextSecondary, fontSize: 14),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Request Reset',
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

