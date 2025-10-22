import 'package:flutter/material.dart';
import 'package:leeterboard/chatpage-components/chat_view.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provider.dart';

class ChatPage extends StatelessWidget {
  final String groupId;
  final String groupName;

  const ChatPage({super.key, required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    final chatProv = context.read<ChatProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => chatProv.joinGroup(context, groupId),
    );
    return ChatView(groupId: groupId, groupName: groupName);
  }
}
