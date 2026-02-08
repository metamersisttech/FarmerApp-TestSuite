import 'package:flutter/material.dart';

/// State mixin for the vet onboarding carousel screen
mixin VetOnboardingStateMixin<T extends StatefulWidget> on State<T> {
  late PageController pageController;
  int currentPage = 0;
  final int totalPages = 4;

  void initializeOnboarding() {
    pageController = PageController();
  }

  void onPageChanged(int page) {
    if (mounted) {
      setState(() => currentPage = page);
    }
  }

  void nextPage() {
    if (currentPage < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool get isLastPage => currentPage == totalPages - 1;

  void disposeOnboarding() {
    pageController.dispose();
  }
}
