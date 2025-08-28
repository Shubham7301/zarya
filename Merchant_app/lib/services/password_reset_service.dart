import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class PasswordResetService {
  // Use configuration for API URLs
  static String get baseUrl => AppConfig.currentApiUrl;

  // Request password reset via email
  static Future<Map<String, dynamic>> requestEmailReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
        }),
      ).timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to send email reset: $e');
    }
  }

  // Request password reset via phone
  static Future<Map<String, dynamic>> requestPhoneReset(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/phone'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone': phone,
        }),
      ).timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to send phone reset: $e');
    }
  }

  // Verify reset code
  static Future<Map<String, dynamic>> verifyResetCode(
    String identifier, // email or phone
    String code,
    String type, // 'email' or 'phone'
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/verify'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'identifier': identifier,
          'code': code,
          'type': type,
        }),
      ).timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to verify reset code: $e');
    }
  }

  // Reset password with new password
  static Future<Map<String, dynamic>> resetPassword(
    String identifier, // email or phone
    String code,
    String newPassword,
    String type, // 'email' or 'phone'
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/reset'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'identifier': identifier,
          'code': code,
          'newPassword': newPassword,
          'type': type,
        }),
      ).timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
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

  // Mock implementation for demo purposes
  static Future<Map<String, dynamic>> mockRequestReset(
    String identifier,
    String type,
  ) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate success response
    return {
      'success': true,
      'message': type == 'email' 
        ? 'Password reset link sent to $identifier'
        : 'Password reset SMS sent to $identifier',
      'resetToken': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // Mock implementation for demo purposes
  static Future<Map<String, dynamic>> mockVerifyCode(
    String identifier,
    String code,
    String type,
  ) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock verification (accept any 6-digit code)
    if (code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code)) {
      return {
        'success': true,
        'message': 'Code verified successfully',
        'verified': true,
      };
    } else {
      throw Exception('Invalid verification code');
    }
  }

  // Mock implementation for demo purposes
  static Future<Map<String, dynamic>> mockResetPassword(
    String identifier,
    String code,
    String newPassword,
    String type,
  ) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock password reset
    if (newPassword.length >= 6) {
      return {
        'success': true,
        'message': 'Password reset successfully',
        'reset': true,
      };
    } else {
      throw Exception('Password must be at least 6 characters');
    }
  }
}
