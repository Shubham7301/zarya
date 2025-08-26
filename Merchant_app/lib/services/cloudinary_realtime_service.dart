import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/cloudinary_config.dart';
import '../models/merchant.dart';
import '../models/merchant_subscription.dart';
import '../models/super_admin.dart';
import '../models/notification_data.dart';

class CloudinaryRealtimeService {
  static const String _cloudinaryApiUrl = 'https://api.cloudinary.com/v1_1';
  static const String _cloudinaryWsUrl = 'wss://api.cloudinary.com/v1_1';
  
  static WebSocketChannel? _channel;
  static StreamController<Map<String, dynamic>>? _dataController;
  static StreamController<NotificationData>? _notificationController;
  static Timer? _heartbeatTimer;
  static bool _isConnected = false;
  static String? _sessionId;

  // Real-time data streams
  static Stream<Map<String, dynamic>> get dataStream => 
      _dataController?.stream ?? Stream.empty();
  
  static Stream<NotificationData> get notificationStream => 
      _notificationController?.stream ?? Stream.empty();

  // Initialize real-time service
  static Future<void> initialize() async {
    try {
      _dataController = StreamController<Map<String, dynamic>>.broadcast();
      _notificationController = StreamController<NotificationData>.broadcast();
      
      // Generate session ID for this client
      final random = DateTime.now().millisecondsSinceEpoch % 10000;
      _sessionId = 'client_${DateTime.now().millisecondsSinceEpoch}_$random';
      
      print('Cloudinary Realtime Service initialized with session: $_sessionId');
    } catch (e) {
      print('Failed to initialize Cloudinary Realtime Service: $e');
    }
  }

  // Connect to Cloudinary real-time stream
  static Future<void> connect() async {
    if (_isConnected) return;

    try {
      // Connect to Cloudinary WebSocket for real-time updates
      final wsUrl = '$_cloudinaryWsUrl/${CloudinaryConfig.cloudName}/realtime';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Listen for real-time updates
      _channel!.stream.listen(
        (data) => _handleRealtimeUpdate(data),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnect(),
      );

      // Send authentication
      await _authenticate();
      
      // Start heartbeat to keep connection alive
      _startHeartbeat();
      
      _isConnected = true;
      print('Connected to Cloudinary real-time stream');
    } catch (e) {
      print('Failed to connect to Cloudinary real-time stream: $e');
      // Fallback to polling if WebSocket fails
      _startPolling();
    }
  }

  // Authenticate with Cloudinary
  static Future<void> _authenticate() async {
    try {
      final authData = {
        'type': 'auth',
        'api_key': CloudinaryConfig.apiKey,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'session_id': _sessionId,
      };
      
      _channel?.sink.add(json.encode(authData));
    } catch (e) {
      print('Authentication failed: $e');
    }
  }

  // Handle real-time updates from Cloudinary
  static void _handleRealtimeUpdate(dynamic data) {
    try {
      final update = json.decode(data.toString());
      final type = update['type'];
      final payload = update['data'];

      switch (type) {
        case 'merchant_updated':
          _handleMerchantUpdate(payload);
          break;
        case 'subscription_updated':
          _handleSubscriptionUpdate(payload);
          break;
        case 'admin_action':
          _handleAdminAction(payload);
          break;
        case 'notification':
          _handleNotification(payload);
          break;
        case 'sync_request':
          _handleSyncRequest(payload);
          break;
        default:
          print('Unknown update type: $type');
      }
    } catch (e) {
      print('Error handling real-time update: $e');
    }
  }

  // Handle merchant updates
  static void _handleMerchantUpdate(Map<String, dynamic> payload) {
    try {
      final merchant = Merchant.fromMap(payload['merchant']);
      final action = payload['action']; // 'created', 'updated', 'deleted'
      
      _dataController?.add({
        'type': 'merchant_update',
        'action': action,
        'merchant': merchant,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Send notification if needed
      if (payload['notify'] == true) {
        _sendNotification(
          'Merchant Updated',
          'Merchant ${merchant.name} has been $action',
          'merchant_updated',
          payload,
        );
      }
    } catch (e) {
      print('Error handling merchant update: $e');
    }
  }

  // Handle subscription updates
  static void _handleSubscriptionUpdate(Map<String, dynamic> payload) {
    try {
      final subscription = MerchantSubscription.fromMap(payload['subscription']);
      final action = payload['action'];
      
      _dataController?.add({
        'type': 'subscription_update',
        'action': action,
        'subscription': subscription,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Send notification
      _sendNotification(
        'Subscription Updated',
        'Subscription for ${subscription.planDisplayName} has been $action',
        'subscription_updated',
        payload,
      );
    } catch (e) {
      print('Error handling subscription update: $e');
    }
  }

  // Handle admin actions
  static void _handleAdminAction(Map<String, dynamic> payload) {
    try {
      final adminId = payload['admin_id'];
      final action = payload['action'];
      final target = payload['target'];
      
      _dataController?.add({
        'type': 'admin_action',
        'admin_id': adminId,
        'action': action,
        'target': target,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Send notification to affected merchants
      if (payload['notify_merchant'] == true) {
        _sendNotification(
          'Admin Action',
          'An administrator has performed: $action',
          'admin_action',
          payload,
        );
      }
    } catch (e) {
      print('Error handling admin action: $e');
    }
  }

  // Handle notifications
  static void _handleNotification(Map<String, dynamic> payload) {
    try {
      final notification = NotificationData(
        title: payload['title'],
        message: payload['message'],
        type: payload['type'],
        data: Map<String, dynamic>.from(payload['data'] ?? {}),
        timestamp: DateTime.parse(payload['timestamp']),
      );
      
      _notificationController?.add(notification);
    } catch (e) {
      print('Error handling notification: $e');
    }
  }

  // Handle sync requests
  static void _handleSyncRequest(Map<String, dynamic> payload) {
    try {
      final requestType = payload['request_type'];
      final requestId = payload['request_id'];
      
      // Respond with current data
      _sendSyncResponse(requestType, requestId);
    } catch (e) {
      print('Error handling sync request: $e');
    }
  }

  // Send sync response
  static void _sendSyncResponse(String requestType, String requestId) {
    try {
      final response = {
        'type': 'sync_response',
        'request_id': requestId,
        'request_type': requestType,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _channel?.sink.add(json.encode(response));
    } catch (e) {
      print('Error sending sync response: $e');
    }
  }

  // Send notification
  static void _sendNotification(String title, String message, String type, Map<String, dynamic> data) {
    try {
      final notification = NotificationData(
        title: title,
        message: message,
        type: type,
        data: data,
        timestamp: DateTime.now(),
      );
      
      _notificationController?.add(notification);
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Start heartbeat to keep connection alive
  static void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      try {
        final heartbeat = {
          'type': 'heartbeat',
          'session_id': _sessionId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        _channel?.sink.add(json.encode(heartbeat));
      } catch (e) {
        print('Heartbeat failed: $e');
        _reconnect();
      }
    });
  }

  // Handle connection errors
  static void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _isConnected = false;
    _reconnect();
  }

  // Handle disconnection
  static void _handleDisconnect() {
    print('WebSocket disconnected');
    _isConnected = false;
    _reconnect();
  }

  // Reconnect logic
  static void _reconnect() {
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    
    Timer(const Duration(seconds: 5), () {
      print('Attempting to reconnect...');
      connect();
    });
  }

  // Fallback polling method
  static void _startPolling() {
    print('Using polling fallback for real-time updates');
    Timer.periodic(const Duration(seconds: 10), (_) async {
      await _pollForUpdates();
    });
  }

  // Poll for updates
  static Future<void> _pollForUpdates() async {
    try {
      final response = await http.get(
        Uri.parse('$_cloudinaryApiUrl/${CloudinaryConfig.cloudName}/realtime/updates'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('${CloudinaryConfig.apiKey}:${CloudinaryConfig.apiSecret}'))}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final updates = json.decode(response.body);
        for (final update in updates) {
          _handleRealtimeUpdate(json.encode(update));
        }
      }
    } catch (e) {
      print('Polling failed: $e');
    }
  }

  // Send data to Cloudinary
  static Future<void> sendUpdate(String type, Map<String, dynamic> data) async {
    try {
      final update = {
        'type': type,
        'data': data,
        'session_id': _sessionId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (_isConnected && _channel != null) {
        _channel!.sink.add(json.encode(update));
      } else {
        // Fallback to HTTP if WebSocket not available
        await _sendUpdateViaHttp(update);
      }
    } catch (e) {
      print('Failed to send update: $e');
    }
  }

  // Send update via HTTP
  static Future<void> _sendUpdateViaHttp(Map<String, dynamic> update) async {
    try {
      await http.post(
        Uri.parse('$_cloudinaryApiUrl/${CloudinaryConfig.cloudName}/realtime/update'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('${CloudinaryConfig.apiKey}:${CloudinaryConfig.apiSecret}'))}',
          'Content-Type': 'application/json',
        },
        body: json.encode(update),
      );
    } catch (e) {
      print('HTTP update failed: $e');
    }
  }

  // Subscribe to specific data types
  static Future<void> subscribe(String dataType, {String? merchantId}) async {
    try {
      final subscription = {
        'type': 'subscribe',
        'data_type': dataType,
        'session_id': _sessionId,
        'merchant_id': merchantId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (_isConnected && _channel != null) {
        _channel!.sink.add(json.encode(subscription));
      }
    } catch (e) {
      print('Failed to subscribe: $e');
    }
  }

  // Unsubscribe from data types
  static Future<void> unsubscribe(String dataType) async {
    try {
      final unsubscription = {
        'type': 'unsubscribe',
        'data_type': dataType,
        'session_id': _sessionId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (_isConnected && _channel != null) {
        _channel!.sink.add(json.encode(unsubscription));
      }
    } catch (e) {
      print('Failed to unsubscribe: $e');
    }
  }

  // Disconnect and cleanup
  static void disconnect() {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    _dataController?.close();
    _notificationController?.close();
    print('Cloudinary Realtime Service disconnected');
  }

  // Check connection status
  static bool get isConnected => _isConnected;

  // Get session ID
  static String? get sessionId => _sessionId;
}
