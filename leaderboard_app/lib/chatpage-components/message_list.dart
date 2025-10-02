import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import '../provider/chat_provider.dart';

/// MessageList features:
/// 1. Bubble tails only on the last message in a consecutive block from the same sender.
/// 2. Only other users' names are shown (current user's name omitted) above the first bubble in their consecutive block.
/// 3. Swipe left on any message to reveal timestamps for all messages; swipe right to hide.
class MessageList extends StatefulWidget {
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
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  /// Global toggle: when true show timestamp for all messages.
  bool _showAllTimes = false;

  void _setShowAllTimes(bool value) {
    if (_showAllTimes == value) return;
    setState(() => _showAllTimes = value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final messages = provider.getMessages(widget.groupId);

    if (messages.isEmpty) {
      return Center(
        child: Text(
          "No messages yet",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMe = msg["isMe"] == true;
        final isSystem = msg["senderID"] == "system";
        final isImage = msg["type"] == "image";

        if (isSystem) return _SystemMessage(msg: msg);
        if (isImage) return _ImageMessage(msg: msg, isMe: isMe);

        // Determine tail: only last in consecutive block by same sender.
        final currentSender = msg["senderID"];
        bool hasTail = true;
        if (index < messages.length - 1) {
          final next = messages[index + 1];
          if (next["senderID"] == currentSender) {
            hasTail = false;
          }
        }

        final prevSender = index > 0 ? messages[index - 1]["senderID"] : null;
        final showName = prevSender != msg["senderID"]; // only first in block

        return _TextMessage(
          msg: msg,
          isMe: isMe,
          tail: hasTail,
          showTime: _showAllTimes,
          showName: showName,
          onSwipeLeft: () => _setShowAllTimes(true),
          onSwipeRight: () => _setShowAllTimes(false),
        );
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

class _TextMessage extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final bool tail;
  final bool showTime; // global toggle
  final bool showName;
  final VoidCallback onSwipeLeft; // show all times
  final VoidCallback onSwipeRight; // hide all times

  const _TextMessage({
    required this.msg,
    required this.isMe,
    required this.tail,
    required this.showTime,
    required this.showName,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  State<_TextMessage> createState() => _TextMessageState();
}

class _TextMessageState extends State<_TextMessage> {
  double _dragX = 0; // negative when swiping left

  static const double _revealThreshold = -30; // pixels
  static const double _hideThreshold = 30; // for right swipe (unused mostly)
  static const double _minDrag = -90; // allow slight off-screen travel
  static const double _maxDrag = 40;

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _dragX += d.delta.dx;
      if (_dragX < _minDrag) _dragX = _minDrag;
      if (_dragX > _maxDrag) _dragX = _maxDrag;
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    if (_dragX <= _revealThreshold || velocity < -600) {
      widget.onSwipeLeft();
    } else if (_dragX >= _hideThreshold || velocity > 600) {
      widget.onSwipeRight();
    }
    // snap back
    setState(() => _dragX = 0);
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.isMe;
    final bubbleColor = isMe ? const Color(0xFFE3C17D) : Colors.grey.shade900;
    final textColor = isMe ? Colors.black : Colors.white;
    final nameColor = isMe ? Colors.black : (widget.msg["senderColor"] ?? Colors.white);

    // Base offset when timestamps visible (shift left a bit to emphasize reveal)
    final baseShift = widget.showTime ? -12.0 : 0.0;
    final effectiveShift = baseShift + _dragX; // _dragX usually 0 except during gesture

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (widget.showName && !isMe)
                Transform.translate(
                  offset: Offset(effectiveShift, 0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 20),
                        Text(
                          widget.msg["senderName"] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: nameColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Bubble slides left/right; timestamp stays put creating a reveal effect.
                  Transform.translate(
                    offset: Offset(effectiveShift, 0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: BubbleSpecialThree(
                        text: widget.msg["message"] ?? '',
                        color: bubbleColor,
                        isSender: isMe,
                        tail: widget.tail,
                        textStyle: TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if (widget.showTime) ...[
                    const SizedBox(width: 6),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.msg["timestamp"] ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
