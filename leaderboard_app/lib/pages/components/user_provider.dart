import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String name = "First Name Last Name";
  String email = "username@email.com";
  int streak = 4;

  void updateName(String newName) {
    name = newName;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    email = newEmail;
    notifyListeners();
  }

  void incrementStreak() {
    streak++;
    notifyListeners();
  }
}
