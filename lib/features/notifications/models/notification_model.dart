/// Notification data model
///
/// Parses notification JSON from Django backend.
/// Supports payload helpers for navigation by notification type.
class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.payload,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notification_id'] as int? ?? json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : <String, dynamic>{},
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Return a copy with isRead set to true (for optimistic updates)
  NotificationModel copyWithRead() {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      payload: payload,
      isRead: true,
      createdAt: createdAt,
    );
  }

  // ============ Payload Helpers ============

  int? get conversationId => _parseIntField('conversation_id');
  int? get appointmentId => _parseIntField('appointment_id');
  int? get listingId => _parseIntField('listing_id');

  int? _parseIntField(String key) {
    final value = payload[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  // ============ Display Helpers ============

  /// Human-readable relative time ("2h ago", "3d ago", etc.)
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}
