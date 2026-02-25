// Conversation models for direct buyer-seller messaging.
// Maps GET /api/messages/conversations/ response items.

/// User info in a conversation (the other party)
class ConversationUser {
  final int id;
  final String username;
  final String fullName;
  final String? profileImage;

  const ConversationUser({
    required this.id,
    required this.username,
    required this.fullName,
    this.profileImage,
  });

  factory ConversationUser.fromJson(Map<String, dynamic> json) {
    return ConversationUser(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      profileImage: json['profile_image'] as String?,
    );
  }

  /// Display name: full_name if available, otherwise username
  String get displayName =>
      fullName.isNotEmpty ? fullName : username;

  /// Display initials for avatar fallback
  String get initials {
    final name = displayName;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

/// Listing that initiated the conversation
class ConversationListing {
  final int listingId;
  final String title;

  const ConversationListing({
    required this.listingId,
    required this.title,
  });

  factory ConversationListing.fromJson(Map<String, dynamic> json) {
    return ConversationListing(
      listingId: json['listing_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
    );
  }
}

/// Last message preview in a conversation
class ConversationLastMessage {
  final String body;
  final DateTime createdAt;
  final int fromUserId;

  const ConversationLastMessage({
    required this.body,
    required this.createdAt,
    required this.fromUserId,
  });

  factory ConversationLastMessage.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['created_at'] as String);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return ConversationLastMessage(
      body: json['body'] as String? ?? '',
      createdAt: parsedDate,
      fromUserId: json['from_user_id'] as int? ?? 0,
    );
  }
}

/// A conversation between two users
class Conversation {
  final int conversationId;
  final ConversationUser otherUser;
  final ConversationListing? initiatedFromListing;
  final ConversationLastMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final DateTime createdAt;

  const Conversation({
    required this.conversationId,
    required this.otherUser,
    this.initiatedFromListing,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    DateTime parsedUpdated;
    DateTime parsedCreated;
    try {
      parsedUpdated = DateTime.parse(json['updated_at'] as String);
    } catch (_) {
      parsedUpdated = DateTime.now();
    }
    try {
      parsedCreated = DateTime.parse(json['created_at'] as String);
    } catch (_) {
      parsedCreated = DateTime.now();
    }

    return Conversation(
      conversationId: json['conversation_id'] as int? ?? 0,
      otherUser: ConversationUser.fromJson(
        json['other_user'] as Map<String, dynamic>? ?? {},
      ),
      initiatedFromListing: json['initiated_from_listing'] is Map<String, dynamic>
          ? ConversationListing.fromJson(
              json['initiated_from_listing'] as Map<String, dynamic>,
            )
          : null,
      lastMessage: json['last_message'] is Map<String, dynamic>
          ? ConversationLastMessage.fromJson(
              json['last_message'] as Map<String, dynamic>,
            )
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      updatedAt: parsedUpdated,
      createdAt: parsedCreated,
    );
  }

  /// Relative time label for display (e.g., "2m", "3h", "Yesterday")
  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d';

    final month = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][updatedAt.month - 1];
    return '$month ${updatedAt.day}';
  }
}
