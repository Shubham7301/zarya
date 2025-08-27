class NotificationData {
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  NotificationData({
    required this.title,
    required this.message,
    required this.type,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      timestamp: map['timestamp'] is String 
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }
}
