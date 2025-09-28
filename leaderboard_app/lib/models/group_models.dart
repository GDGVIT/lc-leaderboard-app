// Model classes for Group APIs

class Group {
  final String id;
  final String name;
  final String? description;
  final bool isPrivate;
  final int? maxMembers;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<GroupMember> members;
  final GroupCreator? creator;

  Group({
    required this.id,
    required this.name,
    this.description,
    required this.isPrivate,
    this.maxMembers,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.members = const [],
    this.creator,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    final membersRaw = (json['members'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return Group(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description'] as String?,
      isPrivate: json['isPrivate'] == true,
      maxMembers: (json['maxMembers'] as num?)?.toInt(),
      createdBy: (json['createdBy'] ?? json['ownerId'])?.toString(),
      createdAt: _tryDate(json['createdAt']),
      updatedAt: _tryDate(json['updatedAt']),
      members: membersRaw.map(GroupMember.fromJson).toList(growable: false),
      creator: json['creator'] != null ? GroupCreator.fromJson(json['creator'] as Map<String, dynamic>) : null,
    );
  }

  static DateTime? _tryDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}

class GroupMember {
  final String id;
  final String userId;
  final String groupId;
  final String role; // OWNER, ADMIN, MODERATOR, MEMBER
  final int xp;
  final DateTime? joinedAt;
  final GroupMemberUser? user;

  GroupMember({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.role,
    required this.xp,
    this.joinedAt,
    this.user,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      groupId: (json['groupId'] ?? '').toString(),
      role: (json['role'] ?? 'MEMBER').toString(),
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      joinedAt: Group._tryDate(json['joinedAt']),
      user: json['user'] != null ? GroupMemberUser.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
}

/// Optional strongly typed role enum. Use [GroupRoleExt.parse] to convert
/// backend string values without throwing.
enum GroupRole { owner, admin, moderator, member }

extension GroupRoleExt on GroupRole {
  static GroupRole parse(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'OWNER':
        return GroupRole.owner;
      case 'ADMIN':
        return GroupRole.admin;
      case 'MODERATOR':
        return GroupRole.moderator;
      default:
        return GroupRole.member;
    }
  }

  String get asApiValue {
    switch (this) {
      case GroupRole.owner:
        return 'OWNER';
      case GroupRole.admin:
        return 'ADMIN';
      case GroupRole.moderator:
        return 'MODERATOR';
      case GroupRole.member:
        return 'MEMBER';
    }
  }
}


class GroupCreator {
  final String id;
  final String username;
  final String? email;

  GroupCreator({required this.id, required this.username, this.email});

  factory GroupCreator.fromJson(Map<String, dynamic> json) => GroupCreator(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        username: (json['username'] ?? '').toString(),
        email: json['email'] as String?,
      );
}

class GroupMemberUser {
  final String id;
  final String username;
  final String? leetcodeHandle;
  final bool leetcodeVerified;

  GroupMemberUser({
    required this.id,
    required this.username,
    this.leetcodeHandle,
    required this.leetcodeVerified,
  });

  factory GroupMemberUser.fromJson(Map<String, dynamic> json) => GroupMemberUser(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        username: (json['username'] ?? '').toString(),
        leetcodeHandle: json['leetcodeHandle'] as String?,
        leetcodeVerified: json['leetcodeVerified'] == true,
      );
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasNext;
  final bool hasPrev;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
        totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
        hasNext: json['hasNext'] == true,
        hasPrev: json['hasPrev'] == true,
      );
}

class PagedGroups {
  final List<Group> groups;
  final Pagination? pagination;

  PagedGroups({required this.groups, this.pagination});

  factory PagedGroups.fromJson(Map<String, dynamic> json) {
    final groupsRaw = (json['groups'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return PagedGroups(
      groups: groupsRaw.map(Group.fromJson).toList(growable: false),
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>) : null,
    );
  }
}
