import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/features/home/screens/home_page.dart';
import 'package:flutter_app/features/language/screens/choose_language_page.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/auth/auth_header_icon.dart';
import 'package:flutter_app/shared/widgets/auth/auth_primary_button.dart';

class OtpVerificationPage extends StatefulWidget {
  final String mobileNumber;
  final String? username;
  final String? email;
  final bool isNewUser;

  const OtpVerificationPage({
    super.key,
    required this.mobileNumber,
    this.username,
    this.email,
    this.isNewUser = false,
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
      // Call API to verify OTP (send phone WITHOUT +91 prefix)
      final response = await _authService.verifyLoginOtp(
        phone: widget.mobileNumber, // Send without +91 prefix
        otp: _otp,
      );

      // Set auth token for future requests
      _authService.setAuthToken(response.accessToken);

      // Navigate based on user type
      if (mounted) {
        if (widget.isNewUser) {
          // New user - go to language selection
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ChooseLanguagePage()),
            (route) => false,
          );
        } else {
          // Existing user - go directly to home
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
      }
    } on UnauthorizedException catch (e) {
      setState(() {
        _errorMessage = e.message.contains('Invalid OTP') 
            ? 'Invalid OTP. Please try again.' 
            : e.message;
      });
    } on NetworkException {
      setState(() {
        _errorMessage = 'No internet connection. Please try again.';
      });
    } on ApiException catch (e) {
      // Handle API errors (including 401 with "Invalid OTP" message)
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      print('❌ OTP Verification error: $e');
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
      // Call API to resend OTP (send phone WITHOUT +91 prefix)
      await _authService.sendLoginOtp(
        phone: widget.mobileNumber,
      );

      if (mounted) {
        // Clear all OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        
        // Reset focus to first field
        _focusNodes[0].requestFocus();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
      print('❌ Resend OTP error: $e');
      setState(() {
        _errorMessage = 'Failed to resend OTP. Please try again.';
        _canResend = true;
      });
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              
              // Header with icon
              const AuthHeaderIcon(icon: Icons.verified_user_rounded),
              const SizedBox(height: 26),
              
              // Title
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
              
              // Subtitle
              Text(
                'Enter the 6-digit code sent to\n+91 ${widget.mobileNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.authTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 26),

              // Error Message
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

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (RawKeyEvent event) {
                        // Handle backspace on empty field
                        if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
                          if (_otpControllers[index].text.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                            _otpControllers[index - 1].clear();
                          }
                        }
                      },
                      child: TextFormField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        enabled: !_isLoading,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.authTextPrimary,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          // Handle forward navigation
                          if (value.isNotEmpty) {
                            if (index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else {
                              // Last field - unfocus keyboard
                              FocusScope.of(context).unfocus();
                            }
                          }
                          // Trigger rebuild to update button state
                          setState(() {});
                        },
                        onEditingComplete: () {
                          // Move to next field on done/enter
                          if (index < 5 && _otpControllers[index].text.isNotEmpty) {
                            _focusNodes[index + 1].requestFocus();
                          }
                        },
                        // Handle backspace key press
                        onTap: () {
                          // If field is empty and user taps, move to previous field
                          if (_otpControllers[index].text.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Verify Button
              AuthPrimaryButton(
                text: 'Verify & Continue',
                isLoading: _isLoading,
                onPressed: _isLoading || _otp.length != 6 ? null : _handleVerifyOtp,
              ),

              const SizedBox(height: 20),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(
                      color: AppTheme.authTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: _canResend ? _handleResendOtp : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _canResend ? 'Resend OTP' : 'Resend in ${_resendTimer}s',
                      style: TextStyle(
                        color: _canResend
                            ? AppTheme.primaryColor
                            : AppTheme.authTextSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

