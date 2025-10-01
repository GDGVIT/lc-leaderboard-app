import 'chat_message.dart';

/// DTO for messages retrieved via REST (history endpoint)
class ChatMessageDto {
  final String id;
  final String content;
  final String senderId;
  final String groupId;
  final DateTime createdAt;
  final String? senderName;

  ChatMessageDto({
    required this.id,
    required this.content,
    required this.senderId,
    required this.groupId,
    required this.createdAt,
    this.senderName,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    return ChatMessageDto(
      id: (json['id'] ?? json['_id']).toString(),
      content: (json['content'] ?? json['message'] ?? '').toString(),
      senderId: (json['senderId'] ?? (sender is Map ? sender['id'] ?? sender['_id'] : '')).toString(),
      groupId: (json['groupId'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      senderName: sender is Map ? (sender['username'] ?? sender['name'])?.toString() : null,
    );
  }

  ChatMessage toDomain() => ChatMessage(
        id: id,
        groupId: groupId,
        senderId: senderId,
        senderName: senderName ?? 'User',
        message: content,
        timestamp: createdAt,
      );
}