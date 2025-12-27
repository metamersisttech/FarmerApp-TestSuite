import 'package:flutter/material.dart';

/// Mixin for language selection page state management
mixin LanguageStateMixin<T extends StatefulWidget> on State<T> {
  String? selectedLanguageCode;
  String? hoveredLanguageCode;

  /// Handle language selection
  void selectLanguage(String code) {
    if (mounted) {
      setState(() => selectedLanguageCode = code);
    }
  }

  /// Handle hover enter
  void onHoverEnter(String code) {
    if (mounted) {
      setState(() => hoveredLanguageCode = code);
    }
  }

  /// Handle hover exit
  void onHoverExit() {
    if (mounted) {
      setState(() => hoveredLanguageCode = null);
    }
  }

  /// Clear selection
  void clearSelection() {
    if (mounted) {
      setState(() {
        selectedLanguageCode = null;
        hoveredLanguageCode = null;
      });
    }
  }

  /// Check if a language is selected
  bool isLanguageSelected(String code) {
    return selectedLanguageCode == code;
  }

  /// Check if a language is hovered
  bool isLanguageHovered(String code) {
    return hoveredLanguageCode == code;
  }
}

