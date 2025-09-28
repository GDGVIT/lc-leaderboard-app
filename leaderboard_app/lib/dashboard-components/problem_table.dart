import 'package:flutter/material.dart';
import 'package:leaderboard_app/models/dashboard_models.dart';

class ProblemTable extends StatelessWidget {
  final List<SubmissionItem> submissions;
  const ProblemTable({super.key, required this.submissions});

  @override
  Widget build(BuildContext context) {
    if (submissions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No recent accepted submissions',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity, // match parent width
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DataTable(
        columnSpacing: 12,
        dataRowMinHeight: 32,
        dataRowMaxHeight: 36,
        headingRowHeight: 32,
        headingRowColor: WidgetStateProperty.all(
          Colors.grey[900],
        ),
        columns: const [
          DataColumn(
            label: Text(
              "No.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              "Title",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              "Accuracy",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              "Level",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
        rows: List.generate(
          submissions.length,
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
              DataCell(Text(
                submissions[index].title,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              )),
              DataCell(Text(
                "${submissions[index].acRate.toStringAsFixed(0)}%",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              )),
              DataCell(Text(
                submissions[index].difficulty,
                style: TextStyle(
                  color: submissions[index].difficulty.toLowerCase() == 'easy'
                      ? Colors.green
                      : submissions[index].difficulty.toLowerCase() == 'medium'
                          ? Colors.orange
                          : Colors.red,
                  fontSize: 12,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
