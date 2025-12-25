import 'package:flutter/material.dart';
import 'package:flutter_app/features/useridentity/models/user_identity_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/cards/selection_card.dart';

/// Card widget for displaying a single user identity option
class UserIdentityCard extends StatelessWidget {
  final UserIdentityModel identity;
  final bool isSelected;
  final bool isHovered;
  final VoidCallback onTap;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;

  const UserIdentityCard({
    super.key,
    required this.identity,
    required this.isSelected,
    required this.isHovered,
    required this.onTap,
    required this.onHoverEnter,
    required this.onHoverExit,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionCard(
      isSelected: isSelected,
      isHovered: isHovered,
      onTap: onTap,
      onHoverEnter: onHoverEnter,
      onHoverExit: onHoverExit,
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              identity.icon,
              color: isSelected ? Colors.white : AppTheme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // Identity name
          Expanded(
            child: Text(
              identity.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.authTextPrimary,
              ),
            ),
          ),
          
          // Selection indicator
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: AppTheme.primaryColor,
              size: 24,
            ),
        ],
      ),
    );
  }
}

