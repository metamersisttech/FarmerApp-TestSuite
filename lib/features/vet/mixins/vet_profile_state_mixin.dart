import 'package:flutter/material.dart';

/// State mixin for the vet profile screen
mixin VetProfileStateMixin<T extends StatefulWidget> on State<T> {
  bool isLoading = true;
  String? errorMessage;
  bool isSaving = false;

  void setProfileLoading(bool loading) {
    if (mounted) {
      setState(() => isLoading = loading);
    }
  }

  void setProfileError(String? error) {
    if (mounted) {
      setState(() => errorMessage = error);
    }
  }

  void setProfileSaving(bool saving) {
    if (mounted) {
      setState(() => isSaving = saving);
    }
  }
}
