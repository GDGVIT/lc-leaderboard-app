import 'package:flutter/material.dart';
import 'package:leaderboard_app/models/group_models.dart';
import 'package:leaderboard_app/services/groups/group_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupService service;
  GroupProvider(this.service);

  bool _loading = false;
  String? _error;
  List<Group> _myGroups = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<Group> get myGroups => _myGroups;

  Future<void> loadMyGroups() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _myGroups = await service.getMyGroups();
    } catch (e) {
      _error = 'Failed to load my groups';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Group?> createGroup({required String name, String? description, bool isPrivate = false, int? maxMembers}) async {
    try {
      final g = await service.createGroup(name: name, description: description, isPrivate: isPrivate, maxMembers: maxMembers);
      _myGroups = [..._myGroups, g];
      notifyListeners();
      return g;
    } catch (e) {
      _error = 'Failed to create group';
      notifyListeners();
      return null;
    }
  }
}
