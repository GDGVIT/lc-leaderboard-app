import 'package:dio/dio.dart';
import 'package:leaderboard_app/models/group_models.dart';
import 'package:leaderboard_app/services/core/api_client.dart';

class GroupService {
	final Dio _dio;
	GroupService(this._dio);

	static Future<GroupService> create() async {
		final client = await ApiClient.create();
		return GroupService(client.dio);
	}

	// Public: Get all groups with pagination and optional search
	Future<PagedGroups> getAllGroups({int page = 1, int limit = 10, String? search}) async {
		final res = await _dio.get('/groups', queryParameters: {
			'page': page,
			'limit': limit,
			if (search != null && search.isNotEmpty) 'search': search,
		});
		final body = res.data as Map<String, dynamic>;
		final data = (body['data'] ?? body) as Map<String, dynamic>;
		return PagedGroups.fromJson(data);
	}

	// Public: Get group by ID
	Future<Group> getGroupById(String groupId) async {
		final res = await _dio.get('/groups/$groupId');
		final body = res.data as Map<String, dynamic>;
		final data = (body['data'] ?? body) as Map<String, dynamic>;
		return Group.fromJson(data);
	}

	// Public: Get group members
	Future<List<GroupMember>> getGroupMembers(String groupId) async {
		final res = await _dio.get('/groups/$groupId/members');
		final body = res.data as Map<String, dynamic>;
		final data = (body['data'] ?? body) as List<dynamic>;
		return data.cast<Map<String, dynamic>>().map(GroupMember.fromJson).toList();
	}

	// Protected: Create group
	Future<Group> createGroup({required String name, String? description, bool isPrivate = false, int? maxMembers}) async {
		final res = await _dio.post('/groups', data: {
			'name': name,
			if (description != null) 'description': description,
			'isPrivate': isPrivate,
			if (maxMembers != null) 'maxMembers': maxMembers,
		});
		final body = res.data as Map<String, dynamic>;
		final data = (body['data'] ?? body) as Map<String, dynamic>;
		return Group.fromJson(data);
	}

	// Protected: Get user's groups
	Future<List<Group>> getMyGroups() async {
		final res = await _dio.get('/groups/user/my-groups');
		final body = res.data as Map<String, dynamic>;
		final data = (body['data'] ?? body);
		if (data is List) {
			return data.cast<Map<String, dynamic>>().map(Group.fromJson).toList();
		}
		if (data is Map<String, dynamic> && data['groups'] is List) {
			return (data['groups'] as List).cast<Map<String, dynamic>>().map(Group.fromJson).toList();
		}
		return const [];
	}

	// Protected: Update group
	Future<Group> updateGroup(String groupId, {required String name, String? description, required bool isPrivate, int? maxMembers}) async {
		final res = await _dio.put('/groups/$groupId', data: {
			'name': name,
			if (description != null) 'description': description,
			'isPrivate': isPrivate,
			if (maxMembers != null) 'maxMembers': maxMembers,
		});
		final body = res.data as Map<String, dynamic>;
		final data = (body['data'] ?? body) as Map<String, dynamic>;
		return Group.fromJson(data);
	}

	// Protected: Delete group
	Future<void> deleteGroup(String groupId) async {
		await _dio.delete('/groups/$groupId');
	}

	// Membership: Join group
	Future<void> joinGroup(String groupId) async {
		await _dio.post('/groups/$groupId/join');
	}

	// Membership: Leave group
	Future<void> leaveGroup(String groupId) async {
		await _dio.delete('/groups/$groupId/leave');
	}

	// Management: Remove member
	Future<void> removeMember(String groupId, String userId) async {
		await _dio.delete('/groups/$groupId/members/$userId');
	}

	// Management: Update member role
	Future<void> updateMemberRole(String groupId, String userId, String role) async {
		await _dio.put('/groups/$groupId/members/$userId/role', data: {
			'role': role,
		});
	}

	// Management: Transfer ownership
	Future<void> transferOwnership(String groupId, String newOwnerId) async {
		await _dio.post('/groups/$groupId/transfer-ownership', data: {
			'newOwnerId': newOwnerId,
		});
	}
}

