import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Helper class for consistent form input decoration
class FormInputDecorationHelper {
  /// Build input decoration with consistent styling
  static InputDecoration build({
    required String hintText,
    String? error,
    Widget? prefixIcon,
    bool filled = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      errorText: error,
      prefixIcon: prefixIcon,
      filled: filled,
      fillColor: filled ? Colors.white : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: error != null ? Colors.red : AppTheme.authPrimaryColor,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: error != null 
              ? Colors.red 
              : AppTheme.authPrimaryColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: error != null ? Colors.red : AppTheme.authPrimaryColor,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    );
  }
}
