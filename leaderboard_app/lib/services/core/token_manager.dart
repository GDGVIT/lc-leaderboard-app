import 'package:shared_preferences/shared_preferences.dart';

/// Centralized helpers for reading/writing auth tokens.
/// Keys are kept backward compatible with existing code.
class TokenManager {
  static const String _kAccessTokenKey = 'authToken';
  static const String _kRefreshTokenKey = 'refreshToken';

  /// Returns the stored access token (JWT) or null if not set.
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kAccessTokenKey);
    if (token == null || token.isEmpty) return null;
    return token;
  }

  /// Returns the stored refresh token or null if not present.
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kRefreshTokenKey);
    if (token == null || token.isEmpty) return null;
    return token;
  }

  /// Persist both access and optional refresh tokens.
  static Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessTokenKey, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_kRefreshTokenKey, refreshToken);
    }
  }

  /// Update only the access token.
  static Future<void> saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessTokenKey, accessToken);
  }

  /// Update only the refresh token.
  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRefreshTokenKey, refreshToken);
  }

  /// Remove tokens from storage.
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessTokenKey);
    await prefs.remove(_kRefreshTokenKey);
  }
}
