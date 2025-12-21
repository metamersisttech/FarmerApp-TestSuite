import 'package:flutter/material.dart';
import 'package:flutter_app/features/language/models/language_model.dart';
import 'package:flutter_app/features/language/widgets/language_card.dart';

/// Displays a scrollable list of language options
class LanguageList extends StatelessWidget {
  final List<LanguageModel> languages;
  final String? selectedCode;
  final String? hoveredCode;
  final ValueChanged<LanguageModel> onSelect;
  final ValueChanged<String> onHoverEnter;
  final VoidCallback onHoverExit;

  const LanguageList({
    super.key,
    required this.languages,
    required this.selectedCode,
    required this.hoveredCode,
    required this.onSelect,
    required this.onHoverEnter,
    required this.onHoverExit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: languages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, index) {
        final language = languages[index];
        return LanguageCard(
          language: language,
          isSelected: selectedCode == language.code,
          isHovered: hoveredCode == language.code,
          onTap: () => onSelect(language),
          onHoverEnter: () => onHoverEnter(language.code),
          onHoverExit: onHoverExit,
        );
      },
    );
  }
}
