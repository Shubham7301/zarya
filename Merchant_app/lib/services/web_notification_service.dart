import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/notification_data.dart';

class WebNotificationService {
  static const String baseUrl = 'https://your-api-domain.com/api';
  static StreamController<NotificationData>? _notificationController;
  static StreamSubscription<Map<String, dynamic>>? _subscription;
  static bool _isInitialized = false;

  // Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request notification permission for web
      if (html.window.navigator.permissions != null) {
        final permission = await html.window.navigator.permissions!.query({'name': 'notifications'});
        if (permission.state == 'granted') {
          print('Notification permission granted');
        } else if (permission.state == 'prompt') {
          print('Notification permission prompt needed');
        } else {
          print('Notification permission denied');
        }
      }

      _notificationController = StreamController<NotificationData>.broadcast();
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize notification service: $e');
    }
  }

  // Start listening for real-time updates
  static void startListening(String merchantId, String token) {
    if (!_isInitialized) {
      print('Notification service not initialized');
      return;
    }

    _subscription = _getRealTimeUpdates(merchantId, token).listen((update) {
      _handleUpdate(update);
    });
  }

  // Stop listening for updates
  static void stopListening() {
    _subscription?.cancel();
    _notificationController?.close();
    _isInitialized = false;
  }

  // Get real-time updates stream
  static Stream<Map<String, dynamic>> _getRealTimeUpdates(String merchantId, String token) {
    // This would be implemented with WebSocket or Server-Sent Events
    // For now, we'll simulate real-time updates with periodic polling
    return Stream.periodic(const Duration(seconds: 30), (_) async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/merchants/$merchantId/updates'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          return {'error': 'Failed to get updates'};
        }
      } catch (e) {
        return {'error': 'Network error: $e'};
      }
    }).asyncMap((future) => future as Future<Map<String, dynamic>>);
  }

  // Handle different types of updates
  static void _handleUpdate(Map<String, dynamic> update) {
    if (update.containsKey('error')) {
      print('Update error: ${update['error']}');
      return;
    }

    final type = update['type'];
    final data = update['data'];

    switch (type) {
      case 'subscription_updated':
        _showSubscriptionUpdateNotification(data);
        break;
      case 'status_changed':
        _showStatusChangeNotification(data);
        break;
      case 'subscription_expired':
        _showExpirationNotification(data);
        break;
      case 'subscription_renewed':
        _showRenewalNotification(data);
        break;
      case 'profile_updated':
        _showProfileUpdateNotification(data);
        break;
      case 'account_created':
        _showAccountCreatedNotification(data);
        break;
      default:
        print('Unknown update type: $type');
    }
  }

  // Show subscription update notification
  static void _showSubscriptionUpdateNotification(Map<String, dynamic> data) {
    final notification = NotificationData(
      title: 'Subscription Updated',
      message: 'Your subscription has been updated by the administrator.',
      type: 'subscription_updated',
      data: data,
      timestamp: DateTime.now(),
    );

    _showBrowserNotification(notification);
    _notificationController?.add(notification);
  }

  // Show status change notification
  static void _showStatusChangeNotification(Map<String, dynamic> data) {
    final status = data['status'] ?? 'unknown';
    final message = status == 'active' 
        ? 'Your account has been activated!'
        : 'Your account status has been changed to $status.';

    final notification = NotificationData(
      title: 'Account Status Changed',
      message: message,
      type: 'status_changed',
      data: data,
      timestamp: DateTime.now(),
    );

    _showBrowserNotification(notification);
    _notificationController?.add(notification);
  }

  // Show expiration notification
  static void _showExpirationNotification(Map<String, dynamic> data) {
    final notification = NotificationData(
      title: 'Subscription Expired',
      message: 'Your subscription has expired. Please renew to continue using our services.',
      type: 'subscription_expired',
      data: data,
      timestamp: DateTime.now(),
    );

    _showBrowserNotification(notification);
    _notificationController?.add(notification);
  }

  // Show renewal notification
  static void _showRenewalNotification(Map<String, dynamic> data) {
    final notification = NotificationData(
      title: 'Subscription Renewed',
      message: 'Your subscription has been successfully renewed!',
      type: 'subscription_renewed',
      data: data,
      timestamp: DateTime.now(),
    );

    _showBrowserNotification(notification);
    _notificationController?.add(notification);
  }

  // Show profile update notification
  static void _showProfileUpdateNotification(Map<String, dynamic> data) {
    final notification = NotificationData(
      title: 'Profile Updated',
      message: 'Your profile has been updated by the administrator.',
      type: 'profile_updated',
      data: data,
      timestamp: DateTime.now(),
    );

    _showBrowserNotification(notification);
    _notificationController?.add(notification);
  }

  // Show account created notification
  static void _showAccountCreatedNotification(Map<String, dynamic> data) {
    final plan = data['plan'] ?? 'Unknown Plan';
    final notification = NotificationData(
      title: 'Welcome to Zarya!',
      message: 'Your account has been created successfully with $plan plan.',
      type: 'account_created',
      data: data,
      timestamp: DateTime.now(),
    );

    _showBrowserNotification(notification);
    _notificationController?.add(notification);
  }

  // Show browser notification
  static void _showBrowserNotification(NotificationData notification) {
    try {
      // For web, we'll use a simpler approach without browser notifications for now
      print('Browser notification: ${notification.title} - ${notification.message}');
    } catch (e) {
      print('Failed to show browser notification: $e');
    }
  }

  // Get notification stream
  static Stream<NotificationData> get notificationStream {
    return _notificationController?.stream ?? Stream.empty();
  }

  // Send notification to specific merchant
  static Future<void> sendNotificationToMerchant(
    String merchantId, 
    String title, 
    String message, 
    Map<String, dynamic> data,
  ) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/merchants/$merchantId/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'message': message,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }

  // Show in-app notification
  static void showInAppNotification(BuildContext context, NotificationData notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(notification.message),
          ],
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Handle notification tap
            _handleNotificationTap(context, notification);
          },
        ),
      ),
    );
  }

  // Handle notification tap
  static void _handleNotificationTap(BuildContext context, NotificationData notification) {
    switch (notification.type) {
      case 'subscription_updated':
      case 'subscription_expired':
      case 'subscription_renewed':
        // Navigate to subscription screen
        Navigator.pushNamed(context, '/subscription');
        break;
      case 'status_changed':
        // Navigate to profile screen
        Navigator.pushNamed(context, '/profile');
        break;
      case 'profile_updated':
        // Navigate to profile screen
        Navigator.pushNamed(context, '/profile');
        break;
      case 'account_created':
        // Navigate to dashboard
        Navigator.pushNamed(context, '/dashboard');
        break;
      default:
        // Default to dashboard
        Navigator.pushNamed(context, '/dashboard');
    }
  }

  // Clear all notifications
  static void clearAllNotifications() {
    // This would clear browser notifications if possible
    print('Clearing all notifications');
  }

  // Get notification count
  static int getNotificationCount() {
    // This would return the count of unread notifications
    return 0;
  }

  // Mark notification as read
  static void markAsRead(String notificationId) {
    // This would mark a specific notification as read
    print('Marking notification $notificationId as read');
  }
}
