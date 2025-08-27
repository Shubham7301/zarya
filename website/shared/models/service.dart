import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String? id;
  final String merchantId;
  final String name;
  final String description;
  final double price;
  final int duration; // in minutes
  final String category;
  final bool isActive;
  final List<String> images;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Service({
    this.id,
    required this.merchantId,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.category,
    required this.isActive,
    required this.images,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'category': category,
      'isActive': isActive,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map, {String? id}) {
    return Service(
      id: id,
      merchantId: map['merchantId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? 60,
      category: map['category'] ?? '',
      isActive: map['isActive'] ?? true,
      images: List<String>.from(map['images'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Service copyWith({
    String? id,
    String? merchantId,
    String? name,
    String? description,
    double? price,
    int? duration,
    String? category,
    bool? isActive,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Format price as currency
  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  // Format duration as human readable
  String get formattedDuration {
    if (duration < 60) {
      return '${duration}min';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (minutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${minutes}min';
      }
    }
  }
}
