# Dinelify — Mobile App

Flutter client for the Dinelify food ordering platform. Talks to the Laravel API in `../dinelify-api`.

## Architecture

```
lib/
 core/        constants (Env), network (Dio + interceptors), storage (secure token), theme, utils, widgets
 data/        models, services (raw Dio calls), repositories (used by providers/screens)
 features/    auth, dashboard, menu, orders, profile, notifications — each with screens/ and providers/
 routes/      go_router config + auth-guarded redirects
 main.dart
```

State management: Riverpod (no codegen — plain `Provider` / `StateNotifierProvider` / `FutureProvider`).
Networking: Dio, with a single interceptor that attaches the bearer token and clears the session on 401.
Auth token storage: `flutter_secure_storage` only — never `SharedPreferences`.

## Environments

No API URL is hardcoded. Each environment is a JSON file under `env/`:

- `env/local.json` — intentionally omits `API_BASE_URL`. `Env.apiBaseUrl` (in `lib/core/constants/env.dart`) picks the right local address automatically based on the platform it's compiled for: `http://10.0.2.2:8000/api` (the Android emulator's alias for your host machine's `localhost:8000`) when running as an Android app, or `http://localhost:8000/api` when running on Flutter Web. This means the same `env/local.json` works for both `flutter run` (Android) and `flutter run -d chrome` — no manual switching between env files. `10.0.2.2` only resolves on the Android **emulator** — a real/physical device can't reach it, so API calls (locations, rooms, etc.) fail silently there unless you use `env/local_device.json` below.
- `env/local_device.json` — for a **real Android device connected over USB**. Run `adb reverse tcp:8000 tcp:8000` once per USB connection (forwards the device's `localhost:8000` to your host's Laravel server), then run with this file so `API_BASE_URL` points at `http://127.0.0.1:8000/api` instead of the emulator-only `10.0.2.2`. (`adb reverse` needs to be re-run after unplugging/replugging the device or restarting adb.) If you're not on USB, an alternative is to set `API_BASE_URL` in a copy of this file to your host machine's LAN IP instead of using `adb reverse`.
- `env/qa.json` and `env/production.json` set `API_BASE_URL` explicitly and are unaffected by the platform-based default.

Run with a given environment via `--dart-define-from-file`:

```bash
flutter run --dart-define-from-file=env/local.json          # Android emulator -> 10.0.2.2
adb reverse tcp:8000 tcp:8000                                # once per USB connection
flutter run --dart-define-from-file=env/local_device.json   # Real Android device (USB) -> 127.0.0.1
flutter run -d chrome --dart-define-from-file=env/local.json # Chrome -> localhost
flutter run --dart-define-from-file=env/qa.json
flutter build apk --dart-define-from-file=env/production.json
```

## Running locally

1. Start the Laravel API (see `../dinelify-api/README.md`), e.g. `php artisan serve`.
2. `flutter pub get`
3. `flutter run --dart-define-from-file=env/local.json`

A seeded demo account exists for quick testing: mobile `9999999999` (OTP is echoed back in the `send-otp` response body as `debug_otp` whenever `APP_ENV` isn't `production`).

## Testing

```bash
flutter analyze
flutter test
```
