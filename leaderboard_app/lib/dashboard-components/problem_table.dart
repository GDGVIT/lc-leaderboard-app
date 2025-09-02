import 'package:flutter/material.dart';
import 'package:leaderboard_app/models/dashboard_models.dart';

class ProblemTable extends StatelessWidget {
  final List<SubmissionItem> submissions;
  const ProblemTable({super.key, required this.submissions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity, // match parent width
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
              "Acc.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              "Lvl",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              "Prog",
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
              DataCell(Icon(
                Icons.circle,
                color: submissions[index].statusDisplay.toLowerCase() == 'accepted'
                    ? Colors.green
                    : Colors.grey,
                size: 10,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
