import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';

/// Provides a configured singleton Dio instance with auth header + logging.
class DioProvider {
  static Dio? _dio;

  static String _defaultBaseUrl() {
    const fromEnv = String.fromEnvironment('BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }

  static Future<Dio> getInstance({String? baseUrl}) async {
    if (_dio != null) return _dio!;
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _defaultBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final token = prefs.getString('authToken');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }, onError: (e, handler) {
      // Simple retry for idempotent GETs on network issues
      if (_shouldRetry(e)) {
        _retry(dio, e.requestOptions).then(handler.resolve).catchError((_) => handler.next(e));
      } else {
        handler.next(e);
      }
    }));

    // Basic log interceptor (custom to avoid extra dependency)
    dio.interceptors.add(_LogInterceptor());

    _dio = dio;
    return dio;
  }

  static bool _shouldRetry(DioException e) {
    return e.type == DioExceptionType.connectionError && e.requestOptions.method == 'GET';
  }

  static Future<Response<dynamic>> _retry(Dio dio, RequestOptions requestOptions) async {
    final opts = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
    );
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: opts,
    );
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kIsWeb) {
      // Avoid verbose logs in web release; adjust as needed.
    }
    debugPrint('[HTTP] => ${options.method} ${options.baseUrl}${options.path}');
    if (options.data != null) debugPrint('  Body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[HTTP] <= ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[HTTP] !! ${err.type} ${err.message} path=${err.requestOptions.path}');
    handler.next(err);
  }
}

void debugPrint(String message) {
  // Lightweight wrapper to silence in release if desired.
  if (kIsWeb || true) {
    // ignore: avoid_print
    print(message);
  }
}
