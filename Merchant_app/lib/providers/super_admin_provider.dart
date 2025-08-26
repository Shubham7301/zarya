import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/merchant.dart';
import '../models/merchant_subscription.dart';
import '../models/super_admin.dart';
import '../models/notification_data.dart';
import '../services/super_admin_api_service.dart';
import '../services/cloudinary_realtime_service.dart';
import '../services/database_sync_service.dart';

class SuperAdminProvider with ChangeNotifier {
  // State variables
  SuperAdmin? _currentAdmin;
  List<Merchant> _merchants = [];
  List<MerchantSubscription> _subscriptions = [];
  Map<String, dynamic> _analytics = {};
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _realtimeSubscription;
  StreamSubscription? _notificationSubscription;

  // Getters
  SuperAdmin? get currentAdmin => _currentAdmin;
  List<Merchant> get merchants => _merchants;
  List<MerchantSubscription> get subscriptions => _subscriptions;
  Map<String, dynamic> get analytics => _analytics;
  Map<String, dynamic> get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentAdmin != null;

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Initialize real-time services
      await _startRealTimeUpdates();
      
      // Load initial data
      await Future.wait([
        loadDashboardData(),
        loadMerchants(),
        loadSubscriptions(),
        loadAnalytics(),
      ]);
      
      _clearError();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Login admin
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await SuperAdminApiService.adminLogin(email, password);
      
      if (response['success'] == true) {
        _currentAdmin = SuperAdmin.fromJson(response['admin']);
        SuperAdminApiService.setAuthToken(response['token']);
        notifyListeners();
        return true;
      } else {
        _setError(response['error'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout admin
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      // Disconnect real-time services
      await _stopRealTimeUpdates();
      
      // Clear API token
      SuperAdminApiService.clearAuthToken();
      
      // Clear local data
      _currentAdmin = null;
      _merchants.clear();
      _subscriptions.clear();
      _analytics.clear();
      _dashboardData.clear();
      
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Dashboard data
  Future<void> loadDashboardData() async {
    try {
      _dashboardData = await SuperAdminApiService.getDashboardData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load dashboard data: $e');
    }
  }

  // Merchants management
  Future<void> loadMerchants({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
    String? status,
  }) async {
    try {
      _merchants = await SuperAdminApiService.getMerchants(
        page: page,
        limit: limit,
        search: search,
        category: category,
        status: status,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load merchants: $e');
    }
  }

  Future<Merchant?> createMerchant(Map<String, dynamic> merchantData) async {
    try {
      final merchant = await SuperAdminApiService.createMerchant(merchantData);
      if (merchant != null) {
        _merchants.add(merchant);
        notifyListeners();
      }
      return merchant;
    } catch (e) {
      _setError('Failed to create merchant: $e');
      return null;
    }
  }

  Future<bool> updateMerchant(String merchantId, Map<String, dynamic> updateData) async {
    try {
      final updatedMerchant = await SuperAdminApiService.updateMerchant(merchantId, updateData);
      
      if (updatedMerchant != null) {
        final index = _merchants.indexWhere((m) => m.id == merchantId);
        if (index != -1) {
          _merchants[index] = updatedMerchant;
          notifyListeners();
        }
      }
      
      return updatedMerchant != null;
    } catch (e) {
      _setError('Failed to update merchant: $e');
      return false;
    }
  }

  Future<bool> deleteMerchant(String merchantId) async {
    try {
      final success = await SuperAdminApiService.deleteMerchant(merchantId);
      if (success) {
        _merchants.removeWhere((m) => m.id == merchantId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to delete merchant: $e');
      return false;
    }
  }

  Future<bool> toggleMerchantStatus(String merchantId) async {
    try {
      final index = _merchants.indexWhere((m) => m.id == merchantId);
      if (index != -1) {
        final currentStatus = _merchants[index].isActive;
        final success = await SuperAdminApiService.updateMerchant(merchantId, {
          'isActive': !currentStatus,
        });
        
        if (success != null) {
          _merchants[index] = success;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _setError('Failed to toggle merchant status: $e');
      return false;
    }
  }

  // Subscriptions management
  Future<void> loadSubscriptions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      _subscriptions = await SuperAdminApiService.getSubscriptions(
        page: page,
        limit: limit,
        status: status,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load subscriptions: $e');
    }
  }

  Future<MerchantSubscription?> createSubscription(Map<String, dynamic> subscriptionData) async {
    try {
      // Note: createSubscription method was removed from API service
      // You may need to implement this based on your requirements
      _setError('Create subscription not implemented');
      return null;
    } catch (e) {
      _setError('Failed to create subscription: $e');
      return null;
    }
  }

  Future<bool> updateSubscription(String subscriptionId, Map<String, dynamic> updateData) async {
    try {
      final updatedSubscription = await SuperAdminApiService.updateSubscription(subscriptionId, updateData);
      
      if (updatedSubscription != null) {
        final index = _subscriptions.indexWhere((s) => s.id == subscriptionId);
        if (index != -1) {
          _subscriptions[index] = updatedSubscription;
          notifyListeners();
        }
      }
      
      return updatedSubscription != null;
    } catch (e) {
      _setError('Failed to update subscription: $e');
      return false;
    }
  }

  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      // Note: cancelSubscription method was removed from API service
      // You may need to implement this based on your requirements
      _setError('Cancel subscription not implemented');
      return false;
    } catch (e) {
      _setError('Failed to cancel subscription: $e');
      return false;
    }
  }

  Future<MerchantSubscription?> renewSubscription(String subscriptionId, int duration, double amount) async {
    try {
      // Note: renewSubscription method was removed from API service
      // You may need to implement this based on your requirements
      _setError('Renew subscription not implemented');
      return null;
    } catch (e) {
      _setError('Failed to renew subscription: $e');
      return null;
    }
  }

  // Analytics
  Future<void> loadAnalytics({String? period, String? category}) async {
    try {
      _analytics = await SuperAdminApiService.getAnalyticsData(
        period: period,
        category: category,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load analytics: $e');
    }
  }

  Future<Map<String, dynamic>> getMerchantAnalytics(String merchantId, {String? period}) async {
    try {
      // Note: getMerchantAnalytics method was removed from API service
      // You may need to implement this based on your requirements
      return {};
    } catch (e) {
      _setError('Failed to get merchant analytics: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getSubscriptionAnalytics({String? period}) async {
    try {
      // Note: getSubscriptionAnalytics method was removed from API service
      // You may need to implement this based on your requirements
      return {};
    } catch (e) {
      _setError('Failed to get subscription analytics: $e');
      return {};
    }
  }

  // Image upload
  Future<String?> uploadMerchantImage(String merchantId, List<int> imageBytes, String fileName) async {
    try {
      // Note: uploadMerchantImage method was removed from API service
      // You may need to implement this based on your requirements
      _setError('Upload merchant image not implemented');
      return null;
    } catch (e) {
      _setError('Failed to upload image: $e');
      return null;
    }
  }

  // Real-time updates
  Future<void> _startRealTimeUpdates() async {
    try {
      // Initialize Cloudinary real-time service
      await CloudinaryRealtimeService.initialize();
      await CloudinaryRealtimeService.connect();
      
      // Subscribe to updates
      await CloudinaryRealtimeService.subscribe('merchants');
      await CloudinaryRealtimeService.subscribe('subscriptions');
      await CloudinaryRealtimeService.subscribe('admin_actions');
      
      // Listen to data stream
      _realtimeSubscription = CloudinaryRealtimeService.dataStream.listen(
        _handleRealtimeUpdate,
        onError: (error) => _setError('Real-time update error: $error'),
      );
      
      // Listen to notifications
      _notificationSubscription = CloudinaryRealtimeService.notificationStream.listen(
        (notification) => _handleNotification(notification),
        onError: (error) => _setError('Notification error: $error'),
      );
      
      // Initial sync
      await DatabaseSyncService.syncMerchants();
      await DatabaseSyncService.syncSubscriptions();
      
    } catch (e) {
      _setError('Failed to start real-time updates: $e');
    }
  }

  Future<void> _stopRealTimeUpdates() async {
    try {
      await _realtimeSubscription?.cancel();
      await _notificationSubscription?.cancel();
      CloudinaryRealtimeService.disconnect();
    } catch (e) {
      _setError('Failed to stop real-time updates: $e');
    }
  }

  void _handleRealtimeUpdate(Map<String, dynamic> data) {
    try {
      final type = data['type'];
      final action = data['action'];
      final payload = data['payload'];
      
      switch (type) {
        case 'merchant':
          _handleMerchantUpdate(action, payload);
          break;
        case 'subscription':
          _handleSubscriptionUpdate(action, payload);
          break;
        case 'admin_action':
          _handleAdminAction(payload);
          break;
        case 'sync_request':
          _handleSyncRequest(payload);
          break;
      }
    } catch (e) {
      _setError('Failed to handle real-time update: $e');
    }
  }

  void _handleMerchantUpdate(String action, Map<String, dynamic> payload) {
    try {
      final merchant = Merchant.fromJson(payload);
      
      switch (action) {
        case 'created':
          _merchants.add(merchant);
          break;
        case 'updated':
          final index = _merchants.indexWhere((m) => m.id == merchant.id);
          if (index != -1) {
            _merchants[index] = merchant;
          }
          break;
        case 'deleted':
          _merchants.removeWhere((m) => m.id == merchant.id);
          break;
        case 'synced':
          // Handle sync response
          break;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to handle merchant update: $e');
    }
  }

  void _handleSubscriptionUpdate(String action, Map<String, dynamic> payload) {
    try {
      final subscription = MerchantSubscription.fromJson(payload);
      
      switch (action) {
        case 'created':
          _subscriptions.add(subscription);
          break;
        case 'updated':
          final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
          if (index != -1) {
            _subscriptions[index] = subscription;
          }
          break;
        case 'deleted':
          _subscriptions.removeWhere((s) => s.id == subscription.id);
          break;
        case 'synced':
          // Handle sync response
          break;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to handle subscription update: $e');
    }
  }

  void _handleAdminAction(Map<String, dynamic> payload) {
    try {
      final actionType = payload['type'];
      final data = payload['data'];
      
      // Handle different admin actions
      switch (actionType) {
        case 'merchant_created':
        case 'merchant_updated':
        case 'merchant_deleted':
          // Refresh merchants list
          loadMerchants();
          break;
        case 'subscription_created':
        case 'subscription_updated':
        case 'subscription_deleted':
          // Refresh subscriptions list
          loadSubscriptions();
          break;
        case 'analytics_updated':
          // Refresh analytics
          loadAnalytics();
          break;
      }
    } catch (e) {
      _setError('Failed to handle admin action: $e');
    }
  }

  void _handleSyncRequest(Map<String, dynamic> payload) {
    try {
      final syncType = payload['type'];
      
      switch (syncType) {
        case 'merchants':
          loadMerchants();
          break;
        case 'subscriptions':
          loadSubscriptions();
          break;
        case 'analytics':
          loadAnalytics();
          break;
        case 'dashboard':
          loadDashboardData();
          break;
      }
    } catch (e) {
      _setError('Failed to handle sync request: $e');
    }
  }

  void _handleNotification(NotificationData notification) {
    try {
      // Handle notifications (could show snackbar, etc.)
      final title = notification.title;
      final message = notification.message;
      final type = notification.type;
      
      // You can implement notification display logic here
      print('Notification: $title - $message ($type)');
    } catch (e) {
      _setError('Failed to handle notification: $e');
    }
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Search and filter methods
  List<Merchant> searchMerchants(String query) {
    if (query.isEmpty) return _merchants;
    
    return _merchants.where((merchant) {
      return merchant.businessName.toLowerCase().contains(query.toLowerCase()) ||
             merchant.ownerName.toLowerCase().contains(query.toLowerCase()) ||
             merchant.email.toLowerCase().contains(query.toLowerCase()) ||
             merchant.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Merchant> filterMerchantsByCategory(String category) {
    if (category.isEmpty) return _merchants;
    return _merchants.where((merchant) => merchant.category == category).toList();
  }

  List<Merchant> filterMerchantsByStatus(bool isActive) {
    return _merchants.where((merchant) => merchant.isActive == isActive).toList();
  }

  List<MerchantSubscription> filterSubscriptionsByStatus(SubscriptionStatus status) {
    return _subscriptions.where((subscription) => subscription.status == status).toList();
  }

  List<MerchantSubscription> getSubscriptionsForMerchant(String merchantId) {
    return _subscriptions.where((subscription) => subscription.merchantId == merchantId).toList();
  }

  // Statistics
  int get totalMerchants => _merchants.length;
  int get activeMerchants => _merchants.where((m) => m.isActive).length;
  int get inactiveMerchants => _merchants.where((m) => !m.isActive).length;
  int get totalSubscriptions => _subscriptions.length;
  int get activeSubscriptions => _subscriptions.where((s) => s.status == SubscriptionStatus.active).length;
  int get expiredSubscriptions => _subscriptions.where((s) => s.status == SubscriptionStatus.expired).length;

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _notificationSubscription?.cancel();
    CloudinaryRealtimeService.disconnect();
    super.dispose();
  }
}
