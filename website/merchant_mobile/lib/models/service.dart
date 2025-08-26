class Service {
  final String? id;
  final String name;
  final String description;
  final double price;
  final int duration; // in minutes
  final List<String> images;
  final String category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Service({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.images,
    required this.category,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'images': images,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Service.fromMap(Map<String, dynamic> map, {String? id}) {
    return Service(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? 60,
      images: List<String>.from(map['images'] ?? []),
      category: map['category'] ?? '',
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

  Service copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? duration,
    List<String>? images,
    String? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      images: images ?? this.images,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Format duration as hours and minutes
  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  // Format price with currency
  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }
}
