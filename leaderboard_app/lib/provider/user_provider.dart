import 'package:flutter/material.dart';
import 'package:leaderboard_app/models/auth_models.dart';
import 'package:leaderboard_app/services/user/user_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _error;

  String get name => _user?.username ?? 'First Last';
  String get email => _user?.email ?? 'username@email.com';
  int get streak => _user?.streak ?? 0;
  User? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;

  void updateUser({required String name, required String email, required int streak}) {
    _user = User(
      id: _user?.id ?? '',
      username: name,
      email: email,
      leetcodeHandle: _user?.leetcodeHandle,
      leetcodeVerified: _user?.leetcodeVerified ?? false,
      streak: streak,
    );
    notifyListeners();
  }

  Future<void> fetchProfile(UserService service) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await service.getProfile();
    } catch (e) {
      _error = 'Failed to load profile';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateStreakRemote(UserService service, int newStreak) async {
    try {
      await service.updateStreak(newStreak);
      if (_user != null) {
        _user = User(
          id: _user!.id,
          username: _user!.username,
          email: _user!.email,
          leetcodeHandle: _user!.leetcodeHandle,
          leetcodeVerified: _user!.leetcodeVerified,
          streak: newStreak,
        );
        notifyListeners();
      }
    } catch (e) {
      // swallow error for now
    }
  }
}
