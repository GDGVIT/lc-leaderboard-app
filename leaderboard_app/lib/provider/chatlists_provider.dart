import 'package:flutter/material.dart';

class ChatListProvider extends ChangeNotifier {
  /// List of group chats
  List<Map<String, dynamic>> _chatGroups = [];

  List<Map<String, dynamic>> get chatGroups => _chatGroups;

  /// Load dummy group chats
  void loadDummyGroups() {
    _chatGroups = List.generate(
      5,
      (index) => {
        "groupId": "group_$index",
        "name": "Group ${index + 1}",
        "lastMessage": "This is the latest message in Group ${index + 1}",
        "time": "12:${30 + index} pm",
        "members": List.generate(
          4,
          (mIndex) => {
            "uid": "uid_${index}_${mIndex}",
            "name": "Member ${mIndex + 1}",
          },
        ),
        "unread": index % 2 == 0, // alternate unread status
      },
    );
    notifyListeners();
  }

  /// Mark a group as read
  void markGroupAsRead(String groupId) {
    final index = _chatGroups.indexWhere((group) => group["groupId"] == groupId);
    if (index != -1) {
      _chatGroups[index]["unread"] = false;
      notifyListeners();
    }
  }

  /// Update last message for a group
  void updateLastMessage(String groupId, String message, String time) {
    final index = _chatGroups.indexWhere((group) => group["groupId"] == groupId);
    if (index != -1) {
      _chatGroups[index]["lastMessage"] = message;
      _chatGroups[index]["time"] = time;
      notifyListeners();
    }
  }
}