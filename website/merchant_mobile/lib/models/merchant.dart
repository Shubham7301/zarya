class WorkingHours {
  final String day;
  final String startTime;
  final String endTime;
  final bool isOpen;

  WorkingHours({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isOpen,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'isOpen': isOpen,
    };
  }

  factory WorkingHours.fromMap(Map<String, dynamic> map) {
    return WorkingHours(
      day: map['day'] ?? '',
      startTime: map['startTime'] ?? '09:00',
      endTime: map['endTime'] ?? '17:00',
      isOpen: map['isOpen'] ?? true,
    );
  }
}

class Merchant {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String description;
  final String category; // salon, clinic, spa, etc.
  final List<String> images;
  final List<WorkingHours> workingHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Merchant({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.description,
    required this.category,
    required this.images,
    required this.workingHours,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'description': description,
      'category': category,
      'images': images,
      'workingHours': workingHours.map((wh) => wh.toMap()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Merchant.fromMap(Map<String, dynamic> map, {String? id}) {
    return Merchant(
      id: id,
      name: map['name'] ?? '',
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

  Merchant copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? description,
    String? category,
    List<String>? images,
    List<WorkingHours>? workingHours,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Merchant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      description: description ?? this.description,
      category: category ?? this.category,
      images: images ?? this.images,
      workingHours: workingHours ?? this.workingHours,
      isActive: isActive ?? this.isActive,
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
}
