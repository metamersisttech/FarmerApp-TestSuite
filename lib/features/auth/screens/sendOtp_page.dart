import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/features/auth/controllers/otp_controller.dart';
import 'package:flutter_app/features/auth/mixins/auth_state_mixin.dart';
import 'package:flutter_app/features/auth/services/auth_navigation_service.dart';
import 'package:flutter_app/features/auth/widgets/phone_input_form.dart';
import 'package:flutter_app/features/auth/widgets/social_login_section.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/auth/auth_header_icon.dart';
import 'package:flutter_app/shared/widgets/auth/auth_primary_button.dart';

class SendOtpPage extends StatefulWidget {
  const SendOtpPage({super.key});

  @override
  State<SendOtpPage> createState() => _SendOtpPageState();
}

class _SendOtpPageState extends State<SendOtpPage>
    with AuthStateMixin, ToastMixin {
  late final TextEditingController _phoneController;
  late final OtpController _otpController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _otpController = OtpController(AuthService());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Handle send OTP button press
  Future<void> _handleSendOtp() async {
    // Validate form
    if (!validateForm()) return;

    final phone = _phoneController.text.trim();

    // Show loader before API call
    setLoading(true);
    setError(null);

    final result = await _otpController.sendOtp(phone);

    if (!mounted) return;

    // Hide loader after API call
    setLoading(false);

    // Handle result
    if (result.success) {
      // Show OTP if available (temporary for development)
      if (result.otp != null) {
        showSuccessToast('Your OTP: ${result.otp}');
      }

      // Navigate to OTP verification
      AuthNavigationService.toOtpVerification(
        context,
        phoneNumber: phone,
      );
    } else if (result.isUserNotFound) {
      // User not found - show toast and STAY on screen (no redirect to register)
      showErrorToast(result.errorMessage ?? 'User not found. Please contact support.');
    } else {
      // Show error and stay on screen
      showErrorToast(result.errorMessage ?? 'Failed to send OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.authBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  _buildHeader(),
                  const SizedBox(height: 26),
                  PhoneInputForm(
                    formKey: formKey,
                    controller: _phoneController,
                    isLoading: isLoading,
                    errorMessage: errorMessage,
                  ),
                  const SizedBox(height: 16),
                  AuthPrimaryButton(
                    buttonKey: const Key('get_otp_btn'),
                    text: 'Get OTP',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _handleSendOtp,
                  ),
                  TextButton(
                    key: const Key('email_login_link'),
                    onPressed: isLoading
                        ? null
                        : () => Navigator.pushNamed(context, AppRoutes.emailLogin),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.authPrimaryColor,
                    ),
                    child: const Text('OR login via email'),
                  ),
                  const Spacer(),
                  SocialLoginSection(
                    isLoading: isLoading,
                    onGooglePressed: () {},
                    onFacebookPressed: () {},
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    key: const Key('signup_link'),
                    onPressed: isLoading
                        ? null
                        : () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      'Or Sign up instead',
                      style: TextStyle(
                        color: AppTheme.authPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        AuthHeaderIcon(icon: Icons.phone_android_rounded),
        SizedBox(height: 24),
        Text(
          'Enter Mobile Number',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.authTextPrimary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "We'll send you a verification code",
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
}
