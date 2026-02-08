import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/mixins/appointment_chat_state_mixin.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/models/chat_message_model.dart';
import 'package:flutter_app/features/appointment/widgets/chat_message_bubble.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Chat screen for appointment messaging.
///
/// Shows messages between farmer and vet for a confirmed appointment.
/// Polls for new messages every 5 seconds.
class AppointmentChatScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentChatScreen({super.key, required this.appointment});

  @override
  State<AppointmentChatScreen> createState() => _AppointmentChatScreenState();
}

class _AppointmentChatScreenState extends State<AppointmentChatScreen>
    with AppointmentChatStateMixin {
  @override
  AppointmentModel get appointment => widget.appointment;

  @override
  void initState() {
    super.initState();
    initializeChat();
  }

  @override
  void dispose() {
    disposeChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE4),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages list
          Expanded(child: _buildMessagesList()),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            otherPartyName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (otherPartySubtitle != null)
            Text(
              otherPartySubtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
        ],
      ),
      actions: [
        if (otherPartyPhone != null && otherPartyPhone!.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.phone_rounded, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling $otherPartyName...'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildMessagesList() {
    if (isChatLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (chatError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48,
                  color: Colors.red[300]),
              const SizedBox(height: 12),
              Text(
                chatError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => initializeChat(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final items = groupedMessages;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 56,
                color: AppTheme.mutedForeground.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.mutedForeground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start the conversation!',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.mutedForeground.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        // Date header
        if (item is String) {
          return _buildDateHeader(ChatMessage.dateLabel(item));
        }

        // Message bubble
        final message = item as ChatMessage;
        return ChatMessageBubble(
          message: message,
          isMine: message.isMine(currentUserId),
        );
      },
    );
  }

  Widget _buildDateHeader(String label) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B6B6B),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F3ED),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: messageController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Color(0xFFA0A0A0),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => sendMessage(),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Send button
          Container(
            height: 44,
            width: 44,
            margin: const EdgeInsets.only(bottom: 1),
            child: Material(
              color: AppTheme.primaryColor,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: isSending ? null : sendMessage,
                customBorder: const CircleBorder(),
                child: Center(
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
