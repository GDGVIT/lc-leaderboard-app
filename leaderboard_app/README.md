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

