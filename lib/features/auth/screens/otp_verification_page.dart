import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/features/auth/controllers/otp_controller.dart';
import 'package:flutter_app/features/auth/mixins/auth_state_mixin.dart';
import 'package:flutter_app/features/auth/services/auth_navigation_service.dart';
import 'package:flutter_app/features/auth/widgets/otp_input_widget.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/auth/auth_header_icon.dart';
import 'package:flutter_app/shared/widgets/auth/auth_primary_button.dart';

class OtpVerificationPage extends StatefulWidget {
  final String mobileNumber;

  const OtpVerificationPage({
    super.key,
    required this.mobileNumber,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with AuthStateMixin, ToastMixin {
  late final OtpController _otpController;
  final GlobalKey<OtpInputWidgetState> _otpWidgetKey = GlobalKey();
  
  String _otp = '';
  int _resendTimer = 30;
  bool _canResend = false;
  bool _isVerifying = false; // Prevent duplicate verify calls

  @override
  void initState() {
    super.initState();
    _otpController = OtpController(AuthService());
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _startResendTimer();
      } else if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  /// Handle OTP verification
  Future<void> _handleVerifyOtp() async {
    // Prevent duplicate calls
    if (_isVerifying) return;

    if (_otp.length != 6) {
      showErrorToast('Please enter complete 6-digit OTP');
      return;
    }

    _isVerifying = true;
    setLoading(true);

    final result = await _otpController.verifyOtp(widget.mobileNumber, _otp);

    // Check mounted before any UI updates
    if (!mounted) return;

    if (result.success) {
      // User data is stored in otp_handler_service
      // Navigate directly to Home (don't update loading state, we're leaving)
      AuthNavigationService.toHome(context, user: result.user);
    } else {
      _isVerifying = false;
      setLoading(false);
      showErrorToast(result.errorMessage ?? 'Verification failed');
      setError(result.errorMessage);
    }
  }

  /// Handle resend OTP
  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 30;
    });

    final result = await _otpController.sendOtp(widget.mobileNumber);

    if (!mounted) return;

    if (result.success) {
      _otpWidgetKey.currentState?.clear();
      
      if (result.otp != null) {
        showSuccessToast('Your OTP: ${result.otp}');
      } else {
        showSuccessToast('OTP sent successfully!');
      }
      
      _startResendTimer();
    } else {
      setState(() => _canResend = true);
      showErrorToast(result.errorMessage ?? 'Failed to resend OTP');
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 26),
              if (errorMessage != null) ...[
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              OtpInputWidget(
                key: _otpWidgetKey,
                enabled: !isLoading,
                onChanged: (value) => setState(() => _otp = value),
                onCompleted: (value) => _handleVerifyOtp(),
              ),
              const SizedBox(height: 16),
              AuthPrimaryButton(
                buttonKey: const Key('verify_otp_btn'),
                text: 'Verify & Continue',
                isLoading: isLoading,
                onPressed: isLoading || _otp.length != 6 ? null : _handleVerifyOtp,
              ),
              const SizedBox(height: 20),
              _buildResendSection(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const AuthHeaderIcon(icon: Icons.verified_user_rounded),
        const SizedBox(height: 26),
        const Text(
          'Verify OTP',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.authTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Enter the 6-digit code sent to\n+91 ${widget.mobileNumber}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.authTextSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Didn't receive the code? ",
          style: TextStyle(color: AppTheme.authTextSecondary, fontSize: 14),
        ),
        TextButton(
          key: const Key('resend_otp_btn'),
          onPressed: _canResend ? _handleResendOtp : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _canResend ? 'Resend OTP' : 'Resend in ${_resendTimer}s',
            style: TextStyle(
              color: _canResend ? AppTheme.primaryColor : AppTheme.authTextSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
