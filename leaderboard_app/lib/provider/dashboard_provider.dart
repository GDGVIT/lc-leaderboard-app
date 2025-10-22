import 'package:flutter/material.dart';
import 'package:leeterboard/models/dashboard_models.dart';
import 'package:leeterboard/services/dashboard/dashboard_service.dart';
import 'package:leeterboard/provider/user_provider.dart';
import 'package:leeterboard/services/user/user_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService service;
  final UserProvider userProvider;
  final UserService? userService; // optional for profile refresh

  DashboardProvider({
    required this.service,
    required this.userProvider,
    this.userService,
  }) {
    // Listen for changes to user verification so we can (re)load submissions
    // when the user becomes verified after the initial dashboard load.
    userProvider.addListener(_handleUserChange);
  }

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
    await Future.wait([loadDaily(), loadSubmissions(), loadLeaderboard()]);
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
        // After fetching submissions, refresh user profile to update streak if service available.
        if (userService != null) {
          try {
            await userProvider.fetchProfile(userService!);
          } catch (_) {
            // ignore profile refresh errors
          }
        }
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

  void _handleUserChange() {
    // If user became verified and we have not loaded submissions yet, load them.
    if (isVerified) {
      if (submissions.isEmpty && !loadingSubs) {
        // Fire and forget; internal method handles notify + errors.
        loadSubmissions();
      }
    } else {
      // User no longer verified (or logged out): clear submissions.
      if (submissions.isNotEmpty) {
        submissions = const [];
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    userProvider.removeListener(_handleUserChange);
    super.dispose();
  }
}
