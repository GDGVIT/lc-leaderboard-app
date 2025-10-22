import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leeterboard/provider/group_membership_provider.dart';
import 'package:leeterboard/pages/chat_page.dart';
import 'package:leeterboard/pages/groupinfo_page.dart';

/// Decides whether to show chat directly or group info depending on membership.
class ChatGate extends StatefulWidget {
  final String groupId;
  final String? groupName;
  const ChatGate({super.key, required this.groupId, this.groupName});

  @override
  State<ChatGate> createState() => _ChatGateState();
}

class _ChatGateState extends State<ChatGate> {
  @override
  void initState() {
    super.initState();
    // Kick off membership check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GroupMembershipProvider>().check(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final membership = context.watch<GroupMembershipProvider>();
    switch (membership.status) {
      case GroupMembershipStatus.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case GroupMembershipStatus.error:
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(membership.error ?? 'Error'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => membership.check(widget.groupId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      case GroupMembershipStatus.member:
        return ChatPage(
          groupId: widget.groupId,
          groupName: widget.groupName ?? membership.group?.name ?? 'Group',
        );
      case GroupMembershipStatus.notMember:
        return GroupInfoPage(
          groupId: widget.groupId,
          initialName: widget.groupName ?? membership.group?.name,
        );
    }
  }
}
