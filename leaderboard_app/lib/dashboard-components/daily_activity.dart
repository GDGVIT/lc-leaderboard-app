import 'package:flutter/material.dart';
import 'package:leeterboard/models/dashboard_models.dart';
import 'package:url_launcher/url_launcher.dart';

class LeetCodeDailyCard extends StatelessWidget {
  final DailyQuestion? daily;
  const LeetCodeDailyCard({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    final dq = daily;
    return Container(
      padding: const EdgeInsets.all(14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: dq == null
          ? const Text(
              'Daily question unavailable',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 4,
                        ), // nudge text downward
                        child: Text(
                          dq.questionTitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          softWrap: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (dq.difficulty.trim().isNotEmpty)
                      Align(
                        alignment: Alignment.center,
                        child: _DifficultyPill(dq.difficulty),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                    ),
                    onPressed: dq.questionLink.isEmpty
                        ? null
                        : () async {
                            final url = Uri.parse(dq.questionLink);
                            if (!await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            )) {
                              // ignore: avoid_print
                              print('Could not launch $url');
                            }
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Go to Question',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.north_east, size: 18, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DifficultyPill extends StatelessWidget {
  final String raw;
  const _DifficultyPill(this.raw);

  @override
  Widget build(BuildContext context) {
    final diff = raw.toLowerCase();
    final Color bg = diff == 'easy'
        ? const Color(0xFF6BC864)
        : diff == 'medium'
        ? const Color(0xFFFFC44E)
        : const Color(0xFFFF2727);
    final label = raw.isEmpty
        ? raw
        : raw[0].toUpperCase() + raw.substring(1).toLowerCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
