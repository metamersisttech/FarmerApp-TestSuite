import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Reusable card for switching between farmer and vet modes.
/// Used in both farmer profile (switch to vet) and vet profile (switch to farmer).
class SwitchModeCard extends StatelessWidget {
  final String targetMode; // 'farmer' or 'vet'
  final VoidCallback? onTap;
  final bool isLoading;

  const SwitchModeCard({
    super.key,
    required this.targetMode,
    this.onTap,
    this.isLoading = false,
  });

  bool get _isTargetVet => targetMode == 'vet';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isTargetVet
                    ? AppTheme.authPrimaryColor.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isTargetVet
                    ? Icons.medical_services_outlined
                    : Icons.agriculture_outlined,
                color: _isTargetVet
                    ? AppTheme.authPrimaryColor
                    : Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isTargetVet
                        ? 'Switch to Vet Mode'
                        : 'Switch to Farmer Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isTargetVet
                          ? AppTheme.authPrimaryColor
                          : Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isTargetVet
                        ? 'Access your vet dashboard'
                        : 'Access your farmer dashboard',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isTargetVet
                        ? AppTheme.authPrimaryColor
                        : Colors.orange,
                  ),
                ),
              )
            else
              Icon(
                Icons.swap_horiz,
                color: Colors.grey[400],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
