# FCM Push Notifications — Implementation Guide

## Overview

The FarmerApp uses Firebase Cloud Messaging (FCM) to deliver push notifications for:

- **Messages** — New buyer-seller direct messages
- **Appointments** — Vet appointment status changes
- **Listings** — Updates to animal listings

Notifications work in all three app states: foreground (local notification banner), background (system tray), and terminated (cold-start deep link).

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Token Lifecycle                              │
│                                                                     │
│  Firebase SDK                                                       │
│      │                                                              │
│      ▼                                                              │
│  FCMService.registerToken()                                         │
│      │                                                              │
│      ├──► CommonHelper.setFcmToken()   (FlutterSecureStorage)       │
│      │                                                              │
│      └──► BackendHelper.postFcmRegister()                           │
│               │                                                     │
│               ▼                                                     │
│           POST /api/fcm/register/  ──►  Django backend              │
│                                                                     │
│  On logout:                                                         │
│  FCMService.unregisterToken()                                       │
│      │                                                              │
│      ├──► BackendHelper.postFcmUnregister()                         │
│      │        │                                                     │
│      │        ▼                                                     │
│      │    POST /api/fcm/unregister/  ──►  Django backend            │
│      │                                                              │
│      └──► CommonHelper.clearFcmToken()                              │
└─────────────────────────────────────────────────────────────────────┘
```

## FCMService

**File:** `lib/core/services/fcm_service.dart`

Singleton service that owns all FCM logic. Access via `FCMService()`.

### `initialize()`

Called once from `main.dart` after `Firebase.initializeApp()`. Runs a 7-step setup:

| Step | What it does |
|------|-------------|
| 1 | `requestPermission()` — iOS + Android 13+ notification prompt |
| 2 | `setForegroundNotificationPresentationOptions()` — iOS foreground display (alert, badge, sound) |
| 3 | `_initLocalNotifications()` — flutter_local_notifications plugin + Android channel |
| 4 | `onMessage.listen()` — foreground message handler |
|   | `onMessageOpenedApp.listen()` — background-tap handler |
| 5 | `getInitialMessage()` — check for cold-start notification |
| 6 | `onBackgroundMessage()` — register top-level background handler |
| 7 | `onTokenRefresh.listen()` — re-register on token rotation |

### `registerToken()`

Gets the FCM token from Firebase, stores it locally, and sends it to the backend with retry.

```dart
Future<void> registerToken() async {
  final token = await _messaging.getToken();
  if (token == null) return;

  await _commonHelper.setFcmToken(token);       // local storage
  await _registerWithRetry(token);               // backend API
}
```

Called as fire-and-forget (no `await` at call site) from:
- `main.dart:59` — app startup if already authenticated
- `email_login_service.dart:87` — after email login
- `otp_handler_service.dart:113` — after OTP login

### `unregisterToken()`

Reads the stored token, tells the backend to remove it, then clears local storage.

```dart
Future<void> unregisterToken() async {
  final token = await _commonHelper.getFcmToken();
  if (token == null) return;

  await _backendHelper.postFcmUnregister({'token': token});
  await _commonHelper.clearFcmToken();
}
```

Called (awaited) from:
- `profile_service.dart:178` — farmer logout, in `finally` block
- `vet_dashboard_profile_page.dart:96` — vet dashboard logout dialog

### `_registerWithRetry()`

Exponential backoff: 3 attempts with 2s, 4s, 8s delays between retries.

```dart
Future<void> _registerWithRetry(String token, {int maxAttempts = 3}) async {
  const baseDelay = Duration(seconds: 2);
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      final deviceType = Platform.isIOS ? 'ios' : 'android';
      await _backendHelper.postFcmRegister({
        'token': token,
        'device_type': deviceType,
      });
      return; // success
    } catch (_) {
      if (attempt == maxAttempts) return; // give up silently
      final delay = baseDelay * (1 << (attempt - 1)); // 2s, 4s, 8s
      await Future.delayed(delay);
    }
  }
}
```

### Notification Handling

**Foreground** — `_handleForegroundMessage()` displays a local notification via `flutter_local_notifications`. The payload is set to `message.data['notification_type']`.

**Background tap** — `_handleNotificationTap()` reads `notification_type` and `listing_id` from `message.data` and navigates.

**Local notification tap** — `_onLocalNotificationTap()` reads the type from `response.payload`.

### Navigation Routing

`_navigateByType()` uses the global `navigatorKey` to push named routes:

| `notification_type` | Route | Arguments |
|---------------------|-------|-----------|
| `message` | `AppRoutes.conversations` | — |
| `appointment` | `AppRoutes.myAppointments` | — |
| `listing` | `AppRoutes.animalDetail` | `listingId` (int, parsed from `data['listing_id']`) |

### Android Notification Channel

```dart
static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'farmerapp_notifications',        // id
  'FarmerApp Notifications',        // name
  description: 'Notifications for messages, appointments, and listings',
  importance: Importance.high,
);
```

### Background Handler

Top-level function required by Firebase (cannot be a class method):

```dart
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // No-op: Android/iOS handle display automatically for background messages
}
```

## API Endpoints

**File:** `lib/core/constants/api_endpoints.dart` (lines 95-99)

| Constant | Path | Status |
|----------|------|--------|
| `fcmRegister` | `fcm/register/` | Wired up |
| `fcmUnregister` | `fcm/unregister/` | Wired up |
| `fcmTokens` | `fcm/tokens/` | Defined, not wired |
| `fcmTest` | `fcm/test/` | Defined, not wired |

### Register — `POST /api/fcm/register/`

```json
{
  "token": "<fcm-registration-token>",
  "device_type": "android" | "ios"
}
```

### Unregister — `POST /api/fcm/unregister/`

```json
{
  "token": "<fcm-registration-token>"
}
```

## Backend Helper

**File:** `lib/core/helpers/backend_helper.dart` (lines 879-908)

| Method | Endpoint |
|--------|----------|
| `postFcmRegister(Map data)` | `POST /api/fcm/register/` |
| `postFcmUnregister(Map data)` | `POST /api/fcm/unregister/` |

Both follow the standard BackendHelper pattern: call `_client.post()`, catch `DioException`, throw `BackendException`.

## Token Storage

**File:** `lib/core/helpers/common_helper.dart` (lines 113-128)

| Method | What it does |
|--------|-------------|
| `setFcmToken(String token)` | Writes to FlutterSecureStorage key `fcm_token` |
| `getFcmToken()` | Reads from FlutterSecureStorage key `fcm_token` |
| `clearFcmToken()` | Deletes the `fcm_token` key |

`clearAll()` (line 107-111) also deletes the `fcm_token` key, ensuring it's wiped on logout even if `unregisterToken()` fails.

## Integration Points

### App Startup — `lib/main.dart`

```dart
// Line 28: Firebase init
await Firebase.initializeApp();

// Line 52: FCM init (permissions, handlers, channels)
await FCMService().initialize();

// Lines 56-61: Register token if already logged in
if (user != null) {
  final token = await commonHelper.getAccessToken();
  if (token != null) {
    FCMService().registerToken(); // fire-and-forget
  }
}
```

### Email Login — `lib/features/auth/services/email_login_service.dart`

```dart
// Line 87: After saving auth data
FCMService().registerToken(); // fire-and-forget
```

### OTP Login — `lib/features/auth/services/otp_handler_service.dart`

```dart
// Line 113: After saving auth data
FCMService().registerToken(); // fire-and-forget
```

### Farmer Logout — `lib/features/profile/services/profile_service.dart`

```dart
// Line 178: In finally block of logout()
await FCMService().unregisterToken();
// Line 181: Then clears all auth data
await _commonHelper.clearAll();
```

### Vet Dashboard Logout — `lib/features/vet_dashboard/screens/vet_dashboard_profile_page.dart`

```dart
// Line 96: In logout dialog onPressed
await FCMService().unregisterToken();
// Line 98: Then clears all auth data
await CommonHelper().clearAll();
```

## Platform Configuration

### Android

| Item | Location | Value |
|------|----------|-------|
| Google Services config | `android/app/google-services.json` | Present |
| Google Services plugin | `android/app/build.gradle.kts` line 6 | `com.google.gms.google-services` |
| Firebase BoM | `android/app/build.gradle.kts` line 14 | `com.google.firebase:firebase-bom:34.6.0` |
| Notification permission | `android/app/src/main/AndroidManifest.xml` | `android.permission.POST_NOTIFICATIONS` |

### iOS

| Item | Location | Status |
|------|----------|--------|
| GoogleService-Info.plist | `ios/Runner/GoogleService-Info.plist` | **MISSING — TODO** |
| APNs configuration | Apple Developer Console | Not configured yet |

## Dependencies

From `pubspec.yaml`:

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | `^4.2.1` | Firebase initialization |
| `firebase_messaging` | `^16.1.0` | FCM token management, message streams |
| `flutter_local_notifications` | `^18.0.1` | Foreground notification display |
| `flutter_secure_storage` | `^9.2.0` | Encrypted FCM token storage |

## Debug Prints

Current debug print statements (remove before production):

| Location | Print | Purpose |
|----------|-------|---------|
| `initialize()` line 82 | `FCM service initialized` | Confirms init completed |
| `_requestPermission()` line 127 | `Notification permission: {status}` | Shows permission result |
| `registerToken()` line 90 | `FCM token generated: {token}` | Full token (sensitive!) |
| `registerToken()` line 99 | `FCM token registration failed (non-critical)` | Catch-all failure |
| `_registerWithRetry()` line 231 | `Sending FCM token to API: {token}...` | API call debug |
| `_registerWithRetry()` line 236 | `FCM token registered: {first 20 chars}...` | Success confirmation |
| `_registerWithRetry()` line 240 | `FCM token registration failed after N attempts` | Max retries exhausted |
| `_registerWithRetry()` line 244 | `FCM register attempt N failed, retrying in Ns...` | Retry backoff |
| `unregisterToken()` line 110 | `FCM token unregistered` | Unregister success |
