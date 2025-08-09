import 'package:flutter/material.dart';
import 'package:leaderboard_app/components/compact_calendar.dart';
import 'package:leaderboard_app/components/leaderboard_table.dart';
import 'package:leaderboard_app/components/problem_table.dart';
import 'package:leaderboard_app/components/daily_activity.dart';
import 'package:leaderboard_app/components/week_view.dart';
import 'package:leaderboard_app/components/weekly_stats.dart';
import 'package:leaderboard_app/provider/user_provider.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth < 400
                ? constraints.maxWidth
                : 400;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    // Header (now reactive using Consumer)
                    Consumer<UserProvider>(
                      builder: (context, user, _) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        color: Colors.grey[900],
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, color: Colors.black),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildHeaderButton(
                              Icons.local_fire_department,
                              "${user.streak}",
                              Colors.amber,
                            ),
                            const SizedBox(width: 8),
                            _buildHeaderButton(
                              Icons.person_add,
                              "Invite",
                              Colors.amber,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WeekView(),
                            const SizedBox(height: 10),
                            LeetCodeDailyCard(),
                            const SizedBox(height: 10),
                            LeaderboardTable(),
                            const SizedBox(height: 10),
                            ProblemTable(),
                            const SizedBox(height: 10),
                            WeeklyStats(),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const CompactCalendar(),
                            ),
                          ],
                        ),
                      ),
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

  static Widget _buildHeaderButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}