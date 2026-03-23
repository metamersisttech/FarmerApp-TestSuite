import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/notifications/models/notification_model.dart';
import 'package:flutter_app/features/notifications/services/notification_service.dart';

/// Controller for notification state and pagination
class NotificationController extends BaseController {
  final NotificationService _service;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  NotificationController({NotificationService? service})
      : _service = service ?? NotificationService();

  // ============ Getters ============

  List<NotificationModel> get notifications => _getGroupedNotifications();
  List<NotificationModel> get rawNotifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  /// Group message notifications by conversation/appointment to avoid duplicates
  /// For direct messages: group by conversation_id (keep latest)
  /// For appointment messages: group by appointment_id (keep latest)
  /// For other notifications: show all
  List<NotificationModel> _getGroupedNotifications() {
    final grouped = <String, NotificationModel>{};
    final nonGroupable = <NotificationModel>[];

    for (final notification in _notifications) {
      final type = notification.type;
      
      // Group direct messages by conversation_id
      if (type == 'direct_message') {
        final conversationId = notification.conversationId;
        if (conversationId != null) {
          final key = 'conversation_$conversationId';
          // Keep the latest (most recent) notification for this conversation
          if (!grouped.containsKey(key) || 
              notification.createdAt.isAfter(grouped[key]!.createdAt)) {
            grouped[key] = notification;
          }
          continue;
        }
      }
      
      // Group appointment messages by appointment_id
      if (type == 'appointment_message') {
        final appointmentId = notification.appointmentId;
        if (appointmentId != null) {
          final key = 'appointment_msg_$appointmentId';
          // Keep the latest notification for this appointment chat
          if (!grouped.containsKey(key) || 
              notification.createdAt.isAfter(grouped[key]!.createdAt)) {
            grouped[key] = notification;
          }
          continue;
        }
      }
      
      // Don't group other notification types (bids, appointment status, etc.)
      nonGroupable.add(notification);
    }

    // Combine grouped and non-grouped notifications, sort by creation time
    final result = [...grouped.values, ...nonGroupable];
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  // ============ Load Methods ============

  /// Load first page of notifications (resets state)
  Future<void> loadNotifications() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();
    _currentPage = 1;
    _hasMore = true;

    final result = await _service.getNotifications(page: 1);

    if (isDisposed) return;

    if (result.success) {
      _notifications = result.notifications ?? [];
      _hasMore = result.nextPageUrl != null;
      _currentPage = 1;
    } else {
      setError(result.message ?? 'Failed to load notifications.');
    }

    setLoading(false);
  }

  /// Load next page (infinite scroll)
  Future<void> loadMoreNotifications() async {
    if (isDisposed || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _currentPage + 1;
    final result = await _service.getNotifications(page: nextPage);

    if (isDisposed) return;

    if (result.success) {
      final newItems = result.notifications ?? [];
      _notifications = [..._notifications, ...newItems];
      _hasMore = result.nextPageUrl != null;
      _currentPage = nextPage;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Fetch just the unread count (for badge display)
  Future<void> fetchUnreadCount() async {
    if (isDisposed) return;

    final result = await _service.getUnreadCount();

    if (isDisposed) return;

    if (result.success) {
      _unreadCount = result.unreadCount ?? 0;
      notifyListeners();
    }
  }

  // ============ Action Methods ============

  /// Mark a single notification as read (optimistic update)
  /// For message notifications, this marks ALL messages in the same conversation as read
  Future<void> markAsRead(int notificationId) async {
    if (isDisposed) return;

    // Find the notification
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final notification = _notifications[index];
    final type = notification.type;
    
    // For message notifications, mark all in the same conversation as read
    List<int> idsToMark = [notificationId];
    
    if (type == 'direct_message') {
      final conversationId = notification.conversationId;
      if (conversationId != null) {
        // Find all notifications from the same conversation
        idsToMark = _notifications
            .where((n) => 
                n.type == 'direct_message' && 
                n.conversationId == conversationId &&
                !n.isRead)
            .map((n) => n.id)
            .toList();
      }
    } else if (type == 'appointment_message') {
      final appointmentId = notification.appointmentId;
      if (appointmentId != null) {
        // Find all notifications from the same appointment chat
        idsToMark = _notifications
            .where((n) => 
                n.type == 'appointment_message' && 
                n.appointmentId == appointmentId &&
                !n.isRead)
            .map((n) => n.id)
            .toList();
      }
    }

    // Optimistic local update for all related notifications
    int markedCount = 0;
    for (int i = 0; i < _notifications.length; i++) {
      if (idsToMark.contains(_notifications[i].id) && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWithRead();
        markedCount++;
      }
    }
    
    if (markedCount > 0) {
      _unreadCount = (_unreadCount - markedCount).clamp(0, _unreadCount);
      notifyListeners();
    }

    // Fire API call for the primary notification
    // (Backend should ideally mark all related ones, but we're doing optimistic update)
    final result = await _service.markAsRead(notificationId);
    if (!result.success) {
      debugPrint('Failed to mark notification $notificationId as read: ${result.message}');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (isDisposed) return;

    // Optimistic local update
    _notifications = _notifications.map((n) => n.isRead ? n : n.copyWithRead()).toList();
    _unreadCount = 0;
    notifyListeners();

    // Fire API call
    final result = await _service.markAllAsRead();
    if (!result.success) {
      debugPrint('Failed to mark all as read: ${result.message}');
    }
  }
}
