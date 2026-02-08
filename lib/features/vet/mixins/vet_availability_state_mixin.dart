import 'package:flutter/material.dart';

/// State mixin for the vet availability screen
mixin VetAvailabilityStateMixin<T extends StatefulWidget> on State<T> {
  bool isLoading = true;
  String? errorMessage;
  bool isSaving = false;

  void setAvailabilityLoading(bool loading) {
    if (mounted) {
      setState(() => isLoading = loading);
    }
  }

  void setAvailabilityError(String? error) {
    if (mounted) {
      setState(() => errorMessage = error);
    }
  }

  void setAvailabilitySaving(bool saving) {
    if (mounted) {
      setState(() => isSaving = saving);
    }
  }
}
