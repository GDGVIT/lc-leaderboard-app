import 'package:flutter/foundation.dart';
import 'package:leaderboard_app/models/group_models.dart';
import 'package:leaderboard_app/services/groups/group_service.dart';
import 'package:leaderboard_app/provider/user_provider.dart';

enum GroupMembershipStatus { loading, member, notMember, error }

class GroupMembershipProvider extends ChangeNotifier {
  final GroupService service;
  final UserProvider userProvider;

  GroupMembershipProvider({required this.service, required this.userProvider});

  GroupMembershipStatus _status = GroupMembershipStatus.loading;
  GroupMembershipStatus get status => _status;

  Group? _group;
  Group? get group => _group;

  String? _error;
  String? get error => _error;

  Future<void> check(String groupId) async {
    _status = GroupMembershipStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final g = await service.getGroupById(groupId);
      _group = g;
      final uid = userProvider.user?.id;
      if (uid != null && g.members.any((m) => m.userId == uid)) {
        _status = GroupMembershipStatus.member;
      } else {
        _status = GroupMembershipStatus.notMember;
      }
    } catch (e) {
      _error = 'Failed to load group';
      _status = GroupMembershipStatus.error;
    } finally {
      notifyListeners();
    }
  }

  void markJoined() {
    if (_status != GroupMembershipStatus.member) {
      _status = GroupMembershipStatus.member;
      notifyListeners();
    }
  }
}
