import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/notifications/models/notification_model.dart';

/// Result of notification operations
class NotificationResult {
  final bool success;
  final String? message;
  final List<NotificationModel>? notifications;
  final NotificationModel? notification;
  final int? totalCount;
  final int? unreadCount;
  final String? nextPageUrl;

  const NotificationResult({
    required this.success,
    this.message,
    this.notifications,
    this.notification,
    this.totalCount,
    this.unreadCount,
    this.nextPageUrl,
  });

  factory NotificationResult.success({
    List<NotificationModel>? notifications,
    NotificationModel? notification,
    int? totalCount,
    int? unreadCount,
    String? nextPageUrl,
    String? message,
  }) {
    return NotificationResult(
      success: true,
      message: message,
      notifications: notifications,
      notification: notification,
      totalCount: totalCount,
      unreadCount: unreadCount,
      nextPageUrl: nextPageUrl,
    );
  }

  factory NotificationResult.error(String message) {
    return NotificationResult(success: false, message: message);
  }
}

/// Service for notification CRUD operations
class NotificationService {
  final BackendHelper _backendHelper;
  final CommonHelper _commonHelper;

  NotificationService({
    BackendHelper? backendHelper,
    CommonHelper? commonHelper,
  })  : _backendHelper = backendHelper ?? BackendHelper(),
        _commonHelper = commonHelper ?? CommonHelper();

  /// Initialize API client with stored token
  Future<void> _initializeAuth() async {
    final accessToken = await _commonHelper.getAccessToken();
    if (accessToken != null) {
      APIClient().setAuthorization(accessToken);
    }
  }

  /// Get notifications (paginated, with optional filters)
  Future<NotificationResult> getNotifications({
    String? type,
    bool? isRead,
    int? page,
    int? pageSize,
  }) async {
    try {
      await _initializeAuth();

      final params = <String, dynamic>{};
      if (type != null) params['type'] = type;
      if (isRead != null) params['is_read'] = isRead.toString();
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final data = await _backendHelper.getNotifications(params: params);

      List<dynamic> results;
      int? totalCount;
      String? nextPageUrl;

      if (data is Map<String, dynamic>) {
        results = data['results'] as List<dynamic>? ?? [];
        totalCount = data['count'] as int?;
        nextPageUrl = data['next'] as String?;
      } else if (data is List) {
        results = data;
        totalCount = data.length;
      } else {
        results = [];
      }

      final notifications = results
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return NotificationResult.success(
        notifications: notifications,
        totalCount: totalCount ?? notifications.length,
        nextPageUrl: nextPageUrl,
      );
    } on BackendException catch (e) {
      return NotificationResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return NotificationResult.error('Failed to load notifications.');
    }
  }

  /// Mark a single notification as read
  Future<NotificationResult> markAsRead(int notificationId) async {
    try {
      await _initializeAuth();
      await _backendHelper.postMarkNotificationRead(notificationId);
      return NotificationResult.success(
        message: 'Notification marked as read.',
      );
    } on BackendException catch (e) {
      return NotificationResult.error(e.message);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return NotificationResult.error('Failed to mark notification as read.');
    }
  }

  /// Mark all notifications as read
  Future<NotificationResult> markAllAsRead() async {
    try {
      await _initializeAuth();
      await _backendHelper.postMarkAllNotificationsRead();
      return NotificationResult.success(
        message: 'All notifications marked as read.',
      );
    } on BackendException catch (e) {
      return NotificationResult.error(e.message);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return NotificationResult.error('Failed to mark all as read.');
    }
  }

  /// Get unread notification count
  Future<NotificationResult> getUnreadCount() async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.getNotificationsUnreadCount();
      final count = json['unread_count'] as int? ?? json['count'] as int? ?? 0;
      return NotificationResult.success(unreadCount: count);
    } on BackendException catch (e) {
      return NotificationResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return NotificationResult.error('Failed to get unread count.');
    }
  }
}
