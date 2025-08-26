import 'package:flutter/foundation.dart';
import '../models/merchant.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class MerchantProvider with ChangeNotifier {
  
  List<Merchant> _merchants = [];
  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;

  List<Merchant> get merchants => _merchants;
  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all active merchants
  Future<void> fetchMerchants() async {
    _setLoading(true);
    try {
      // For development, use sample data. In production, use API service
      final merchantsData = ApiService.getSampleMerchants();
      
      _merchants = merchantsData
          .map((data) => Merchant.fromMap(data, id: data['id']))
          .where((merchant) => merchant.isActive)
          .toList();
      
      // Sort by name
      _merchants.sort((a, b) => a.name.compareTo(b.name));
      
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch merchants: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Get merchant by ID
  Future<Merchant?> getMerchantById(String merchantId) async {
    try {
      // First check if we already have it in memory
      final existingMerchant = _merchants.where((m) => m.id == merchantId).firstOrNull;
      if (existingMerchant != null) {
        return existingMerchant;
      }
      
      // Otherwise get from sample data
      final merchantsData = ApiService.getSampleMerchants();
      final merchantData = merchantsData.where((m) => m['id'] == merchantId).firstOrNull;
      
      if (merchantData != null) {
        return Merchant.fromMap(merchantData, id: merchantData['id']);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching merchant: $e');
      return null;
    }
  }

  // Get services for a specific merchant
  Future<void> fetchServicesForMerchant(String merchantId) async {
    _setLoading(true);
    try {
      // Get sample services for the merchant
      final servicesData = ApiService.getSampleServices(merchantId);
      
      _services = servicesData
          .map((data) => Service.fromMap(data, id: data['id']))
          .where((service) => service.isActive)
          .toList();
      
      // Sort by name
      _services.sort((a, b) => a.name.compareTo(b.name));
      
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch services: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Search merchants by category or name
  List<Merchant> searchMerchants(String query) {
    if (query.isEmpty) return _merchants;
    
    final lowercaseQuery = query.toLowerCase();
    return _merchants.where((merchant) {
      return merchant.name.toLowerCase().contains(lowercaseQuery) ||
             merchant.category.toLowerCase().contains(lowercaseQuery) ||
             merchant.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get unique categories
  List<String> getCategories() {
    final categories = _merchants.map((m) => m.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Filter merchants by category
  List<Merchant> getMerchantsByCategory(String category) {
    return _merchants.where((m) => m.category == category).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
