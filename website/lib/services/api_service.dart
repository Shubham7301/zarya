import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/cloudinary_config.dart';

class ApiService {
  static const String baseUrl = 'https://your-backend-api.com/api'; // Replace with your backend URL
  
  static late SharedPreferences _prefs;
  static String? _authToken;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _authToken = _prefs.getString('auth_token');
    print('API Service initialized with Cloudinary');
    print('Cloud Name: ${CloudinaryConfig.cloudName}');
  }

  // Helper method to get optimized image URLs
  static String getImageUrl(String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    final transformations = <String>[];
    
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_$format');
    
    final transformation = transformations.join(',');
    return '${CloudinaryConfig.baseUrl}/image/upload/$transformation/$publicId';
  }

  // Get headers with auth token
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // Auth methods
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        await _prefs.setString('auth_token', _authToken!);
        return data;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    _authToken = null;
    await _prefs.remove('auth_token');
  }

  // Merchant methods
  static Future<List<Map<String, dynamic>>> getMerchants() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/merchants'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['merchants'] ?? []);
      }
      return [];
    } catch (e) {
      print('Get merchants error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getMerchantById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/merchants/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Get merchant error: $e');
      return null;
    }
  }

  // Service methods
  static Future<List<Map<String, dynamic>>> getServicesByMerchant(String merchantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/merchants/$merchantId/services'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['services'] ?? []);
      }
      return [];
    } catch (e) {
      print('Get services error: $e');
      return [];
    }
  }

  // Time slot methods
  static Future<List<Map<String, dynamic>>> getAvailableSlots({
    required String merchantId,
    required String date,
    required int serviceDuration,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/merchants/$merchantId/slots?date=$date&duration=$serviceDuration'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['slots'] ?? []);
      }
      return [];
    } catch (e) {
      print('Get slots error: $e');
      return [];
    }
  }

  // Appointment methods
  static Future<Map<String, dynamic>?> createAppointment({
    required String merchantId,
    required String serviceId,
    required String dateTime,
    required Map<String, dynamic> customerInfo,
    String? customerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appointments'),
        headers: _headers,
        body: jsonEncode({
          'merchantId': merchantId,
          'serviceId': serviceId,
          'dateTime': dateTime,
          'customerInfo': customerInfo,
          'customerId': customerId,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Create appointment error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getAppointmentById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Get appointment error: $e');
      return null;
    }
  }

  // Cloudinary image methods
  static String getOptimizedImageUrl(String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    final transformations = <String>[];
    
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_$format');
    
    final transformation = transformations.join(',');
    return '${CloudinaryConfig.baseUrl}/image/upload/$transformation/$publicId';
  }

  static String getThumbnailUrl(String publicId) {
    return getOptimizedImageUrl(
      publicId,
      width: 300,
      height: 200,
      quality: 'auto',
      format: 'webp',
    );
  }

  static String getHeroImageUrl(String publicId) {
    return getOptimizedImageUrl(
      publicId,
      width: 800,
      height: 400,
      quality: 'auto',
      format: 'webp',
    );
  }

  // Utility methods
  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Sample merchants with Cloudinary image URLs
  static List<Map<String, dynamic>> getSampleMerchants() {
    return [
      {
        'id': '1',
        'name': 'Glamour Salon',
        'description': 'Premium beauty and hair services',
        'category': 'Beauty',
        'rating': 4.8,
        'reviewCount': 124,
        'address': '123 Beauty Street, City Center',
        'phone': '+1 (555) 123-4567',
        'email': 'info@glamoursalon.com',
        'images': ['zarya/sample/salon1'], // Cloudinary public ID
        'services': ['1', '2', '3'],
        'workingHours': [
          {'day': 'Monday', 'startTime': '09:00', 'endTime': '18:00', 'isOpen': true},
          {'day': 'Tuesday', 'startTime': '09:00', 'endTime': '18:00', 'isOpen': true},
          {'day': 'Wednesday', 'startTime': '09:00', 'endTime': '18:00', 'isOpen': true},
          {'day': 'Thursday', 'startTime': '09:00', 'endTime': '18:00', 'isOpen': true},
          {'day': 'Friday', 'startTime': '09:00', 'endTime': '19:00', 'isOpen': true},
          {'day': 'Saturday', 'startTime': '08:00', 'endTime': '17:00', 'isOpen': true},
          {'day': 'Sunday', 'startTime': '10:00', 'endTime': '16:00', 'isOpen': false},
        ],
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];
  }

  // Sample services
  static List<Map<String, dynamic>> getSampleServices([String? merchantId]) {
    if (merchantId != null) {
      // Return services for specific merchant
      final allServices = [
        {
          'id': '1',
          'merchantId': '1',
          'name': 'Hair Cut & Style',
          'description': 'Professional haircut with styling',
          'price': 45.0,
          'duration': 60,
          'category': 'Hair',
          'isActive': true,
          'images': ['zarya/sample/haircut'], // Cloudinary public ID
          'createdAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        // Add more services
      ];
      return allServices.where((service) => service['merchantId'] == merchantId).toList();
    }
    
    // Return all services if no merchantId specified
    return [
      {
        'id': '1',
        'merchantId': '1',
        'name': 'Hair Cut & Style',
        'description': 'Professional haircut with styling',
        'price': 45.0,
        'duration': 60,
        'category': 'Hair',
        'isActive': true,
        'images': ['zarya/sample/haircut'], // Cloudinary public ID
        'createdAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      // Add more services
    ];
  }

}
