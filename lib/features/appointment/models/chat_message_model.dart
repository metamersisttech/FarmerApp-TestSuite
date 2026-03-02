// Chat message model for appointment messaging.
// Maps GET /api/appointments/{id}/messages/ response items.

/// Sender info embedded in each message
class ChatMessageSender {
  final int id;
  final String name;
  final String? profileImage;

  const ChatMessageSender({
    required this.id,
    required this.name,
    this.profileImage,
  });

  factory ChatMessageSender.fromJson(Map<String, dynamic> json) {
    return ChatMessageSender(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ??
          json['full_name'] as String? ??
          '',
      profileImage: json['profile_image'] as String?,
    );
  }
}

/// A single chat message
class ChatMessage {
  final int messageId;
  final ChatMessageSender fromUser;
  final String body;
  final List<String> attachments;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessage({
    required this.messageId,
    required this.fromUser,
    required this.body,
    this.attachments = const [],
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final attachmentsList = <String>[];
    if (json['attachments'] is List) {
      for (final a in json['attachments'] as List) {
        if (a is String) attachmentsList.add(a);
      }
    }

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['created_at'] as String);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return ChatMessage(
      messageId: json['message_id'] as int? ?? json['id'] as int? ?? 0,
      fromUser: ChatMessageSender.fromJson(
        json['from_user'] as Map<String, dynamic>? ?? {},
      ),
      body: json['body'] as String? ?? '',
      attachments: attachmentsList,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: parsedDate,
    );
  }

  /// Check if message is from the given user ID
  bool isMine(int currentUserId) => fromUser.id == currentUserId;

  /// Formatted time string (e.g. "2:30 PM")
  String get formattedTime {
    final hour = createdAt.hour;
    final minute = createdAt.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Date-only key for grouping (yyyy-MM-dd)
  String get dateKey =>
      '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

  /// Display label for date grouping
  static String dateLabel(String dateKey) {
    try {
      final date = DateTime.parse(dateKey);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(date.year, date.month, date.day);

      if (messageDate == today) return 'Today';
      if (messageDate == today.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      }

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateKey;
    }
  }
}
