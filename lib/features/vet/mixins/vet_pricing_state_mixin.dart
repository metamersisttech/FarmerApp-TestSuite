import 'package:flutter/material.dart';

/// State mixin for the vet pricing screen
mixin VetPricingStateMixin<T extends StatefulWidget> on State<T> {
  bool isLoading = true;
  String? errorMessage;
  bool isSaving = false;

  void setPricingLoading(bool loading) {
    if (mounted) {
      setState(() => isLoading = loading);
    }
  }

  void setPricingError(String? error) {
    if (mounted) {
      setState(() => errorMessage = error);
    }
  }

  void setPricingSaving(bool saving) {
    if (mounted) {
      setState(() => isSaving = saving);
    }
  }
}
