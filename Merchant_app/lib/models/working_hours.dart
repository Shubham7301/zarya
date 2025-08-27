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

  factory WorkingHours.fromMap(Map<String, dynamic> map) {
    return WorkingHours(
      day: map['day'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      isOpen: map['isOpen'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'isOpen': isOpen,
    };
  }

  WorkingHours copyWith({
    String? day,
    String? startTime,
    String? endTime,
    bool? isOpen,
  }) {
    return WorkingHours(
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  @override
  String toString() {
    return 'WorkingHours(day: $day, startTime: $startTime, endTime: $endTime, isOpen: $isOpen)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkingHours &&
        other.day == day &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.isOpen == isOpen;
  }

  @override
  int get hashCode {
    return day.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        isOpen.hashCode;
  }
}
