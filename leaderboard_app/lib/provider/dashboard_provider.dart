import 'package:flutter/material.dart';
import 'package:leaderboard_app/models/dashboard_models.dart';
import 'package:leaderboard_app/services/dashboard/dashboard_service.dart';
import 'package:leaderboard_app/provider/user_provider.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService service;
  final UserProvider userProvider;

  DashboardProvider({required this.service, required this.userProvider});

  bool loadingDaily = false;
  bool loadingSubs = false;
  bool loadingLeaders = false;

  String? errorDaily;
  String? errorSubs;
  String? errorLeaders;

  DailyQuestion? daily;
  List<SubmissionItem> submissions = const [];
  List<TopUser> leaderboard = const [];

  bool get isVerified => userProvider.user?.leetcodeVerified == true;

  Future<void> loadAll() async {
    await Future.wait([
      loadDaily(),
      loadSubmissions(),
      loadLeaderboard(),
    ]);
  }

  Future<void> loadDaily() async {
    loadingDaily = true;
    errorDaily = null;
    notifyListeners();
    try {
      daily = await service.getDailyQuestion();
    } catch (_) {
      errorDaily = 'Failed to load today\'s question';
    } finally {
      loadingDaily = false;
      notifyListeners();
    }
  }

  Future<void> loadSubmissions() async {
    loadingSubs = true;
    errorSubs = null;
    notifyListeners();
    try {
      if (!isVerified) {
        submissions = const [];
      } else {
        submissions = await service.getUserSubmissions();
      }
    } catch (_) {
      errorSubs = 'Failed to load recent submissions';
    } finally {
      loadingSubs = false;
      notifyListeners();
    }
  }

  Future<void> loadLeaderboard() async {
    loadingLeaders = true;
    errorLeaders = null;
    notifyListeners();
    try {
      leaderboard = await service.getTopUsers();
    } catch (_) {
      errorLeaders = 'Failed to load leaderboard';
    } finally {
      loadingLeaders = false;
      notifyListeners();
    }
  }
}
