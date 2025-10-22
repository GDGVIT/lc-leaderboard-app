import 'package:dio/dio.dart';
import 'package:leeterboard/services/core/api_client.dart';

class LeetCodeService {
  final Dio _dio;
  LeetCodeService(this._dio);

  static Future<LeetCodeService> create() async {
    final client = await ApiClient.create();
    return LeetCodeService(client.dio);
  }

  Future<StartVerificationResponse> startVerification(String username) async {
    final res = await _dio.post(
      '/leetcode/connect',
      data: {'leetcodeUsername': username},
    );
    final body = res.data as Map<String, dynamic>;
    final data = (body['data'] ?? body) as Map<String, dynamic>;
    return StartVerificationResponse.fromJson(data);
  }

  Future<LeetCodeVerificationStatus> getStatus() async {
    final res = await _dio.get('/leetcode/status');
    final body = res.data as Map<String, dynamic>;
    final data = (body['data'] ?? body) as Map<String, dynamic>;
    return LeetCodeVerificationStatus.fromJson(data);
  }
}

class LeetCodeVerificationStatus {
  final bool isVerified;
  final bool isInProgress;
  final String? leetcodeHandle;

  LeetCodeVerificationStatus({
    required this.isVerified,
    required this.isInProgress,
    required this.leetcodeHandle,
  });

  factory LeetCodeVerificationStatus.fromJson(Map<String, dynamic> json) {
    return LeetCodeVerificationStatus(
      isVerified: json['isVerified'] == true,
      isInProgress: json['isInProgress'] == true,
      leetcodeHandle: json['leetcodeHandle'] as String?,
    );
  }
}

class StartVerificationResponse {
  final String verificationCode;
  final String leetcodeUsername;
  final int? timeoutInSeconds;
  final int? pollIntervalInSeconds;
  final String? instructions;

  StartVerificationResponse({
    required this.verificationCode,
    required this.leetcodeUsername,
    this.timeoutInSeconds,
    this.pollIntervalInSeconds,
    this.instructions,
  });

  factory StartVerificationResponse.fromJson(Map<String, dynamic> json) {
    return StartVerificationResponse(
      verificationCode: (json['verificationCode'] ?? '') as String,
      leetcodeUsername: (json['leetcodeUsername'] ?? '') as String,
      timeoutInSeconds: (json['timeoutInSeconds'] as num?)?.toInt(),
      pollIntervalInSeconds: (json['pollIntervalInSeconds'] as num?)?.toInt(),
      instructions: json['instructions'] as String?,
    );
  }
}
