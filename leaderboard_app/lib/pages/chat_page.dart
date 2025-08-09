import 'package:flutter/material.dart';
import 'package:leaderboard_app/provider/chat_provider.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';
import 'profile_page.dart';

class ChatPage extends StatelessWidget {
  final String groupId;
  final String groupName;

  const ChatPage({super.key, required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = ChatProvider();
        // Ensure group data is initialized by calling methods
        // that internally call _initGroupIfNeeded(...)
        provider.getReplyTo(groupId);
        provider.getAttachmentOptionsVisibility(groupId);
        return provider;
      },
      child: ChatView(groupId: groupId, groupName: groupName),
    );
  }
}

class ChatView extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ChatView({super.key, required this.groupId, required this.groupName});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), scrollDown);
      }
    });
    // initial scroll after build
    Future.delayed(const Duration(milliseconds: 500), scrollDown);
  }

  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final provider = Provider.of<ChatProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(),
          titleSpacing: 0,
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            child: Row(
              children: [
                const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.groupName,
                      style: TextStyle(
                        color: theme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Online",
                      style: TextStyle(
                        color: theme.primary.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(child: _buildMessageList(provider)),
            _buildUserInput(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(ChatProvider provider) {
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
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMe = msg["senderID"] == provider.currentUserID;
        final isSystem = msg["senderID"] == "system";
        final isImage = msg["type"] == "image";

        if (isSystem) {
          return _systemMessage(msg);
        }

        if (isImage) {
          return _imageMessage(msg, isMe);
        }

        return GestureDetector(
          onDoubleTap: () {
            provider.setReplyTo(widget.groupId, msg["message"]);
          },
          child: _textMessage(msg, isMe),
        );
      },
    );
  }

  Widget _systemMessage(Map<String, dynamic> msg) => Center(
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

  Widget _imageMessage(Map<String, dynamic> msg, bool isMe) => Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
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
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    ),
  );

  Widget _textMessage(Map<String, dynamic> msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.inversePrimary
              : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Always align left inside bubble
          children: [
            // Name (always left-aligned)
            Text(
              msg["senderName"] ?? "",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: msg["senderColor"] ?? Colors.white,
              ),
            ),
            const SizedBox(height: 4),

            // Reply preview
            if (msg["replyTo"] != null)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  msg["replyTo"],
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.black87 : Colors.white60,
                  ),
                ),
              ),

            // Message text
            Text(
              msg["message"] ?? "",
              style: TextStyle(
                color: isMe ? Colors.black : Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),

            // Timestamp
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

  Widget _buildUserInput(ChatProvider provider) {
    final theme = Theme.of(context).colorScheme;
    final replyTo = provider.getReplyTo(widget.groupId);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reply section
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
                        onTap: () => provider.clearReplyTo(widget.groupId),
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

            // Input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 40,
                        maxHeight: 150,
                      ),
                      child: Scrollbar(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _messageController,
                            focusNode: myFocusNode,
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

                // Send button
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: CircleAvatar(
                    backgroundColor: theme.primary,
                    radius: 22,
                    child: IconButton(
                      onPressed: () {
                        provider.sendMessage(
                          widget.groupId,
                          _messageController.text.trim(),
                        );
                        _messageController.clear();
                        scrollDown();
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