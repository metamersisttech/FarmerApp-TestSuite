/// Role Request Screen
///
/// User applies for transport provider role.
library;

import 'package:flutter/material.dart';
import 'package:flutter_app/features/transport/services/transport_navigation_service.dart';

class RoleRequestScreen extends StatelessWidget {
  const RoleRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Transport Provider'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero icon
            Icon(
              Icons.local_shipping,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Join Our Transport Network',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Help farmers transport their livestock safely and earn money on your own schedule.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Benefits
            _BenefitCard(
              icon: Icons.monetization_on,
              title: 'Earn Money',
              description: 'Set your own rates and earn per transport job.',
            ),
            const SizedBox(height: 12),
            _BenefitCard(
              icon: Icons.schedule,
              title: 'Flexible Schedule',
              description: 'Work when you want. Accept jobs that fit your availability.',
            ),
            const SizedBox(height: 12),
            _BenefitCard(
              icon: Icons.location_on,
              title: 'Local Jobs',
              description: 'Get notified about transport requests in your area.',
            ),
            const SizedBox(height: 12),
            _BenefitCard(
              icon: Icons.verified_user,
              title: 'Verified Network',
              description: 'Join a trusted network of verified transport providers.',
            ),
            const SizedBox(height: 32),

            // Requirements section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requirements',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RequirementItem(text: 'Valid driving license'),
                  const SizedBox(height: 8),
                  _RequirementItem(text: 'Vehicle registration certificate (RC)'),
                  const SizedBox(height: 8),
                  _RequirementItem(text: 'Vehicle suitable for livestock transport'),
                  const SizedBox(height: 8),
                  _RequirementItem(text: 'Valid vehicle insurance'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Apply button
            ElevatedButton(
              onPressed: () => TransportNavigationService.navigateToOnboardingForm(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;

  const _RequirementItem({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
