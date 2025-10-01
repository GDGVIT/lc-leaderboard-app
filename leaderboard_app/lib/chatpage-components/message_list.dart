import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provider.dart';

class MessageList extends StatelessWidget {
  final String groupId;
  final ScrollController scrollController;
  final VoidCallback scrollDownCallback;

  const MessageList({
    super.key,
    required this.groupId,
    required this.scrollController,
    required this.scrollDownCallback,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final messages = provider.getMessages(groupId);

    if (messages.isEmpty) {
      return Center(
        child: Text(
          "No messages yet",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
  final isMe = msg["isMe"] == true;
        final isSystem = msg["senderID"] == "system";
        final isImage = msg["type"] == "image";

        if (isSystem) return _SystemMessage(msg: msg);

        if (isImage) return _ImageMessage(msg: msg, isMe: isMe);

        return _TextMessage(msg: msg, isMe: isMe);
      },
    );
  }
}

class _SystemMessage extends StatelessWidget {
  final Map<String, dynamic> msg;
  const _SystemMessage({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(msg["icon"] ?? Icons.info, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              msg["message"] ?? "",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(width: 6),
            Text(
              msg["timestamp"] ?? "",
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageMessage extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  const _ImageMessage({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? const Color(0xFFE3C17D) : Colors.grey.shade900;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Pixel.image, size: 64, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg["timestamp"] ?? "",
              style: TextStyle(fontSize: 10, color: isMe ? Colors.black54 : Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextMessage extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  const _TextMessage({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? const Color(0xFFE3C17D) : Colors.grey.shade900;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (isMe ? 'You' : (msg["senderName"] ?? "")),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.black : (msg["senderColor"] ?? Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg["message"] ?? "",
              style: TextStyle(
                color: isMe ? Colors.black : Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                msg["timestamp"] ?? "",
                style: TextStyle(
                  color: isMe ? Colors.black54 : Colors.white54,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
