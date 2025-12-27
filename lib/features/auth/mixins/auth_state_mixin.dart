import 'package:flutter/material.dart';

/// Mixin for common auth page state management
mixin AuthStateMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage;

  /// Validate form and clear errors
  bool validateForm() {
    setState(() => errorMessage = null);
    return formKey.currentState?.validate() ?? false;
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

  /// Clear error message
  void clearError() {
    if (mounted) {
      setState(() => errorMessage = null);
    }
  }
}

