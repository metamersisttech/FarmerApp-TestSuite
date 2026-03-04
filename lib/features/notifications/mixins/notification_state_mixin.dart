import 'package:flutter/material.dart';
import 'package:flutter_app/features/notifications/controllers/notification_controller.dart';
import 'package:flutter_app/features/notifications/models/notification_model.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Mixin for notification screen state management.
/// Creates controller + scroll controller, handles navigation by type.
mixin NotificationStateMixin<T extends StatefulWidget> on State<T> {
  late NotificationController notificationController;
  late ScrollController scrollController;

  void initializeNotificationController() {
    notificationController = NotificationController();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      notificationController.loadMoreNotifications();
    }
  }

  /// Handle tapping a notification — mark as read + navigate by type
  void handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      notificationController.markAsRead(notification.id);
    }

    // Navigate based on type
    switch (notification.type) {
      case 'direct_message':
        Navigator.pushNamed(context, AppRoutes.conversations);
        break;
      case 'appointment_message':
        Navigator.pushNamed(context, AppRoutes.myAppointments);
        break;
      case 'new_bid':
        final listingId = notification.listingId;
        if (listingId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.listingBids,
            arguments: listingId,
          );
        }
        break;
      case 'bid_approved':
      case 'bid_rejected':
        final listingId = notification.listingId;
        if (listingId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.animalDetail,
            arguments: listingId,
          );
        }
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification details not available.')),
        );
    }
  }

  /// Mark all notifications as read
  void handleMarkAllAsRead() {
    notificationController.markAllAsRead();
  }

  void disposeNotificationController() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    notificationController.dispose();
  }
}
