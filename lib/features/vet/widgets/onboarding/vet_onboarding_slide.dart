import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// A single slide in the vet onboarding carousel
class VetOnboardingSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String>? bulletPoints;

  const VetOnboardingSlide({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.bulletPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.authPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: AppTheme.authPrimaryColor,
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),

          // Bullet points
          if (bulletPoints != null && bulletPoints!.isNotEmpty) ...[
            const SizedBox(height: 24),
            ...bulletPoints!.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.authPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          point,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
