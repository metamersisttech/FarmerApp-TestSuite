import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/appointment/models/chat_message_model.dart';
import 'package:flutter_app/features/messaging/models/conversation_model.dart';

/// Result of messaging operations
class MessagingResult {
  final bool success;
  final String? message;
  final List<Conversation>? conversations;
  final Conversation? conversation;
  final List<ChatMessage>? messages;
  final ChatMessage? sentMessage;
  final bool? created;

  const MessagingResult({
    required this.success,
    this.message,
    this.conversations,
    this.conversation,
    this.messages,
    this.sentMessage,
    this.created,
  });

  factory MessagingResult.ok({
    List<Conversation>? conversations,
    Conversation? conversation,
    List<ChatMessage>? messages,
    ChatMessage? sentMessage,
    bool? created,
    String? message,
  }) {
    return MessagingResult(
      success: true,
      message: message,
      conversations: conversations,
      conversation: conversation,
      messages: messages,
      sentMessage: sentMessage,
      created: created,
    );
  }

  factory MessagingResult.error(String message) {
    return MessagingResult(success: false, message: message);
  }
}

/// Service for direct buyer-seller messaging operations.
class MessagingService {
  final BackendHelper _backendHelper;
  final CommonHelper _commonHelper;

  MessagingService({
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

  /// Start or get conversation from a listing
  /// POST /api/listings/{listing_id}/chat/
  Future<MessagingResult> startConversation(int listingId) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.postStartConversation(listingId);

      final conversationJson = json['conversation'] as Map<String, dynamic>? ?? json;
      final conversation = Conversation.fromJson(conversationJson);
      final created = json['created'] as bool? ?? false;

      return MessagingResult.ok(
        conversation: conversation,
        created: created,
      );
    } on BackendException catch (e) {
      return MessagingResult.error(e.message);
    } catch (e) {
      debugPrint('Error starting conversation: $e');
      return MessagingResult.error('Failed to start conversation.');
    }
  }

  /// Get all conversations (inbox)
  /// GET /api/messages/conversations/
  Future<MessagingResult> getConversations() async {
    try {
      await _initializeAuth();
      final data = await _backendHelper.getConversations();

      List<dynamic> results;
      if (data is List) {
        results = data;
      } else if (data is Map) {
        results = data['results'] as List<dynamic>? ?? [];
      } else {
        results = [];
      }

      final conversations = results
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();

      return MessagingResult.ok(conversations: conversations);
    } on BackendException catch (e) {
      return MessagingResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting conversations: $e');
      return MessagingResult.error('Failed to load conversations.');
    }
  }

  /// Get messages for a conversation (with pagination)
  /// GET /api/messages/conversations/{id}/messages/
  Future<MessagingResult> getMessages(
    int conversationId, {
    int? limit,
    int? beforeMessageId,
  }) async {
    try {
      await _initializeAuth();
      final data = await _backendHelper.getConversationMessages(
        conversationId,
        limit: limit,
        beforeMessageId: beforeMessageId,
      );

      List<dynamic> results;
      if (data is List) {
        results = data;
      } else if (data is Map) {
        results = data['results'] as List<dynamic>? ??
            data['messages'] as List<dynamic>? ??
            [];
      } else {
        results = [];
      }

      final messages = results
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      return MessagingResult.ok(messages: messages);
    } on BackendException catch (e) {
      return MessagingResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return MessagingResult.error('Failed to load messages.');
    }
  }

  /// Send a message in a conversation
  /// POST /api/messages/conversations/{id}/messages/
  Future<MessagingResult> sendMessage(
    int conversationId,
    String body,
  ) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.postConversationMessage(
        conversationId,
        {'body': body},
      );
      final message = ChatMessage.fromJson(json);
      return MessagingResult.ok(sentMessage: message);
    } on BackendException catch (e) {
      return MessagingResult.error(e.message);
    } catch (e) {
      debugPrint('Error sending message: $e');
      return MessagingResult.error('Failed to send message.');
    }
  }

  /// Mark messages as read in a conversation
  /// POST /api/messages/conversations/{id}/messages/read/
  Future<MessagingResult> markAsRead(int conversationId) async {
    try {
      await _initializeAuth();
      await _backendHelper.postConversationMarkRead(conversationId);
      return MessagingResult.ok();
    } on BackendException catch (e) {
      return MessagingResult.error(e.message);
    } catch (e) {
      debugPrint('Error marking messages read: $e');
      return MessagingResult.error('Failed to mark messages as read.');
    }
  }
}
