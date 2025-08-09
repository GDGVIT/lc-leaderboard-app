import 'package:flutter/material.dart';
import 'package:leaderboard_app/chatpage-components/chat_view.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provider.dart';

class ChatPage extends StatelessWidget {
  final String groupId;
  final String groupName;

  const ChatPage({super.key, required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = ChatProvider();
        provider.getReplyTo(groupId);
        provider.getAttachmentOptionsVisibility(groupId);
        return provider;
      },
      child: ChatView(groupId: groupId, groupName: groupName),
    );
  }
}