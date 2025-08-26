import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/cloudinary_config.dart';
import '../models/merchant.dart';
import '../models/merchant_subscription.dart';
import '../models/super_admin.dart';
import '../models/notification_data.dart';
import 'cloudinary_realtime_service.dart';

class DatabaseSyncService {
  static const String _backendApiUrl = 'https://your-backend-api.com/api';
  static const String _cloudinaryApiUrl = 'https://api.cloudinary.com/v1_1';
  
  // Sync merchants with Cloudinary
  static Future<void> syncMerchants() async {
    try {
      // Fetch merchants from backend
      final merchants = await _fetchMerchantsFromBackend();
      
      // Upload to Cloudinary for real-time sync
      for (final merchant in merchants) {
        await _uploadMerchantToCloudinary(merchant);
      }
      
      print('Synced ${merchants.length} merchants to Cloudinary');
    } catch (e) {
      print('Failed to sync merchants: $e');
    }
  }

  // Sync subscriptions with Cloudinary
  static Future<void> syncSubscriptions() async {
    try {
      // Fetch subscriptions from backend
      final subscriptions = await _fetchSubscriptionsFromBackend();
      
      // Upload to Cloudinary for real-time sync
      for (final subscription in subscriptions) {
        await _uploadSubscriptionToCloudinary(subscription);
      }
      
      print('Synced ${subscriptions.length} subscriptions to Cloudinary');
    } catch (e) {
      print('Failed to sync subscriptions: $e');
    }
  }

  // Fetch merchants from backend
  static Future<List<Merchant>> _fetchMerchantsFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendApiUrl/merchants'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_BACKEND_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['merchants'] as List)
            .map((merchant) => Merchant.fromMap(merchant))
            .toList();
      } else {
        throw Exception('Failed to fetch merchants: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching merchants from backend: $e');
      // Return mock data for demo
      return _getMockMerchants();
    }
  }

  // Fetch subscriptions from backend
  static Future<List<MerchantSubscription>> _fetchSubscriptionsFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendApiUrl/subscriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_BACKEND_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['subscriptions'] as List)
            .map((subscription) => MerchantSubscription.fromMap(subscription))
            .toList();
      } else {
        throw Exception('Failed to fetch subscriptions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching subscriptions from backend: $e');
      // Return mock data for demo
      return _getMockSubscriptions();
    }
  }

  // Upload merchant to Cloudinary
  static Future<void> _uploadMerchantToCloudinary(Merchant merchant) async {
    try {
      final merchantData = {
        'id': merchant.id,
        'name': merchant.name,
        'ownerName': merchant.ownerName,
        'email': merchant.email,
        'phone': merchant.phone,
        'address': merchant.address,
        'description': merchant.description,
        'category': merchant.category,
        'isActive': merchant.isActive,
        'subscriptionId': merchant.subscriptionId,
        'createdAt': merchant.createdAt.toIso8601String(),
        'updatedAt': merchant.updatedAt?.toIso8601String(),
        'sync_timestamp': DateTime.now().toIso8601String(),
      };

      // Upload to Cloudinary as metadata
      await http.post(
        Uri.parse('${CloudinaryConfig.uploadUrl}/image/upload'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'public_id': 'zarya/merchants/${merchant.id}',
          'upload_preset': CloudinaryConfig.uploadPreset,
          'context': json.encode(merchantData),
          'resource_type': 'raw',
        }),
      );

      // Send real-time update
      await CloudinaryRealtimeService.sendUpdate('merchant_synced', {
        'merchant_id': merchant.id,
        'action': 'synced',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to upload merchant to Cloudinary: $e');
    }
  }

  // Upload subscription to Cloudinary
  static Future<void> _uploadSubscriptionToCloudinary(MerchantSubscription subscription) async {
    try {
      final subscriptionData = {
        'id': subscription.id,
        'merchantId': subscription.merchantId,
        'plan': subscription.plan.name,
        'status': subscription.status.name,
        'startDate': subscription.startDate.toIso8601String(),
        'endDate': subscription.endDate.toIso8601String(),
        'amount': subscription.amount,
        'currency': subscription.currency,
        'paymentMethod': subscription.paymentMethod,
        'transactionId': subscription.transactionId,
        'createdAt': subscription.createdAt.toIso8601String(),
        'updatedAt': subscription.updatedAt?.toIso8601String(),
        'notes': subscription.notes,
        'sync_timestamp': DateTime.now().toIso8601String(),
      };

      // Upload to Cloudinary as metadata
      await http.post(
        Uri.parse('${CloudinaryConfig.uploadUrl}/image/upload'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'public_id': 'zarya/subscriptions/${subscription.id}',
          'upload_preset': CloudinaryConfig.uploadPreset,
          'context': json.encode(subscriptionData),
          'resource_type': 'raw',
        }),
      );

      // Send real-time update
      await CloudinaryRealtimeService.sendUpdate('subscription_synced', {
        'subscription_id': subscription.id,
        'merchant_id': subscription.merchantId,
        'action': 'synced',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to upload subscription to Cloudinary: $e');
    }
  }

  // Create merchant in backend and sync to Cloudinary
  static Future<Merchant?> createMerchant(Map<String, dynamic> merchantData) async {
    try {
      // Create in backend
      final response = await http.post(
        Uri.parse('$_backendApiUrl/merchants'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_BACKEND_TOKEN',
        },
        body: json.encode(merchantData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final merchant = Merchant.fromMap(data['merchant']);

        // Sync to Cloudinary
        await _uploadMerchantToCloudinary(merchant);

        // Send real-time notification
        await CloudinaryRealtimeService.sendUpdate('merchant_created', {
          'merchant': merchant.toMap(),
          'action': 'created',
          'notify': true,
          'timestamp': DateTime.now().toIso8601String(),
        });

        return merchant;
      } else {
        throw Exception('Failed to create merchant: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to create merchant: $e');
      return null;
    }
  }

  // Update merchant in backend and sync to Cloudinary
  static Future<bool> updateMerchant(String merchantId, Map<String, dynamic> updates) async {
    try {
      // Update in backend
      final response = await http.put(
        Uri.parse('$_backendApiUrl/merchants/$merchantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_BACKEND_TOKEN',
        },
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final merchant = Merchant.fromMap(data['merchant']);

        // Sync to Cloudinary
        await _uploadMerchantToCloudinary(merchant);

        // Send real-time notification
        await CloudinaryRealtimeService.sendUpdate('merchant_updated', {
          'merchant': merchant.toMap(),
          'action': 'updated',
          'notify': true,
          'timestamp': DateTime.now().toIso8601String(),
        });

        return true;
      } else {
        throw Exception('Failed to update merchant: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to update merchant: $e');
      return false;
    }
  }

  // Create subscription in backend and sync to Cloudinary
  static Future<MerchantSubscription?> createSubscription(Map<String, dynamic> subscriptionData) async {
    try {
      // Create in backend
      final response = await http.post(
        Uri.parse('$_backendApiUrl/subscriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_BACKEND_TOKEN',
        },
        body: json.encode(subscriptionData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final subscription = MerchantSubscription.fromMap(data['subscription']);

        // Sync to Cloudinary
        await _uploadSubscriptionToCloudinary(subscription);

        // Send real-time notification
        await CloudinaryRealtimeService.sendUpdate('subscription_created', {
          'subscription': subscription.toMap(),
          'action': 'created',
          'notify': true,
          'timestamp': DateTime.now().toIso8601String(),
        });

        return subscription;
      } else {
        throw Exception('Failed to create subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to create subscription: $e');
      return null;
    }
  }

  // Update subscription in backend and sync to Cloudinary
  static Future<bool> updateSubscription(String subscriptionId, Map<String, dynamic> updates) async {
    try {
      // Update in backend
      final response = await http.put(
        Uri.parse('$_backendApiUrl/subscriptions/$subscriptionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_BACKEND_TOKEN',
        },
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final subscription = MerchantSubscription.fromMap(data['subscription']);

        // Sync to Cloudinary
        await _uploadSubscriptionToCloudinary(subscription);

        // Send real-time notification
        await CloudinaryRealtimeService.sendUpdate('subscription_updated', {
          'subscription': subscription.toMap(),
          'action': 'updated',
          'notify': true,
          'timestamp': DateTime.now().toIso8601String(),
        });

        return true;
      } else {
        throw Exception('Failed to update subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to update subscription: $e');
      return false;
    }
  }

  // Setup webhooks for real-time sync
  static Future<void> setupWebhooks() async {
    try {
      // Setup Cloudinary webhook for database changes
      await http.post(
        Uri.parse('${CloudinaryConfig.webhookUrl}/setup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('${CloudinaryConfig.apiKey}:${CloudinaryConfig.apiSecret}'))}',
        },
        body: json.encode({
          'url': '$_backendApiUrl/webhooks/cloudinary',
          'events': ['upload', 'delete', 'update'],
          'notification_type': 'webhook',
        }),
      );

      print('Webhooks setup successfully');
    } catch (e) {
      print('Failed to setup webhooks: $e');
    }
  }

  // Mock data for demo
  static List<Merchant> _getMockMerchants() {
    return [
      Merchant(
        id: '1',
        name: 'Beauty Salon Pro',
        ownerName: 'Sarah Johnson',
        email: 'sarah@beautysalonpro.com',
        phone: '+1-555-0123',
        address: '123 Main St, Downtown',
        description: 'Professional beauty services',
        category: 'salon',
        images: [],
        workingHours: [],
        isActive: true,
        subscriptionId: 'sub_1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Merchant(
        id: '2',
        name: 'Health Clinic Plus',
        ownerName: 'Dr. Michael Chen',
        email: 'michael@healthclinicplus.com',
        phone: '+1-555-0456',
        address: '456 Oak Ave, Medical District',
        description: 'Comprehensive health services',
        category: 'clinic',
        images: [],
        workingHours: [],
        isActive: false,
        subscriptionId: 'sub_2',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];
  }

  static List<MerchantSubscription> _getMockSubscriptions() {
    return [
      MerchantSubscription(
        id: 'sub_1',
        merchantId: '1',
        plan: SubscriptionPlan.premium,
        status: SubscriptionStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        amount: 179.97,
        currency: 'USD',
        paymentMethod: 'Credit Card',
        transactionId: 'txn_123456789',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      MerchantSubscription(
        id: 'sub_2',
        merchantId: '2',
        plan: SubscriptionPlan.basic,
        status: SubscriptionStatus.expired,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now().subtract(const Duration(days: 30)),
        amount: 89.97,
        currency: 'USD',
        paymentMethod: 'PayPal',
        transactionId: 'txn_987654321',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        notes: 'Subscription expired due to non-payment',
      ),
    ];
  }
}
