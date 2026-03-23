import 'package:flutter/material.dart';

/// Field error message display
class FieldError extends StatelessWidget {
  final String error;

  const FieldError({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 14, color: Colors.red.shade700),
          const SizedBox(width: 4),
          Text(
            error,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
