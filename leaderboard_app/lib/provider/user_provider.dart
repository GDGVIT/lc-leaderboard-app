import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _name = 'First Name Last Name';
  String _email = 'username@email.com';
  int _streak = 8;

  String get name => _name;
  String get email => _email;
  int get streak => _streak;

  void updateUser({required String name, required String email, required int streak}) {
    _name = name;
    _email = email;
    _streak = streak;
    notifyListeners();
  }
}
