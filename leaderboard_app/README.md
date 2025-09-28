# leaderboard_app

Flutter application with backend integration using `dio` + `retrofit` for typed HTTP APIs.

## Backend Integration

We use:

* `dio` for HTTP transport, interceptors, timeouts.
* `retrofit` for declarative REST interface generation (`lib/services/core/rest_client.dart`).
* `build_runner` + `retrofit_generator` (and `json_serializable` if/when model code generation is added).

### Generating code

Run code generation after updating API interface annotations:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Using the REST client

```dart
import 'package:leaderboard_app/services/core/dio_provider.dart';
import 'package:leaderboard_app/services/core/rest_client.dart';

final dio = await DioProvider.getInstance();
final api = RestClient(dio);

final start = await api.startVerification({'leetcodeUsername': 'someUser'});
final status = await api.getVerificationStatus('someUser');
```

Auth tokens (JWT) are automatically attached from `SharedPreferences` via an interceptor in `DioProvider`.

### Environment / Base URL

Centralized in `lib/config/api_config.dart`.

Default baked-in base URL (when no override is supplied):

```
http://140.238.213.170:3002/api
```

Override at build/run time:

```bash
flutter run --dart-define=API_BASE_URL=https://your.api.host/api
```

Release / CI example:

```bash
flutter build apk --dart-define=API_BASE_URL=https://prod.api.host/api
```

Trailing slashes are trimmed automatically. Keep `/api` if your backend routes are under that prefix.

### Adding new endpoints

1. Edit `lib/services/core/rest_client.dart` – add a method with appropriate HTTP verb annotation.
2. Run the build command above to regenerate `rest_client.g.dart`.
3. Consume the new method from services or providers.

### Logging & Retry

`DioProvider` adds a lightweight log interceptor and simple retry (only once) for idempotent GET requests on connection errors.

---

Generated code (`rest_client.g.dart`) should not be manually edited.

## Building a Release APK / Sharing the App

1. (Optional) Override the API base URL at build time (recommended for different envs):

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://prod.api.host/api
```

If you omit `--dart-define` the baked-in default from `ApiConfig` is used.

2. The unsigned release APK will be at:

```
build\app\outputs\flutter-apk\app-release.apk
```

3. (Recommended) Create a keystore and configure signing in `android/key.properties` + `build.gradle` to avoid Play Store rejection and to allow in-place upgrades.

### Example keystore creation (run once)

```bash
keytool -genkey -v -keystore my-release-key.keystore -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

Place the keystore under `android/` (never commit to VCS) and add a `key.properties`:

```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../my-release-key.keystore
```

Then update `android/app/build.gradle` signingConfigs + buildTypes (if not already present).

### Distributing for quick tests

You can directly share `app-release.apk` with testers (they must enable install from unknown sources). For Play Store publishing prefer an AAB:

```bash
flutter build appbundle --dart-define=API_BASE_URL=https://prod.api.host/api
```

## Troubleshooting: "Cannot reach server. Check BASE_URL..."

This message originates from `ErrorUtils.fromDio` when the `DioExceptionType.connectionError` occurs. Common causes:

| Cause | Fix |
|-------|-----|
| Device has no internet | Ensure Wi‑Fi/data works (open a website) |
| Backend URL wrong or down | Open the URL in mobile Chrome to verify response |
| Using `localhost` / private IP not reachable externally | Use a public/stable host or expose via tunneling (ngrok, Cloudflare) |
| HTTP blocked (if you switch to HTTPS only) | Ensure correct scheme in `API_BASE_URL` |
| Missing INTERNET permission | Manifest now includes `<uses-permission android:name="android.permission.INTERNET" />` |

To quickly verify the URL the app is using, add a temporary log:

```dart
print('API base URL: ' + ApiConfig.baseUrl);
```

Or run with an override:

```bash
flutter run --release --dart-define=API_BASE_URL=https://your-temp-api/api
```

If the backend uses a self-signed certificate, Android may reject it—use a valid cert (Let's Encrypt) for production.

## Future Enhancements (Optional)

* Add build flavors: dev / staging / prod with per-flavor `--dart-define` presets.
* Add environment banner in-app for non-prod.
* Implement exponential backoff retries for transient network errors.
* Add Sentry or similar for error monitoring.

