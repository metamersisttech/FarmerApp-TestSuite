import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Search Location Bar
///
/// Displays current location with option to change it
class SearchLocationBar extends StatelessWidget {
  final String? location;
  final VoidCallback onTap;
  final bool isDetecting;

  const SearchLocationBar({
    super.key,
    required this.location,
    required this.onTap,
    this.isDetecting = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            // Location Icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.authPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isDetecting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.authPrimaryColor,
                      ),
                    )
                  : Icon(
                      location != null ? Icons.location_on : Icons.location_off,
                      color: AppTheme.authPrimaryColor,
                      size: 20,
                    ),
            ),

            const SizedBox(width: 12),

            // Location Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDetecting
                        ? 'Detecting location...'
                        : location ?? 'Tap to set location',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: location != null ? Colors.black87 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Change Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
