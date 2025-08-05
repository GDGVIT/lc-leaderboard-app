import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'profile_page.dart'; // <- Assuming this file exists

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode myFocusNode = FocusNode();
  String? replyTo;

  bool showAttachmentOptions = false;

  final String currentUserId = "uid_me";

  List<Map<String, dynamic>> dummyMessages = [
    {"senderID": "uid_me", "type": "image", "timestamp": "12:34 pm"},
    {
      "senderID": "uid_me",
      "message": "text text text text text text text text text text...",
      "timestamp": "12:34 pm",
    },
    {
      "senderID": "system",
      "message": "Duelled",
      "timestamp": "12:34 pm",
      "icon": Pixel.bullseye,
    },
    {
      "senderID": "uid_1",
      "message": "text text text text text text text text text text...",
      "timestamp": "12:35 pm",
    },
    {
      "senderID": "uid_me",
      "message": "text text text text text text text text text text...",
      "timestamp": "12:35 pm",
    },
    {
      "senderID": "uid_1",
      "message": "text text text text text text text text text text...",
      "timestamp": "12:35 pm",
    },
  ];

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), scrollDown);
      }
    });
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

  void sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      dummyMessages.add({
        "senderID": currentUserId,
        "message": _messageController.text.trim(),
        "timestamp": "now",
        if (replyTo != null) "replyTo": replyTo,
      });
      _messageController.clear();
      replyTo = null;
    });
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
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
                    "Penny Valeria",
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.inversePrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text("Duel Now!"),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (showAttachmentOptions) _buildAttachmentDropdown(),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: dummyMessages.length,
      itemBuilder: (context, index) {
        final msg = dummyMessages[index];
        final isMe = msg["senderID"] == currentUserId;
        final isSystem = msg["senderID"] == "system";
        final isImage = msg["type"] == "image";

        if (isSystem) {
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
                  Icon(
                    msg["icon"] ?? Icons.info,
                    size: 16,
                    color: Colors.white,
                  ),
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

        if (isImage) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
        }

        return GestureDetector(
          onDoubleTap: () {
            setState(() {
              replyTo = msg["message"]; // set reply target on double-tap
            });
          },

          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(maxWidth: 280),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  if (msg["replyTo"] != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                  Text(
                    msg["message"] ?? "",
                    style: TextStyle(
                      color: isMe ? Colors.black : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: isMe
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
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
          ),
        );
      },
    );
  }

  Widget _buildUserInput() {
    final theme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.black,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                showAttachmentOptions ? Icons.close : Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  showAttachmentOptions = !showAttachmentOptions;
                });
              },
            ),
            if (replyTo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Replying to: $replyTo",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        setState(() {
                          replyTo = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: myFocusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: theme.primary,
              child: IconButton(
                onPressed: sendMessage,
                icon: const Icon(Pixel.arrowup, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentDropdown() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 20, bottom: 8),
        padding: const EdgeInsets.all(12),
        width: 180, // ✅ restrict width
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            AttachmentOption(icon: Icons.mic, label: "Audio"),
            SizedBox(height: 12),
            AttachmentOption(icon: Icons.photo, label: "Photos & Videos"),
            SizedBox(height: 12),
            AttachmentOption(icon: Icons.attach_file, label: "File"),
          ],
        ),
      ),
    );
  }
}

class AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;

  const AttachmentOption({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 22),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}