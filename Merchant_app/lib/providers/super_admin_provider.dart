import 'package:flutter/foundation.dart';
import '../models/merchant.dart';
import '../models/merchant_subscription.dart';
import '../models/super_admin.dart';

class SuperAdminProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  SuperAdmin? _superAdmin;
  
  // Mock data for offline demo
  List<Merchant> _merchants = [];
  List<MerchantSubscription> _subscriptions = [];
  Map<String, dynamic> _analytics = {};
  Map<String, dynamic> _dashboardData = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  SuperAdmin? get superAdmin => _superAdmin;
  List<Merchant> get merchants => _merchants;
  List<MerchantSubscription> get subscriptions => _subscriptions;
  Map<String, dynamic> get analytics => _analytics;
  Map<String, dynamic> get dashboardData => _dashboardData;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Load mock data for offline demo
      await _loadMockData();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadMockData() async {
    // Mock merchants data
    _merchants = [
      Merchant(
        id: '1',
        businessName: 'Beauty Salon Pro',
        ownerName: 'Sarah Johnson',
        email: 'sarah@beautysalonpro.com',
        phone: '+1-555-0123',
        address: '123 Main St, Downtown',
        city: 'New York',
        businessType: 'Beauty & Wellness',
        status: 'active',
        description: 'Professional beauty salon services',
        category: 'Beauty & Wellness',
        images: const [],
        workingHours: const [],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Merchant(
        id: '2',
        businessName: 'Tech Solutions Inc',
        ownerName: 'Mike Chen',
        email: 'mike@techsolutions.com',
        phone: '+1-555-0456',
        address: '456 Tech Ave, Business District',
        city: 'San Francisco',
        businessType: 'Technology',
        status: 'active',
        description: 'IT consulting and development services',
        category: 'Technology',
        images: const [],
        workingHours: const [],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Merchant(
        id: '3',
        businessName: 'Fitness First',
        ownerName: 'Emma Wilson',
        email: 'emma@fitnessfirst.com',
        phone: '+1-555-0789',
        address: '789 Fitness Blvd, Health Zone',
        city: 'Los Angeles',
        businessType: 'Health & Fitness',
        status: 'pending',
        description: 'Comprehensive fitness training programs',
        category: 'Health & Fitness',
        images: const [],
        workingHours: const [],
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    // Mock subscriptions data
    _subscriptions = [
      MerchantSubscription(
        id: '1',
        merchantId: '1',
        planName: 'Premium Plan',
        plan: SubscriptionPlan.premium,
        status: SubscriptionStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 335)),
        amount: 8500.0,
        currency: 'INR',
        features: const ['Unlimited Appointments', 'Advanced Analytics', 'Priority Support'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      MerchantSubscription(
        id: '2',
        merchantId: '2',
        planName: 'Business Plan',
        plan: SubscriptionPlan.enterprise,
        status: SubscriptionStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 45)),
        endDate: DateTime.now().add(const Duration(days: 320)),
        amount: 12500.0,
        currency: 'INR',
        features: const ['Multi-location Support', 'API Access', 'Custom Branding'],
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      MerchantSubscription(
        id: '3',
        merchantId: '3',
        planName: 'Starter Plan',
        plan: SubscriptionPlan.basic,
        status: SubscriptionStatus.pending,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 350)),
        amount: 2500.0,
        currency: 'INR',
        features: const ['Basic Appointments', 'Standard Support'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    // Mock analytics data
    _analytics = {
      'totalMerchants': _merchants.length,
      'activeMerchants': _merchants.where((m) => m.status == 'active').length,
      'pendingMerchants': _merchants.where((m) => m.status == 'pending').length,
      'totalRevenue': 299.97,
      'monthlyGrowth': 15.5,
      'topBusinessTypes': ['Beauty & Wellness', 'Technology', 'Health & Fitness'],
      'subscriptionPlans': {
        'Premium': 1,
        'Business': 1,
        'Starter': 1,
      },
    };

    // Mock dashboard data
    _dashboardData = {
      'recentActivity': [
        {'type': 'new_merchant', 'message': 'Fitness First joined the platform', 'time': '2 hours ago'},
        {'type': 'subscription_renewal', 'message': 'Beauty Salon Pro renewed Premium plan', 'time': '1 day ago'},
        {'type': 'payment_received', 'message': 'Payment received from Tech Solutions Inc', 'time': '3 days ago'},
      ],
      'systemHealth': {
        'uptime': '99.9%',
        'activeUsers': 156,
        'serverLoad': 'Low',
        'lastBackup': '2 hours ago',
      },
    };

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Mock super admin login for offline demo
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      if (email == 'admin@zarya.com' && password == 'Admin123!') {
        _superAdmin = SuperAdmin(
          id: '1',
          email: email,
          name: 'System Administrator',
          role: 'super_admin',
          permissions: ['manage_merchants', 'view_analytics', 'manage_subscriptions'],
          isActive: true,
          createdAt: DateTime.now(),
        );
        await initialize();
        return true;
      } else {
        _setError('Invalid credentials');
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _superAdmin = null;
    _merchants.clear();
    _subscriptions.clear();
    _analytics.clear();
    _dashboardData.clear();
    notifyListeners();
  }

  // Update merchant status
  Future<bool> updateMerchantStatus(String merchantId, String status) async {
    _setLoading(true);
    try {
      // Find the merchant
      final merchantIndex = _merchants.indexWhere((m) => m.id == merchantId);
      if (merchantIndex == -1) return false;

      // Update the merchant status
      final updatedMerchant = _merchants[merchantIndex].copyWith(
        status: status,
        isActive: status == 'active',
      );
      
      _merchants[merchantIndex] = updatedMerchant;
      notifyListeners();
      
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }



  // Create a new merchant
  Future<Merchant?> createMerchant(Map<String, dynamic> merchantData) async {
    _setLoading(true);
    try {
      final newMerchant = Merchant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessName: merchantData['businessName'] ?? '',
        ownerName: merchantData['ownerName'] ?? '',
        email: merchantData['email'] ?? '',
        phone: merchantData['phone'] ?? '',
        address: merchantData['address'] ?? '',
        city: merchantData['city'] ?? '',
        businessType: merchantData['businessType'] ?? '',
        status: 'pending',
        description: merchantData['description'] ?? '',
        category: merchantData['category'] ?? '',
        images: [],
        workingHours: [],
        isActive: false,
        subscriptionId: merchantData['subscriptionPlan'] ?? '',
        createdAt: DateTime.now(),
      );

      _merchants.add(newMerchant);
      notifyListeners();
      
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      return newMerchant;
    } catch (e) {
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing merchant
  Future<bool> updateMerchant(String merchantId, Map<String, dynamic> merchantData) async {
    _setLoading(true);
    try {
      final merchantIndex = _merchants.indexWhere((m) => m.id == merchantId);
      if (merchantIndex == -1) return false;

      final currentMerchant = _merchants[merchantIndex];
      final updatedMerchant = currentMerchant.copyWith(
        businessName: merchantData['businessName'] ?? currentMerchant.businessName,
        ownerName: merchantData['ownerName'] ?? currentMerchant.ownerName,
        email: merchantData['email'] ?? currentMerchant.email,
        phone: merchantData['phone'] ?? currentMerchant.phone,
        address: merchantData['address'] ?? currentMerchant.address,
        city: merchantData['city'] ?? currentMerchant.city,
        businessType: merchantData['businessType'] ?? currentMerchant.businessType,
        description: merchantData['description'] ?? currentMerchant.description,
        category: merchantData['category'] ?? currentMerchant.category,
      );

      _merchants[merchantIndex] = updatedMerchant;
      notifyListeners();
      
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Enable/Disable merchant account
  Future<bool> toggleMerchantStatus(String merchantId, bool isActive) async {
    try {
      final merchantIndex = _merchants.indexWhere((m) => m.id == merchantId);
      if (merchantIndex == -1) return false;

      _merchants[merchantIndex] = _merchants[merchantIndex].copyWith(
        isActive: isActive,
        status: isActive ? 'active' : 'suspended',
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to toggle merchant status: $e');
      return false;
    }
  }

  // Delete merchant account
  Future<bool> deleteMerchant(String merchantId) async {
    try {
      _merchants.removeWhere((m) => m.id == merchantId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete merchant: $e');
      return false;
    }
  }

  // Get merchants by status
  List<Merchant> getMerchantsByStatus(String status) {
    return _merchants.where((m) => m.status == status).toList();
  }

  // Get active merchants count
  int get activeMerchantsCount => _merchants.where((m) => m.isActive).length;

  // Get pending merchants count
  int get pendingMerchantsCount => _merchants.where((m) => m.status == 'pending').length;

  // Get total merchants count
  int get totalMerchantsCount => _merchants.length;

  Future<bool> updateSubscriptionStatus(String subscriptionId, String status) async {
    try {
      final subscriptionIndex = _subscriptions.indexWhere((s) => s.id == subscriptionId);
      if (subscriptionIndex != -1) {
        // Convert string status to enum for the subscription model
        SubscriptionStatus newStatus;
        switch (status) {
          case 'active':
            newStatus = SubscriptionStatus.active;
            break;
          case 'suspended':
            newStatus = SubscriptionStatus.suspended;
            break;
          case 'cancelled':
            newStatus = SubscriptionStatus.cancelled;
            break;
          default:
            newStatus = SubscriptionStatus.pending;
        }
        _subscriptions[subscriptionIndex] = _subscriptions[subscriptionIndex].copyWith(status: newStatus);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update subscription status: $e');
      return false;
    }
  }

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
}

