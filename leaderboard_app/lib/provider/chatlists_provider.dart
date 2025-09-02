import 'package:flutter/material.dart';
import 'package:leaderboard_app/services/groups/group_service.dart';

class ChatListProvider extends ChangeNotifier {
  /// List of group chats
  List<Map<String, dynamic>> _chatGroups = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get chatGroups => _chatGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  /// Load groups from backend (public groups)
  Future<void> loadPublicGroups(GroupService service, {int page = 1, int limit = 10, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final paged = await service.getAllGroups(page: page, limit: limit, search: search);
      _chatGroups = paged.groups.map((g) {
        return {
          'groupId': g.id,
          'name': g.name,
          'lastMessage': '',
          'time': '',
          'members': g.members.map((m) => {
                'uid': m.userId,
                'name': m.user?.username ?? m.userId,
              }).toList(),
          'unread': false,
          'favourite': false,
        };
      }).toList();
    } catch (e) {
      _error = 'Failed to load groups';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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