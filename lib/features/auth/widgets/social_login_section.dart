import 'package:flutter/material.dart';
import 'package:flutter_app/shared/widgets/auth/auth_divider.dart';
import 'package:flutter_app/shared/widgets/auth/auth_social_button.dart';

/// Reusable social login section with Google and Facebook buttons
class SocialLoginSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;

  const SocialLoginSection({
    super.key,
    this.isLoading = false,
    this.onGooglePressed,
    this.onFacebookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AuthDivider(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: AuthSocialButton(
                provider: SocialProvider.google,
                text: 'Google',
                onPressed: isLoading ? null : onGooglePressed,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AuthSocialButton(
                provider: SocialProvider.facebook,
                text: 'Facebook',
                onPressed: isLoading ? null : onFacebookPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

