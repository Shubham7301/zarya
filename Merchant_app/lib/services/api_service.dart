import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/merchant.dart';
import '../models/service.dart';
import '../models/appointment.dart';
import '../config/cloudinary_config.dart';
import '../config/app_config.dart';

class ApiService {
  // Use configuration for API base URL
  static String get baseUrl => AppConfig.currentApiUrl;
  
  // Headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Add auth token to headers if available
  static Map<String, String> _getAuthHeaders(String? token) {
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Merchant authentication
  static Future<Map<String, dynamic>> merchantLogin(String email, String password) async {
    // Demo mode - return mock authentication
    if (AppConfig.enableMockData) {
      return _getDemoLoginResponse(email, password);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/merchant/login'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Demo login response
  static Map<String, dynamic> _getDemoLoginResponse(String email, String password) {
    // Demo credentials
    final demoCredentials = {
      'sarah@beautysalonpro.com': 'password123',
      'merchant@gmail.com': 'gmail123',
      'demo@merchant.com': 'demo123',
      'test@business.com': 'test123',
      'admin@zarya.com': 'Admin123!',
    };

    if (demoCredentials.containsKey(email) && demoCredentials[email] == password) {
      return {
        'success': true,
        'token': 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
        'merchant': {
          'id': 'demo_merchant_001',
          'businessName': 'Demo Beauty Salon',
          'ownerName': 'Sarah Johnson',
          'email': email,
          'phone': '+1 (555) 123-4567',
          'address': '123 Beauty Street, Downtown, NY 10001',
          'businessType': 'Beauty & Wellness',
          'status': 'active',
          'description': 'Professional beauty salon offering hair, makeup, and spa services.',
          'category': 'Beauty & Wellness',
          'images': [
            'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=250&fit=crop',
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400&h=250&fit=crop',
          ],
          'workingHours': [
            {'day': 'Monday', 'startTime': '09:00', 'endTime': '18:00', 'isOpen': true},
            {'day': 'Tuesday', 'startTime': '09:00', 'endTime': '18:00', 'isOpen': true},
            {'day': 'Wednesday', 'startTime': '09:00', 'endTime': '18:00', 'isOpen': true},
            {'day': 'Thursday', 'startTime': '09:00', 'endTime': '18:00', 'isOpen': true},
            {'day': 'Friday', 'startTime': '09:00', 'endTime': '18:00', 'isOpen': true},
            {'day': 'Saturday', 'startTime': '10:00', 'endTime': '16:00', 'isOpen': true},
            {'day': 'Sunday', 'startTime': '10:00', 'endTime': '16:00', 'isOpen': false},
          ],
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
        },
        'message': 'Demo login successful! Welcome to the Zarya Merchant App.',
      };
    } else {
      return {
        'success': false,
        'error': 'Invalid email or password. Try: sarah@beautysalonpro.com / password123 or merchant@gmail.com / gmail123',
      };
    }
  }

  // Get merchant profile
  static Future<Merchant?> getMerchantProfile(String merchantId, String? token) async {
    // Demo mode - return mock profile
    if (AppConfig.enableMockData) {
      return _getDemoMerchantProfile();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _getAuthHeaders(token),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return Merchant.fromJson(data['user']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get merchant profile: $e');
    }
  }

  // Demo merchant profile
  static Merchant _getDemoMerchantProfile() {
    return Merchant(
      id: '1',
      businessName: 'Demo Beauty Salon',
      ownerName: 'Sarah Johnson',
      email: 'sarah@beautysalonpro.com',
      phone: '+1-555-0123',
      address: '123 Main St, Downtown',
      city: 'New York',
      businessType: 'Beauty & Wellness',
      status: 'active',
      description: 'Professional beauty salon services',
      category: 'Beauty & Wellness',
      images: [],
      workingHours: [],
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  // Update merchant profile
  static Future<bool> updateMerchantProfile(Merchant merchant, String? token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _getAuthHeaders(token),
        body: json.encode(merchant.toJson()),
      ).timeout(AppConfig.apiTimeout);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update merchant profile: $e');
    }
  }

  // Get optimized image URL
  static String getOptimizedImageUrl(
    String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
    String crop = 'fill',
  }) {
    final transformations = <String>[];
    
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('c_$crop');
    transformations.add('q_$quality');
    transformations.add('f_$format');
    
    final transformation = transformations.join(',');
    return '${CloudinaryConfig.baseUrl}/image/upload/$transformation/$publicId';
  }

  // Predefined image sizes
  static String getThumbnailUrl(String publicId) => getOptimizedImageUrl(
    publicId,
    width: 300,
    height: 200,
    quality: 'auto',
  );

  static String getCardImageUrl(String publicId) => getOptimizedImageUrl(
    publicId,
    width: 400,
    height: 250,
    quality: 'auto',
  );

  static String getHeroImageUrl(String publicId) => getOptimizedImageUrl(
    publicId,
    width: 800,
    height: 400,
    quality: 'auto',
  );

  // Service Management
  static Future<List<Service>> getServices(String merchantId, String? token) async {
    // Demo mode - return mock services
    if (AppConfig.enableMockData) {
      return _getDemoServices();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/merchants/$merchantId/services'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Service.fromMap(item, id: item['id'])).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching services: $e');
      return [];
    }
  }

  // Demo services
  static List<Service> _getDemoServices() {
    return [
      Service(
        id: 'service_001',
        merchantId: '1',
        name: 'Haircut & Styling',
        description: 'Professional haircut and styling service',
        duration: 60,
        price: 3750.0,
        category: 'Hair',
        staffIds: [],
        isActive: true,
        images: ['https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=250&fit=crop'],
        createdAt: DateTime.now(),
      ),
      Service(
        id: 'service_002',
        merchantId: '1',
        name: 'Hair Coloring',
        description: 'Full hair coloring service with premium products',
        duration: 120,
        price: 7000.0,
        category: 'Hair',
        staffIds: [],
        isActive: true,
        images: ['https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400&h=250&fit=crop'],
        createdAt: DateTime.now(),
      ),
      Service(
        id: 'service_003',
        merchantId: '1',
        name: 'Manicure',
        description: 'Classic manicure with nail polish',
        duration: 45,
        price: 2000.0,
        category: 'Nails',
        staffIds: [],
        isActive: true,
        images: ['https://images.unsplash.com/photo-1604654894610-df63bc536371?w=400&h=250&fit=crop'],
        createdAt: DateTime.now(),
      ),
      Service(
        id: 'service_004',
        merchantId: '1',
        name: 'Facial Treatment',
        description: 'Rejuvenating facial treatment',
        duration: 90,
        price: 5500.0,
        category: 'Skincare',
        staffIds: [],
        isActive: true,
        images: ['https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400&h=250&fit=crop'],
        createdAt: DateTime.now(),
      ),
      Service(
        id: 'service_005',
        merchantId: '1',
        name: 'Makeup Application',
        description: 'Professional makeup for special occasions',
        duration: 75,
        price: 4500.0,
        category: 'Makeup',
        staffIds: [],
        isActive: true,
        images: ['https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400&h=250&fit=crop'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  static Future<Service?> createService(Service service, String merchantId, String? token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/merchants/$merchantId/services'),
        headers: _getAuthHeaders(token),
        body: jsonEncode(service.toMap()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Service.fromMap(data, id: data['id']);
      }
      return null;
    } catch (e) {
      print('Error creating service: $e');
      return null;
    }
  }

  static Future<bool> updateService(Service service, String merchantId, String? token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/merchants/$merchantId/services/${service.id}'),
        headers: _getAuthHeaders(token),
        body: jsonEncode(service.toMap()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating service: $e');
      return false;
    }
  }

  static Future<bool> deleteService(String serviceId, String merchantId, String? token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/merchants/$merchantId/services/$serviceId'),
        headers: _getAuthHeaders(token),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }

  // Appointment Management
  static Future<List<Appointment>> getAppointments(
    String merchantId, 
    String? token, {
    DateTime? startDate,
    DateTime? endDate,
    AppointmentStatus? status,
  }) async {
    // Demo mode - return mock appointments
    if (AppConfig.enableMockData) {
      return _getDemoAppointments();
    }

    try {
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (status != null) {
        queryParams['status'] = status.name;
      }

      final uri = Uri.parse('$baseUrl/merchants/$merchantId/appointments')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Appointment.fromMap(item, id: item['id'])).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  // Demo appointments
  static List<Appointment> _getDemoAppointments() {
    final now = DateTime.now();
    return [
      Appointment(
        id: 'appointment_001',
        merchantId: '1',
        customerId: 'customer_001',
        customerName: 'Emma Wilson',
        customerEmail: 'emma.wilson@email.com',
        customerPhone: '+1 (555) 123-4567',
        serviceId: 'service_001',
        serviceName: 'Haircut & Styling',
        servicePrice: 3750.0,
        appointmentDate: DateTime(now.year, now.month, now.day + 1),
        appointmentTime: '10:00',
        status: AppointmentStatus.confirmed,
        bookingType: BookingType.online,
        notes: 'Customer prefers layered cut',
        createdAt: DateTime.now(),
      ),
      Appointment(
        id: 'appointment_002',
        merchantId: '1',
        customerId: 'customer_002',
        customerName: 'Michael Brown',
        customerEmail: 'michael.brown@email.com',
        customerPhone: '+1 (555) 234-5678',
        serviceId: 'service_002',
        serviceName: 'Hair Coloring',
        servicePrice: 7000.0,
        appointmentDate: DateTime(now.year, now.month, now.day + 2),
        appointmentTime: '14:00',
        status: AppointmentStatus.pending,
        bookingType: BookingType.online,
        notes: 'First time client',
        createdAt: DateTime.now(),
      ),
      Appointment(
        id: 'appointment_003',
        merchantId: '1',
        customerId: 'customer_003',
        customerName: 'Sarah Davis',
        customerEmail: 'sarah.davis@email.com',
        customerPhone: '+1 (555) 345-6789',
        serviceId: 'service_003',
        serviceName: 'Manicure',
        servicePrice: 2000.0,
        appointmentDate: DateTime(now.year, now.month, now.day),
        appointmentTime: '16:00',
        status: AppointmentStatus.completed,
        bookingType: BookingType.online,
        notes: 'Regular client - prefers French manicure',
        createdAt: DateTime.now(),
      ),
      Appointment(
        id: 'appointment_004',
        merchantId: '1',
        customerId: 'customer_004',
        customerName: 'Jennifer Lee',
        customerEmail: 'jennifer.lee@email.com',
        customerPhone: '+1 (555) 456-7890',
        serviceId: 'service_004',
        serviceName: 'Facial Treatment',
        servicePrice: 5500.0,
        appointmentDate: DateTime(now.year, now.month, now.day + 3),
        appointmentTime: '11:00',
        status: AppointmentStatus.confirmed,
        bookingType: BookingType.online,
        notes: 'Sensitive skin - use gentle products',
        createdAt: DateTime.now(),
      ),
      Appointment(
        id: 'appointment_005',
        merchantId: '1',
        customerId: 'customer_005',
        customerName: 'Amanda Garcia',
        customerEmail: 'amanda.garcia@email.com',
        customerPhone: '+1 (555) 567-8901',
        serviceId: 'service_005',
        serviceName: 'Makeup Application',
        servicePrice: 4500.0,
        appointmentDate: DateTime(now.year, now.month, now.day + 4),
        appointmentTime: '15:00',
        status: AppointmentStatus.pending,
        bookingType: BookingType.online,
        notes: 'Wedding makeup - natural look preferred',
        createdAt: DateTime.now(),
      ),
    ];
  }

  static Future<bool> updateAppointmentStatus(
    String appointmentId,
    String merchantId,
    AppointmentStatus status,
    String? token,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/merchants/$merchantId/appointments/$appointmentId'),
        headers: _getAuthHeaders(token),
        body: jsonEncode({'status': status.name}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating appointment status: $e');
      return false;
    }
  }

  static Future<bool> addAppointmentNotes(
    String appointmentId,
    String merchantId,
    String notes,
    String? token,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/merchants/$merchantId/appointments/$appointmentId'),
        headers: _getAuthHeaders(token),
        body: jsonEncode({'notes': notes}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error adding appointment notes: $e');
      return false;
    }
  }

  // Dashboard Statistics
  static Future<Map<String, dynamic>> getDashboardStats(
    String merchantId,
    String? token, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Demo mode - return mock dashboard stats
    if (AppConfig.enableMockData) {
      return _getDemoDashboardStats();
    }

    try {
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final uri = Uri.parse('$baseUrl/merchants/$merchantId/dashboard')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {};
    }
  }

  // Demo dashboard statistics
  static Map<String, dynamic> _getDemoDashboardStats() {
    return {
      'totalAppointments': 25,
      'completedAppointments': 18,
      'pendingAppointments': 5,
      'cancelledAppointments': 2,
      'totalRevenue': 108000.0,
      'averageRating': 4.8,
      'totalCustomers': 15,
      'recentAppointments': [
        {
          'id': 'appointment_001',
          'customerName': 'Emma Wilson',
          'serviceName': 'Haircut & Styling',
          'date': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'status': 'confirmed',
        },
        {
          'id': 'appointment_002',
          'customerName': 'Michael Brown',
          'serviceName': 'Hair Coloring',
          'date': DateTime.now().add(Duration(days: 2)).toIso8601String(),
          'status': 'pending',
        },
      ],
      'topServices': [
        {'name': 'Haircut & Styling', 'count': 8, 'revenue': 30000.0},
        {'name': 'Hair Coloring', 'count': 5, 'revenue': 35000.0},
        {'name': 'Manicure', 'count': 6, 'revenue': 12000.0},
        {'name': 'Facial Treatment', 'count': 4, 'revenue': 22000.0},
        {'name': 'Makeup Application', 'count': 2, 'revenue': 9000.0},
      ],
    };
  }

  // Error handling helper
  static String _handleError(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      return errorData['message'] ?? 'An error occurred';
    } catch (e) {
      return 'An error occurred (${response.statusCode})';
    }
  }
}
