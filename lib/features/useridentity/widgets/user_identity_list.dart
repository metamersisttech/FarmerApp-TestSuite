import 'package:flutter/material.dart';
import 'package:flutter_app/features/useridentity/models/user_identity_model.dart';
import 'package:flutter_app/features/useridentity/widgets/user_identity_card.dart';

/// Displays a scrollable list of user identity options
class UserIdentityList extends StatelessWidget {
  final List<UserIdentityModel> identities;
  final String? selectedCode;
  final String? hoveredCode;
  final ValueChanged<UserIdentityModel> onSelect;
  final ValueChanged<String> onHoverEnter;
  final VoidCallback onHoverExit;

  const UserIdentityList({
    super.key,
    required this.identities,
    required this.selectedCode,
    required this.hoveredCode,
    required this.onSelect,
    required this.onHoverEnter,
    required this.onHoverExit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: identities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, index) {
        final identity = identities[index];
        return UserIdentityCard(
          identity: identity,
          isSelected: selectedCode == identity.code,
          isHovered: hoveredCode == identity.code,
          onTap: () => onSelect(identity),
          onHoverEnter: () => onHoverEnter(identity.code),
          onHoverExit: onHoverExit,
        );
      },
    );
  }
}

