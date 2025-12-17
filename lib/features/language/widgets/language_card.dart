import 'package:flutter/material.dart';
import 'package:flutter_app/features/language/models/language_model.dart';
import 'package:flutter_app/shared/widgets/cards/selection_card.dart';
import 'package:flutter_app/shared/widgets/common/icon_badge.dart';
import 'package:flutter_app/shared/widgets/common/selection_indicator.dart';
import 'package:flutter_app/shared/widgets/common/title_subtitle.dart';

/// A selectable card displaying a language option
/// Uses shared widgets for reusability
class LanguageCard extends StatelessWidget {
  final LanguageModel language;
  final bool isSelected;
  final bool isHovered;
  final VoidCallback onTap;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;

  const LanguageCard({
    super.key,
    required this.language,
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
          IconBadge(
            text: language.code,
            isSelected: isSelected,
            isHovered: isHovered,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TitleSubtitle(
              title: language.name,
              subtitle: language.nativeName,
              isSelected: isSelected,
            ),
          ),
          SelectionIndicator(
            isSelected: isSelected,
            isHovered: isHovered,
          ),
        ],
      ),
    );
  }
}
