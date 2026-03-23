import 'package:flutter/material.dart';

/// Card displaying availability status with icon and description
class AvailabilityStatusCard extends StatelessWidget {
  final bool isAvailable;
  final VoidCallback? onTap;

  const AvailabilityStatusCard({
    super.key,
    required this.isAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isAvailable ? Colors.green : Colors.grey)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAvailable
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: isAvailable ? Colors.green : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAvailable
                        ? 'Currently Available'
                        : 'Currently Unavailable',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isAvailable ? Colors.green : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage your availability schedule',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
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
