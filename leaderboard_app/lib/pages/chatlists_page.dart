import 'package:flutter/material.dart';
import 'chat_page.dart';

class ChatlistsPage extends StatelessWidget {
  ChatlistsPage({super.key});

  final String currentUserEmail = "me@example.com";

  final List<Map<String, dynamic>> dummyUsers = List.generate(
    10,
    (index) => {
      "name": "Penny Valeria",
      "message": "Text text text text....",
      "time": "12:35 pm",
      "email": "user$index@example.com",
      "uid": "uid_$index",
      "unread": index != 0,
    },
  );

  final List<String> filters = ["All", "Unread", "Favourites", "Groups"];
  final int selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.surface,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chats title
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: Text(
                  'Chats',
                  style: TextStyle(
                    color: theme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Search + Add Button
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

              // Filter Buttons
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: filters.asMap().entries.map((entry) {
                    final i = entry.key;
                    final label = entry.value;
                    final isSelected = i == selectedFilterIndex;

                    return ElevatedButton(
                      onPressed: () {
                        // Add filter logic here if needed
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? theme.secondary
                            : Colors.grey.shade900,
                        foregroundColor: isSelected
                            ? Colors.black
                            : theme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Chat List
              Expanded(
                child: ListView.builder(
                  itemCount: dummyUsers.length,
                  itemBuilder: (context, index) {
                    final user = dummyUsers[index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  receiverEmail: user["email"]!,
                                  receiverID: user["uid"]!,
                                ),
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
                                // Profile picture
                                Stack(
                                  children: [
                                    const CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.grey,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.black,
                                        child: CircleAvatar(
                                          radius: 4,
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),

                                // Name and message
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user["name"],
                                        style: TextStyle(
                                          color: theme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user["message"],
                                        style: TextStyle(
                                          color: theme.primary.withOpacity(0.7),
                                          fontSize: 13,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Time and unread dot
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      user["time"],
                                      style: TextStyle(
                                        color: theme.primary.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (user["unread"])
                                      const CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.amber,
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
