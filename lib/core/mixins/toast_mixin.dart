import 'package:flutter/material.dart';

/// Toast type enum
enum ToastType { success, error, info }

/// Mixin for showing toast notifications at the top of the screen
mixin ToastMixin<T extends StatefulWidget> on State<T> {
  OverlayEntry? _currentToast;

  /// Show toast notification at the top of the screen
  void showTopToast(
    String message, {
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 5),
  }) {
    // Remove existing toast if any
    _currentToast?.remove();

    // Determine color and icon based on type
    Color backgroundColor;
    IconData icon;
    
    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case ToastType.error:
        backgroundColor = Colors.redAccent;
        icon = Icons.error_outline;
        break;
      case ToastType.info:
        backgroundColor = Colors.blueAccent;
        icon = Icons.info_outline;
        break;
    }

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
              color: backgroundColor,
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
                  icon,
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
      // Check if widget is still mounted before removing toast
      if (mounted && _currentToast != null) {
        _currentToast?.remove();
        _currentToast = null;
      }
    });
  }

  /// Show success toast (green)
  void showSuccessToast(String message) =>
      showTopToast(message, type: ToastType.success);

  /// Show error toast (red)
  void showErrorToast(String message) => 
      showTopToast(message, type: ToastType.error);

  /// Show info toast (blue)
  void showInfoToast(String message) => 
      showTopToast(message, type: ToastType.info);

  @override
  void dispose() {
    _currentToast?.remove();
    _currentToast = null;
    super.dispose();
  }
}

