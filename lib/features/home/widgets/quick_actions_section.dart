import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Quick action item data model
class QuickActionItem {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
  });
}

/// Quick Actions section widget
class QuickActionsSection extends StatelessWidget {
  final String title;
  final VoidCallback? onMarketplaceTap;
  final VoidCallback? onAgriStoreTap;
  final VoidCallback? onVetServicesTap;
  final VoidCallback? onTransportTap;
  final VoidCallback? onFinanceTap;
  final VoidCallback? onAIToolsTap;
  final VoidCallback? onCommunityTap;
  final VoidCallback? onPremiumTap;

  const QuickActionsSection({
    super.key,
    this.title = 'Quick Actions',
    this.onMarketplaceTap,
    this.onAgriStoreTap,
    this.onVetServicesTap,
    this.onTransportTap,
    this.onFinanceTap,
    this.onAIToolsTap,
    this.onCommunityTap,
    this.onPremiumTap,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      // Row 1
      QuickActionItem(
        label: 'Browse Livestock',
        icon: Icons.storefront_outlined,
        iconColor: const Color(0xFF4CAF50),
        backgroundColor: const Color(0xFFE8F5E9),
        onTap: onMarketplaceTap,
      ),
      QuickActionItem(
        label: 'Agri Store',
        icon: Icons.inventory_2_outlined,
        iconColor: const Color(0xFF5C6BC0),
        backgroundColor: const Color(0xFFE8EAF6),
        onTap: onAgriStoreTap,
      ),
      QuickActionItem(
        label: 'Vet Services',
        icon: Icons.medical_services_outlined,
        iconColor: const Color(0xFFE91E63),
        backgroundColor: const Color(0xFFFCE4EC),
        onTap: onVetServicesTap,
      ),
      QuickActionItem(
        label: 'Transport',
        icon: Icons.local_shipping_outlined,
        iconColor: const Color(0xFFFF7043),
        backgroundColor: const Color(0xFFFBE9E7),
        onTap: onTransportTap,
      ),
      // Row 2
      QuickActionItem(
        label: 'Finance',
        icon: Icons.account_balance_outlined,
        iconColor: const Color(0xFF26A69A),
        backgroundColor: const Color(0xFFE0F2F1),
        onTap: onFinanceTap,
      ),
      QuickActionItem(
        label: 'AI Tools',
        icon: Icons.auto_awesome_outlined,
        iconColor: const Color(0xFF9C27B0),
        backgroundColor: const Color(0xFFF3E5F5),
        onTap: onAIToolsTap,
      ),
      QuickActionItem(
        label: 'Community',
        icon: Icons.groups_outlined,
        iconColor: const Color(0xFF00ACC1),
        backgroundColor: const Color(0xFFE0F7FA),
        onTap: onCommunityTap,
      ),
      QuickActionItem(
        label: 'Premium',
        icon: Icons.workspace_premium_outlined,
        iconColor: const Color(0xFFFFB300),
        backgroundColor: const Color(0xFFFFF8E1),
        onTap: onPremiumTap,
      ),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.authTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Horizontal scrollable list of quick actions
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < actions.length - 1 ? 12 : 0,
                  ),
                  child: _QuickActionButton(item: actions[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Single quick action button widget
class _QuickActionButton extends StatelessWidget {
  final QuickActionItem item;

  const _QuickActionButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: SizedBox(
        width: 75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container - fixed size
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: item.backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              child: Icon(
                item.icon,
                color: item.iconColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 6),
            // Label
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
