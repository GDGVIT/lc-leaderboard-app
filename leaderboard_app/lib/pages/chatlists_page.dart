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
                    child: CircleAvatar(
                      backgroundColor: theme.secondary,
                      child: Icon(Icons.add, color: Colors.black),
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