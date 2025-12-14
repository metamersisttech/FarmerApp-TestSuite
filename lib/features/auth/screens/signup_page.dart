import 'package:flutter/material.dart';
import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/core/utils/validators.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/features/auth/screens/otp_verification_page.dart';
import 'package:flutter_app/features/home/screens/home_page.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/auth/auth_divider.dart';
import 'package:flutter_app/shared/widgets/auth/auth_header_icon.dart';
import 'package:flutter_app/shared/widgets/auth/auth_primary_button.dart';
import 'package:flutter_app/shared/widgets/auth/auth_social_button.dart';
import 'package:flutter_app/shared/widgets/auth/phone_number_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  /// Handle Send OTP
  Future<void> _handleSendOtp() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    // Show loading
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.sendOtp(
        phone: '+91${_mobileController.text.trim()}',
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              mobileNumber: _mobileController.text.trim(),
            ),
          ),
        );
      }
    } on NetworkException {
      setState(() {
        _errorMessage = 'No internet connection. Please try again.';
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle skip - navigate to home without signup
  void _handleSkip() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.authBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 110),
              const AuthHeaderIcon(icon: Icons.phone_android_rounded),
              const SizedBox(height: 26),
              const Text(
                'Enter Mobile Number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.authTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "We'll send you a verification code",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.authTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 26),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    PhoneNumberField(
                      controller: _mobileController,
                      enabled: !_isLoading,
                      validator: Validators.validatePhone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              AuthPrimaryButton(
                text: 'Get OTP',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handleSendOtp,
              ),

              const Spacer(),
              const AuthDivider(),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: AuthSocialButton(
                      provider: SocialProvider.google,
                      text: 'Google',
                      onPressed: _isLoading ? null : () {},
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AuthSocialButton(
                      provider: SocialProvider.facebook,
                      text: 'Facebook',
                      onPressed: _isLoading ? null : () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              TextButton(
                onPressed: _isLoading ? null : _handleSkip,
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: AppTheme.authTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

