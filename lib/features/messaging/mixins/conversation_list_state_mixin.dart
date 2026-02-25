import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/messaging/models/conversation_model.dart';
import 'package:flutter_app/features/messaging/services/messaging_service.dart';

/// Mixin for conversations list (inbox) state management.
///
/// Handles loading, polling, and refresh of conversations.
mixin ConversationListStateMixin<T extends StatefulWidget> on State<T> {
  final MessagingService _messagingService = MessagingService();

  List<Conversation> conversations = [];
  bool isLoadingConversations = true;
  String? conversationsError;
  Timer? _pollTimer;

  /// Initialize: load conversations and start polling
  Future<void> initializeConversations() async {
    await _loadConversations();

    // Poll every 10 seconds for updates
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _pollConversations(),
    );
  }

  /// Load all conversations
  Future<void> _loadConversations() async {
    if (!mounted) return;

    setState(() {
      isLoadingConversations = true;
      conversationsError = null;
    });

    final result = await _messagingService.getConversations();

    if (!mounted) return;

    if (result.success && result.conversations != null) {
      setState(() {
        conversations = result.conversations!;
        isLoadingConversations = false;
      });
    } else {
      setState(() {
        conversationsError = result.message ?? 'Failed to load conversations';
        isLoadingConversations = false;
      });
    }
  }

  /// Poll for updated conversations (silent, no loading indicator)
  Future<void> _pollConversations() async {
    if (!mounted) return;

    final result = await _messagingService.getConversations();

    if (!mounted) return;

    if (result.success && result.conversations != null) {
      setState(() {
        conversations = result.conversations!;
      });
    }
  }

  /// Refresh conversations (for pull-to-refresh)
  Future<void> refreshConversations() async {
    final result = await _messagingService.getConversations();

    if (!mounted) return;

    if (result.success && result.conversations != null) {
      setState(() {
        conversations = result.conversations!;
        conversationsError = null;
      });
    }
  }

  /// Dispose timer
  void disposeConversations() {
    _pollTimer?.cancel();
  }
}
