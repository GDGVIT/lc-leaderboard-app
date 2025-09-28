import 'package:flutter/material.dart';
import 'package:leaderboard_app/models/dashboard_models.dart';

class LeaderboardTable extends StatelessWidget {
  final List<TopUser> users;
  const LeaderboardTable({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity, // matches parent width
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
  child: DataTable(
        columnSpacing: 10,
        dataRowMinHeight: 32,
        dataRowMaxHeight: 36,
        headingRowHeight: 32,
        headingRowColor: WidgetStateProperty.all(
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
        ],
        rows: List.generate(
          users.length,
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
                  users[index].username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              DataCell(Text(
                "${users[index].streak}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              )),
              DataCell(Text(
                "${users[index].totalSolved}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              )),
            ],
          ),
        ),
      ),
    );
  }
}