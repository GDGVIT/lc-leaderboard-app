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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    Provider.of<ChatProvider>(context);

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
              );
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
                    Text(
                      widget.groupName,
                      style: TextStyle(
                        color: theme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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