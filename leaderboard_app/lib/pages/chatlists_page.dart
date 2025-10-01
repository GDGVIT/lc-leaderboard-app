import 'dart:async';
import 'package:flutter/material.dart';
import 'package:leaderboard_app/provider/chatlists_provider.dart';
import 'package:leaderboard_app/services/groups/group_service.dart';
import 'package:provider/provider.dart';
import 'groupinfo_page.dart';
import 'chat_page.dart';
import 'package:leaderboard_app/provider/user_provider.dart';

class ChatlistsPage extends StatefulWidget {
  const ChatlistsPage({super.key});

  @override
  State<ChatlistsPage> createState() => _ChatlistsPageState();
}

class _ChatlistsPageState extends State<ChatlistsPage> {
  bool _loadedOnce = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loadedOnce) return;
      _loadedOnce = true;
      final chatProvider = context.read<ChatListProvider>();
      if (!chatProvider.isLoading && chatProvider.chatGroups.isEmpty && chatProvider.error == null) {
        final svc = context.read<GroupService>();
        chatProvider.loadPublicGroups(svc);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value.trim());
    // Debounce network search to avoid spamming backend
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final svc = context.read<GroupService>();
      context.read<ChatListProvider>().loadPublicGroups(svc, search: _searchQuery.isEmpty ? null : _searchQuery);
    });
  }

  Future<void> _refresh() async {
    final svc = context.read<GroupService>();
    await context.read<ChatListProvider>().loadPublicGroups(svc, search: _searchQuery.isEmpty ? null : _searchQuery);
  }

  void _showCreateGroupSheet() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final maxMembersController = TextEditingController();
    bool isPrivate = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context).colorScheme;
            final provider = context.watch<ChatListProvider>();
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Create Group',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: theme.primary,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: theme.primary),
                    decoration: InputDecoration(
                      labelText: 'Name *',
                      labelStyle: TextStyle(color: theme.primary.withOpacity(0.7)),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    style: TextStyle(color: theme.primary),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: theme.primary.withOpacity(0.7)),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: maxMembersController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: theme.primary),
                          decoration: InputDecoration(
                            labelText: 'Max Members (optional)',
                            labelStyle: TextStyle(color: theme.primary.withOpacity(0.7)),
                            filled: true,
                            fillColor: Colors.grey.shade900,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Private', style: TextStyle(color: theme.primary.withOpacity(0.7))),
                          Switch(
                            value: isPrivate,
                            onChanged: (v) => setSheetState(() => isPrivate = v),
                            activeColor: theme.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (provider.createError != null) ...[
                    const SizedBox(height: 4),
                    Text(provider.createError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: provider.isCreating
                          ? null
                          : () async {
                              final name = nameController.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
                                return;
                              }
                              final maxMembers = int.tryParse(maxMembersController.text.trim());
                              final svc = context.read<GroupService>();
                              final created = await provider.createNewGroup(
                                svc,
                                name: name,
                                description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                                isPrivate: isPrivate,
                                maxMembers: maxMembers,
                              );
                              if (created != null && mounted) {
                                Navigator.pop(context); // close sheet
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Group created')),
                                );
                              }
                            },
                      icon: provider.isCreating
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onSecondary),
                            )
                          : const Icon(Icons.check),
                      label: Text(provider.isCreating ? 'Creating...' : 'Create'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final chatProvider = Provider.of<ChatListProvider>(context);
  final groups = chatProvider.chatGroups;

    return Scaffold(
      backgroundColor: theme.surface,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: Text(
                  'Group Chats',
                  style: TextStyle(
                    color: theme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Search + Add
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: theme.primary),
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(
                            color: theme.primary.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          // Reduced vertical padding to make the bar slightly shorter
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          // Removed search icon per request
                          // prefixIcon: Icon(Icons.search, color: theme.primary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  tooltip: 'Clear',
                                  icon: Icon(Icons.close, color: theme.primary.withOpacity(0.7)),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _onSearchChanged(_searchController.text),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: _showCreateGroupSheet,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Group List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: Builder(
                    builder: (context) {
                      if (chatProvider.isLoading && groups.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (chatProvider.error != null) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Text(
                                chatProvider.error!,
                                style: TextStyle(color: theme.primary),
                              ),
                            ),
                          ],
                        );
                      }
                      if (groups.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Text(
                                'No groups found',
                                style: TextStyle(color: theme.primary),
                              ),
                            ),
                          ],
                        );
                      }
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          final groupId = group['groupId']?.toString() ?? '';
                          final groupName = group['name']?.toString() ?? 'Unnamed Group';
                          return Column(
                            children: [
                              InkWell(
                                splashColor: const Color(0xFF705B37).withOpacity(0.35),
                                highlightColor: const Color(0xFF705B37).withOpacity(0.25),
                                onTap: () async {
                                  chatProvider.markGroupAsRead(groupId);
                                  // Determine if user already member; best effort by fetching group
                                  final groupSvc = context.read<GroupService>();
                                  final userId = context.read<UserProvider?>()?.user?.id;
                                  bool isMember = false;
                                  try {
                                    final g = await groupSvc.getGroupById(groupId);
                                    if (userId != null) {
                                      isMember = g.members.any((m) => m.userId == userId);
                                    }
                                  } catch (_) {
                                    // fallback: show info page
                                  }
                                  if (!mounted) return;
                                  if (isMember) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(groupId: groupId, groupName: groupName),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GroupInfoPage(groupId: groupId, initialName: groupName),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.grey,
                                        child: Icon(Icons.group, color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              groupName,
                                              style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              group['lastMessage'] ?? '',
                                              style: TextStyle(color: theme.primary.withOpacity(0.7), fontSize: 13, overflow: TextOverflow.ellipsis),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            group['time']?.toString() ?? '',
                                            style: TextStyle(color: theme.primary.withOpacity(0.6), fontSize: 12),
                                          ),
                                          const SizedBox(height: 8),
                                          if (group['unread'] == true)
                                            CircleAvatar(radius: 6, backgroundColor: theme.secondary),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(height: 1, thickness: 0.6, color: Colors.grey.shade800),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}