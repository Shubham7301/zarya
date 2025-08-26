import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/merchant.dart';
import '../models/merchant_subscription.dart';
import '../models/super_admin.dart';
import '../config/app_config.dart';

class SuperAdminApiService {
  // Use configuration for API URLs
  static String get baseUrl => AppConfig.currentApiUrl;
  static String get socketUrl => AppConfig.currentSocketUrl;

  static String? _authToken;

  // Set authentication token
  static void setAuthToken(String token) {
    _authToken = token;
  }

  // Get headers with authentication
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Handle API responses
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'API request failed');
    }
  }

  // Super Admin Authentication
  static Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/admin/login'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(AppConfig.apiTimeout);

      final data = _handleResponse(response);
      
      // Store the token for future requests
      if (data['token'] != null) {
        setAuthToken(data['token']);
      }

      return data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Get all merchants
  static Future<List<Merchant>> getMerchants({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/merchants').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers).timeout(AppConfig.apiTimeout);
      final data = _handleResponse(response);

      if (data['data'] != null) {
        return (data['data'] as List)
            .map((json) => Merchant.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch merchants: $e');
    }
  }

  // Create new merchant
  static Future<Merchant?> createMerchant(Map<String, dynamic> merchantData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/merchants'),
        headers: _headers,
        body: json.encode(merchantData),
      ).timeout(AppConfig.apiTimeout);

      final data = _handleResponse(response);
      return Merchant.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to create merchant: $e');
    }
  }

  // Update merchant
  static Future<Merchant?> updateMerchant(String merchantId, Map<String, dynamic> merchantData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/merchants/$merchantId'),
        headers: _headers,
        body: json.encode(merchantData),
      ).timeout(AppConfig.apiTimeout);

      final data = _handleResponse(response);
      return Merchant.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to update merchant: $e');
    }
  }

  // Delete merchant
  static Future<bool> deleteMerchant(String merchantId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/merchants/$merchantId'),
        headers: _headers,
      ).timeout(AppConfig.apiTimeout);

      _handleResponse(response);
      return true;
    } catch (e) {
      throw Exception('Failed to delete merchant: $e');
    }
  }

  // Get dashboard data
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'),
        headers: _headers,
      ).timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }

  // Get analytics data
  static Future<Map<String, dynamic>> getAnalyticsData({
    String? period,
    String? category,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (period != null) queryParams['period'] = period;
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse('$baseUrl/analytics').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers).timeout(AppConfig.apiTimeout);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch analytics data: $e');
    }
  }

  // Get subscriptions
  static Future<List<MerchantSubscription>> getSubscriptions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/subscriptions').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers).timeout(AppConfig.apiTimeout);
      final data = _handleResponse(response);

      if (data['data'] != null) {
        return (data['data'] as List)
            .map((json) => MerchantSubscription.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch subscriptions: $e');
    }
  }

  // Update subscription
  static Future<MerchantSubscription?> updateSubscription(
    String subscriptionId,
    Map<String, dynamic> subscriptionData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/subscriptions/$subscriptionId'),
        headers: _headers,
        body: json.encode(subscriptionData),
      ).timeout(AppConfig.apiTimeout);

      final data = _handleResponse(response);
      return MerchantSubscription.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to update subscription: $e');
    }
  }

  // Export data
  static Future<String> exportData({
    String format = 'json',
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        'format': format,
      };
      
      if (type != null) queryParams['type'] = type;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl/admin/export').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers).timeout(AppConfig.apiTimeout);
      return response.body;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  // Get system logs
  static Future<List<Map<String, dynamic>>> getSystemLogs({
    int page = 1,
    int limit = 50,
    String? level,
    String? type,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (level != null) queryParams['level'] = level;
      if (type != null) queryParams['type'] = type;

      final uri = Uri.parse('$baseUrl/admin/logs').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers).timeout(AppConfig.apiTimeout);
      final data = _handleResponse(response);

      if (data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch system logs: $e');
    }
  }

  // Clear authentication token
  static void clearAuthToken() {
    _authToken = null;
  }
}
