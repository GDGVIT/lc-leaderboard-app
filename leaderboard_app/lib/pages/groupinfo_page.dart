import 'package:flutter/material.dart';
import 'package:leaderboard_app/models/group_models.dart';
import 'package:leaderboard_app/services/groups/group_service.dart';
import 'package:leaderboard_app/services/dashboard/dashboard_service.dart';
import 'package:leaderboard_app/provider/user_provider.dart';
import 'package:leaderboard_app/provider/chatlists_provider.dart';
import 'package:provider/provider.dart';
import 'package:leaderboard_app/provider/group_membership_provider.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupId;
  final String? initialName;

  const GroupInfoPage({super.key, required this.groupId, this.initialName});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  Group? _group;
  bool _loading = true;
  String? _error;
  bool _mutating = false;
  String? _currentUserId;
  // Hydrated user stats from global leaderboard (username -> (streak, solved))
  final Map<String, (int streak, int solved)> _userStats = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _currentUserId = context.read<UserProvider>().user?.id;
      final svc = context.read<GroupService>();
      final g = await svc.getGroupById(widget.groupId);
      // Hydrate streak / solved from dashboard leaderboard (best-effort)
      try {
        final dash = context.read<DashboardService>();
        final lb = await dash.getLeaderboard();
        _userStats
          ..clear()
          ..addEntries(lb.map((u) => MapEntry(u.username.toLowerCase(), (u.streak, u.totalSolved))));
      } catch (_) {
        // ignore hydration errors silently
      }
      if (!mounted) return;
      setState(() => _group = g);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load group');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isMember {
    final uid = _currentUserId;
    if (uid == null || _group == null) return false;
    return _group!.members.any((m) => m.userId == uid);
  }

  bool get _isOwner {
    final uid = _currentUserId;
    final g = _group;
    if (uid == null || g == null) return false;
    if (g.creator?.id == uid || g.createdBy == uid) return true;
    return g.members.any((m) => m.userId == uid && m.role.toUpperCase() == 'OWNER');
  }

  bool get _isAdmin {
    final uid = _currentUserId;
    final g = _group;
    if (uid == null || g == null) return false;
    return g.members.any((m) => m.userId == uid && (m.role.toUpperCase() == 'ADMIN' || m.role.toUpperCase() == 'MODERATOR'));
  }

  bool _canManage(GroupMember target) {
    // Owner can manage anyone except themselves
    if (_isOwner) {
      // Prevent self demotion via manage menu (handled elsewhere) by disallowing actions on OWNER role belonging to current user.
      return !(target.role.toUpperCase() == 'OWNER' && target.userId == _currentUserId);
    }
    // Admins can manage only regular members (not owner, not other admins/mods)
    if (_isAdmin) {
      final role = target.role.toUpperCase();
      return role != 'OWNER' && role != 'ADMIN' && role != 'MODERATOR';
    }
    return false; // members cannot manage anyone
  }

  Future<void> _joinLeave() async {
    if (_group == null) return;
    setState(() => _mutating = true);
    try {
      final svc = context.read<GroupService>();
      if (_isMember) {
        await svc.leaveGroup(_group!.id);
        // After leaving, refresh public group listing so counts & membership reflect change
        try {
          final chatListProv = context.read<ChatListProvider?>();
            if (chatListProv != null) {
              chatListProv.loadPublicGroups(svc);
            }
        } catch (_) {}
        // Pop immediately with result so upstream (e.g., ChatPage) can react
        if (mounted) Navigator.of(context).pop({'leftGroup': true, 'groupId': _group!.id});
        return; // skip reloading after leave
      } else {
        await svc.joinGroup(_group!.id);
        // Inform membership provider (if in tree) so gate can switch to chat
        final membershipProv = context.read<GroupMembershipProvider?>();
        membershipProv?.markJoined();
        // Refresh public groups so membership filter updates automatically
        try {
          final chatListProv = context.read<ChatListProvider?>();
          if (chatListProv != null) {
            chatListProv.loadPublicGroups(svc);
          }
        } catch (_) {}
      }
      await _load();
    } catch (e) {
      setState(() => _error = 'Operation failed');
    } finally {
      setState(() => _mutating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final name = _group?.name ?? widget.initialName ?? 'Group';

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(),
        elevation: 0,
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
          // Only the owner should see the 3-dot menu (admins no longer see it)
          if (!_loading && _group != null && _isOwner)
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    await _showEditGroupDialog();
                    break;
                  case 'delete':
                    await _confirmDelete();
                    break;
                  case 'transfer':
                    await _promptTransferOwnership();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit Group')),
                const PopupMenuItem(value: 'delete', child: Text('Delete Group')),
                if (_isOwner) const PopupMenuItem(value: 'transfer', child: Text('Transfer Ownership')),
              ],
      ),
    ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.group,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 8),
                      if (_group?.description != null)
                        Text(
                          _group!.description!,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _mutating ? null : _joinLeave,
                          style: ElevatedButton.styleFrom(backgroundColor: theme.secondary),
                          child: Text(_isMember ? 'Leave Group' : 'Join Group', style: const TextStyle(color: Colors.black)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _membersCard(_group?.members ?? const []),
                      const SizedBox(height: 16),
                      _xpTable(_group?.members ?? const []),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _membersCard(List<GroupMember> members) {
    // Sort members: Owner first, then Admin/Moderator, then Member; alphabetically within each tier
    int roleRank(String role) {
      final r = role.toUpperCase();
      if (r == 'OWNER') return 0;
      if (r == 'ADMIN' || r == 'MODERATOR') return 1;
      return 2; // MEMBER or anything else
    }
    final sorted = [...members]
      ..sort((a, b) {
        final ar = roleRank(a.role);
        final br = roleRank(b.role);
        if (ar != br) return ar.compareTo(br);
        final aName = (a.user?.username ?? a.userId).toLowerCase();
        final bName = (b.user?.username ?? b.userId).toLowerCase();
        return aName.compareTo(bName);
      });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Members', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          ...sorted.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey.shade700,
                      child: Text(
                        (m.user?.username.isNotEmpty == true) ? m.user!.username[0] : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      m.user?.username ?? m.userId,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blueGrey.shade700, borderRadius: BorderRadius.circular(8)),
                      child: Text(m.role, style: const TextStyle(fontSize: 12)),
                    ),
                    if (_canManage(m))
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          switch (value) {
                            case 'remove':
                              if (_canManage(m)) await _removeMember(m);
                              break;
                            case 'promote':
                              if (_canManage(m)) await _changeRole(m, 'ADMIN');
                              break;
                            case 'demote':
                              if (_canManage(m)) await _changeRole(m, 'MEMBER');
                              break;
                            case 'makeOwner':
                              if (_isOwner && m.role.toUpperCase() != 'OWNER') await _transferOwnershipTo(m);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'remove', child: Text('Remove')),
                          const PopupMenuItem(value: 'promote', child: Text('Promote to Admin')),
                          const PopupMenuItem(value: 'demote', child: Text('Demote to Member')),
                          if (_isOwner && m.role.toUpperCase() != 'OWNER') const PopupMenuItem(value: 'makeOwner', child: Text('Make Owner')),
                        ],
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _xpTable(List<GroupMember> members) {
    // Sort by hydrated streak desc, then solved desc, then xp desc, then username asc as final tie-breaker
    final sorted = [...members];
    sorted.sort((a, b) {
      String aName = (a.user?.username ?? a.userId).toLowerCase();
      String bName = (b.user?.username ?? b.userId).toLowerCase();
      final aStats = _userStats[aName];
      final bStats = _userStats[bName];
      final aStreak = aStats?.$1 ?? a.user?.streak ?? 0;
      final bStreak = bStats?.$1 ?? b.user?.streak ?? 0;
      if (bStreak != aStreak) return bStreak.compareTo(aStreak);
      final aSolved = aStats?.$2 ?? a.user?.totalSolved ?? 0;
      final bSolved = bStats?.$2 ?? b.user?.totalSolved ?? 0;
      if (bSolved != aSolved) return bSolved.compareTo(aSolved);
      if (b.xp != a.xp) return b.xp.compareTo(a.xp);
      return aName.compareTo(bName);
    });
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        color: Colors.grey.shade900,
        child: LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 16,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 40,
              headingRowHeight: 32,
              headingRowColor: MaterialStateProperty.all(Colors.grey[850]),
              columns: const [
                DataColumn(label: Text('Place', style: TextStyle(color: Colors.white, fontSize: 12))),
                DataColumn(label: Text('Player', style: TextStyle(color: Colors.white, fontSize: 12))),
                DataColumn(label: Text('Streak', style: TextStyle(color: Colors.white, fontSize: 12))),
                DataColumn(label: Text('Solved', style: TextStyle(color: Colors.white, fontSize: 12))),
              ],
              rows: List.generate(sorted.length, (i) {
                final m = sorted[i];
                final uname = (m.user?.username ?? m.userId).toLowerCase();
                final hydrated = _userStats[uname];
                final streak = hydrated != null ? hydrated.$1 : (m.user?.streak ?? 0);
                final solved = hydrated != null ? hydrated.$2 : (m.user?.totalSolved ?? 0);
                final streakDisplay = streak == 0 ? '—' : '$streak';
                final solvedDisplay = solved == 0 ? '—' : '$solved';
                return DataRow(cells: [
                  DataCell(Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12))),
                  DataCell(Text(m.user?.username ?? m.userId, style: const TextStyle(color: Colors.white, fontSize: 12))),
                  DataCell(Text(streakDisplay, style: const TextStyle(color: Colors.white, fontSize: 12))),
                  DataCell(Text(solvedDisplay, style: const TextStyle(color: Colors.white, fontSize: 12))),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditGroupDialog() async {
    if (_group == null) return;
    final nameCtrl = TextEditingController(text: _group!.name);
    final descCtrl = TextEditingController(text: _group!.description ?? '');
    bool isPrivate = _group!.isPrivate;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setLocalState) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Edit Group'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Private'),
                  value: isPrivate,
                  onChanged: (v) => setLocalState(() => isPrivate = v),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: colors.secondary, foregroundColor: Colors.black),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
    if (result != true) return;
    setState(() => _mutating = true);
    try {
      final svc = context.read<GroupService>();
      final updated = await svc.updateGroup(_group!.id, name: nameCtrl.text.trim(), description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(), isPrivate: isPrivate);
      // Optimistically update chat list provider
      if (mounted) {
        context.read<ChatListProvider?>()?.updateGroupMeta(groupId: updated.id, name: updated.name, isPrivate: updated.isPrivate);
      }
      await _load();
    } catch (_) {
      setState(() => _error = 'Failed to update group');
    } finally {
      setState(() => _mutating = false);
    }
  }

  Future<void> _confirmDelete() async {
    if (_group == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Group'),
        content: const Text('Are you sure you want to delete this group? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _mutating = true);
    try {
      final svc = context.read<GroupService>();
      await svc.deleteGroup(_group!.id);
      // Update chat list provider so list reflects deletion
      if (mounted) {
        final chatListProv = context.read<ChatListProvider?>();
        chatListProv?.removeGroup(_group!.id);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      setState(() => _error = 'Failed to delete group');
    } finally {
      setState(() => _mutating = false);
    }
  }

  Future<void> _removeMember(GroupMember m) async {
    if (_group == null) return;
    setState(() => _mutating = true);
    try {
      final svc = context.read<GroupService>();
      await svc.removeMember(_group!.id, m.userId);
      await _load();
    } catch (_) {
      setState(() => _error = 'Failed to remove member');
    } finally {
      setState(() => _mutating = false);
    }
  }

  Future<void> _changeRole(GroupMember m, String role) async {
    if (_group == null) return;
    setState(() => _mutating = true);
    try {
      final svc = context.read<GroupService>();
      await svc.updateMemberRole(_group!.id, m.userId, role);
      await _load();
    } catch (_) {
      setState(() => _error = 'Failed to update role');
    } finally {
      setState(() => _mutating = false);
    }
  }

  Future<void> _promptTransferOwnership() async {
    if (_group == null) return;
    final members = _group!.members.where((m) => m.userId != _currentUserId).toList();
    String? selectedUserId = members.isNotEmpty ? members.first.userId : null;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Transfer Ownership'),
        content: DropdownButton<String>(
          value: selectedUserId,
          items: members
              .map((m) => DropdownMenuItem(
                    value: m.userId,
                    child: Text(m.user?.username ?? m.userId),
                  ))
              .toList(),
          onChanged: (v) {
            selectedUserId = v;
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Transfer')),
        ],
      ),
    );
    if (ok == true && selectedUserId != null) {
      await _transferOwnershipToUserId(selectedUserId!);
    }
  }

  Future<void> _transferOwnershipTo(GroupMember m) async {
    await _transferOwnershipToUserId(m.userId);
  }

  Future<void> _transferOwnershipToUserId(String userId) async {
    if (_group == null) return;
    setState(() => _mutating = true);
    try {
      final svc = context.read<GroupService>();
      await svc.transferOwnership(_group!.id, userId);
      await _load();
    } catch (_) {
      setState(() => _error = 'Failed to transfer ownership');
    } finally {
      setState(() => _mutating = false);
    }
  }
}