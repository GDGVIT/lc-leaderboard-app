import 'package:flutter/material.dart';
import 'package:leaderboard_app/pages/groupinfo_page.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provider.dart';
import 'message_list.dart';
import 'user_input.dart';

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
  int _lastMessageCount = 0; // retained for possible future usage

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), scrollDown);
      }
    });
    Future.delayed(const Duration(milliseconds: 500), scrollDown);
    // Hook into provider after first frame to attach incoming message callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final chat = context.read<ChatProvider>();
      chat.onIncomingMessage = (gid) {
        if (gid == widget.groupId) {
          WidgetsBinding.instance.addPostFrameCallback((_) => scrollDown());
        }
      };
    });
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
  void dispose() {
    try {
      final chat = context.read<ChatProvider>();
      if (chat.onIncomingMessage != null) chat.onIncomingMessage = null;
    } catch (_) {}
    _messageController.dispose();
    _scrollController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final chat = Provider.of<ChatProvider>(context); // watch

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
                MaterialPageRoute(
                  builder: (_) => GroupInfoPage(groupId: widget.groupId, initialName: widget.groupName),
                ),
              ).then((result) {
                if (result is Map && result['leftGroup'] == true) {
                  if (mounted) Navigator.of(context).pop();
                }
              });
            },
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.group, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        widget.groupName,
                        style: TextStyle(
                          color: theme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (chat.isConnecting)
                        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      if (!chat.isConnecting && !chat.isConnected)
                        const Icon(Icons.cloud_off, color: Colors.red, size: 16),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: MessageList(
                groupId: widget.groupId,
                scrollController: _scrollController,
                scrollDownCallback: scrollDown,
              ),
            ),
            UserInput(
              groupId: widget.groupId,
              messageController: _messageController,
              focusNode: myFocusNode,
              scrollDownCallback: scrollDown,
            ),
          ],
        ),
      ),
    );
  }
}
