import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provider.dart';

class UserInput extends StatelessWidget {
  final String groupId;
  final TextEditingController messageController;
  final FocusNode focusNode;
  final VoidCallback scrollDownCallback;

  const UserInput({
    super.key,
    required this.groupId,
    required this.messageController,
    required this.focusNode,
    required this.scrollDownCallback,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final provider = Provider.of<ChatProvider>(context);
    final replyTo = provider.getReplyTo(groupId);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replyTo != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Replying to: $replyTo",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => provider.clearReplyTo(groupId),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 40, maxHeight: 150),
                      child: Scrollbar(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: messageController,
                            focusNode: focusNode,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Type a message...",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: CircleAvatar(
                    backgroundColor: theme.primary,
                    radius: 22,
                    child: IconButton(
                      onPressed: () {
                        provider.sendMessage(groupId, messageController.text.trim());
                        messageController.clear();
                        scrollDownCallback();
                      },
                      icon: const Icon(Pixel.arrowup, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}