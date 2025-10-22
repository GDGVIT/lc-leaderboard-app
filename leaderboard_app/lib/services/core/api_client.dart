import 'package:dio/dio.dart';
import 'package:leeterboard/config/api_config.dart';
import 'package:leeterboard/services/core/dio_provider.dart';

class ApiClient {
  static final String kBaseUrl = ApiConfig.baseUrl;
  final Dio dio;

  ApiClient._internal(this.dio);

  static Future<ApiClient> create({String? baseUrl}) async {
    final dio = await DioProvider.getInstance(baseUrl: baseUrl ?? kBaseUrl);
    return ApiClient._internal(dio);
  }
}
