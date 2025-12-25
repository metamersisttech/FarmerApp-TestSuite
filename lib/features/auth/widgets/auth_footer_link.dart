import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Footer link widget for auth screens (e.g., "Already have an account? Sign In")
class AuthFooterLink extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback? onTap;
  final bool enabled;

  const AuthFooterLink({
    super.key,
    required this.text,
    required this.linkText,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.authTextSecondary,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Text(
            linkText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: enabled ? AppTheme.authPrimaryColor : AppTheme.authTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

