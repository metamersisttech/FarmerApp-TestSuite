import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/appointment/models/chat_message_model.dart';
import 'package:flutter_app/features/messaging/models/conversation_model.dart';
import 'package:flutter_app/features/messaging/services/messaging_service.dart';

/// Mixin for direct chat screen state management.
///
/// Handles message loading, polling, sending, pagination, and auto-scroll.
mixin DirectChatStateMixin<T extends StatefulWidget> on State<T> {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<ChatMessage> messages = [];
  bool isChatLoading = true;
  bool isSending = false;
  bool isLoadingOlder = false;
  String? chatError;
  int? _currentUserId;
  Timer? _pollTimer;
  bool _hasOlderMessages = true;

  /// Must be overridden to provide the conversation
  Conversation get conversation;

  int get currentUserId => _currentUserId ?? 0;

  /// Initialize chat: load user, load messages, mark as read, start polling
  Future<void> initializeDirectChat() async {
    // Load current user ID
    final user = await CommonHelper().getLoggedInUser();
    _currentUserId = user?.id;
    debugPrint('[DirectChat] Current user ID: $_currentUserId (raw user: ${user?.id})');

    // Load messages
    await _loadMessages();

    // Mark as read
    _messagingService.markAsRead(conversation.conversationId);

    // Start polling every 5 seconds
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _pollNewMessages(),
    );

    // Listen for scroll-to-top to load older messages
    scrollController.addListener(_onScroll);
  }

  /// Load initial messages
  Future<void> _loadMessages() async {
    if (!mounted) return;

    setState(() {
      isChatLoading = true;
      chatError = null;
    });

    final result = await _messagingService.getMessages(
      conversation.conversationId,
    );

    if (!mounted) return;

    if (result.success && result.messages != null) {
      debugPrint('[DirectChat] Loaded ${result.messages!.length} messages. CurrentUserId=$_currentUserId');
      for (final msg in result.messages!) {
        final body = msg.body.length > 30 ? '${msg.body.substring(0, 30)}...' : msg.body;
        debugPrint('[DirectChat] msg#${msg.messageId}: fromUser.id=${msg.fromUser.id}, '
            'fromUser.name=${msg.fromUser.name}, '
            'isMine=${msg.isMine(_currentUserId ?? 0)}, '
            'body="$body"');
      }
      setState(() {
        messages = result.messages!;
        isChatLoading = false;
      });
      _scrollToBottom();
    } else {
      setState(() {
        chatError = result.message ?? 'Failed to load messages';
        isChatLoading = false;
      });
    }
  }

  /// Poll for new messages (silent, no loading indicator)
  Future<void> _pollNewMessages() async {
    if (!mounted) return;

    final result = await _messagingService.getMessages(
      conversation.conversationId,
    );

    if (!mounted) return;

    if (result.success && result.messages != null) {
      final newCount = result.messages!.length;
      final oldCount = messages.length;

      if (newCount != oldCount) {
        setState(() {
          messages = result.messages!;
        });
        // Mark as read for newly received messages
        _messagingService.markAsRead(conversation.conversationId);
        if (newCount > oldCount) {
          _scrollToBottom();
        }
      }
    }
  }

  /// Load older messages when scrolled to top
  void _onScroll() {
    if (scrollController.position.pixels <= 0 &&
        !isLoadingOlder &&
        _hasOlderMessages &&
        messages.isNotEmpty) {
      _loadOlderMessages();
    }
  }

  /// Load older messages (pagination)
  Future<void> _loadOlderMessages() async {
    if (!mounted || messages.isEmpty) return;

    setState(() => isLoadingOlder = true);

    final oldestMessageId = messages.first.messageId;

    final result = await _messagingService.getMessages(
      conversation.conversationId,
      beforeMessageId: oldestMessageId,
      limit: 20,
    );

    if (!mounted) return;

    if (result.success && result.messages != null) {
      if (result.messages!.isEmpty) {
        _hasOlderMessages = false;
      } else {
        setState(() {
          messages = [...result.messages!, ...messages];
        });
      }
    }

    setState(() => isLoadingOlder = false);
  }

  /// Send a message
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isSending) return;

    if (!mounted) return;
    setState(() => isSending = true);

    messageController.clear();

    final result = await _messagingService.sendMessage(
      conversation.conversationId,
      text,
    );

    if (!mounted) return;

    if (result.success && result.sentMessage != null) {
      setState(() {
        messages.add(result.sentMessage!);
        isSending = false;
      });
      _scrollToBottom();
    } else {
      // Restore the text so user can retry
      messageController.text = text;
      setState(() => isSending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Failed to send message'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  /// Scroll to bottom of message list
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Get the other party's display name for AppBar
  String get otherPartyName => conversation.otherUser.displayName;

  /// Get subtitle for AppBar (listing title if available)
  String? get listingTitle => conversation.initiatedFromListing?.title;

  /// Group messages by date for display
  List<dynamic> get groupedMessages {
    if (messages.isEmpty) return [];

    final grouped = <dynamic>[];
    String? lastDateKey;

    for (final msg in messages) {
      if (msg.dateKey != lastDateKey) {
        lastDateKey = msg.dateKey;
        grouped.add(msg.dateKey); // String = date header
      }
      grouped.add(msg); // ChatMessage = message bubble
    }

    return grouped;
  }

  /// Dispose timer and controllers
  void disposeDirectChat() {
    _pollTimer?.cancel();
    scrollController.removeListener(_onScroll);
    messageController.dispose();
    scrollController.dispose();
  }
}
