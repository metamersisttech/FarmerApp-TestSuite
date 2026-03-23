import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Bottom action bar with call, video, chat, and book buttons
class VetBottomActionBar extends StatelessWidget {
  final VoidCallback? onCallTap;
  final VoidCallback? onVideoTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onBookTap;
  final bool isAvailable;

  const VetBottomActionBar({
    super.key,
    this.onCallTap,
    this.onVideoTap,
    this.onChatTap,
    this.onBookTap,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Action icons
          _buildActionIcon(
            icon: Icons.phone_outlined,
            onTap: onCallTap,
            tooltip: 'Call',
          ),
          const SizedBox(width: 12),
          _buildActionIcon(
            icon: Icons.videocam_outlined,
            onTap: onVideoTap,
            tooltip: 'Video Call',
          ),
          const SizedBox(width: 12),
          _buildActionIcon(
            icon: Icons.chat_outlined,
            onTap: onChatTap,
            tooltip: 'Chat',
          ),
          const SizedBox(width: 16),
          // Book appointment button
          Expanded(
            child: _buildBookButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    VoidCallback? onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return GestureDetector(
      onTap: isAvailable ? onBookTap : null,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isAvailable ? AppTheme.primaryColor : Colors.grey[400],
          borderRadius: BorderRadius.circular(24),
          boxShadow: isAvailable
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            isAvailable ? 'Book Appointment' : 'Currently Unavailable',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
