/// Transport Message Model
///
/// Represents a message in a transport request chat.
/// Maps to Django TransportMessageSerializer.
library;

import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';

class TransportMessageModel {
  final int messageId;
  final UserModel? fromUser;
  final String body;
  final List<String> attachments; // GCS keys
  final bool isRead;
  final DateTime createdAt;

  const TransportMessageModel({
    required this.messageId,
    this.fromUser,
    required this.body,
    this.attachments = const [],
    this.isRead = false,
    required this.createdAt,
  });

  factory TransportMessageModel.fromJson(Map<String, dynamic> json) {
    // Parse from user
    UserModel? fromUser;
    if (json['from_user'] is Map<String, dynamic>) {
      fromUser = UserModel.fromJson(json['from_user'] as Map<String, dynamic>);
    } else if (json['sender'] is Map<String, dynamic>) {
      fromUser = UserModel.fromJson(json['sender'] as Map<String, dynamic>);
    }

    // Parse attachments
    List<String> attachments = [];
    final rawAttachments = json['attachments'];
    if (rawAttachments is List) {
      attachments = rawAttachments.map((e) => e.toString()).toList();
    }

    return TransportMessageModel(
      messageId: json['message_id'] as int? ?? json['id'] as int? ?? 0,
      fromUser: fromUser,
      body: json['body'] as String? ?? json['content'] as String? ?? '',
      attachments: attachments,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      if (fromUser != null) 'from_user': fromUser!.toJson(),
      'body': body,
      'attachments': attachments,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get sender name
  String get senderName {
    if (fromUser == null) return 'Unknown';
    return fromUser!.fullNameDisplay;
  }

  /// Get sender ID
  int? get senderId => fromUser?.id;

  /// Get attachment URLs
  List<String> get attachmentUrls {
    return attachments.map((key) => CommonHelper.getImageUrl(key)).toList();
  }

  /// Check if has attachments
  bool get hasAttachments => attachments.isNotEmpty;

  /// Get formatted time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Get formatted timestamp for display
  String get timestamp {
    final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${createdAt.minute.toString().padLeft(2, '0')} $period';
  }

  TransportMessageModel copyWith({
    int? messageId,
    UserModel? fromUser,
    String? body,
    List<String>? attachments,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return TransportMessageModel(
      messageId: messageId ?? this.messageId,
      fromUser: fromUser ?? this.fromUser,
      body: body ?? this.body,
      attachments: attachments ?? this.attachments,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TransportMessageModel(messageId: $messageId, body: $body, isRead: $isRead)';
  }
}
