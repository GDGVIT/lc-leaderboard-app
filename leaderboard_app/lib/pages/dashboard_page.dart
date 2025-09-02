import 'package:flutter/material.dart';
import 'package:leaderboard_app/dashboard-components/compact_calendar.dart';
import 'package:leaderboard_app/dashboard-components/leaderboard_table.dart';
import 'package:leaderboard_app/dashboard-components/problem_table.dart';
import 'package:leaderboard_app/dashboard-components/daily_activity.dart';
import 'package:leaderboard_app/dashboard-components/week_view.dart';
import 'package:leaderboard_app/dashboard-components/weekly_stats.dart';
import 'package:leaderboard_app/models/dashboard_models.dart';
import 'package:leaderboard_app/provider/user_provider.dart';
import 'package:leaderboard_app/services/dashboard/dashboard_service.dart';
import 'package:leaderboard_app/services/user/user_service.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  List<SubmissionItem> _submissions = const [];
  List<TopUser> _topUsers = const [];
  DailyQuestion? _daily;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Also load user profile once if not available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final up = context.read<UserProvider>();
      if (up.user == null) {
        final us = context.read<UserService>();
        up.fetchProfile(us);
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = context.read<DashboardService>();
      final results = await Future.wait([
        service.getUserSubmissions(),
        service.getTopUsers(),
        service.getDailyQuestion(),
      ]);
      if (!mounted) return;
      setState(() {
        _submissions = results[0] as List<SubmissionItem>;
        _topUsers = results[1] as List<TopUser>;
        _daily = results[2] as DailyQuestion?;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load dashboard');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

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
                            if (_loading)
                              _loadingCard(height: 90)
                            else
                              LeetCodeDailyCard(daily: _daily),
                            const SizedBox(height: 10),
                            if (_loading)
                              _loadingCard(height: 180)
                            else
                              LeaderboardTable(users: _topUsers),
                            const SizedBox(height: 10),
                            if (_loading)
                              _loadingCard(height: 180)
                            else
                              ProblemTable(submissions: _submissions),
                            const SizedBox(height: 10),
                            const WeeklyStats(),
                            const SizedBox(height: 10),
                            const CompactCalendar(),
                            if (_error != null) ...[
                              const SizedBox(height: 10),
                              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                            ],
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
}