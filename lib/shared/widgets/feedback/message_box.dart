import 'package:flutter/material.dart';

/// Message box widget for displaying errors, success, warnings, etc.
class MessageBox extends StatelessWidget {
  final String message;
  final MessageType type;
  final VoidCallback? onDismiss;

  const MessageBox({
    super.key,
    required this.message,
    this.type = MessageType.error,
    this.onDismiss,
  });

  /// Convenience constructor for error messages
  const MessageBox.error({
    super.key,
    required this.message,
    this.onDismiss,
  }) : type = MessageType.error;

  /// Convenience constructor for success messages
  const MessageBox.success({
    super.key,
    required this.message,
    this.onDismiss,
  }) : type = MessageType.success;

  /// Convenience constructor for warning messages
  const MessageBox.warning({
    super.key,
    required this.message,
    this.onDismiss,
  }) : type = MessageType.warning;

  /// Convenience constructor for info messages
  const MessageBox.info({
    super.key,
    required this.message,
    this.onDismiss,
  }) : type = MessageType.info;

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(config.icon, color: config.iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: config.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close, color: config.iconColor, size: 18),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  _MessageConfig _getConfig() {
    switch (type) {
      case MessageType.error:
        return _MessageConfig(
          backgroundColor: Colors.red.shade50,
          iconColor: Colors.redAccent,
          textColor: Colors.redAccent,
          icon: Icons.error_outline,
        );
      case MessageType.success:
        return _MessageConfig(
          backgroundColor: Colors.green.shade50,
          iconColor: Colors.green.shade700,
          textColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );
      case MessageType.warning:
        return _MessageConfig(
          backgroundColor: Colors.orange.shade50,
          iconColor: Colors.orange.shade700,
          textColor: Colors.orange.shade700,
          icon: Icons.warning_amber_outlined,
        );
      case MessageType.info:
        return _MessageConfig(
          backgroundColor: Colors.blue.shade50,
          iconColor: Colors.blue.shade700,
          textColor: Colors.blue.shade700,
          icon: Icons.info_outline,
        );
    }
  }
}

enum MessageType { error, success, warning, info }

class _MessageConfig {
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  _MessageConfig({
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}

