import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaderboard_app/config/api_config.dart';

class ApiClient {
  static final String kBaseUrl = ApiConfig.baseUrl;
  final Dio dio;

  ApiClient._internal(this.dio);

  static Future<ApiClient> create({String? baseUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? kBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = prefs.getString('authToken');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          // You can add logging or global error handling here
          handler.next(e);
        },
      ),
    );

    return ApiClient._internal(dio);
  }
}
