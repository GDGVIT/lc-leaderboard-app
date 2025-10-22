import 'package:dio/dio.dart';
import 'package:leeterboard/models/auth_models.dart';
import 'package:leeterboard/models/dashboard_models.dart';
import 'package:leeterboard/services/core/api_client.dart';

class UserService {
  final Dio _dio;
  UserService(this._dio);

  static Future<UserService> create() async {
    final client = await ApiClient.create();
    return UserService(client.dio);
  }

  Future<User> getProfile() async {
    final res = await _dio.get('/user/profile');
    final body = res.data as Map<String, dynamic>;
    final data = (body['data'] ?? body) as Map<String, dynamic>;
    final userJson = (data['user'] ?? data) as Map<String, dynamic>;
    return User.fromJson(userJson);
  }

  Future<List<TopUser>> getPublicLeaderboard() async {
    final res = await _dio.get('/user/leaderboard');
    final body = res.data as Map<String, dynamic>;
    final data = (body['data'] ?? body) as Map<String, dynamic>;
    final list = (data['leaderboard'] ?? data['users'] ?? []) as List<dynamic>;
    return list.cast<Map<String, dynamic>>().map(TopUser.fromJson).toList();
  }

  Future<void> updateStreak(int streak) async {
    await _dio.patch('/user/streak', data: {'streak': streak});
  }
}
