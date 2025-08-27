enum SubscriptionStatus {
  active,
  expired,
  suspended,
  pending,
  cancelled,
}

enum SubscriptionPlan {
  freeTrial,
  basic,
  premium,
  enterprise,
}

class MerchantSubscription {
  final String id;
  final String merchantId;
  final String planName;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String currency;
  final List<String> features;
  final String? paymentMethod;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;

  MerchantSubscription({
    required this.id,
    required this.merchantId,
    required this.planName,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.currency,
    required this.features,
    this.paymentMethod,
    this.transactionId,
    required this.createdAt,
    this.updatedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'planName': planName,
      'plan': plan.name,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'features': features,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory MerchantSubscription.fromMap(Map<String, dynamic> map, {String? id}) {
    return MerchantSubscription(
      id: id ?? map['id'] ?? '',
      merchantId: map['merchantId'] ?? '',
      planName: map['planName'] ?? map['plan'] ?? 'Basic',
      plan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == map['plan'],
        orElse: () => SubscriptionPlan.basic,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SubscriptionStatus.pending,
      ),
      startDate: map['startDate'] is String 
          ? DateTime.parse(map['startDate'])
          : DateTime.now(),
      endDate: map['endDate'] is String 
          ? DateTime.parse(map['endDate'])
          : DateTime.now().add(const Duration(days: 30)),
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'INR',
      features: List<String>.from(map['features'] ?? []),
      paymentMethod: map['paymentMethod'],
      transactionId: map['transactionId'],
      createdAt: map['createdAt'] is String 
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] is String 
              ? DateTime.parse(map['updatedAt'])
              : DateTime.now())
          : null,
      notes: map['notes'],
    );
  }

  factory MerchantSubscription.fromJson(Map<String, dynamic> json) {
    return MerchantSubscription.fromMap(json, id: json['id']);
  }

  MerchantSubscription copyWith({
    String? id,
    String? merchantId,
    String? planName,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? amount,
    String? currency,
    List<String>? features,
    String? paymentMethod,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return MerchantSubscription(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      planName: planName ?? this.planName,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      features: features ?? this.features,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  // Check if subscription is active
  bool get isActive {
    return status == SubscriptionStatus.active && 
           DateTime.now().isBefore(endDate);
  }

  // Check if subscription is expired
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  // Get days remaining
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  // Get subscription duration in months
  int get durationInMonths {
    return ((endDate.year - startDate.year) * 12) + 
           (endDate.month - startDate.month);
  }

  // Get formatted plan name
  String get planDisplayName {
    switch (plan) {
      case SubscriptionPlan.freeTrial:
        return 'Free Trial';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  // Get formatted status
  String get statusDisplayName {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.suspended:
        return 'Suspended';
      case SubscriptionStatus.pending:
        return 'Pending';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Get formatted amount
  String get formattedAmount {
    return '$currency ${amount.toStringAsFixed(2)}';
  }
}
