import 'package:flutter/material.dart';
import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/core/utils/validators.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_app/features/auth/screens/register_page.dart';
import 'package:flutter_app/features/home/screens/home_page.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/auth/auth_divider.dart';
import 'package:flutter_app/shared/widgets/auth/auth_primary_button.dart';
import 'package:flutter_app/shared/widgets/auth/auth_social_button.dart';
import 'package:flutter_app/shared/widgets/common/page_header.dart';
import 'package:flutter_app/shared/widgets/feedback/message_box.dart';
import 'package:flutter_app/shared/widgets/forms/text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authRepository.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    } on UnauthorizedException {
      setState(() => _errorMessage = 'Invalid email or password');
    } on NetworkException {
      setState(() => _errorMessage = 'No internet connection. Please try again.');
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSkip() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 110),

                // Header
                const PageHeader(
                  icon: Icons.login_rounded,
                  title: 'Welcome Back',
                  subtitle: 'Sign in to continue',
                ),
                const SizedBox(height: 26),

                // Error Message
                if (_errorMessage != null) ...[
                  MessageBox.error(
                    message: _errorMessage!,
                    onDismiss: () => setState(() => _errorMessage = null),
                  ),
                  const SizedBox(height: 12),
                ],

                // Email Field
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

                // Password Field
                PasswordField(
                  controller: _passwordController,
                  hintText: 'Password',
                  enabled: !_isLoading,
                  validator: (value) => Validators.validateRequired(value, fieldName: 'Password'),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 16),

                // Login Button
                AuthPrimaryButton(
                  text: 'Login',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleLogin,
                ),
                const SizedBox(height: 16),

                // Forgot Password / Sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Forgot Password - Coming soon!')),
                              );
                            },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppTheme.authTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Text(' / ', style: TextStyle(color: AppTheme.authTextSecondary)),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterPage()),
                              ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: AppTheme.authPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Divider
                const AuthDivider(),
                const SizedBox(height: 18),

                // Social Login Buttons
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

                // Continue as Guest
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
      ),
    );
  }
}
