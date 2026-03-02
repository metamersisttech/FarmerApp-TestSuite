import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/appointment/models/chat_message_model.dart';

/// Result of chat operations
class ChatResult {
  final bool success;
  final String? message;
  final List<ChatMessage>? messages;
  final ChatMessage? sentMessage;
  final int? unreadCount;

  const ChatResult({
    required this.success,
    this.message,
    this.messages,
    this.sentMessage,
    this.unreadCount,
  });

  factory ChatResult.ok({
    List<ChatMessage>? messages,
    ChatMessage? sentMessage,
    int? unreadCount,
    String? message,
  }) {
    return ChatResult(
      success: true,
      message: message,
      messages: messages,
      sentMessage: sentMessage,
      unreadCount: unreadCount,
    );
  }

  factory ChatResult.error(String message) {
    return ChatResult(success: false, message: message);
  }
}

/// Service for appointment chat operations.
/// Kept separate from AppointmentService to isolate chat concerns.
class ChatService {
  final BackendHelper _backendHelper;
  final CommonHelper _commonHelper;

  ChatService({
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

  /// Get messages for an appointment
  /// GET /api/appointments/{id}/messages/
  Future<ChatResult> getMessages(int appointmentId) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.getAppointmentMessages(appointmentId);

      final results = json['results'] as List<dynamic>? ??
          json['messages'] as List<dynamic>? ??
          [];

      final messages = results
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      return ChatResult.ok(messages: messages);
    } on BackendException catch (e) {
      return ChatResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return ChatResult.error('Failed to load messages.');
    }
  }

  /// Send a message
  /// POST /api/appointments/{id}/messages/
  Future<ChatResult> sendMessage(int appointmentId, String body) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.postSendMessage(
        appointmentId,
        {'body': body},
      );
      final message = ChatMessage.fromJson(json);
      return ChatResult.ok(sentMessage: message);
    } on BackendException catch (e) {
      return ChatResult.error(e.message);
    } catch (e) {
      debugPrint('Error sending message: $e');
      return ChatResult.error('Failed to send message.');
    }
  }

  /// Get unread message count
  /// GET /api/appointments/{id}/messages/unread-count/
  Future<ChatResult> getUnreadCount(int appointmentId) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.getUnreadMessageCount(appointmentId);
      final count = json['unread_count'] as int? ?? json['count'] as int? ?? 0;
      return ChatResult.ok(unreadCount: count);
    } on BackendException catch (e) {
      return ChatResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return ChatResult.error('Failed to get unread count.');
    }
  }

  /// Mark all messages as read
  /// POST /api/appointments/{id}/messages/read/
  Future<ChatResult> markAsRead(int appointmentId) async {
    try {
      await _initializeAuth();
      await _backendHelper.postMarkMessagesRead(appointmentId);
      return ChatResult.ok();
    } on BackendException catch (e) {
      return ChatResult.error(e.message);
    } catch (e) {
      debugPrint('Error marking messages read: $e');
      return ChatResult.error('Failed to mark messages as read.');
    }
  }
}
