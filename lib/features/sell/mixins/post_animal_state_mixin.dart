import 'package:flutter/material.dart';

/// Mixin for post animal form state management
mixin PostAnimalStateMixin<T extends StatefulWidget> on State<T> {
  int currentStep = 0;
  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// Navigate to specific step
  void goToStep(int step) {
    pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Go to next step
  void nextStep() {
    if (currentStep < 3) {
      goToStep(currentStep + 1);
    }
  }

  /// Go to previous step
  void previousStep() {
    if (currentStep > 0) {
      goToStep(currentStep - 1);
    }
  }

  /// Update current step
  void updateStep(int step) {
    if (mounted) {
      setState(() => currentStep = step);
    }
  }

  /// Check if on first step
  bool get isFirstStep => currentStep == 0;

  /// Check if on last step (4 steps: 0-3)
  bool get isLastStep => currentStep == 3;

  /// Get step label
  String getStepLabel(int step) {
    const labels = ['Details', 'Health', 'Media', 'Preview'];
    return step >= 0 && step < labels.length ? labels[step] : '';
  }
}
