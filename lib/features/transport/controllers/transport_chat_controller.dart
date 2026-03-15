/// Transport Chat Controller
///
/// Manages transport request chat messages.
library;

import 'dart:async';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/transport_message_model.dart';
import 'package:flutter_app/features/transport/services/transport_chat_service.dart';

class TransportChatController extends BaseController {
  final TransportChatService _chatService;

  int? _requestId;
  List<TransportMessageModel> _messages = [];
  int _unreadCount = 0;
  bool _isSending = false;
  bool _isUploading = false;
  List<String> _pendingAttachments = [];

  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 10);

  int? get requestId => _requestId;
  List<TransportMessageModel> get messages => _messages;
  int get unreadCount => _unreadCount;
  bool get isSending => _isSending;
  bool get isUploading => _isUploading;
  List<String> get pendingAttachments => _pendingAttachments;

  /// Check if has messages
  bool get hasMessages => _messages.isNotEmpty;

  /// Check if has pending attachments
  bool get hasPendingAttachments => _pendingAttachments.isNotEmpty;

  TransportChatController({
    TransportChatService? chatService,
  }) : _chatService = chatService ?? TransportChatService();

  /// Initialize with request ID
  Future<void> initialize(int requestId) async {
    if (isDisposed) return;

    _requestId = requestId;
    await loadMessages();
    _startPolling();
  }

  /// Load messages (can optionally pass requestId)
  Future<void> loadMessages([int? requestId]) async {
    if (requestId != null) {
      _requestId = requestId;
    }

    if (isDisposed || _requestId == null) return;

    setLoading(true);
    clearError();

    try {
      final result = await _chatService.getMessages(_requestId!);

      if (isDisposed) return;

      if (result.success) {
        _messages = result.messages ?? [];
        _unreadCount = result.unreadCount ?? 0;

        // Mark as read
        if (_unreadCount > 0) {
          await markMessagesAsRead(_requestId!);
        }

        notifyListeners();
      } else {
        setError(result.errorMessage ?? 'Failed to load messages');
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to load messages: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Start polling for new messages
  void _startPolling() {
    _stopPolling();

    _pollTimer = Timer.periodic(
      _pollInterval,
      (_) => _pollMessages(),
    );
  }

  /// Stop polling
  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Poll for new messages
  Future<void> _pollMessages() async {
    if (isDisposed || _requestId == null) return;

    try {
      final result = await _chatService.getMessages(_requestId!);

      if (isDisposed) return;

      if (result.success && result.messages != null) {
        final hadNewMessages = result.messages!.length > _messages.length;
        _messages = result.messages!;
        _unreadCount = result.unreadCount ?? 0;

        // Mark as read if new messages
        if (hadNewMessages && _unreadCount > 0) {
          await markMessagesAsRead(_requestId!);
        }

        notifyListeners();
      }
    } catch (e) {
      // Silently fail polling
    }
  }

  /// Mark messages as read (public API)
  Future<void> markMessagesAsRead(int requestId) async {
    if (isDisposed) return;

    try {
      await _chatService.markMessagesAsRead(requestId);
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      // Silently fail
    }
  }

  /// Send a message (accepts named parameters for compatibility)
  Future<bool> sendMessage({
    int? requestId,
    required String body,
  }) async {
    final targetRequestId = requestId ?? _requestId;
    if (isDisposed || targetRequestId == null) return false;

    if (body.trim().isEmpty && _pendingAttachments.isEmpty) {
      return false;
    }

    _isSending = true;
    clearError();
    notifyListeners();

    try {
      final result = await _chatService.sendMessage(
        targetRequestId,
        body.trim(),
        attachmentKeys: _pendingAttachments.isNotEmpty ? _pendingAttachments : null,
      );

      if (isDisposed) return false;

      _isSending = false;

      if (result.success && result.message != null) {
        _messages.add(result.message!);
        _pendingAttachments = [];
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to send message');
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        _isSending = false;
        setError('Failed to send message: $e');
        notifyListeners();
      }
      return false;
    }
  }

  /// Check if the user is the current user
  bool isCurrentUser(int? userId) {
    // TODO: Get current user ID from auth service
    // For now, return false - messages from others will be on the left
    return false;
  }

  /// Upload attachment
  Future<bool> uploadAttachment(String filePath) async {
    if (isDisposed || _requestId == null) return false;

    _isUploading = true;
    notifyListeners();

    try {
      final key = await _chatService.uploadAttachment(filePath);

      if (isDisposed) return false;

      _isUploading = false;

      if (key != null) {
        _pendingAttachments.add(key);
        notifyListeners();
        return true;
      } else {
        setError('Failed to upload attachment');
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        _isUploading = false;
        setError('Failed to upload attachment: $e');
        notifyListeners();
      }
      return false;
    }
  }

  /// Remove pending attachment
  void removePendingAttachment(int index) {
    if (index >= 0 && index < _pendingAttachments.length) {
      _pendingAttachments.removeAt(index);
      notifyListeners();
    }
  }

  /// Clear pending attachments
  void clearPendingAttachments() {
    _pendingAttachments = [];
    notifyListeners();
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    if (_requestId == null) return 0;

    try {
      final result = await _chatService.getUnreadCount(_requestId!);
      if (result.success) {
        _unreadCount = result.count ?? 0;
        return _unreadCount;
      }
    } catch (e) {
      // Return current count on error
    }
    return _unreadCount;
  }

  /// Refresh messages
  Future<void> refreshMessages() async {
    if (isDisposed || _requestId == null) return;

    try {
      final result = await _chatService.getMessages(_requestId!);

      if (isDisposed) return;

      if (result.success) {
        _messages = result.messages ?? [];
        _unreadCount = result.unreadCount ?? 0;

        if (_unreadCount > 0) {
          await markMessagesAsRead(_requestId!);
        }

        notifyListeners();
      }
    } catch (e) {
      // Silently fail refresh
    }
  }

  /// Reset state
  void reset() {
    _stopPolling();
    _requestId = null;
    _messages = [];
    _unreadCount = 0;
    _isSending = false;
    _isUploading = false;
    _pendingAttachments = [];
    clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
