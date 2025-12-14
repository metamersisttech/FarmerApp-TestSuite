import 'package:flutter/material.dart';

import 'package:flutter_app/shared/themes/app_theme.dart';

enum SocialProvider { google, facebook }

class AuthSocialButton extends StatelessWidget {
  final SocialProvider provider;
  final String text;
  final VoidCallback? onPressed;

  const AuthSocialButton({
    super.key,
    required this.provider,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppTheme.authBorderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _brandMark(),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: AppTheme.authTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brandMark() {
    switch (provider) {
      case SocialProvider.google:
        return Container(
          height: 22,
          width: 22,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppTheme.authBorderColor),
          ),
          child: const Center(
            child: Text(
              'G',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        );
      case SocialProvider.facebook:
        return Container(
          height: 22,
          width: 22,
          decoration: BoxDecoration(
            color: Color(0xFF1877F2),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Center(
            child: Icon(Icons.facebook, size: 14, color: Colors.white),
          ),
        );
    }
  }
}


