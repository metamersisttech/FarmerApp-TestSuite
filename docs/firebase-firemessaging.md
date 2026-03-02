# Firebase Messaging SDK — Quick Reference

Quick reference for the Firebase Messaging and flutter_local_notifications APIs used in the FarmerApp FCM implementation (`lib/core/services/fcm_service.dart`).

## FirebaseMessaging

Package: `firebase_messaging: ^16.1.0`

### Instance Access

```dart
final FirebaseMessaging _messaging = FirebaseMessaging.instance;
```

Singleton — always use `.instance`, never construct directly.

### requestPermission()

Prompts the user for notification permission (iOS always, Android 13+).

```dart
NotificationSettings settings = await _messaging.requestPermission(
  alert: true,       // Show notification banners
  badge: true,       // Update app icon badge count
  sound: true,       // Play notification sound
  provisional: false // true = silent delivery without prompt (iOS only)
);
```

Returns `NotificationSettings` (see below). On Android < 13, permission is granted at install time and this is a no-op.

### getToken()

Returns the FCM registration token for this device.

```dart
String? token = await _messaging.getToken();
```

- Returns `null` if permission was denied or token generation failed
- Token may change over time (app reinstall, cache clear, server rotation) — listen to `onTokenRefresh`
- Send this token to your backend to target this device for push notifications

### onTokenRefresh

Stream that fires when the FCM token is rotated.

```dart
_messaging.onTokenRefresh.listen((String newToken) {
  // Re-register the new token with your backend
});
```

Common rotation triggers: app data cleared, app restored on new device, server-side invalidation.

### setForegroundNotificationPresentationOptions()

Controls how iOS displays notifications when the app is in the **foreground**. No effect on Android (use flutter_local_notifications instead).

```dart
await _messaging.setForegroundNotificationPresentationOptions(
  alert: true,  // Show notification banner
  badge: true,  // Update badge count
  sound: true,  // Play sound
);
```

### getInitialMessage()

Returns the `RemoteMessage` that caused the app to open from a **terminated** state. Returns `null` if the app was opened normally.

```dart
RemoteMessage? message = await _messaging.getInitialMessage();
if (message != null) {
  // Navigate based on message.data
}
```

Call this once during initialization to handle cold-start deep links.

## FirebaseMessaging Static Streams

### onMessage

Stream of messages received while the app is in the **foreground**.

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // message.notification — title, body
  // message.data — custom payload from backend
});
```

On Android, foreground messages do **not** automatically display a notification — you must show one yourself (via flutter_local_notifications).

### onMessageOpenedApp

Stream that fires when the user taps a notification while the app is in the **background** (not terminated).

```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Navigate based on message.data['notification_type']
});
```

### onBackgroundMessage()

Registers a **top-level** function to handle messages when the app is in the background or terminated. The handler runs in an isolate.

```dart
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Process message (no UI access)
}

// In initialization:
FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
```

Requirements:
- Must be a **top-level function** (not a class method or closure)
- Must have `@pragma('vm:entry-point')` annotation to prevent tree-shaking
- Must call `Firebase.initializeApp()` since it runs in a separate isolate
- Cannot access UI, navigator, or widget state

## RemoteMessage

Represents an incoming FCM message.

### Key Properties

| Property | Type | Description |
|----------|------|-------------|
| `.notification` | `RemoteNotification?` | Notification payload (title, body) — `null` for data-only messages |
| `.data` | `Map<String, dynamic>` | Custom key-value payload from backend |

### RemoteNotification

| Property | Type | Description |
|----------|------|-------------|
| `.title` | `String?` | Notification title |
| `.body` | `String?` | Notification body text |

### Data Payload (FarmerApp-specific)

The backend sends these keys in `message.data`:

| Key | Values | Used for |
|-----|--------|----------|
| `notification_type` | `"message"`, `"appointment"`, `"listing"` | Navigation routing |
| `listing_id` | `"123"` (string) | Deep link to animal detail (listing type only) |

## NotificationSettings

Returned by `requestPermission()`.

### Key Property

| Property | Type | Description |
|----------|------|-------------|
| `.authorizationStatus` | `AuthorizationStatus` | Permission result |

### AuthorizationStatus Enum

| Value | Meaning |
|-------|---------|
| `authorized` | Full permission granted |
| `denied` | User denied permission |
| `notDetermined` | User hasn't been asked yet (iOS) |
| `provisional` | Provisional/quiet permission (iOS) |

---

## flutter_local_notifications (Companion Package)

Package: `flutter_local_notifications: ^18.0.1`

Used to display notifications when the app is in the foreground, since Android does not show FCM notifications automatically in this state.

### FlutterLocalNotificationsPlugin

Main entry point for the plugin.

```dart
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();
```

#### initialize()

```dart
await _localNotifications.initialize(
  const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,  // Already handled by FirebaseMessaging
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  ),
  onDidReceiveNotificationResponse: (NotificationResponse response) {
    // Handle notification tap — response.payload contains the type
  },
);
```

#### show()

Display a local notification.

```dart
_localNotifications.show(
  id,           // int — unique notification ID (we use notification.hashCode)
  title,        // String? — notification title
  body,         // String? — notification body
  details,      // NotificationDetails — platform-specific config
  payload: '',  // String? — passed to onDidReceiveNotificationResponse on tap
);
```

#### createNotificationChannel() (Android)

```dart
await _localNotifications
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
```

### AndroidNotificationChannel

Defines an Android notification channel (required for Android 8+).

```dart
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'farmerapp_notifications',        // id
  'FarmerApp Notifications',        // name
  description: 'Notifications for messages, appointments, and listings',
  importance: Importance.high,      // heads-up notification
);
```

### AndroidNotificationDetails

Per-notification Android display settings.

```dart
AndroidNotificationDetails(
  channelId,              // Must match a created channel
  channelName,
  channelDescription: '', // Optional
  importance: Importance.high,
  priority: Priority.high,
  icon: '@mipmap/ic_launcher',
)
```

### DarwinNotificationDetails

iOS/macOS notification display settings (we use defaults).

```dart
const DarwinNotificationDetails()
```

### DarwinInitializationSettings

iOS initialization settings.

```dart
const DarwinInitializationSettings(
  requestAlertPermission: false,  // Don't re-request (Firebase already did)
  requestBadgePermission: false,
  requestSoundPermission: false,
)
```

### NotificationResponse

Passed to `onDidReceiveNotificationResponse` when the user taps a local notification.

| Property | Type | Description |
|----------|------|-------------|
| `.payload` | `String?` | The payload string passed to `show()` |
| `.id` | `int?` | The notification ID |

---

## Platform Setup Notes

### Android

1. **Google Services plugin** — `android/app/build.gradle.kts`:
   ```kotlin
   plugins {
       id("com.google.gms.google-services")
   }
   ```

2. **Firebase BoM** — `android/app/build.gradle.kts` dependencies:
   ```kotlin
   implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
   implementation("com.google.firebase:firebase-analytics")
   ```

3. **POST_NOTIFICATIONS permission** — `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
   ```

4. **google-services.json** — downloaded from Firebase Console, placed at `android/app/google-services.json`

### iOS

1. **GoogleService-Info.plist** — downloaded from Firebase Console, added to `ios/Runner/` via Xcode (not just file copy — must be in the Xcode project target)

2. **APNs setup** — required for FCM on iOS:
   - Enable "Push Notifications" capability in Xcode
   - Upload APNs authentication key (`.p8`) or certificate to Firebase Console > Project Settings > Cloud Messaging

3. **Background Modes** — enable in Xcode:
   - "Remote notifications" background mode

4. **Info.plist** — no additional keys needed (firebase_messaging handles registration)
