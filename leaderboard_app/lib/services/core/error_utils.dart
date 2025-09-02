import 'package:dio/dio.dart';

class ErrorUtils {
  static String fromDio(Object error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message'] ?? data['error'] ?? data['msg'];
        if (msg is String && msg.isNotEmpty) {
          return code != null ? '($code) $msg' : msg;
        }
      } else if (data is String && data.isNotEmpty) {
        return code != null ? '($code) $data' : data;
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Network timeout. Please try again.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Cannot reach server. Check BASE_URL and that the backend is running.';
      }
      return code != null ? 'Request failed ($code)' : 'Request failed';
    }
    return 'Unexpected error';
  }
}
