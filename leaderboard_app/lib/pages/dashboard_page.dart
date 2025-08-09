import 'package:flutter/material.dart';
import 'package:leaderboard_app/dashboard-components/compact_calendar.dart';
import 'package:leaderboard_app/dashboard-components/leaderboard_table.dart';
import 'package:leaderboard_app/dashboard-components/problem_table.dart';
import 'package:leaderboard_app/dashboard-components/daily_activity.dart';
import 'package:leaderboard_app/dashboard-components/week_view.dart';
import 'package:leaderboard_app/dashboard-components/weekly_stats.dart';
import 'package:leaderboard_app/provider/user_provider.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
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
                        color: colors.tertiary.withOpacity(0.15),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: colors.surface,
                              child: Icon(Icons.person, color: colors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      color: colors.primary.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildHeaderButton(
                              Icons.local_fire_department,
                              "${user.streak}",
                              colors.secondary,
                            ),
                            const SizedBox(width: 8),
                            _buildHeaderButton(
                              Icons.person_add,
                              "Invite",
                              colors.secondary,
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
                            const WeekView(),
                            const SizedBox(height: 10),
                            const LeetCodeDailyCard(),
                            const SizedBox(height: 10),
                            const LeaderboardTable(),
                            const SizedBox(height: 10),
                            const ProblemTable(),
                            const SizedBox(height: 10),
                            const WeeklyStats(),
                            const SizedBox(height: 10),
                            const CompactCalendar(),
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