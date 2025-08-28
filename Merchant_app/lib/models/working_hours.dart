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

  // Default working hours for each day
  static List<WorkingHours> getDefaultWorkingHours() {
    return [
      WorkingHours(day: 'Monday', startTime: '09:00', endTime: '17:00', isOpen: true),
      WorkingHours(day: 'Tuesday', startTime: '09:00', endTime: '17:00', isOpen: true),
      WorkingHours(day: 'Wednesday', startTime: '09:00', endTime: '17:00', isOpen: true),
      WorkingHours(day: 'Thursday', startTime: '09:00', endTime: '17:00', isOpen: true),
      WorkingHours(day: 'Friday', startTime: '09:00', endTime: '17:00', isOpen: true),
      WorkingHours(day: 'Saturday', startTime: '10:00', endTime: '16:00', isOpen: true),
      WorkingHours(day: 'Sunday', startTime: '10:00', endTime: '16:00', isOpen: false),
    ];
  }

  // Get day abbreviation
  String get dayAbbreviation {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'Mon';
      case 'tuesday':
        return 'Tue';
      case 'wednesday':
        return 'Wed';
      case 'thursday':
        return 'Thu';
      case 'friday':
        return 'Fri';
      case 'saturday':
        return 'Sat';
      case 'sunday':
        return 'Sun';
      default:
        return day.substring(0, 3);
    }
  }

  // Format time for display
  String get formattedTime {
    if (!isOpen) return 'Closed';
    return '$startTime - $endTime';
  }

  // Check if current time is within working hours
  bool get isCurrentlyOpen {
    if (!isOpen) return false;
    
    final now = DateTime.now();
    final currentDay = _getDayName(now.weekday);
    if (currentDay != day) return false;
    
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return currentTime.compareTo(startTime) >= 0 && currentTime.compareTo(endTime) <= 0;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

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
        other.isOpen == this.isOpen;
  }

  @override
  int get hashCode {
    return day.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        isOpen.hashCode;
  }
}
