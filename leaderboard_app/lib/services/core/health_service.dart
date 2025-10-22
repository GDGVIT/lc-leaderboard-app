import 'package:dio/dio.dart';
import 'package:leeterboard/services/core/api_client.dart';

class HealthService {
  final Dio _dio;
  HealthService(this._dio);

  static Future<HealthService> create() async {
    final client = await ApiClient.create();
    return HealthService(client.dio);
  }

  Future<bool> isHealthy() async {
    try {
      final res = await _dio.get('/health');
      return (res.statusCode ?? 200) >= 200 && (res.statusCode ?? 200) < 300;
    } catch (_) {
      return false;
    }
  }
}
