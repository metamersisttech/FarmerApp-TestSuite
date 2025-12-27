import 'package:flutter/material.dart';
import 'package:flutter_app/features/profile/models/profile_model.dart';
import 'package:flutter_app/features/profile/widgets/profile_menu_item.dart';

/// Profile menu list widget
class ProfileMenuList extends StatelessWidget {
  final List<ProfileMenuItem> menuItems;

  const ProfileMenuList({
    super.key,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == menuItems.length - 1;
          
          return Column(
            children: [
              ProfileMenuItemWidget(
                icon: item.icon,
                title: item.title,
                badgeCount: item.badgeCount,
                onTap: item.onTap,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 16,
                  color: Colors.grey[200],
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

