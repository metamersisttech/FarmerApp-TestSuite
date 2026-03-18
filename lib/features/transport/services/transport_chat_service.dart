/// Transport Chat Service
///
/// Handles messaging operations for transport requests.
library;

import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/transport/models/transport_message_model.dart';
import 'package:flutter_app/features/transport/models/transport_result_models.dart';

class TransportChatService {
  final BackendHelper _backendHelper;

  TransportChatService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Get messages for a transport request
  Future<MessageListResult> getMessages(int requestId) async {
    try {
      final response = await _backendHelper.getTransportMessages(requestId);

      List<dynamic> messagesList = [];
      int? unreadCount;

      if (response is List) {
        messagesList = response;
      } else if (response is Map) {
        messagesList = response['results'] as List<dynamic>? ??
            response['messages'] as List<dynamic>? ??
            [];
        unreadCount = response['unread_count'] as int?;
      }

      final messages = messagesList
          .whereType<Map<String, dynamic>>()
          .map((m) => TransportMessageModel.fromJson(m))
          .toList();

      // Sort by created at (newest first for display, oldest first for chat)
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return MessageListResult.successful(messages, unreadCount: unreadCount);
    } on BackendException catch (e) {
      return MessageListResult.failed(e.message);
    } catch (e) {
      return MessageListResult.failed('Failed to load messages: $e');
    }
  }

  /// Send a message
  Future<SendMessageResult> sendMessage(
    int requestId,
    String body, {
    List<String>? attachmentKeys,
  }) async {
    try {
      final data = <String, dynamic>{
        'body': body,
      };
      if (attachmentKeys != null && attachmentKeys.isNotEmpty) {
        data['attachments'] = attachmentKeys;
      }

      final response = await _backendHelper.postTransportMessage(requestId, data);
      final message = TransportMessageModel.fromJson(response);
      return SendMessageResult.successful(message);
    } on BackendException catch (e) {
      return SendMessageResult.failed(e.message);
    } catch (e) {
      return SendMessageResult.failed('Failed to send message: $e');
    }
  }

  /// Mark messages as read
  Future<MarkReadResult> markMessagesAsRead(int requestId) async {
    try {
      final response = await _backendHelper.postTransportMessagesRead(requestId);
      final markedCount = response['marked_count'] as int?;
      return MarkReadResult.successful(markedCount: markedCount);
    } on BackendException catch (e) {
      return MarkReadResult.failed(e.message);
    } catch (e) {
      return MarkReadResult.failed('Failed to mark messages as read: $e');
    }
  }

  /// Get unread message count
  Future<UnreadCountResult> getUnreadCount(int requestId) async {
    try {
      final response = await _backendHelper.getTransportMessagesUnreadCount(requestId);
      final count = response['unread_count'] as int? ?? response['count'] as int? ?? 0;
      return UnreadCountResult.successful(count);
    } on BackendException catch (e) {
      return UnreadCountResult.failed(e.message);
    } catch (e) {
      return UnreadCountResult.failed('Failed to get unread count: $e');
    }
  }

  /// Upload attachment and get GCS key
  Future<String?> uploadAttachment(String filePath) async {
    try {
      final response = await _backendHelper.postUploadFile(filePath, 'general');
      return response['key'] as String?;
    } on BackendException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to upload attachment: $e');
    }
  }
}
