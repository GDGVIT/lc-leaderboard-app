import 'package:flutter/material.dart';

class WeeklyStats extends StatelessWidget {
  const WeeklyStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Center(
            child: Text(
              "This Week",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          _buildBar("Easy", 0.8, Colors.green),
          _buildBar("Medium", 0.8, Colors.amber),
          _buildBar("Hard", 0.8, Colors.red),
        ],
      ),
    );
  }

  static Widget _buildBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            color: color,
            backgroundColor: Colors.white24,
          ),
        ),
      ],
    );
  }
}
