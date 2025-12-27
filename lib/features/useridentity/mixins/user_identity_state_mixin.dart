import 'package:flutter/material.dart';

/// Mixin for user identity selection state management
mixin UserIdentityStateMixin<T extends StatefulWidget> on State<T> {
  String? selectedIdentityCode;
  String? hoveredIdentityCode;
  bool isLoading = false;
  String? errorMessage;

  /// Select an identity
  void selectIdentity(String code) {
    if (mounted) {
      setState(() => selectedIdentityCode = code);
    }
  }

  /// Handle hover enter
  void onHoverEnter(String code) {
    if (mounted) {
      setState(() => hoveredIdentityCode = code);
    }
  }

  /// Handle hover exit
  void onHoverExit() {
    if (mounted) {
      setState(() => hoveredIdentityCode = null);
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    if (mounted) {
      setState(() => isLoading = loading);
    }
  }

  /// Set error message
  void setError(String? error) {
    if (mounted) {
      setState(() => errorMessage = error);
    }
  }

  /// Clear selection
  void clearSelection() {
    if (mounted) {
      setState(() {
        selectedIdentityCode = null;
        hoveredIdentityCode = null;
      });
    }
  }

  /// Check if an identity is selected
  bool isSelected(String code) => selectedIdentityCode == code;

  /// Check if an identity is hovered
  bool isHovered(String code) => hoveredIdentityCode == code;

  /// Check if any identity is selected
  bool get hasSelection => selectedIdentityCode != null;
}

