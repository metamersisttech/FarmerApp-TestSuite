import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// KYC verification status card
class KycStatusCard extends StatelessWidget {
  final bool isVerified;
  final String? status; // verified, pending, not_verified
  final VoidCallback? onTap;

  const KycStatusCard({
    super.key,
    this.isVerified = false,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isKycVerified = isVerified || status == 'verified';
    final isPending = status == 'pending';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isKycVerified
                    ? AppTheme.authPrimaryColor.withOpacity(0.1)
                    : isPending
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isKycVerified
                    ? Icons.verified_user
                    : isPending
                        ? Icons.schedule
                        : Icons.shield_outlined,
                color: isKycVerified
                    ? AppTheme.authPrimaryColor
                    : isPending
                        ? Colors.orange
                        : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isKycVerified
                        ? 'KYC Verified'
                        : isPending
                            ? 'KYC Pending'
                            : 'KYC Not Verified',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isKycVerified
                          ? AppTheme.authPrimaryColor
                          : isPending
                              ? Colors.orange
                              : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isKycVerified
                        ? 'Your account is fully verified'
                        : isPending
                            ? 'Verification in progress'
                            : 'Complete verification to unlock all features',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow if not verified (to complete KYC)
            if (!isKycVerified)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

