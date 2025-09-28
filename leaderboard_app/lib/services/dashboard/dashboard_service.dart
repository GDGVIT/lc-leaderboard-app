import 'package:dio/dio.dart';
import 'package:leaderboard_app/models/dashboard_models.dart';
import 'package:leaderboard_app/models/submissions_models.dart';
import 'package:leaderboard_app/services/core/api_client.dart';

class DashboardService {
  final Dio _dio;
  DashboardService(this._dio);

  static Future<DashboardService> create() async {
    final client = await ApiClient.create();
    return DashboardService(client.dio);
  }

  Future<List<SubmissionItem>> getUserSubmissions() async {
    final res = await _dio.get('/dashboard/submissions');
    final body = res.data as Map<String, dynamic>;
    // Attempt structured parsing
    try {
      final parsed = SubmissionsResponse.fromJson(body);
      return parsed.data.submissions.map((e) => e.toSubmissionItem()).toList();
    } catch (_) {
      // Fallback to previous loose parsing strategy
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final raw = (data['submissions'] ?? data['items'] ?? data['results'] ?? data) as dynamic;
      final list = raw is List
          ? raw.cast<Map<String, dynamic>>()
          : (raw is Map<String, dynamic> && raw['submissions'] is List)
              ? (raw['submissions'] as List).cast<Map<String, dynamic>>()
              : <Map<String, dynamic>>[];
      return list.map(SubmissionItem.fromJson).toList();
    }
  }

  Future<DailyQuestion?> getDailyQuestion() async {
  final res = await _dio.get('/dashboard/daily');
  final body = res.data as Map<String, dynamic>;
  final data = (body['data'] ?? body) as Map<String, dynamic>;
  final dq = (data['dailyQuestion'] ?? data['daily'] ?? data['question'] ?? data) as dynamic;
  if (dq is Map<String, dynamic>) return DailyQuestion.fromJson(dq);
  return null;
  }

  Future<List<TopUser>> getTopUsers() async {
  final res = await _dio.get('/dashboard/leaderboard');
  final body = res.data as Map<String, dynamic>;
  final data = (body['data'] ?? body) as Map<String, dynamic>;
  final raw = (data['leaderboard'] ?? data['users'] ?? data['results'] ?? data) as dynamic;
  final list = raw is List
    ? raw.cast<Map<String, dynamic>>()
    : (raw is Map<String, dynamic> && raw['leaderboard'] is List)
      ? (raw['leaderboard'] as List).cast<Map<String, dynamic>>()
      : <Map<String, dynamic>>[];
  return list.map(TopUser.fromJson).toList();
  }

  // New: explicit getLeaderboard support. Tries /leaderboard first, falls back to /dashboard/leaderboard.
  Future<List<TopUser>> getLeaderboard() async {
    try {
      final res = await _dio.get('/leaderboard');
      final body = res.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final raw = (data['leaderboard'] ?? data['users'] ?? []) as List<dynamic>;
      return raw.cast<Map<String, dynamic>>().map(TopUser.fromJson).toList();
    } on DioException catch (e) {
      // Fallback to the existing dashboard endpoint for compatibility
      if (e.response?.statusCode == 404 || e.type == DioExceptionType.unknown) {
        return getTopUsers();
      }
      rethrow;
    }
  }
}
