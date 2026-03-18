/// Fare Proposal State Mixin
///
/// Provides form state and validation for fare proposal.
library;

import 'package:flutter/material.dart';

mixin FareProposalStateMixin<T extends StatefulWidget> on State<T> {
  final fareController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  double? minFare;
  double? maxFare;
  bool isProposing = false;

  /// Set fare range
  void setFareRange(double min, double max) {
    setState(() {
      minFare = min;
      maxFare = max;
    });

    // Set default value to midpoint if empty
    if (fareController.text.isEmpty) {
      final suggested = ((min + max) / 2).round();
      fareController.text = suggested.toString();
    }
  }

  /// Validate fare
  String? validateFare(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a fare amount';
    }

    final fare = double.tryParse(value.replaceAll(',', ''));
    if (fare == null) {
      return 'Please enter a valid amount';
    }

    if (fare <= 0) {
      return 'Fare must be greater than 0';
    }

    if (minFare != null && maxFare != null) {
      // Allow 10% flexibility outside range
      final lowerBound = minFare! * 0.9;
      final upperBound = maxFare! * 1.1;

      if (fare < lowerBound) {
        return 'Fare is too low. Minimum: \u20B9${lowerBound.toStringAsFixed(0)}';
      }

      if (fare > upperBound) {
        return 'Fare is too high. Maximum: \u20B9${upperBound.toStringAsFixed(0)}';
      }
    }

    return null;
  }

  /// Get fare value
  double? getFare() {
    final text = fareController.text.replaceAll(',', '');
    return double.tryParse(text);
  }

  /// Validate form
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Get suggested fare (midpoint)
  double get suggestedFare {
    if (minFare == null || maxFare == null) return 0;
    return (minFare! + maxFare!) / 2;
  }

  /// Get formatted fare range
  String get formattedFareRange {
    if (minFare == null || maxFare == null) return '';
    return '\u20B9${minFare!.toStringAsFixed(0)} - \u20B9${maxFare!.toStringAsFixed(0)}';
  }

  /// Set proposing state
  void setProposing(bool value) {
    setState(() {
      isProposing = value;
    });
  }

  /// Set fare to suggested value
  void setToSuggestedFare() {
    fareController.text = suggestedFare.round().toString();
  }

  /// Set fare to minimum
  void setToMinFare() {
    if (minFare != null) {
      fareController.text = minFare!.round().toString();
    }
  }

  /// Set fare to maximum
  void setToMaxFare() {
    if (maxFare != null) {
      fareController.text = maxFare!.round().toString();
    }
  }

  /// Increase fare by amount
  void increaseFare(double amount) {
    final current = getFare() ?? suggestedFare;
    fareController.text = (current + amount).round().toString();
  }

  /// Decrease fare by amount
  void decreaseFare(double amount) {
    final current = getFare() ?? suggestedFare;
    final newFare = (current - amount).round();
    if (newFare > 0) {
      fareController.text = newFare.toString();
    }
  }

  /// Reset form
  void resetForm() {
    fareController.clear();
    setState(() {
      minFare = null;
      maxFare = null;
      isProposing = false;
    });
    formKey.currentState?.reset();
  }

  @override
  void dispose() {
    fareController.dispose();
    super.dispose();
  }
}
