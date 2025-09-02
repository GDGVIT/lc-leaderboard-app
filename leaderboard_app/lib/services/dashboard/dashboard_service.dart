import 'package:dio/dio.dart';
import 'package:leaderboard_app/models/dashboard_models.dart';
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
    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final list = (data['submissions'] as List<dynamic>).cast<Map<String, dynamic>>();
    return list.map(SubmissionItem.fromJson).toList();
  }

  Future<DailyQuestion?> getDailyQuestion() async {
    final res = await _dio.get('/dashboard/daily');
    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final dq = data['dailyQuestion'];
    if (dq == null) return null;
    return DailyQuestion.fromJson(dq as Map<String, dynamic>);
  }

  Future<List<TopUser>> getTopUsers() async {
    final res = await _dio.get('/dashboard/leaderboard');
    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final list = (data['leaderboard'] as List<dynamic>).cast<Map<String, dynamic>>();
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
