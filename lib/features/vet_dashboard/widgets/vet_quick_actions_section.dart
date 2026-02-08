import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Quick actions grid for the vet dashboard.
/// Shows 4 vet-specific quick actions in a 2x2 grid.
class VetQuickActionsSection extends StatelessWidget {
  final VoidCallback? onAppointmentsTap;
  final VoidCallback? onAvailabilityTap;
  final VoidCallback? onPricingTap;
  final VoidCallback? onProfileTap;

  const VetQuickActionsSection({
    super.key,
    this.onAppointmentsTap,
    this.onAvailabilityTap,
    this.onPricingTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        label: 'Appointments',
        icon: Icons.calendar_today_outlined,
        iconColor: AppTheme.authPrimaryColor,
        backgroundColor: AppTheme.authPrimaryColor.withOpacity(0.1),
        onTap: onAppointmentsTap,
      ),
      _QuickAction(
        label: 'Availability',
        icon: Icons.schedule_outlined,
        iconColor: const Color(0xFF5C6BC0),
        backgroundColor: const Color(0xFFE8EAF6),
        onTap: onAvailabilityTap,
      ),
      _QuickAction(
        label: 'Pricing',
        icon: Icons.payments_outlined,
        iconColor: const Color(0xFFFF7043),
        backgroundColor: const Color(0xFFFBE9E7),
        onTap: onPricingTap,
      ),
      _QuickAction(
        label: 'My Profile',
        icon: Icons.person_outline,
        iconColor: const Color(0xFF26A69A),
        backgroundColor: const Color(0xFFE0F2F1),
        onTap: onProfileTap,
      ),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.authTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return GestureDetector(
                onTap: action.onTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: action.backgroundColor,
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                          ),
                          child: Icon(
                            action.icon,
                            color: action.iconColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
  });
}
