import 'package:flutter/material.dart';

/// Logout button with red styling
class LogoutButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const LogoutButton({
    super.key,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEEBEB), // Light red background
              border: Border.all(
                color: const Color(0xFFE57373), // Slight red border
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE57373)),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  const Icon(
                    Icons.logout,
                    color: Color(0xFFD32F2F), // Red icon
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  isLoading ? 'Logging out...' : 'Logout',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD32F2F), // Red text
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

