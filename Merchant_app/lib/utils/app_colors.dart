import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryColor = Color(0xFF2196F3); // Alias for primary
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  
  // Secondary colors
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFE0B2);
  
  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF5F5F5);
  
  // Appointment status colors
  static const Color pending = Color(0xFFFFA500);
  static const Color confirmed = Color(0xFF4CAF50);
  static const Color completed = Color(0xFF2196F3);
  static const Color cancelled = Color(0xFFF44336);
  static const Color noShow = Color(0xFF9E9E9E);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
