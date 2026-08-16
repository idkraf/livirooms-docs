class Conversation {
  final int id;
  final int? propertyId;
  final String? propertyName;
  final int? otherUserId;
  final String otherUserName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  Conversation({
    required this.id,
    this.propertyId,
    this.propertyName,
    this.otherUserId,
    required this.otherUserName,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final property = json['property'] as Map<String, dynamic>?;
    final other = json['other_user'] as Map<String, dynamic>?;
    final last = json['last_message'];
    return Conversation(
      id: json['id'] as int,
      propertyId: property?['id'] as int?,
      propertyName: property?['name'] as String?,
      otherUserId: other?['id'] as int?,
      otherUserName: other?['name'] as String? ?? 'Pengguna',
      lastMessage: last is Map<String, dynamic> ? last['body'] as String? : null,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse('${json['last_message_at']}')
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String? body;
  final String? attachment;
  final bool isRead;
  final DateTime? createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.body,
    this.attachment,
    this.isRead = false,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    return Message(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int? ?? 0,
      senderId: json['sender_id'] as int? ?? 0,
      senderName: sender?['name'] as String? ?? 'Pengguna',
      body: json['body'] as String?,
      attachment: json['attachment'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse('${json['created_at']}') : null,
    );
  }
}
