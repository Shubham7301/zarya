import 'package:flutter/material.dart';
import 'service.dart';

class StaffAvailability {
  final String day;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  StaffAvailability({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }

  factory StaffAvailability.fromMap(Map<String, dynamic> map) {
    return StaffAvailability(
      day: map['day'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  StaffAvailability copyWith({
    String? day,
    String? startTime,
    String? endTime,
    bool? isAvailable,
  }) {
    return StaffAvailability(
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class Staff {
  final String? id;
  final String merchantId;
  final String name;
  final String email;
  final String phone;
  final String role; // doctor, stylist, therapist, etc.
  final String specialization;
  final String? profileImage;
  final List<String> serviceIds; // IDs of services this staff can perform
  final List<StaffAvailability> availability;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Staff({
    this.id,
    required this.merchantId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.specialization,
    this.profileImage,
    required this.serviceIds,
    required this.availability,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'specialization': specialization,
      'profileImage': profileImage,
      'serviceIds': serviceIds,
      'availability': availability.map((a) => a.toMap()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map, {String? id}) {
    return Staff(
      id: id,
      merchantId: map['merchantId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      specialization: map['specialization'] ?? '',
      profileImage: map['profileImage'],
      serviceIds: List<String>.from(map['serviceIds'] ?? []),
      availability: (map['availability'] as List<dynamic>? ?? [])
          .map((a) => StaffAvailability.fromMap(a))
          .toList(),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] is String 
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] is String 
              ? DateTime.parse(map['updatedAt'])
              : DateTime.now())
          : null,
    );
  }

  Staff copyWith({
    String? id,
    String? merchantId,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? specialization,
    String? profileImage,
    List<String>? serviceIds,
    List<StaffAvailability>? availability,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Staff(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      specialization: specialization ?? this.specialization,
      profileImage: profileImage ?? this.profileImage,
      serviceIds: serviceIds ?? this.serviceIds,
      availability: availability ?? this.availability,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if staff is available on a specific day and time
  bool isAvailableOn(String day, String time) {
    final dayAvailability = availability.firstWhere(
      (a) => a.day.toLowerCase() == day.toLowerCase(),
      orElse: () => StaffAvailability(
        day: day,
        startTime: '09:00',
        endTime: '17:00',
        isAvailable: false,
      ),
    );

    if (!dayAvailability.isAvailable) return false;

    // Simple time comparison (you might want to use a proper time library)
    return time.compareTo(dayAvailability.startTime) >= 0 && 
           time.compareTo(dayAvailability.endTime) <= 0;
  }

  // Get availability for a specific day
  StaffAvailability? getAvailabilityForDay(String day) {
    try {
      return availability.firstWhere(
        (a) => a.day.toLowerCase() == day.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
