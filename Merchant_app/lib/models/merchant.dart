import 'working_hours.dart';

class Merchant {
  final String? id;
  final String name;
  final String ownerName;
  final String email;
  final String phone;
  final String address;
  final String description;
  final String category; // salon, clinic, spa, etc.
  final List<String> images;
  final List<WorkingHours> workingHours;
  final bool isActive;
  final String? subscriptionId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Merchant({
    this.id,
    required this.name,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.description,
    required this.category,
    required this.images,
    required this.workingHours,
    required this.isActive,
    this.subscriptionId,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerName': ownerName,
      'email': email,
      'phone': phone,
      'address': address,
      'description': description,
      'category': category,
      'images': images,
      'workingHours': workingHours.map((wh) => wh.toMap()).toList(),
      'isActive': isActive,
      'subscriptionId': subscriptionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Merchant.fromMap(Map<String, dynamic> map, {String? id}) {
    return Merchant(
      id: id,
      name: map['name'] ?? '',
      ownerName: map['ownerName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      workingHours: (map['workingHours'] as List<dynamic>? ?? [])
          .map((wh) => WorkingHours.fromMap(wh))
          .toList(),
      isActive: map['isActive'] ?? true,
      subscriptionId: map['subscriptionId'],
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

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant.fromMap(json, id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  Merchant copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? email,
    String? phone,
    String? address,
    String? description,
    String? category,
    List<String>? images,
    List<WorkingHours>? workingHours,
    bool? isActive,
    String? subscriptionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Merchant(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      description: description ?? this.description,
      category: category ?? this.category,
      images: images ?? this.images,
      workingHours: workingHours ?? this.workingHours,
      isActive: isActive ?? this.isActive,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get working hours for a specific day
  WorkingHours? getWorkingHoursForDay(String day) {
    try {
      return workingHours.firstWhere((wh) => wh.day.toLowerCase() == day.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Check if merchant is open on a specific day
  bool isOpenOnDay(String day) {
    final dayHours = getWorkingHoursForDay(day);
    return dayHours?.isOpen ?? false;
  }

  // Getter for business name (alias for name)
  String get businessName => name;
}
