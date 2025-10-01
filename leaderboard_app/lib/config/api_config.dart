// Centralized API configuration for backend base URL.

/// Priority order:
/// 1. Compile-time override via --dart-define=API_BASE_URL=...
/// 2. Baked-in default (production/dev fallback): http://140.238.213.170:3002/api
///
/// If you need per-platform localhost behavior again, reintroduce the previous
/// logic or create an Environment enum.
class ApiConfig {
  static const String _dartDefineBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Returns the base URL (without trailing slash) to use for HTTP requests.
  static String get baseUrl {
    if (_dartDefineBaseUrl.isNotEmpty) return _dartDefineBaseUrl.rstrip('/');
    return 'http://140.238.213.170:3002/api';
  }
}

extension _StringTrim on String {
  String rstrip([String pattern = '/']) {
    if (isEmpty) return this;
    var result = this;
    while (result.endsWith(pattern)) {
      result = result.substring(0, result.length - pattern.length);
    }
    return result;
  }
}
