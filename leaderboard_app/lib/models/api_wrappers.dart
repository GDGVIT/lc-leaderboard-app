// Generic-ish API response helpers and specific wrapper models for
// various backend endpoints. These map the `data` object of the backend
// responses so UI/widgets can depend on strongly typed structures.
//
// Each backend response uses the envelope:
// {
//   "success": bool,
//   "message": String,
//   "timestamp": String (ISO)?,
//   "data": { ... } // shape varies per endpoint
// }
//
// We provide a light-weight [ApiEnvelope] plus concrete data wrappers.


import 'auth_models.dart';
import 'dashboard_models.dart';
import 'group_models.dart';
import 'verification_models.dart';

DateTime? _parseTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString());
}

/// Base envelope for an API response. The [data] field is left dynamic; most
/// callers should prefer using the concrete `XYZResponse` classes below.
class ApiEnvelope<T> {
  final bool success;
  final String message;
  final DateTime? timestamp;
  final T? data;

  ApiEnvelope({
    required this.success,
    required this.message,
    required this.timestamp,
    required this.data,
  });

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json, {
    T Function(Object? json)? parse,
  }) {
    final rawData = json['data'];
    return ApiEnvelope<T>(
      success: json['success'] == true,
      message: (json['message'] ?? '') as String,
      timestamp: _parseTime(json['timestamp']),
      data: parse != null ? parse(rawData) : rawData as T?,
    );
  }
}

/// User profile (`GET /user/profile`)
class UserProfileResponse {
  final bool success;
  final String message;
  final DateTime? timestamp;
  final User user;

  UserProfileResponse({
    required this.success,
    required this.message,
    required this.timestamp,
    required this.user,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? json) as Map<String, dynamic>;
    final userJson = (data['user'] ?? data) as Map<String, dynamic>;
    return UserProfileResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '') as String,
      timestamp: _parseTime(json['timestamp']),
      user: User.fromJson(userJson),
    );
  }
}

/// Group list (`GET /groups`)
class GroupsResponse {
  final bool success;
  final String message;
  final DateTime? timestamp;
  final PagedGroups groups;

  GroupsResponse({
    required this.success,
    required this.message,
    required this.timestamp,
    required this.groups,
  });

  factory GroupsResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? {}) as Map<String, dynamic>;
    return GroupsResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '') as String,
      timestamp: _parseTime(json['timestamp']),
      groups: PagedGroups.fromJson(data),
    );
  }
}

/// Single group (`GET /groups/:id`, create, update)
class GroupResponse {
  final bool success;
  final String message;
  final DateTime? timestamp;
  final Group group;

  GroupResponse({
    required this.success,
    required this.message,
    required this.timestamp,
    required this.group,
  });

  factory GroupResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? json) as Map<String, dynamic>;
    final groupJson = (data['group'] ?? data) as Map<String, dynamic>;
    return GroupResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '') as String,
      timestamp: _parseTime(json['timestamp']),
      group: Group.fromJson(groupJson),
    );
  }
}

/// LeetCode verification start (`POST /leetcode/connect`)
class VerificationStartResponse {
  final bool success;
  final String message;
  final DateTime? timestamp;
  final VerificationStart data;

  VerificationStartResponse({
    required this.success,
    required this.message,
    required this.timestamp,
    required this.data,
  });

  factory VerificationStartResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? {}) as Map<String, dynamic>;
    return VerificationStartResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '') as String,
      timestamp: _parseTime(json['timestamp']),
      data: VerificationStart.fromJson(data),
    );
  }
}

/// LeetCode verification status (`GET /leetcode/status`)
class VerificationStatusResponse {
  final bool success;
  final String message;
  final DateTime? timestamp;
  final VerificationStatus data;

  VerificationStatusResponse({
    required this.success,
    required this.message,
    required this.timestamp,
    required this.data,
  });

  factory VerificationStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? {}) as Map<String, dynamic>;
    return VerificationStatusResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '') as String,
      timestamp: _parseTime(json['timestamp']),
      data: VerificationStatus.fromJson(data),
    );
  }
}

/// Dashboard submissions (`GET /dashboard/submissions`)
class SubmissionsResponse {
  final bool success;
  final String message;
  final DateTime? timestamp;
  final List<SubmissionItem> submissions;
  final int count;
  final int limit;

  SubmissionsResponse({
    required this.success,
    required this.message,
    required this.timestamp,
    required this.submissions,
    required this.count,
    required this.limit,
  });

  factory SubmissionsResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? {}) as Map<String, dynamic>;
    final list = (data['submissions'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return SubmissionsResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '') as String,
      timestamp: _parseTime(json['timestamp']),
      submissions: list.map(SubmissionItem.fromJson).toList(growable: false),
      count: (data['count'] as num?)?.toInt() ?? list.length,
      limit: (data['limit'] as num?)?.toInt() ?? list.length,
    );
  }
}

/// Daily question (`GET /dashboard/daily`)
class DailyQuestionResponse {
  final bool success;
  final String message;
  final DateTime? timestamp;
  final DailyQuestion dailyQuestion;

  DailyQuestionResponse({
    required this.success,
    required this.message,
    required this.timestamp,
    required this.dailyQuestion,
  });

  factory DailyQuestionResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? {}) as Map<String, dynamic>;
    return DailyQuestionResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '') as String,
      timestamp: _parseTime(json['timestamp']),
      dailyQuestion: DailyQuestion.fromJson((data['dailyQuestion'] ?? {}) as Map<String, dynamic>),
    );
  }
}

/// Top users leaderboard (`GET /dashboard/leaderboard` or `/user/leaderboard`)
class TopUsersResponse {
  final bool success;
  final String message;
  final DateTime? timestamp;
  final List<TopUser> leaderboard;
  final int count;

  TopUsersResponse({
    required this.success,
    required this.message,
    required this.timestamp,
    required this.leaderboard,
    required this.count,
  });

  factory TopUsersResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? {}) as Map<String, dynamic>;
    final list = (data['leaderboard'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return TopUsersResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '') as String,
      timestamp: _parseTime(json['timestamp']),
      leaderboard: list.map(TopUser.fromJson).toList(growable: false),
      count: (data['count'] as num?)?.toInt() ?? list.length,
    );
  }
}
