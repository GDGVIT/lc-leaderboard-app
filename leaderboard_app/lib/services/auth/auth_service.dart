import 'package:dio/dio.dart';
import 'package:leaderboard_app/models/auth_models.dart';
import 'package:leaderboard_app/services/core/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leaderboard_app/services/core/dio_provider.dart';

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  static Future<AuthService> create() async {
    final client = await ApiClient.create();
    return AuthService(client.dio);
  }

  Future<AuthResponse> signUp({required String username, required String email, required String password}) async {
    final res = await _dio.post('/auth/signup', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    final response = AuthResponse.fromJson(res.data as Map<String, dynamic>);
    if (response.token.isEmpty) {
      // Some backends do not return JWT on signup; try to login immediately.
      final login = await signIn(email: email, password: password);
      return login;
    } else {
      await _saveAuth(response.token);
      return response;
    }
  }

  Future<AuthResponse> signIn({required String email, required String password}) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final response = AuthResponse.fromJson(res.data as Map<String, dynamic>);
    if (response.token.isEmpty) {
      throw DioException(requestOptions: res.requestOptions, response: res, message: 'Token missing in response');
    }
    await _saveAuth(response.token);
    return response;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear all persisted user-specific data on logout to avoid leaking
    // authentication state or cached profile details between accounts.
    // If in the future some keys should persist across logins (e.g. theme),
    // fetch their values first and re-set them after clear().
    await prefs.clear();
  DioProvider.reset();
    // Also reset any cached singletons that embed auth headers (e.g. Dio).
    try {
      // ignore: avoid_dynamic_calls
      // Access the private singleton via reflection isn't possible; expose a static reset instead if needed.
    } catch (_) {}
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _dio.get('/user/profile');
    return (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  // New: typed user profile fetcher.
  Future<User> getUserProfile() async {
    final res = await _dio.get('/user/profile');
    final body = res.data as Map<String, dynamic>;
    final data = (body['data'] ?? body) as Map<String, dynamic>;
    final userJson = (data['user'] ?? data) as Map<String, dynamic>;
    return User.fromJson(userJson);
  }

  Future<void> _saveAuth(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }
}
