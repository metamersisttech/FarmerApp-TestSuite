import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/models/chat_message_model.dart';
import 'package:flutter_app/features/appointment/services/chat_service.dart';

/// Mixin for AppointmentChatScreen state management.
///
/// Handles message loading, polling, sending, and auto-scroll.
mixin AppointmentChatStateMixin<T extends StatefulWidget> on State<T> {
  final ChatService _chatService = ChatService();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<ChatMessage> messages = [];
  bool isChatLoading = true;
  bool isSending = false;
  String? chatError;
  int? _currentUserId;
  Timer? _pollTimer;

  /// Must be overridden to provide the appointment
  AppointmentModel get appointment;

  int get currentUserId => _currentUserId ?? 0;

  /// Initialize chat: load user, load messages, mark as read, start polling
  Future<void> initializeChat() async {
    // Load current user ID
    final user = await CommonHelper().getLoggedInUser();
    _currentUserId = user?.id;

    // Load messages
    await _loadMessages();

    // Mark as read
    _chatService.markAsRead(appointment.appointmentId);

    // Start polling every 10 seconds
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _pollNewMessages(),
    );
  }

  /// Load all messages
  Future<void> _loadMessages() async {
    if (!mounted) return;

    setState(() {
      isChatLoading = true;
      chatError = null;
    });

    final result = await _chatService.getMessages(appointment.appointmentId);

    if (!mounted) return;

    if (result.success && result.messages != null) {
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

    final result = await _chatService.getMessages(appointment.appointmentId);

    if (!mounted) return;

    if (result.success && result.messages != null) {
      final newCount = result.messages!.length;
      final oldCount = messages.length;

      if (newCount != oldCount) {
        setState(() {
          messages = result.messages!;
        });
        // Mark as read for newly received messages
        _chatService.markAsRead(appointment.appointmentId);
        if (newCount > oldCount) {
          _scrollToBottom();
        }
      }
    }
  }

  /// Send a message
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isSending) return;

    if (!mounted) return;
    setState(() => isSending = true);

    messageController.clear();

    final result = await _chatService.sendMessage(
      appointment.appointmentId,
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
  String get otherPartyName {
    if (appointment.isVetSide) {
      return appointment.requestor?.name ?? 'Farmer';
    }
    return appointment.vet.name;
  }

  /// Get subtitle for AppBar
  String? get otherPartySubtitle {
    if (appointment.isVetSide) {
      return null;
    }
    return appointment.vet.clinicName.isNotEmpty
        ? appointment.vet.clinicName
        : null;
  }

  /// Get phone number of other party (for call button)
  String? get otherPartyPhone {
    if (appointment.isVetSide) {
      return appointment.requestor?.phone;
    }
    return appointment.vet.phone;
  }

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
  void disposeChat() {
    _pollTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
  }
}
