import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/features/home/screens/home_page.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

class OtpVerificationPage extends StatefulWidget {
  final String mobileNumber;
  final String? username;
  final String? email;

  const OtpVerificationPage({
    super.key,
    required this.mobileNumber,
    this.username,
    this.email,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  int _resendTimer = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  String get _otp {
    return _otpControllers.map((c) => c.text).join();
  }

  /// Handle OTP verification
  Future<void> _handleVerifyOtp() async {
    if (_otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter complete 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = (widget.email == null || widget.email!.trim().isEmpty)
          ? null
          : widget.email!.trim();
      final username = (widget.username == null || widget.username!.trim().isEmpty)
          ? null
          : widget.username!.trim();

      // Call API to verify OTP
      final response = await _authService.verifyOtp(
        phone: '+91${widget.mobileNumber}',
        otp: _otp,
        email: email,
        username: username,
      );

      // Set auth token for future requests
      _authService.setAuthToken(response.accessToken);

      // Navigate to home on success
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } on UnauthorizedException {
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
      });
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
        _errorMessage = 'Verification failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle resend OTP
  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 30;
      _errorMessage = null;
    });

    try {
      final email = (widget.email == null || widget.email!.trim().isEmpty)
          ? null
          : widget.email!.trim();
      final username = (widget.username == null || widget.username!.trim().isEmpty)
          ? null
          : widget.username!.trim();

      // Call API to resend OTP
      await _authService.sendOtp(
        phone: '+91${widget.mobileNumber}',
        email: email,
        username: username,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _startResendTimer();
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _canResend = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend OTP. Please try again.';
        _canResend = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Back arrow button at top left
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),

              // Title
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Enter the 6-digit code sent to\n+91 ${widget.mobileNumber}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Error message
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            height: 55,
                            child: TextFormField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              enabled: !_isLoading,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                                setState(() {});
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),

                      // Resend OTP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          TextButton(
                            onPressed: _canResend ? _handleResendOtp : null,
                            child: Text(
                              _canResend
                                  ? 'Resend OTP'
                                  : 'Resend in ${_resendTimer}s',
                              style: TextStyle(
                                color: _canResend
                                    ? AppTheme.primaryColor
                                    : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading || _otp.length != 6
                              ? null
                              : _handleVerifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            disabledBackgroundColor:
                                AppTheme.primaryColor.withValues(alpha: 0.4),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Verify & Continue',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

