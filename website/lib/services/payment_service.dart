import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';

/// Payment service for handling booking payments
/// This is a demo implementation with dummy payment methods
class PaymentService {
  static final Random _random = Random();
  
  // Available payment methods
  static const List<PaymentMethod> availablePaymentMethods = [
    PaymentMethod(
      id: 'card',
      name: 'Credit/Debit Card',
      description: 'Visa, Mastercard, American Express',
      icon: '💳',
      processingFee: 2.9, // 2.9% + 30¢
      processingTime: 'Instant',
      isEnabled: true,
    ),
    PaymentMethod(
      id: 'paypal',
      name: 'PayPal',
      description: 'Pay with your PayPal account',
      icon: '🅿️',
      processingFee: 3.5, // 3.5% + 15¢
      processingTime: 'Instant',
      isEnabled: true,
    ),
    PaymentMethod(
      id: 'apple_pay',
      name: 'Apple Pay',
      description: 'Pay with Touch ID or Face ID',
      icon: '🍎',
      processingFee: 2.9,
      processingTime: 'Instant',
      isEnabled: true,
    ),
    PaymentMethod(
      id: 'google_pay',
      name: 'Google Pay',
      description: 'Pay with your Google account',
      icon: '🌐',
      processingFee: 2.9,
      processingTime: 'Instant',
      isEnabled: true,
    ),
    PaymentMethod(
      id: 'bank_transfer',
      name: 'Bank Transfer',
      description: 'Direct bank account transfer',
      icon: '🏦',
      processingFee: 0.5, // Fixed $0.50 fee
      processingTime: '1-3 business days',
      isEnabled: true,
    ),
    PaymentMethod(
      id: 'cash',
      name: 'Pay at Location',
      description: 'Pay when you arrive for your appointment',
      icon: '💵',
      processingFee: 0.0,
      processingTime: 'At appointment',
      isEnabled: true,
    ),
  ];

  /// Process a payment with dummy implementation
  static Future<PaymentResult> processPayment({
    required String paymentMethodId,
    required double amount,
    required String currency,
    required String appointmentId,
    required PaymentDetails paymentDetails,
  }) async {
    debugPrint('Processing payment: $paymentMethodId, Amount: $amount $currency');
    
    // Simulate processing time
    await _simulateProcessingDelay(paymentMethodId);
    
    // Simulate success/failure (90% success rate)
    final isSuccess = _random.nextDouble() > 0.1;
    
    if (isSuccess) {
      return _createSuccessResult(paymentMethodId, amount, currency, appointmentId);
    } else {
      return _createFailureResult(paymentMethodId, amount);
    }
  }

  /// Calculate total amount including fees
  static PaymentCalculation calculateTotal({
    required double serviceAmount,
    required String paymentMethodId,
    double taxRate = 0.08, // 8% default tax
    double? tipAmount,
  }) {
    final paymentMethod = getPaymentMethod(paymentMethodId);
    
    // Calculate subtotal
    final subtotal = serviceAmount;
    
    // Calculate tax
    final tax = subtotal * taxRate;
    
    // Calculate payment processing fee
    final processingFee = paymentMethod?.processingFee != null
        ? (subtotal * (paymentMethod!.processingFee / 100)) + 0.30 // percentage + fixed fee
        : 0.0;
    
    // Add tip if provided
    final tip = tipAmount ?? 0.0;
    
    // Calculate total
    final total = subtotal + tax + processingFee + tip;
    
    return PaymentCalculation(
      subtotal: subtotal,
      tax: tax,
      processingFee: processingFee,
      tip: tip,
      total: total,
      paymentMethod: paymentMethod!,
    );
  }

  /// Get payment method by ID
  static PaymentMethod? getPaymentMethod(String id) {
    return availablePaymentMethods.where((method) => method.id == id).firstOrNull;
  }

  /// Get enabled payment methods
  static List<PaymentMethod> getEnabledPaymentMethods() {
    return availablePaymentMethods.where((method) => method.isEnabled).toList();
  }

  /// Validate payment details
  static PaymentValidation validatePaymentDetails({
    required String paymentMethodId,
    required PaymentDetails details,
  }) {
    final errors = <String>[];
    
    switch (paymentMethodId) {
      case 'card':
        if (details.cardNumber == null || details.cardNumber!.length < 13) {
          errors.add('Invalid card number');
        }
        if (details.expiryMonth == null || details.expiryYear == null) {
          errors.add('Invalid expiry date');
        }
        if (details.cvv == null || details.cvv!.length < 3) {
          errors.add('Invalid CVV');
        }
        if (details.cardholderName == null || details.cardholderName!.isEmpty) {
          errors.add('Cardholder name is required');
        }
        break;
      
      case 'paypal':
        if (details.email == null || !details.email!.contains('@')) {
          errors.add('Valid PayPal email is required');
        }
        break;
      
      case 'bank_transfer':
        if (details.accountNumber == null || details.accountNumber!.isEmpty) {
          errors.add('Bank account number is required');
        }
        if (details.routingNumber == null || details.routingNumber!.isEmpty) {
          errors.add('Routing number is required');
        }
        break;
      
      case 'apple_pay':
      case 'google_pay':
      case 'cash':
        // These methods don't require additional validation
        break;
      
      default:
        errors.add('Unknown payment method');
    }
    
    return PaymentValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Simulate processing delay based on payment method
  static Future<void> _simulateProcessingDelay(String paymentMethodId) async {
    final delayMs = switch (paymentMethodId) {
      'card' => 2000 + _random.nextInt(2000), // 2-4 seconds
      'paypal' => 1500 + _random.nextInt(2500), // 1.5-4 seconds
      'apple_pay' || 'google_pay' => 800 + _random.nextInt(1200), // 0.8-2 seconds
      'bank_transfer' => 3000 + _random.nextInt(2000), // 3-5 seconds
      'cash' => 500, // Instant confirmation
      _ => 2000,
    };
    
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  /// Create successful payment result
  static PaymentResult _createSuccessResult(
    String paymentMethodId,
    double amount,
    String currency,
    String appointmentId,
  ) {
    return PaymentResult(
      isSuccess: true,
      transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}',
      paymentMethodId: paymentMethodId,
      amount: amount,
      currency: currency,
      processedAt: DateTime.now(),
      message: 'Payment processed successfully',
      appointmentId: appointmentId,
    );
  }

  /// Create failed payment result
  static PaymentResult _createFailureResult(String paymentMethodId, double amount) {
    final errorMessages = [
      'Insufficient funds',
      'Card declined',
      'Payment method temporarily unavailable',
      'Network error - please try again',
      'Invalid payment information',
    ];
    
    return PaymentResult(
      isSuccess: false,
      paymentMethodId: paymentMethodId,
      amount: amount,
      processedAt: DateTime.now(),
      message: errorMessages[_random.nextInt(errorMessages.length)],
      errorCode: 'ERR_${_random.nextInt(9999)}',
    );
  }

  /// Refund a payment (dummy implementation)
  static Future<PaymentResult> refundPayment({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    debugPrint('Processing refund: $transactionId, Amount: $amount');
    
    // Simulate processing time
    await Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(3000)));
    
    // 95% success rate for refunds
    final isSuccess = _random.nextDouble() > 0.05;
    
    if (isSuccess) {
      return PaymentResult(
        isSuccess: true,
        transactionId: 'REF_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}',
        paymentMethodId: 'refund',
        amount: amount,
        currency: 'USD',
        processedAt: DateTime.now(),
        message: 'Refund processed successfully',
      );
    } else {
      return PaymentResult(
        isSuccess: false,
        paymentMethodId: 'refund',
        amount: amount,
        processedAt: DateTime.now(),
        message: 'Refund failed - please contact support',
        errorCode: 'REF_ERR_${_random.nextInt(9999)}',
      );
    }
  }
}

/// Payment method model
class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final String icon;
  final double processingFee; // Percentage fee
  final String processingTime;
  final bool isEnabled;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.processingFee,
    required this.processingTime,
    required this.isEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'processingFee': processingFee,
      'processingTime': processingTime,
      'isEnabled': isEnabled,
    };
  }
}

/// Payment details model
class PaymentDetails {
  final String? cardNumber;
  final int? expiryMonth;
  final int? expiryYear;
  final String? cvv;
  final String? cardholderName;
  final String? email;
  final String? accountNumber;
  final String? routingNumber;
  final Map<String, dynamic>? additionalData;

  PaymentDetails({
    this.cardNumber,
    this.expiryMonth,
    this.expiryYear,
    this.cvv,
    this.cardholderName,
    this.email,
    this.accountNumber,
    this.routingNumber,
    this.additionalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardNumber': cardNumber,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'cardholderName': cardholderName,
      'email': email,
      'accountNumber': accountNumber,
      'routingNumber': routingNumber,
      'additionalData': additionalData,
    };
  }
}

/// Payment result model
class PaymentResult {
  final bool isSuccess;
  final String? transactionId;
  final String paymentMethodId;
  final double amount;
  final String? currency;
  final DateTime processedAt;
  final String message;
  final String? errorCode;
  final String? appointmentId;

  PaymentResult({
    required this.isSuccess,
    this.transactionId,
    required this.paymentMethodId,
    required this.amount,
    this.currency,
    required this.processedAt,
    required this.message,
    this.errorCode,
    this.appointmentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'isSuccess': isSuccess,
      'transactionId': transactionId,
      'paymentMethodId': paymentMethodId,
      'amount': amount,
      'currency': currency,
      'processedAt': processedAt.toIso8601String(),
      'message': message,
      'errorCode': errorCode,
      'appointmentId': appointmentId,
    };
  }
}

/// Payment calculation model
class PaymentCalculation {
  final double subtotal;
  final double tax;
  final double processingFee;
  final double tip;
  final double total;
  final PaymentMethod paymentMethod;

  PaymentCalculation({
    required this.subtotal,
    required this.tax,
    required this.processingFee,
    required this.tip,
    required this.total,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'subtotal': subtotal,
      'tax': tax,
      'processingFee': processingFee,
      'tip': tip,
      'total': total,
      'paymentMethod': paymentMethod.toMap(),
    };
  }
}

/// Payment validation result
class PaymentValidation {
  final bool isValid;
  final List<String> errors;

  PaymentValidation({
    required this.isValid,
    required this.errors,
  });
}

/// Extension for Iterable.firstOrNull
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
