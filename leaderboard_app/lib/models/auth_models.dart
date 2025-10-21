class AuthResponse {
  final bool success;
  final String message;
  final String token;
  final String? refreshToken;
  final User user;

  AuthResponse({
    required this.success,
    required this.message,
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? {}) as Map<String, dynamic>;
    final userJson = (data['user'] ?? json['user'] ?? {}) as Map<String, dynamic>;
    final token = (data['token'] ?? json['token'] ?? '') as String;
    final refresh = (data['refreshToken'] ?? data['refresh_token'] ?? json['refreshToken'] ?? json['refresh_token'] ?? '') as String;
    return AuthResponse(
      success: json['success'] == true || json['ok'] == true,
      message: (json['message'] ?? json['msg'] ?? '') as String,
      token: token,
      refreshToken: refresh.isEmpty ? null : refresh,
      user: User.fromJson(userJson),
    );
  }
}

class User {
  final String id;
  final String username;
  final String? email;
  final String? leetcodeHandle;
  final bool leetcodeVerified;
  final int streak;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.leetcodeHandle,
    required this.leetcodeVerified,
    required this.streak,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
  id: (json['id'] ?? json['_id'] ?? '').toString(),
      username: json['username'] ?? '',
      email: json['email'],
      leetcodeHandle: json['leetcodeHandle'],
      leetcodeVerified: json['leetcodeVerified'] == true,
  streak: (json['streak'] is int) ? json['streak'] as int : int.tryParse('${json['streak'] ?? 0}') ?? 0,
    );
  }
}
