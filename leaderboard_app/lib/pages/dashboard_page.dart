import 'package:flutter/material.dart';
// import 'package:leaderboard_app/dashboard-components/compact_calendar.dart'; // removed widget
import 'package:leaderboard_app/dashboard-components/leaderboard_table.dart';
import 'package:leaderboard_app/dashboard-components/problem_table.dart';
import 'package:leaderboard_app/dashboard-components/daily_activity.dart';
// import 'package:leaderboard_app/dashboard-components/week_view.dart'; // removed widget
// import 'package:leaderboard_app/dashboard-components/weekly_stats.dart'; // removed widget
import 'package:leaderboard_app/provider/user_provider.dart';
// models via provider components
// import 'package:leaderboard_app/models/dashboard_models.dart';
import 'package:leaderboard_app/services/user/user_service.dart';
import 'package:leaderboard_app/provider/dashboard_provider.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _error; // page-level error

  @override
  void initState() {
    super.initState();
    // Start loading all dashboard data via provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dp = context.read<DashboardProvider>();
      dp.loadAll();
    });
    // Also load user profile once if not available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final up = context.read<UserProvider>();
      if (up.user == null) {
        final us = context.read<UserService>();
        up.fetchProfile(us);
      }
    });
  }

  // legacy loader removed; using DashboardProvider

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
                          ],
                        ),
                      ),
                    ),

                    // Scrollable Content
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          // Refresh all dashboard data (daily question, submissions, leaderboard)
                          await context.read<DashboardProvider>().loadAll();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Consumer<DashboardProvider>(
                              builder: (_, dp, __) => dp.loadingDaily
                                  ? _loadingCard(height: 90)
                                  : LeetCodeDailyCard(daily: dp.daily),
                            ),
                            const SizedBox(height: 10),
                            Consumer<DashboardProvider>(
                              builder: (_, dp, __) => dp.loadingLeaders
                                  ? _loadingCard(height: 180)
                                  : LeaderboardTable(users: dp.leaderboard),
                            ),
                            const SizedBox(height: 10),
                            Consumer<DashboardProvider>(
                              builder: (_, dp, __) {
                                if (dp.loadingSubs) return _loadingCard(height: 180);
                                if (!dp.isVerified) {
                                  return _verifyCard();
                                }
                                if (dp.errorSubs != null) {
                                  return _errorCard(dp.errorSubs!);
                                }
                                return ProblemTable(submissions: dp.submissions);
                              },
                            ),
                            const SizedBox(height: 10),
                            // Removed WeeklyStats and CompactCalendar per request
                            if (_error != null) ...[
                              const SizedBox(height: 10),
                              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                            ],
                            ],
                          ),
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

  Widget _loadingCard({double height = 120}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _verifyCard() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Connect your LeetCode account to see recent submissions and streaks',
              style: TextStyle(color: Colors.white70)),
          SizedBox(height: 8),
          Text('Go to Settings > Verify LeetCode', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _errorCard(String message) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Unable to load submissions',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Text(message, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}