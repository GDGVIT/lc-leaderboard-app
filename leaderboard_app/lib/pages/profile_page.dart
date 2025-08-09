import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final List<Map<String, String>> members = const [
    {"name": "Alice", "avatar": "A"},
    {"name": "Bob", "avatar": "B"},
    {"name": "Charlie", "avatar": "C"},
    {"name": "Diana", "avatar": "D"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

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

            // Avatar & Name
            const CircleAvatar(radius: 50, backgroundColor: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              "Penny Valeria",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),

            const SizedBox(height: 16),

            // Members Card
            _membersCard(),

            const SizedBox(height: 16),

            // Leaderboard Card with DataTable
            _leaderboardCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _membersCard() {
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
                      member["avatar"] ?? "?",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _leaderboardCard() {
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
            child: const LeaderboardTable(),
          ),
        ],
      ),
    );
  }
}

class LeaderboardTable extends StatelessWidget {
  const LeaderboardTable({super.key});

  @override
  Widget build(BuildContext context) {
    return DataTable(
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
      rows: List.generate(
        5,
        (index) => DataRow(
          cells: [
            DataCell(
              Text(
                "${index + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            DataCell(
              Text(
                "Player ${index + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const DataCell(
              Text(
                "12",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const DataCell(
              Text(
                "1324",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const DataCell(
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}