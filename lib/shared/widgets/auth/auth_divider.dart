import 'package:flutter/material.dart';

import 'package:flutter_app/shared/themes/app_theme.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({super.key, this.text = 'or continue with'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppTheme.authBorderColor, height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.authTextSecondary),
          ),
        ),
        const Expanded(
          child: Divider(color: AppTheme.authBorderColor, height: 1),
        ),
      ],
    );
  }
}


