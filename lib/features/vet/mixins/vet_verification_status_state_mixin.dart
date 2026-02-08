import 'package:flutter/material.dart';
import 'package:flutter_app/features/vet/models/vet_verification_status_model.dart';

/// State mixin for the vet verification status screen
mixin VetVerificationStatusStateMixin<T extends StatefulWidget> on State<T> {
  VetVerificationStatusModel? verificationStatus;
  bool isLoading = true;
  String? errorMessage;

  void setVerificationStatus(VetVerificationStatusModel? status) {
    if (mounted) {
      setState(() => verificationStatus = status);
    }
  }

  void setStatusLoading(bool loading) {
    if (mounted) {
      setState(() => isLoading = loading);
    }
  }

  void setStatusError(String? error) {
    if (mounted) {
      setState(() => errorMessage = error);
    }
  }
}
