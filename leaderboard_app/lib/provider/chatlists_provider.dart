import 'package:flutter/material.dart';
import 'package:leaderboard_app/services/groups/group_service.dart';

class ChatListProvider extends ChangeNotifier {
  /// List of group chats
  List<Map<String, dynamic>> _chatGroups = [];
  bool _isLoading = false;
  String? _error;

  // Creation state
  bool _isCreating = false;
  String? _createError;

  List<Map<String, dynamic>> get chatGroups => _chatGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCreating => _isCreating;
  String? get createError => _createError;

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

  /// Load groups from backend (public groups) and merge with user's joined groups (including private)
  Future<void> loadPublicGroups(GroupService service, {int page = 1, int limit = 10, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final paged = await service.getAllGroups(page: page, limit: limit, search: search);
      final myGroups = await service.getMyGroups();

      // Map by id to merge (my groups take precedence for member list completeness / privacy visibility)
      final Map<String, Map<String, dynamic>> merged = {};

      void addOrUpdate(group, {bool isMember = false}) {
        merged[group.id] = {
          'groupId': group.id,
          'name': group.name,
          'lastMessage': '',
          'time': '',
          'isPrivate': group.isPrivate,
          'members': group.members.map((m) => {
                'uid': m.userId,
                'name': m.user?.username ?? m.userId,
              }).toList(),
          'unread': false,
          'favourite': false,
          'isMember': isMember,
        };
      }

      for (final g in paged.groups) {
        addOrUpdate(g, isMember: false); // unknown membership until merged with myGroups
      }
      for (final g in myGroups) {
        addOrUpdate(g, isMember: true); // mark membership
      }

      _chatGroups = merged.values.toList();
    } catch (e) {
      _error = 'Failed to load groups';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new group and add to list (optimistically inserts at top)
  Future<Map<String, dynamic>?> createNewGroup(GroupService service, {required String name, String? description, bool isPrivate = false, int? maxMembers}) async {
    if (_isCreating) return null; // prevent duplicate taps
    _isCreating = true;
    _createError = null;
    notifyListeners();
    try {
      final group = await service.createGroup(name: name, description: description, isPrivate: isPrivate, maxMembers: maxMembers);
      final map = {
        'groupId': group.id,
        'name': group.name,
        'lastMessage': '',
        'time': '',
        'isPrivate': group.isPrivate,
        'members': group.members.map((m) => {
              'uid': m.userId,
              'name': m.user?.username ?? m.userId,
            }).toList(),
        'unread': false,
        'favourite': false,
      };
      _chatGroups = [map, ..._chatGroups];
      return map;
    } catch (e) {
      _createError = 'Failed to create group';
      return null;
    } finally {
      _isCreating = false;
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

  /// Remove a group from the list (e.g., after deletion)
  void removeGroup(String groupId) {
    final beforeLen = _chatGroups.length;
    _chatGroups.removeWhere((g) => g['groupId'] == groupId);
    if (beforeLen != _chatGroups.length) {
      notifyListeners();
    }
  }

  /// Update group metadata (e.g., after editing name / privacy)
  void updateGroupMeta({required String groupId, String? name, bool? isPrivate}) {
    final index = _chatGroups.indexWhere((g) => g['groupId'] == groupId);
    if (index == -1) return;
    bool changed = false;
    if (name != null && name.isNotEmpty && _chatGroups[index]['name'] != name) {
      _chatGroups[index]['name'] = name;
      changed = true;
    }
    if (isPrivate != null && _chatGroups[index]['isPrivate'] != isPrivate) {
      _chatGroups[index]['isPrivate'] = isPrivate;
      changed = true;
    }
    if (changed) notifyListeners();
  }
}