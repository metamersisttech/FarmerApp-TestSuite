/// Provider Info Card Widget
///
/// Displays transport provider details when request is accepted.
library;

import 'package:flutter/material.dart';
import 'package:flutter_app/features/transport/models/transport_provider_model.dart';
import 'package:flutter_app/features/transport/models/vehicle_model.dart';

class ProviderInfoCard extends StatelessWidget {
  final TransportProviderModel provider;
  final VehicleModel? vehicle;
  final VoidCallback? onChatTap;
  final VoidCallback? onCallTap;

  const ProviderInfoCard({
    super.key,
    required this.provider,
    this.vehicle,
    this.onChatTap,
    this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Transport Provider',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 12),

            // Provider info row
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: provider.user?.profileImage != null
                      ? NetworkImage(provider.user!.profileImage!)
                      : null,
                  child: provider.user?.profileImage == null
                      ? Icon(
                          Icons.person,
                          size: 28,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Name and rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.user?.displayName ??
                            provider.user?.fullName ??
                            'Provider',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.rating > 0
                                ? provider.rating.toStringAsFixed(1)
                                : 'New',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (provider.completedTrips > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(${provider.completedTrips} trips)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Action buttons
                if (onChatTap != null || onCallTap != null)
                  Row(
                    children: [
                      if (onChatTap != null)
                        IconButton(
                          icon: Icon(
                            Icons.chat_bubble_outline,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: onChatTap,
                          tooltip: 'Chat',
                        ),
                      if (onCallTap != null)
                        IconButton(
                          icon: Icon(
                            Icons.phone_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: onCallTap,
                          tooltip: 'Call',
                        ),
                    ],
                  ),
              ],
            ),

            // Vehicle info (if available)
            if (vehicle != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_shipping,
                      size: 24,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle!.vehicleType,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vehicle!.registrationNumber,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vehicle!.formattedMaxWeight,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
