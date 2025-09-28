import 'package:flutter/material.dart';
import 'package:leaderboard_app/provider/chatlists_provider.dart';
import 'package:leaderboard_app/services/groups/group_service.dart';
import 'package:provider/provider.dart';
import 'groupinfo_page.dart';

class ChatlistsPage extends StatefulWidget {
  const ChatlistsPage({super.key});

  @override
  State<ChatlistsPage> createState() => _ChatlistsPageState();
}

class _ChatlistsPageState extends State<ChatlistsPage> {
  final List<String> filters = const ["All", "Unread", "Favourites"];
  String selectedFilter = "All";
  bool _loadedOnce = false;

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

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> chatGroups) {
    switch (selectedFilter) {
      case "Unread":
        return chatGroups.where((group) => group["unread"] == true).toList();
      case "Favourites":
        // Assuming each group has a "favourite" bool property. If not, update your data model or remove this filter.
        return chatGroups.where((group) => group["favourite"] == true).toList();
      case "All":
      default:
        return chatGroups;
    }
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
    final filteredGroups = _applyFilter(chatProvider.chatGroups);

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

              // Search + Add (You can later wire search functionality here)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: TextField(
                        style: TextStyle(color: theme.primary),
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(
                            color: theme.primary.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.search, color: theme.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: _showCreateGroupSheet,
                      child: CircleAvatar(
                        backgroundColor: theme.secondary,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filters
              SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: filters.map((label) {
                      final isSelected = label == selectedFilter;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedFilter = label;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? theme.secondary
                                  : Colors.grey.shade900,
                              foregroundColor:
                                  isSelected ? Colors.black : theme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Group List
              Expanded(
                child: chatProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (chatProvider.error != null)
                        ? Center(child: Text(chatProvider.error!, style: TextStyle(color: theme.primary)))
                        : filteredGroups.isEmpty
                            ? Center(
                                child: Text(
                                  "No groups found",
                                  style: TextStyle(color: theme.primary),
                                ),
                              )
                            : ListView.builder(
                        itemCount: filteredGroups.length,
                        itemBuilder: (context, index) {
                          final group = filteredGroups[index];
                          final groupId = group["groupId"]?.toString() ?? "";
                          final groupName =
                              group["name"]?.toString() ?? "Unnamed Group";

                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  chatProvider.markGroupAsRead(groupId);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GroupInfoPage(groupId: groupId, initialName: groupName),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      // Group icon
                                      const CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          Icons.group,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Group name + last message
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              groupName,
                                              style: TextStyle(
                                                color: theme.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              group["lastMessage"] ?? "",
                                              style: TextStyle(
                                                color:
                                                    theme.primary.withOpacity(0.7),
                                                fontSize: 13,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Time + unread dot
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            group["time"]?.toString() ?? "",
                                            style: TextStyle(
                                              color: theme.primary.withOpacity(0.6),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (group["unread"] == true)
                                            CircleAvatar(
                                              radius: 6,
                                              backgroundColor: theme.secondary,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                thickness: 0.6,
                                color: Colors.grey.shade800,
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}