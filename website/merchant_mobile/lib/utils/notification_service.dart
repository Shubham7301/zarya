import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'zarya_merchant',
      'Zarya Merchant Notifications',
      channelDescription: 'Notifications for Zarya merchant app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'zarya_merchant_scheduled',
      'Zarya Scheduled Notifications',
      channelDescription: 'Scheduled notifications for Zarya merchant app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Handle notification tap when app is closed
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Handle navigation based on payload
      _handleNotificationAction(payload);
    }
  }

  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background message
    print('Background message: ${message.messageId}');
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification when app is in foreground
    await showLocalNotification(
      id: message.hashCode,
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: message.data['action'],
    );
  }

  // Handle message when app is opened from notification
  static void _handleMessageOpenedApp(RemoteMessage message) {
    final action = message.data['action'];
    if (action != null) {
      _handleNotificationAction(action);
    }
  }

  // Handle notification actions
  static void _handleNotificationAction(String action) {
    switch (action) {
      case 'new_appointment':
        // Navigate to appointments screen
        break;
      case 'appointment_update':
        // Navigate to specific appointment
        break;
      case 'reminder':
        // Handle reminder action
        break;
      default:
        // Default action
        break;
    }
  }

  // Notification types for appointments
  static Future<void> notifyNewAppointment({
    required String customerName,
    required String serviceName,
    required DateTime appointmentTime,
  }) async {
    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'New Appointment',
      body: '$customerName booked $serviceName',
      payload: 'new_appointment',
    );
  }

  static Future<void> notifyAppointmentReminder({
    required String customerName,
    required String serviceName,
    required DateTime appointmentTime,
  }) async {
    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Upcoming Appointment',
      body: '$customerName - $serviceName in 15 minutes',
      payload: 'appointment_reminder',
    );
  }

  static Future<void> scheduleAppointmentReminder({
    required String appointmentId,
    required String customerName,
    required String serviceName,
    required DateTime appointmentTime,
  }) async {
    // Schedule reminder 15 minutes before appointment
    final reminderTime = appointmentTime.subtract(const Duration(minutes: 15));
    
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: appointmentId.hashCode,
        title: 'Upcoming Appointment',
        body: '$customerName - $serviceName in 15 minutes',
        scheduledDate: reminderTime,
        payload: 'appointment_reminder',
      );
    }
  }
}
