/// Availability Toggle Widget
///
/// Large switch with status text for provider availability.
library;

import 'package:flutter/material.dart';

class AvailabilityToggle extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool>? onChanged;
  final bool isLoading;

  const AvailabilityToggle({
    super.key,
    required this.isAvailable,
    this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status text
            Text(
              isAvailable ? 'You are Online' : 'You are Offline',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isAvailable
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isAvailable
                  ? 'You can receive transport requests'
                  : 'Go online to receive requests',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            // Large toggle button
            GestureDetector(
              onTap: isLoading ? null : () => onChanged?.call(!isAvailable),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: isAvailable
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  boxShadow: [
                    BoxShadow(
                      color: (isAvailable
                              ? theme.colorScheme.primary
                              : Colors.grey)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background icons
                    if (!isLoading) ...[
                      Positioned(
                        left: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Icon(
                            Icons.wifi_off,
                            size: 24,
                            color: isAvailable
                                ? theme.colorScheme.onPrimary.withValues(alpha: 0.5)
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Icon(
                            Icons.wifi,
                            size: 24,
                            color: isAvailable
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],

                    // Toggle knob
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: isAvailable ? 64 : 4,
                      top: 4,
                      bottom: 4,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isLoading
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : Icon(
                                isAvailable ? Icons.power_settings_new : Icons.power_off,
                                color: isAvailable
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact availability indicator for app bar or header
class AvailabilityIndicator extends StatelessWidget {
  final bool isAvailable;

  const AvailabilityIndicator({
    super.key,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAvailable ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isAvailable ? 'Online' : 'Offline',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isAvailable ? Colors.green.shade700 : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
