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

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[850],
        ),
        // Use SingleChildScrollView horizontally if titles overflow available width
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxTitleWidth = (constraints.maxWidth - 12*4) * 0.45; // heuristic for title column
            return DataTable(
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
                    DataCell(
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxTitleWidth.clamp(60, 260)),
                        child: Text(
                          submissions[index].title,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        "${submissions[index].acRate.toStringAsFixed(0)}%",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Builder(builder: (context) {
                        final diff = submissions[index].difficulty.toLowerCase();
                        final Color bg = diff == 'easy'
                            ? const Color(0xFF6BC864)
                            : diff == 'medium'
                                ? const Color(0xFFFFC44E)
                                : const Color(0xFFFF2727);
            final raw = submissions[index].difficulty.trim();
            final label = raw.isEmpty
              ? raw
              : raw[0].toUpperCase() + raw.substring(1).toLowerCase();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: bg,
                            // Squircle / boxy-pill: moderate radius
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
