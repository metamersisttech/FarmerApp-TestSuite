import 'package:flutter/material.dart';
import 'package:flutter_app/features/notifications/models/notification_model.dart';

/// A single notification list item card.
/// Shows type icon, title, body, time, and unread indicator.
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getTypeConfig(notification.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF0F9F0),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(config.icon, color: config.color, size: 22),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: Colors.grey[900],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),

            // Unread dot
            if (!notification.isRead)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _TypeConfig _getTypeConfig(String type) {
    switch (type) {
      case 'direct_message':
      case 'appointment_message':
        return _TypeConfig(Icons.chat_bubble_outline, Colors.blue);
      case 'appointment_created':
      case 'appointment_approved':
      case 'appointment_rejected':
      case 'appointment_completed':
        return _TypeConfig(Icons.medical_services_outlined, Colors.teal);
      case 'new_bid':
        return _TypeConfig(Icons.gavel, Colors.orange);
      case 'bid_approved':
        return _TypeConfig(Icons.check_circle_outline, Colors.green);
      case 'bid_rejected':
        return _TypeConfig(Icons.cancel_outlined, Colors.red);
      default:
        return _TypeConfig(Icons.notifications_outlined, Colors.grey);
    }
  }
}

class _TypeConfig {
  final IconData icon;
  final Color color;
  const _TypeConfig(this.icon, this.color);
}
