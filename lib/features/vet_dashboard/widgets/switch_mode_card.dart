import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Reusable card for switching between farmer, vet, and transport modes.
/// Used in farmer profile (switch to vet/transport), vet profile (switch to farmer),
/// and transport profile (switch to farmer).
class SwitchModeCard extends StatelessWidget {
  final String targetMode; // 'farmer', 'vet', or 'transport'
  final VoidCallback? onTap;
  final bool isLoading;

  const SwitchModeCard({
    super.key,
    required this.targetMode,
    this.onTap,
    this.isLoading = false,
  });

  bool get _isTargetVet => targetMode == 'vet';
  bool get _isTargetTransport => targetMode == 'transport';

  IconData get _icon {
    if (_isTargetVet) return Icons.medical_services_outlined;
    if (_isTargetTransport) return Icons.local_shipping;
    return Icons.agriculture_outlined;
  }

  Color get _color {
    if (_isTargetVet) return AppTheme.authPrimaryColor;
    if (_isTargetTransport) return Colors.blue;
    return Colors.orange;
  }

  String get _title {
    if (_isTargetVet) return 'Switch to Vet Mode';
    if (_isTargetTransport) return 'Switch to Transport Mode';
    return 'Switch to Farmer Mode';
  }

  String get _subtitle {
    if (_isTargetVet) return 'Access your vet dashboard';
    if (_isTargetTransport) return 'Access your transport dashboard';
    return 'Access your farmer dashboard';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('switch_mode_card'),
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
                color: _color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                color: _color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isTargetVet
                          ? AppTheme.authPrimaryColor
                          : _isTargetTransport
                              ? Colors.blue[700]
                              : Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
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
                  valueColor: AlwaysStoppedAnimation<Color>(_color),
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
