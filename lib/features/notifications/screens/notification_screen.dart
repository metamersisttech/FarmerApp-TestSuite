import 'package:flutter/material.dart';
import 'package:flutter_app/features/notifications/mixins/notification_state_mixin.dart';
import 'package:flutter_app/features/notifications/widgets/notification_card.dart';
import 'package:flutter_app/features/notifications/widgets/notification_empty_state.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Notification center screen — lists all user notifications
/// with pull-to-refresh, infinite scroll, and mark-all-read.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with NotificationStateMixin {
  @override
  void initState() {
    super.initState();
    initializeNotificationController();
    notificationController.addListener(_onControllerChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationController.loadNotifications();
    });
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    notificationController.removeListener(_onControllerChanged);
    disposeNotificationController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = notificationController.notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.authPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (hasUnread)
            TextButton(
              key: const Key('mark_all_read_btn'),
              onPressed: handleMarkAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Loading state (first load)
    if (notificationController.isLoading &&
        notificationController.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (notificationController.errorMessage != null &&
        notificationController.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                notificationController.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notificationController.loadNotifications(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (notificationController.notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => notificationController.loadNotifications(),
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: NotificationEmptyState(),
        ),
      );
    }

    // Notification list
    return RefreshIndicator(
      onRefresh: () => notificationController.loadNotifications(),
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notificationController.notifications.length +
            (notificationController.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator at bottom
          if (index == notificationController.notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          final notification = notificationController.notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () => handleNotificationTap(notification),
          );
        },
      ),
    );
  }
}
