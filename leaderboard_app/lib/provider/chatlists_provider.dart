import 'package:flutter/material.dart';

class ChatListProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _chatUsers = [];

  List<Map<String, dynamic>> get chatUsers => _chatUsers;

  void loadDummyChats() {
    _chatUsers = List.generate(
      10,
      (index) => {
        "name": "Penny Valeria",
        "message": "Text text text text....",
        "time": "12:35 pm",
        "email": "user$index@example.com",
        "uid": "uid_$index",
        "unread": index != 0,
      },
    );
    notifyListeners();
  }

  void markAsRead(String email) {
    final index = _chatUsers.indexWhere((user) => user["email"] == email);
    if (index != -1) {
      _chatUsers[index]["unread"] = false;
      notifyListeners();
    }
  }
}
