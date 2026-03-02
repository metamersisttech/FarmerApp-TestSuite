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

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

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
  Future<void> markAsRead(int notificationId) async {
    if (isDisposed) return;

    // Optimistic local update
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWithRead();
      _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      notifyListeners();
    }

    // Fire API call
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
