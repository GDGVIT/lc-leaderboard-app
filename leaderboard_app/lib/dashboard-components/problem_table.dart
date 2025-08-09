import 'package:flutter/material.dart';

class ProblemTable extends StatelessWidget {
  const ProblemTable({super.key});

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
          4,
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
              const DataCell(
                Text(
                  "Problem",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              const DataCell(
                Text(
                  "56%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              const DataCell(
                Text(
                  "Easy",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
              const DataCell(
                Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
