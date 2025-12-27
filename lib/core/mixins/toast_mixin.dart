import 'package:flutter/material.dart';

/// Mixin for showing toast notifications at the top of the screen
mixin ToastMixin<T extends StatefulWidget> on State<T> {
  OverlayEntry? _currentToast;

  /// Show toast notification at the top of the screen
  void showTopToast(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 5),
  }) {
    // Remove existing toast if any
    _currentToast?.remove();

    final overlay = Overlay.of(context);
    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isError ? Colors.redAccent : Colors.green,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentToast!);

    Future.delayed(duration, () {
      _currentToast?.remove();
      _currentToast = null;
    });
  }

  /// Show success toast (green)
  void showSuccessToast(String message) =>
      showTopToast(message, isError: false);

  /// Show error toast (red)
  void showErrorToast(String message) => showTopToast(message, isError: true);

  @override
  void dispose() {
    _currentToast?.remove();
    super.dispose();
  }
}

