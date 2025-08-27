import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/merchant.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Merchant? _merchant;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  Merchant? get merchant => _merchant;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _merchant != null;

  // Initialize auth state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedMerchantId = prefs.getString('merchant_id');

      if (savedToken != null && savedMerchantId != null) {
        _token = savedToken;
        await _loadMerchantProfile(savedMerchantId);
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // This would typically call your authentication API
      // For now, we'll simulate a successful login
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // Mock response - replace with actual API call
      final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      final mockMerchantId = 'merchant_${DateTime.now().millisecondsSinceEpoch}';
      
      await _saveAuthData(mockToken, mockMerchantId);
      _token = mockToken;
      
      // Load merchant profile
      await _loadMerchantProfile(mockMerchantId);
      
      return true;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('merchant_id');
      
      _token = null;
      _merchant = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update merchant profile
  Future<bool> updateProfile(Merchant updatedMerchant) async {
    if (_merchant == null || _token == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await ApiService.updateMerchantProfile(updatedMerchant, _token);
      if (success) {
        _merchant = updatedMerchant;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load merchant profile from API
  Future<void> _loadMerchantProfile(String merchantId) async {
    try {
      final profile = await ApiService.getMerchantProfile(merchantId, _token);
      if (profile != null) {
        _merchant = profile;
        notifyListeners();
      } else {
        // If API fails, create a mock profile for development
        _merchant = _createMockMerchant(merchantId);
        notifyListeners();
      }
    } catch (e) {
      // Create mock profile for development
      _merchant = _createMockMerchant(merchantId);
      notifyListeners();
    }
  }

  // Save authentication data to local storage
  Future<void> _saveAuthData(String token, String merchantId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('merchant_id', merchantId);
  }

  // Create mock merchant for development
  Merchant _createMockMerchant(String merchantId) {
    return Merchant(
      id: merchantId,
      name: 'Sample Salon',
      email: 'salon@example.com',
      phone: '+1234567890',
      address: '123 Main Street, City, State 12345',
      description: 'A premium salon offering the best services in town.',
      category: 'salon',
      images: [],
      workingHours: [
        WorkingHours(day: 'Monday', startTime: '09:00', endTime: '18:00', isOpen: true),
        WorkingHours(day: 'Tuesday', startTime: '09:00', endTime: '18:00', isOpen: true),
        WorkingHours(day: 'Wednesday', startTime: '09:00', endTime: '18:00', isOpen: true),
        WorkingHours(day: 'Thursday', startTime: '09:00', endTime: '18:00', isOpen: true),
        WorkingHours(day: 'Friday', startTime: '09:00', endTime: '18:00', isOpen: true),
        WorkingHours(day: 'Saturday', startTime: '10:00', endTime: '16:00', isOpen: true),
        WorkingHours(day: 'Sunday', startTime: '10:00', endTime: '16:00', isOpen: false),
      ],
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  // Helper methods
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
