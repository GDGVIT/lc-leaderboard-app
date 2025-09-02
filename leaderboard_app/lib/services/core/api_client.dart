import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiClient {
  // Choose a sensible default base URL for each platform. Can be overridden via --dart-define=BASE_URL=...
  static String _defaultBaseUrl() {
    const fromEnv = String.fromEnvironment('BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) {
      // Web runs in the browser on the host, so localhost maps to the dev machine.
      return 'http://localhost:3000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator can't reach host via localhost; use the special alias.
      return 'http://10.0.2.2:3000/api';
    }

    // iOS simulator, desktop, etc. can usually use localhost.
    return 'http://localhost:3000/api';
  }

  static final String kBaseUrl = _defaultBaseUrl();
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
