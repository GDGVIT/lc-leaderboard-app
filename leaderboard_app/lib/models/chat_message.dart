class ChatMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromSocket(Map<String, dynamic> raw) {
    final sender = raw['sender'];
    return ChatMessage(
      id: (raw['id'] ?? raw['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString(),
      groupId: (raw['groupId'] ?? '').toString(),
      senderId: sender is Map ? (sender['id'] ?? sender['_id'] ?? '').toString() : '',
      senderName: sender is Map ? (sender['username'] ?? 'User').toString() : 'User',
      message: (raw['message'] ?? '').toString(),
      timestamp: _parseTs(raw['timestamp']),
    );
  }

  static DateTime _parseTs(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}
