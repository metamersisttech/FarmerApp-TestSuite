import 'package:flutter/material.dart';
import 'package:flutter_app/features/notifications/controllers/notification_controller.dart';
import 'package:flutter_app/features/notifications/models/notification_model.dart';
import 'package:flutter_app/features/messaging/models/conversation_model.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Mixin for notification screen state management.
/// Creates controller + scroll controller, handles navigation by type.
mixin NotificationStateMixin<T extends StatefulWidget> on State<T> {
  late NotificationController notificationController;
  late ScrollController scrollController;
  final BackendHelper _backendHelper = BackendHelper();

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
        final conversationId = notification.conversationId;
        if (conversationId != null) {
          _navigateToDirectChat(conversationId);
        } else {
          Navigator.pushNamed(context, AppRoutes.conversations);
        }
        break;
      case 'appointment_message':
        final appointmentId = notification.appointmentId;
        if (appointmentId != null) {
          _navigateToAppointmentChat(appointmentId);
        } else {
          Navigator.pushNamed(context, AppRoutes.myAppointments);
        }
        break;
      case 'appointment_created':
      case 'appointment_approved':
      case 'appointment_rejected':
      case 'appointment_completed':
        final appointmentId = notification.appointmentId;
        if (appointmentId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.appointmentDetail,
            arguments: appointmentId,
          );
        } else {
          Navigator.pushNamed(context, AppRoutes.myAppointments);
        }
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

  /// Navigate to direct chat by fetching conversation details
  Future<void> _navigateToDirectChat(int conversationId) async {
    try {
      final response = await _backendHelper.getConversationById(conversationId);
      final conversation = Conversation.fromJson(response);
      Navigator.pushNamed(
        context,
        AppRoutes.directChat,
        arguments: conversation,
      );
    } catch (e) {
      print('⚠️ Failed to load conversation: $e');
      Navigator.pushNamed(context, AppRoutes.conversations);
    }
  }

  /// Navigate to appointment chat by fetching appointment details
  Future<void> _navigateToAppointmentChat(int appointmentId) async {
    try {
      final response = await _backendHelper.getAppointmentById(appointmentId);
      final appointment = AppointmentModel.fromJson(response);
      Navigator.pushNamed(
        context,
        AppRoutes.appointmentChat,
        arguments: appointment,
      );
    } catch (e) {
      print('⚠️ Failed to load appointment: $e');
      Navigator.pushNamed(context, AppRoutes.myAppointments);
    }
  }

  void disposeNotificationController() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    notificationController.dispose();
  }
}
