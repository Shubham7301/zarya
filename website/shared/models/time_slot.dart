import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSlot {
  final String? id;
  final String merchantId;
  final DateTime date;
  final String startTime; // "09:00"
  final String endTime;   // "09:30"
  final bool isAvailable;
  final String? appointmentId; // if booked
  final DateTime createdAt;
  final DateTime? updatedAt;

  TimeSlot({
    this.id,
    required this.merchantId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.appointmentId,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'appointmentId': appointmentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map, {String? id}) {
    return TimeSlot(
      id: id,
      merchantId: map['merchantId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      appointmentId: map['appointmentId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  TimeSlot copyWith({
    String? id,
    String? merchantId,
    DateTime? date,
    String? startTime,
    String? endTime,
    bool? isAvailable,
    String? appointmentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      appointmentId: appointmentId ?? this.appointmentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get full DateTime for start time
  DateTime get startDateTime {
    final timeParts = startTime.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  // Get full DateTime for end time
  DateTime get endDateTime {
    final timeParts = endTime.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  // Format time range as string
  String get timeRange {
    return '$startTime - $endTime';
  }

  // Check if this slot can accommodate a service duration
  bool canAccommodateService(int serviceDurationMinutes) {
    final slotDuration = endDateTime.difference(startDateTime).inMinutes;
    return slotDuration >= serviceDurationMinutes;
  }

  // Mark slot as booked
  TimeSlot markAsBooked(String appointmentId) {
    return copyWith(
      isAvailable: false,
      appointmentId: appointmentId,
      updatedAt: DateTime.now(),
    );
  }

  // Mark slot as available
  TimeSlot markAsAvailable() {
    return copyWith(
      isAvailable: true,
      appointmentId: null,
      updatedAt: DateTime.now(),
    );
  }
}

