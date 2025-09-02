import 'package:flutter/material.dart';
import 'package:leaderboard_app/models/dashboard_models.dart';
import 'package:url_launcher/url_launcher.dart';

class LeetCodeDailyCard extends StatelessWidget {
  final DailyQuestion? daily;
  const LeetCodeDailyCard({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            daily == null
                ? 'Daily question unavailable'
                : "${daily!.questionTitle} (${daily!.difficulty})\n${daily!.questionLink}",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: daily?.questionLink == null
                  ? null
                  : () async {
                      final url = Uri.parse(daily!.questionLink);
                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                        // ignore: avoid_print
                        print('Could not launch $url');
                      }
                    },
              child: const Text("Go to Question >", style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}