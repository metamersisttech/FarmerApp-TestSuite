/// FCM Push Notification Service
///
/// Singleton service handling Firebase Cloud Messaging:
/// - Permission requests (iOS + Android 13+)
/// - Token management (register/unregister with backend)
/// - Foreground notification display via flutter_local_notifications
/// - Notification tap navigation
library;

import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/messaging/models/conversation_model.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/main.dart' show navigatorKey;
import 'package:flutter_app/routes/app_routes.dart';

/// Top-level background message handler (required by Firebase)
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // No-op: Android/iOS handle display automatically for background messages
}

/// FCM Service — manages push notifications
class FCMService {
  // Singleton
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  // Dependencies
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final CommonHelper _commonHelper = CommonHelper();
  final BackendHelper _backendHelper = BackendHelper();

  // Local notifications plugin for foreground display
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android notification channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'farmerapp_notifications',
    'FarmerApp Notifications',
    description: 'Notifications for messages, appointments, and listings',
    importance: Importance.high,
  );

  /// Initialize — call once from main.dart after Firebase.initializeApp()
  Future<void> initialize() async {
    // 1. Request notification permission (iOS + Android 13+)
    await _requestPermission();

    // 2. Set up foreground notification presentation (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Initialize flutter_local_notifications for foreground display
    await _initLocalNotifications();

    // 4. Set up message handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 5. Check for notification that launched the app (terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleNotificationTap(initialMessage);

    // 6. Set background message handler (top-level function)
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // 7. Listen for token refresh
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    print('✅ FCM service initialized');
  }

  /// Register FCM token with backend — call after login or on app start if authenticated
  Future<void> registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      print('🔑 FCM token generated: $token');

      // Store locally for unregister on logout
      await _commonHelper.setFcmToken(token);

      // Register with backend (retries on transient failures)
      await _registerWithRetry(token);
    } catch (_) {
      // Non-critical — don't fail login if this fails
      print('⚠️ FCM token registration failed (non-critical)');
    }
  }

  /// Unregister FCM token — call before logout
  Future<void> unregisterToken() async {
    final token = await _commonHelper.getFcmToken();
    if (token == null) return;

    try {
      await _backendHelper.postFcmUnregister({'token': token});
      print('✅ FCM token unregistered');
    } catch (_) {
      // Non-critical
    }
    await _commonHelper.clearFcmToken();
  }

  // ============ Private Methods ============

  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('📱 Notification permission: ${settings.authorizationStatus}');
  }

  /// Initialize flutter_local_notifications for foreground display
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create the Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// Handle foreground message — show local notification
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // Store the entire data as JSON string instead of just notification_type
      payload: _encodePayload(message.data),
    );
  }

  /// Encode notification data as payload string
  String _encodePayload(Map<String, dynamic> data) {
    // Create a simple string format: type|key1=value1|key2=value2
    final parts = <String>[];
    data.forEach((key, value) {
      parts.add('$key=$value');
    });
    return parts.join('|');
  }

  /// Decode payload string back to map
  Map<String, dynamic> _decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) return {};
    final data = <String, dynamic>{};
    final parts = payload.split('|');
    for (final part in parts) {
      final keyValue = part.split('=');
      if (keyValue.length == 2) {
        data[keyValue[0]] = keyValue[1];
      }
    }
    return data;
  }

  /// Handle notification tap (app in background → opened)
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['notification_type'];
    _navigateByType(type, data); // Fire and forget
  }

  /// Handle local notification tap (foreground notification tapped)
  void _onLocalNotificationTap(NotificationResponse response) {
    final data = _decodePayload(response.payload);
    final type = data['notification_type'];
    _navigateByType(type, data); // Fire and forget
  }

  /// Navigate based on notification type
  Future<void> _navigateByType(String? type, Map<String, dynamic> data) async {
    // Wait for navigator to be ready if context is not available yet
    BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      // Wait up to 3 seconds for the app to initialize
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        context = navigatorKey.currentContext;
        if (context != null) break;
      }
      if (context == null) {
        print('⚠️ Navigation context not available after waiting');
        return;
      }
    }

    switch (type) {
      case 'direct_message':
        final conversationId = int.tryParse(data['conversation_id']?.toString() ?? '');
        if (conversationId != null) {
          await _navigateToDirectChat(context, conversationId);
        } else {
          Navigator.pushNamed(context, AppRoutes.conversations);
        }
        break;
      case 'appointment_message':
        final appointmentId = int.tryParse(data['appointment_id']?.toString() ?? '');
        if (appointmentId != null) {
          await _navigateToAppointmentChat(context, appointmentId);
        } else {
          Navigator.pushNamed(context, AppRoutes.myAppointments);
        }
        break;
      case 'appointment_created':
      case 'appointment_approved':
      case 'appointment_rejected':
      case 'appointment_completed':
        final appointmentId = int.tryParse(data['appointment_id']?.toString() ?? '');
        if (appointmentId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.appointmentDetail,
            arguments: appointmentId,
          );
        } else {
          Navigator.pushNamed(context, AppRoutes.myAppointments);
        }
        break;
      case 'new_bid':
        final listingId = int.tryParse(data['listing_id']?.toString() ?? '');
        if (listingId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.listingBids,
            arguments: listingId,
          );
        }
        break;
      case 'bid_approved':
      case 'bid_rejected':
        final listingId = int.tryParse(data['listing_id']?.toString() ?? '');
        if (listingId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.animalDetail,
            arguments: listingId,
          );
        }
        break;
    }
  }

  /// Navigate to direct chat by fetching conversation details
  Future<void> _navigateToDirectChat(BuildContext context, int conversationId) async {
    try {
      final response = await _backendHelper.getConversationById(conversationId);
      final conversation = Conversation.fromJson(response);
      Navigator.pushNamed(
        context,
        AppRoutes.directChat,
        arguments: conversation,
      );
    } catch (e) {
      print('⚠️ Failed to load conversation: $e');
      Navigator.pushNamed(context, AppRoutes.conversations);
    }
  }

  /// Navigate to appointment chat by fetching appointment details
  Future<void> _navigateToAppointmentChat(BuildContext context, int appointmentId) async {
    try {
      final response = await _backendHelper.getAppointmentById(appointmentId);
      final appointment = AppointmentModel.fromJson(response);
      Navigator.pushNamed(
        context,
        AppRoutes.appointmentChat,
        arguments: appointment,
      );
    } catch (e) {
      print('⚠️ Failed to load appointment: $e');
      Navigator.pushNamed(context, AppRoutes.myAppointments);
    }
  }

  /// Handle token refresh — re-register with backend
  void _onTokenRefresh(String newToken) async {
    await _commonHelper.setFcmToken(newToken);
    await _registerWithRetry(newToken);
  }

  /// Register FCM token with exponential backoff retry
  Future<void> _registerWithRetry(String token, {int maxAttempts = 3}) async {
    const baseDelay = Duration(seconds: 2);
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final deviceType = Platform.isIOS ? 'ios' : 'android';
        print('📤 Sending FCM token to API: $token, device_type: $deviceType');
        await _backendHelper.postFcmRegister({
          'token': token,
          'device_type': deviceType,
        });
        print('✅ FCM token registered: ${token.substring(0, 20)}...');
        return;
      } catch (_) {
        if (attempt == maxAttempts) {
          print('⚠️ FCM token registration failed after $maxAttempts attempts');
          return;
        }
        final delay = baseDelay * (1 << (attempt - 1));
        print('⚠️ FCM register attempt $attempt failed, retrying in ${delay.inSeconds}s...');
        await Future.delayed(delay);
      }
    }
  }
}
