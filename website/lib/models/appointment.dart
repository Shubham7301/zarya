// Removed Firestore dependency

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  rescheduled
}

class CustomerInfo {
  final String name;
  final String email;
  final String phone;

  CustomerInfo({
    required this.name,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory CustomerInfo.fromMap(Map<String, dynamic> map) {
    return CustomerInfo(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}

class Appointment {
  final String? id;
  final String customerId;
  final String merchantId;
  final String serviceId;
  final String serviceName;
  final DateTime dateTime;
  final AppointmentStatus status;
  final CustomerInfo customerInfo;
  final double price;
  final int duration; // in minutes
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    this.id,
    required this.customerId,
    required this.merchantId,
    required this.serviceId,
    required this.serviceName,
    required this.dateTime,
    required this.status,
    required this.customerInfo,
    required this.price,
    required this.duration,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'merchantId': merchantId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'dateTime': dateTime.toIso8601String(),
      'status': status.name,
      'customerInfo': customerInfo.toMap(),
      'price': price,
      'duration': duration,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map, {String? id}) {
    return Appointment(
      id: id,
      customerId: map['customerId'] ?? '',
      merchantId: map['merchantId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      dateTime: map['dateTime'] is String 
          ? DateTime.parse(map['dateTime'])
          : DateTime.now(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      customerInfo: CustomerInfo.fromMap(map['customerInfo'] ?? {}),
      price: (map['price'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? 60,
      notes: map['notes'],
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

  Appointment copyWith({
    String? id,
    String? customerId,
    String? merchantId,
    String? serviceId,
    String? serviceName,
    DateTime? dateTime,
    AppointmentStatus? status,
    CustomerInfo? customerInfo,
    double? price,
    int? duration,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      merchantId: merchantId ?? this.merchantId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      customerInfo: customerInfo ?? this.customerInfo,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
