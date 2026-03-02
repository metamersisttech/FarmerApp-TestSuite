import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/models/chat_message_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Chat message bubble widget.
///
/// Right-aligned green for "mine", left-aligned white for "theirs".
/// Shows sender name (for theirs), body, time, and read receipt.
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isMine ? 48 : 12,
          right: isMine ? 12 : 48,
          top: 2,
          bottom: 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isMine ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender name (only for "theirs")
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.fromUser.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor.withOpacity(0.9),
                  ),
                ),
              ),

            // Message body
            Text(
              message.body,
              style: TextStyle(
                fontSize: 15,
                color: isMine ? Colors.white : const Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),

            const SizedBox(height: 3),

            // Time + read receipt
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.formattedTime,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isMine
                        ? Colors.white.withOpacity(0.7)
                        : AppTheme.mutedForeground,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 3),
                  Icon(
                    message.isRead
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 14,
                    color: message.isRead
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.6),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
