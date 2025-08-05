import 'package:flutter/material.dart';
import 'package:leaderboard_app/provider/chat_provider.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';
import 'profile_page.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(receiverID: receiverID),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

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
                  Text("Penny Valeria", style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Online", style: TextStyle(color: theme.primary.withOpacity(0.6), fontSize: 12)),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text("Duel Now!"),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(provider)),
          if (provider.showAttachmentOptions) _buildAttachmentDropdown(),
          _buildUserInput(provider),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final msg = provider.messages[index];
        final isMe = msg["senderID"] == provider.currentUserID;
        final isSystem = msg["senderID"] == "system";
        final isImage = msg["type"] == "image";

        if (isSystem) {
          return _systemMessage(msg);
        }

        if (isImage) {
          return _imageMessage(msg);
        }

        return GestureDetector(
          onDoubleTap: () {
            provider.setReplyTo(msg["message"]);
          },
          child: _textMessage(msg, isMe, provider),
        );
      },
    );
  }

  Widget _systemMessage(Map<String, dynamic> msg) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(msg["icon"] ?? Icons.info, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(msg["message"] ?? "", style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(width: 6),
              Text(msg["timestamp"] ?? "", style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ),
      );

  Widget _imageMessage(Map<String, dynamic> msg) => Align(
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
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Icon(Pixel.image, size: 64, color: Colors.grey)),
              ),
              const SizedBox(height: 4),
              Text(msg["timestamp"] ?? "", style: const TextStyle(fontSize: 10, color: Colors.black54)),
            ],
          ),
        ),
      );

  Widget _textMessage(Map<String, dynamic> msg, bool isMe, ChatProvider provider) => Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMe ? Theme.of(context).colorScheme.inversePrimary : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints(maxWidth: 280),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (msg["replyTo"] != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    msg["replyTo"],
                    style: TextStyle(fontSize: 11, color: isMe ? Colors.black87 : Colors.white60),
                  ),
                ),
              Text(
                msg["message"] ?? "",
                style: TextStyle(color: isMe ? Colors.black : Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                child: Text(
                  msg["timestamp"] ?? "",
                  style: TextStyle(color: isMe ? Colors.black54 : Colors.white54, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildUserInput(ChatProvider provider) {
    final theme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.black,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(provider.showAttachmentOptions ? Icons.close : Icons.add, color: Colors.white),
              onPressed: provider.toggleAttachmentOptions,
            ),
            if (provider.replyTo != null)
              Expanded(
                child: Row(
                  children: [
                    Text("Replying to: ${provider.replyTo}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.white54),
                      onPressed: provider.clearReplyTo,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _messageController,
                  focusNode: myFocusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(hintText: "Type a message...", hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: theme.primary,
              child: IconButton(
                onPressed: () {
                  provider.sendMessage(_messageController.text.trim());
                  _messageController.clear();
                  scrollDown();
                },
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
        width: 180,
        decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(10)),
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