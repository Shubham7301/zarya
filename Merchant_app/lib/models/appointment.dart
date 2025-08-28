enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  noShow,
}

enum BookingType {
  online,
  walkIn,
}

class Appointment {
  final String? id;
  final String merchantId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final String? staffId; // ID of assigned staff member
  final String? staffName; // Name of assigned staff member
  final DateTime appointmentDate;
  final String appointmentTime;
  final AppointmentStatus status;
  final BookingType bookingType;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    this.id,
    required this.merchantId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    this.staffId,
    this.staffName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.bookingType,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'staffId': staffId,
      'staffName': staffName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'appointmentTime': appointmentTime,
      'status': status.name,
      'bookingType': bookingType.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map, {String? id}) {
    return Appointment(
      id: id,
      merchantId: map['merchantId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      servicePrice: (map['servicePrice'] ?? 0.0).toDouble(),
      staffId: map['staffId'],
      staffName: map['staffName'],
      appointmentDate: map['appointmentDate'] is String 
          ? DateTime.parse(map['appointmentDate'])
          : DateTime.now(),
      appointmentTime: map['appointmentTime'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      bookingType: BookingType.values.firstWhere(
        (e) => e.name == map['bookingType'],
        orElse: () => BookingType.online,
      ),
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
    String? merchantId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? serviceId,
    String? serviceName,
    double? servicePrice,
    String? staffId,
    String? staffName,
    DateTime? appointmentDate,
    String? appointmentTime,
    AppointmentStatus? status,
    BookingType? bookingType,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      bookingType: bookingType ?? this.bookingType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get formatted date
  String get formattedDate {
    return '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}';
  }

  // Get formatted time
  String get formattedTime {
    return appointmentTime;
  }

  // Get formatted price
  String get formattedPrice {
    return '₹${servicePrice.toStringAsFixed(2)}';
  }

  // Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
           appointmentDate.month == now.month &&
           appointmentDate.day == now.day;
  }

  // Check if appointment is in the past
  bool get isPast {
    final now = DateTime.now();
    final appointmentDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
    );
    return appointmentDateTime.isBefore(now);
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case AppointmentStatus.pending:
        return '#FFA500'; // Orange
      case AppointmentStatus.confirmed:
        return '#4CAF50'; // Green
      case AppointmentStatus.completed:
        return '#2196F3'; // Blue
      case AppointmentStatus.cancelled:
        return '#F44336'; // Red
      case AppointmentStatus.noShow:
        return '#9E9E9E'; // Grey
    }
  }

  // Get status text
  String get statusText {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  // Get booking type text
  String get bookingTypeText {
    switch (bookingType) {
      case BookingType.online:
        return 'Online';
      case BookingType.walkIn:
        return 'Walk-in';
    }
  }
}
