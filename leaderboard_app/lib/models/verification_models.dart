// Models specifically for LeetCode verification endpoints.

class VerificationStart {
  final String verificationCode;
  final String leetcodeUsername;
  final String instructions;
  final int timeoutInSeconds;
  final int pollIntervalInSeconds;

  VerificationStart({
    required this.verificationCode,
    required this.leetcodeUsername,
    required this.instructions,
    required this.timeoutInSeconds,
    required this.pollIntervalInSeconds,
  });

  factory VerificationStart.fromJson(Map<String, dynamic> json) => VerificationStart(
        verificationCode: (json['verificationCode'] ?? '') as String,
        leetcodeUsername: (json['leetcodeUsername'] ?? '') as String,
        instructions: (json['instructions'] ?? '') as String,
        timeoutInSeconds: (json['timeoutInSeconds'] as num?)?.toInt() ?? 0,
        pollIntervalInSeconds: (json['pollIntervalInSeconds'] as num?)?.toInt() ?? 0,
      );
}

class VerificationStatus {
  final bool isVerified;
  final bool isInProgress;
  final String? leetcodeHandle;

  VerificationStatus({
    required this.isVerified,
    required this.isInProgress,
    required this.leetcodeHandle,
  });

  factory VerificationStatus.fromJson(Map<String, dynamic> json) => VerificationStatus(
        isVerified: json['isVerified'] == true,
        isInProgress: json['isInProgress'] == true,
        leetcodeHandle: json['leetcodeHandle'] as String?,
      );
}
