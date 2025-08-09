import 'package:flutter/material.dart';
import 'package:leaderboard_app/provider/chat_provider.dart';
import 'package:provider/provider.dart';

class GroupInfoPage extends StatelessWidget {
  final String groupName;

  const GroupInfoPage({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    // Get ChatProvider instance
    final chatProvider = Provider.of<ChatProvider>(context);

    // Use the dummy users from ChatProvider as members
    final members = chatProvider.dummyUsers;

    // For leaderboard, create sample data based on dummy users
    final leaderboard = List.generate(
      members.length,
      (index) => {
        "place": index + 1,
        "player": members[index]["name"],
        "streak": (12 + index).toString(),
        "solved": (1324 + index * 10).toString(),
        "badge": Icons.star,
      },
    );

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Group icon
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.group,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Use dynamic groupName here
            Text(
              groupName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),

            const SizedBox(height: 16),

            // Members Card
            _membersCard(members),

            const SizedBox(height: 16),

            // Leaderboard Card
            _leaderboardCard(leaderboard),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _membersCard(List<Map<String, dynamic>> members) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Members",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          ...members.map((member) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade700,
                    child: Text(
                      (member["name"] != null && member["name"].isNotEmpty)
                          ? member["name"][0]
                          : "?",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    member["name"] ?? "Unknown",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _leaderboardCard(List<Map<String, dynamic>> leaderboard) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to left
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Leaderboard",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, // Stretch table to max width
            child: DataTable(
              columnSpacing: 10,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 36,
              headingRowHeight: 32,
              headingRowColor: MaterialStateProperty.all(
                Colors.grey[900],
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    "Place",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Player",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Streak",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Solved",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Badge",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              rows: leaderboard.map((row) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        "${row["place"]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        row["player"] ?? "Player",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        row["streak"] ?? "0",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        row["solved"] ?? "0",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Icon(
                        row["badge"] ?? Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}