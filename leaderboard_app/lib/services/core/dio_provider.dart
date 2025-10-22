import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // narrow imports
import 'package:leeterboard/config/api_config.dart';
import 'package:leeterboard/services/core/token_manager.dart';

/// Provides a configured singleton Dio instance with auth header + logging.
class DioProvider {
  static Dio? _dio;
  static Future<String?>? _refreshingFuture;

  static Future<Dio> getInstance({String? baseUrl}) async {
    if (_dio != null) return _dio!;
    // Note: Token values are retrieved on-demand via TokenManager.
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip auth header for explicit opt-out
          if (options.extra['skipAuth'] == true) {
            handler.next(options);
            return;
          }
          final token = await TokenManager.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          // Simple retry for idempotent GETs on network issues
          if (_shouldRetry(e)) {
            _retry(
              dio,
              e.requestOptions,
            ).then(handler.resolve).catchError((_) => handler.next(e));
            return;
          }

          // Refresh on 401 Unauthorized, excluding auth endpoints to avoid loops
          final status = e.response?.statusCode;
          final path = e.requestOptions.path;
          final isAuthPath =
              path.contains('/auth/login') ||
              path.contains('/auth/signup') ||
              path.contains('/auth/refresh');
          final alreadyRetried = e.requestOptions.extra['retried'] == true;

          if (status == 401 && !isAuthPath && !alreadyRetried) {
            try {
              final newToken = await _refreshTokenIfNeeded(dio);
              if (newToken != null && newToken.isNotEmpty) {
                // Clone and retry original request with new token
                final opts = Options(
                  method: e.requestOptions.method,
                  headers: {
                    ...e.requestOptions.headers,
                    'Authorization': 'Bearer $newToken',
                  },
                  responseType: e.requestOptions.responseType,
                  contentType: e.requestOptions.contentType,
                  sendTimeout: e.requestOptions.sendTimeout,
                  receiveTimeout: e.requestOptions.receiveTimeout,
                  extra: {...e.requestOptions.extra, 'retried': true},
                );
                final rerun = await dio.request<dynamic>(
                  e.requestOptions.path,
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                  options: opts,
                );
                handler.resolve(rerun);
                return;
              }
            } catch (_) {
              // fall through to next
            }
          }

          handler.next(e);
        },
      ),
    );

    // Basic log interceptor (custom to avoid extra dependency)
    dio.interceptors.add(_LogInterceptor());

    _dio = dio;
    return dio;
  }

  static bool _shouldRetry(DioException e) {
    final isGet = e.requestOptions.method == 'GET';
    final isNet =
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout;
    if (!(isGet && isNet)) return false;
    final attempts = (e.requestOptions.extra['retryCount'] as int?) ?? 0;
    return attempts < 1; // retry at most once
  }

  static Future<Response<dynamic>> _retry(
    Dio dio,
    RequestOptions requestOptions,
  ) async {
    final attempts = (requestOptions.extra['retryCount'] as int?) ?? 0;
    // brief backoff before retrying
    await Future<void>.delayed(Duration(milliseconds: 500 * (attempts + 1)));
    final opts = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      extra: {...requestOptions.extra, 'retryCount': attempts + 1},
    );
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: opts,
    );
  }

  /// Reset the cached Dio so a subsequent call to [getInstance] creates a
  /// fresh client (used on logout to ensure new auth token picked up).
  static void reset() {
    _dio = null;
  }

  /// Ensure only one refresh happens at a time. Returns new access token or null.
  static Future<String?> _refreshTokenIfNeeded(Dio baseDio) async {
    // If a refresh is already ongoing, await the same future
    final ongoing = _refreshingFuture;
    if (ongoing != null) {
      return ongoing;
    }

    final completer = Completer<String?>();
    _refreshingFuture = completer.future;

    try {
      final newToken = await _callRefreshEndpoint(baseDio);
      completer.complete(newToken);
      return newToken;
    } catch (err) {
      completer.complete(null);
      return null;
    } finally {
      _refreshingFuture = null;
    }
  }

  /// Call the refresh endpoint using a bare Dio to avoid interceptor loops.
  static Future<String?> _callRefreshEndpoint(Dio baseDio) async {
    final refreshToken = await TokenManager.getRefreshToken();
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: baseDio.options.baseUrl,
        connectTimeout: baseDio.options.connectTimeout,
        receiveTimeout: baseDio.options.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    Response res;
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        res = await refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );
      } else {
        // Some backends use HttpOnly cookie refresh; attempt without body
        res = await refreshDio.post('/auth/refresh');
      }
    } on DioException {
      // Refresh failed
      await TokenManager.clearTokens();
      return null;
    }

    final data = res.data is Map<String, dynamic>
        ? res.data as Map<String, dynamic>
        : <String, dynamic>{};
    final payload = (data['data'] ?? data) as Map<String, dynamic>;
    final newAccess =
        (payload['token'] ?? payload['accessToken'] ?? '') as String;
    final newRefresh =
        (payload['refreshToken'] ?? payload['refresh_token'] ?? '') as String;

    if (newAccess.isEmpty) {
      await TokenManager.clearTokens();
      return null;
    }

    // Persist the new tokens
    await TokenManager.saveTokens(
      accessToken: newAccess,
      refreshToken: newRefresh.isEmpty ? null : newRefresh,
    );
    return newAccess;
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
    debugPrint(
      '[HTTP] <= ${response.statusCode} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[HTTP] !! ${err.type} ${err.message} path=${err.requestOptions.path}',
    );
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
