import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/merchant.dart';
import '../models/service.dart';
import '../models/appointment.dart';

class ApiService {
  // Replace with your actual API base URL
  static const String baseUrl = 'https://your-api-domain.com/api';
  
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

  // Merchant Profile Management
  static Future<Merchant?> getMerchantProfile(String merchantId, String? token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/merchants/$merchantId'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Merchant.fromMap(data, id: merchantId);
      }
      return null;
    } catch (e) {
      print('Error fetching merchant profile: $e');
      return null;
    }
  }

  static Future<bool> updateMerchantProfile(Merchant merchant, String? token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/merchants/${merchant.id}'),
        headers: _getAuthHeaders(token),
        body: jsonEncode(merchant.toMap()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating merchant profile: $e');
      return false;
    }
  }

  // Service Management
  static Future<List<Service>> getServices(String merchantId, String? token) async {
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
