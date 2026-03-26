import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:empleame/providers/providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background message handler — must be a top-level function.
// FCM calls this when the app is terminated or in background.
// The system tray notification is shown automatically by FCM on Android.
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No UI work here — app may not be running.
  debugPrint('NotificationService [BG]: ${message.messageId}');
}

/// Channel used for foreground local notifications on Android.
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel',
  'Notificaciones Importantes',
  description: 'Notificaciones de cambio de estado de servicios.',
  importance: Importance.high,
);

/// Centralized service for Firebase Cloud Messaging.
///
/// Responsibilities:
/// - Request push-notification permissions
/// - Register and persist FCM tokens in Firestore
/// - Show foreground notifications via [flutter_local_notifications]
/// - Navigate to the correct screen on notification tap
/// - Respect the user's [isMuted] preference
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifs =
      FlutterLocalNotificationsPlugin();

  /// GoRouter navigator key — set by [initialize].
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Riverpod container ref — set by [initialize] for reading providers.
  ProviderContainer? _container;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Must be called once in [main] after Firebase.initializeApp().
  Future<void> initialize({
    required ProviderContainer container,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    _container = container;
    _navigatorKey = navigatorKey;

    // Register background handler before anything else.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permissions (Android 13+ and iOS both need this).
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // On Android, FCM does NOT auto-show notifications when app is in
    // foreground — we must do it ourselves via flutter_local_notifications.
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    // Initialize local notifications plugin.
    await _initLocalNotifications();

    // Handle messages while app is open (foreground).
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle tap when app was in background (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Handle tap when app was terminated.
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      // Delay to let the app fully initialize before navigating.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToService(initialMessage.data['serviceId']);
      });
    }
  }

  /// Saves (or updates) the current FCM token for [uid] in Firestore.
  /// Also sets up a listener for token refreshes.
  Future<void> saveToken(String uid) async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _persistToken(uid, token);
    }

    // Listen for token rotation (e.g. app re-installed, cache cleared).
    _fcm.onTokenRefresh.listen((newToken) => _persistToken(uid, newToken));
  }

  /// Deletes the current device's FCM token from Firestore on sign-out.
  Future<void> deleteToken(String uid) async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;

      // Find the matching token document and delete it.
      final snapshot = await FirebaseFirestore.instance
          .collection('users/$uid/tokens')
          .where('token', isEqualTo: token)
          .limit(1)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Also invalidate the token on the FCM side.
      await _fcm.deleteToken();
    } catch (e) {
      debugPrint('NotificationService: deleteToken error: $e');
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifs.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Tap on local notification while app is in foreground.
        final serviceId = response.payload;
        _navigateToService(serviceId);
      },
    );

    // Create the high-importance channel on Android 8+.
    if (Platform.isAndroid) {
      await _localNotifs
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  /// Called when a message arrives while the app is in the foreground.
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    // Respect the user's isMuted preference.
    if (await _isUserMuted()) return;

    final notification = message.notification;
    if (notification == null) return;

    final serviceId = message.data['serviceId'] as String?;

    await _localNotifs.show(
      message.hashCode,
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
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: serviceId,
    );
  }

  /// Called when user taps a notification while the app was in background.
  void _onMessageOpenedApp(RemoteMessage message) {
    final serviceId = message.data['serviceId'] as String?;
    _navigateToService(serviceId);
  }

  void _navigateToService(String? serviceId) {
    if (serviceId == null || serviceId.isEmpty) return;
    final context = _navigatorKey?.currentContext;
    if (context != null) {
      GoRouter.of(context).push('/service-detail/$serviceId');
    }
  }

  /// Saves a token document under users/{uid}/tokens/{tokenId}.
  /// Uses the token value itself as the document ID to avoid duplicates.
  Future<void> _persistToken(String uid, String token) async {
    final platform = Platform.isAndroid ? 'android' : 'ios';
    await FirebaseFirestore.instance
        .collection('users/$uid/tokens')
        .doc(token)
        .set({
      'token': token,
      'platform': platform,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    debugPrint('NotificationService: token saved for uid=$uid');
  }

  /// Returns true if the currently signed-in user has isMuted = true.
  Future<bool> _isUserMuted() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;
      final userStream = _container?.read(currentUserStreamProvider);
      final user = userStream?.valueOrNull;
      return user?.isMuted ?? false;
    } catch (_) {
      return false;
    }
  }
}
