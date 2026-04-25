import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tement_mobile/services/api_service.dart';
import 'package:tement_mobile/config/constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  Function(Map<String, dynamic>)? onNotificationTap;

  Future<void> initialize() async {
    // 1. Demander la permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    print('📱 Permission notification: ${settings.authorizationStatus}');

    // 2. Initialiser les notifications locales
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 3. Créer le channel Android (sans priority)
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'tement_channel',
        'Notifications Tement',
        description: 'Notifications de réservation et paiement',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 4. Récupérer le token FCM
    _fcmToken = await _fcm.getToken();
    print('📱 FCM Token: $_fcmToken');

    // 5. Sauvegarder le token sur le serveur
    await _saveTokenToServer(_fcmToken);

    // 6. Écouter les tokens refresh
    _fcm.onTokenRefresh.listen((newToken) {
      print('🔄 Token FCM mis à jour: $newToken');
      _saveTokenToServer(newToken);
    });

    // 7. Écouter les messages en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 8. Écouter quand l'utilisateur ouvre une notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);

    // 9. Vérifier si l'app a été ouverte via une notification
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpen(initialMessage);
    }
  }

  Future<void> _saveTokenToServer(String? token) async {
    if (token == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString(StorageKeys.token);

      if (authToken != null) {
        final apiService = ApiService();
        await apiService.post(ApiConstants.saveFcmToken, data: {
          'fcmToken': token,
        });
        print('✅ Token FCM sauvegardé sur le serveur');
      } else {
        print('⚠️ Pas de token auth, impossible de sauvegarder FCM token');
      }
    } catch (e) {
      print('❌ Erreur sauvegarde token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Message reçu en foreground: ${message.notification?.title}');

    _showLocalNotification(
      title: message.notification?.title ?? 'Tement',
      body: message.notification?.body ?? '',
      payload: message.data,
    );
  }

  void _handleMessageOpen(RemoteMessage message) {
    print('🔓 Notification ouverte: ${message.data}');

    if (onNotificationTap != null) {
      onNotificationTap!(message.data);
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    print('🔓 Tap sur notification locale: ${response.payload}');

    if (onNotificationTap != null && response.payload != null) {
      try {
        final Map<String, dynamic> data = {};
        onNotificationTap!(data);
      } catch (e) {
        print('Erreur parsing payload: $e');
      }
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'tement_channel',
      'Notifications Tement',
      channelDescription: 'Notifications de réservation et paiement',
      importance: Importance.high,
      priority: Priority
          .high, // ✅ priority est dans NotificationDetails, pas dans channel
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload != null ? payload.toString() : null,
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    print('📡 Abonné au topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    print('📡 Désabonné du topic: $topic');
  }

  String? get fcmToken => _fcmToken;
}
