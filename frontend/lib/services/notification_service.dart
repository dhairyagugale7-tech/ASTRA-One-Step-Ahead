import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';


// ============================================================
// BACKGROUND FCM HANDLER
// ============================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  debugPrint(
    'ASTRA FCM: Background message received.',
  );

  debugPrint(
    'ASTRA FCM: Message ID = ${message.messageId}',
  );

  debugPrint(
    'ASTRA FCM: Data = ${message.data}',
  );
}


// ============================================================
// NOTIFICATION SERVICE
// ============================================================

class NotificationService {
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FlutterLocalNotificationsPlugin
      _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<User?>? _authSubscription;

  StreamSubscription<String>? _tokenSubscription;

  StreamSubscription<RemoteMessage>? _messageSubscription;

  StreamSubscription<RemoteMessage>?
      _messageOpenedSubscription;


  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    debugPrint(
      'ASTRA FCM: Initializing...',
    );

    // ----------------------------------------------------------
    // Register background message handler
    // ----------------------------------------------------------

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );


    // ----------------------------------------------------------
    // Request notification permission
    // ----------------------------------------------------------

    final settings =
        await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'ASTRA FCM: Permission status = '
      '${settings.authorizationStatus}',
    );


    // ----------------------------------------------------------
    // Initialize local notifications
    // ----------------------------------------------------------

    await _initializeLocalNotifications();


    // ----------------------------------------------------------
    // Create SOS notification channel
    // ----------------------------------------------------------

    await _createSOSNotificationChannel();


    // ----------------------------------------------------------
    // Handle foreground messages
    // ----------------------------------------------------------

    _messageSubscription ??=
        FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        debugPrint(
          'ASTRA FCM: Foreground message received.',
        );

        debugPrint(
          'ASTRA FCM: Data = ${message.data}',
        );

        if (message.notification != null) {
          debugPrint(
            'ASTRA FCM: Notification title = '
            '${message.notification!.title}',
          );

          debugPrint(
            'ASTRA FCM: Notification body = '
            '${message.notification!.body}',
          );
        }

        await _showForegroundNotification(
          message,
        );
      },
    );


    // ----------------------------------------------------------
    // Handle notification opened from background
    // ----------------------------------------------------------

    _messageOpenedSubscription ??=
        FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {
        debugPrint(
          'ASTRA FCM: Notification opened.',
        );

        await _handleNotificationData(
          message.data,
        );
      },
    );


    // ----------------------------------------------------------
    // Handle notification that launched the app
    // ----------------------------------------------------------

    final initialMessage =
        await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint(
        'ASTRA FCM: App launched from notification.',
      );

      await _handleNotificationData(
        initialMessage.data,
      );
    }


    // ----------------------------------------------------------
    // Save current FCM token
    // ----------------------------------------------------------

    await _saveCurrentToken();


    // ----------------------------------------------------------
    // Wait for authentication if necessary
    // ----------------------------------------------------------

    _authSubscription ??=
        _auth.authStateChanges().listen(
      (user) async {
        if (user != null) {
          debugPrint(
            'ASTRA FCM: Authenticated user detected: '
            '${user.uid}',
          );

          await _saveCurrentToken();
        }
      },
    );


    // ----------------------------------------------------------
    // Listen for token refresh
    // ----------------------------------------------------------

    _tokenSubscription ??=
        _messaging.onTokenRefresh.listen(
      (token) async {
        debugPrint(
          'ASTRA FCM: Token refreshed.',
        );

        await _saveToken(token);
      },
    );


    debugPrint(
      'ASTRA FCM: Initialization complete.',
    );
  }


  // ============================================================
  // LOCAL NOTIFICATION INITIALIZATION
  // ============================================================

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings =
        InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse response) async {
        debugPrint(
          'ASTRA FCM: Local notification tapped.',
        );

        final payload = response.payload;

        if (payload == null || payload.isEmpty) {
          return;
        }

        final uri = Uri.tryParse(payload);

        if (uri == null) {
          return;
        }

        try {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          debugPrint(
            'ASTRA FCM: Unable to open notification URL: $e',
          );
        }
      },
    );

    debugPrint(
      'ASTRA FCM: Local notifications initialized.',
    );
  }


  // ============================================================
  // CREATE SOS CHANNEL
  // ============================================================

  Future<void> _createSOSNotificationChannel() async {
    const androidChannel =
        AndroidNotificationChannel(
      'sos_alerts',
      'SOS Alerts',
      description:
          'Emergency SOS alerts from ASTRA.',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        'sos_alarm',
      ),
    );

    final androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      androidChannel,
    );

    debugPrint(
      'ASTRA FCM: SOS notification channel created.',
    );
  }


  // ============================================================
  // SHOW FOREGROUND NOTIFICATION
  // ============================================================

  Future<void> _showForegroundNotification(
    RemoteMessage message,
  ) async {
    final notification =
        message.notification;

    final data = message.data;

    final title =
        notification?.title ??
        '🚨 ASTRA EMERGENCY SOS';

    final body =
        notification?.body ??
        'Emergency SOS activated. Tap to view the location.';

    final locationUrl =
        data['locationUrl'];


    const androidDetails =
        AndroidNotificationDetails(
      'sos_alerts',
      'SOS Alerts',
      channelDescription:
          'Emergency SOS alerts from ASTRA.',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        'sos_alarm',
      ),
      enableVibration: true,
      fullScreenIntent: true,
    );

    const notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );


    await _localNotifications.show(
      id: message.messageId?.hashCode ??
          DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: locationUrl,
    );

    debugPrint(
      'ASTRA FCM: Foreground SOS notification shown.',
    );
  }


  // ============================================================
  // HANDLE NOTIFICATION DATA
  // ============================================================

  Future<void> _handleNotificationData(
    Map<String, dynamic> data,
  ) async {
    final locationUrl =
        data['locationUrl'];

    if (locationUrl == null ||
        locationUrl.toString().isEmpty) {
      return;
    }

    final uri =
        Uri.tryParse(
      locationUrl.toString(),
    );

    if (uri == null) {
      return;
    }

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      debugPrint(
        'ASTRA FCM: SOS location opened.',
      );
    } catch (e) {
      debugPrint(
        'ASTRA FCM: Unable to open SOS location: $e',
      );
    }
  }


  // ============================================================
  // SAVE CURRENT TOKEN
  // ============================================================

  Future<void> _saveCurrentToken() async {
    try {
      final user =
          _auth.currentUser;

      if (user == null) {
        debugPrint(
          'ASTRA FCM: No authenticated user yet.',
        );

        return;
      }

      final token =
          await _messaging.getToken();

      if (token == null ||
          token.isEmpty) {
        debugPrint(
          'ASTRA FCM: Unable to get FCM token.',
        );

        return;
      }

      debugPrint(
        'ASTRA FCM: Token received.',
      );

      await _saveToken(token);
    } catch (e) {
      debugPrint(
        'ASTRA FCM: Error getting token: $e',
      );
    }
  }


  // ============================================================
  // SAVE TOKEN TO FIRESTORE
  // ============================================================

  Future<void> _saveToken(
    String token,
  ) async {
    try {
      final user =
          _auth.currentUser;

      if (user == null) {
        debugPrint(
          'ASTRA FCM: Cannot save token. '
          'User not logged in.',
        );

        return;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'fcmToken': token,
        },
        SetOptions(
          merge: true,
        ),
      );

      debugPrint(
        'ASTRA FCM: Token saved for user '
        '${user.uid}.',
      );
    } catch (e) {
      debugPrint(
        'ASTRA FCM: Error saving token: $e',
      );
    }
  }


  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    _authSubscription?.cancel();
    _tokenSubscription?.cancel();
    _messageSubscription?.cancel();
    _messageOpenedSubscription?.cancel();
  }
}