import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/appointment.dart';
import '../models/service.dart';
import '../models/time_slot.dart';
import '../services/api_service.dart';
import '../services/payment_service.dart';

class BookingProvider with ChangeNotifier {
  final Uuid _uuid = const Uuid();
  
  bool _isLoading = false;
  String? _error;
  List<TimeSlot> _availableSlots = [];
  Appointment? _currentBooking;
  PaymentCalculation? _paymentCalculation;
  PaymentResult? _lastPaymentResult;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TimeSlot> get availableSlots => _availableSlots;
  Appointment? get currentBooking => _currentBooking;
  PaymentCalculation? get paymentCalculation => _paymentCalculation;
  PaymentResult? get lastPaymentResult => _lastPaymentResult;

  // Get available time slots for a merchant on a specific date
  Future<void> fetchAvailableSlots({
    required String merchantId,
    required DateTime date,
    required int serviceDuration,
  }) async {
    _setLoading(true);
    try {
      // Generate sample time slots
      _availableSlots = _generateSampleTimeSlots(merchantId, date, serviceDuration);
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch available slots: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Create a new appointment
  Future<bool> createAppointment({
    required String merchantId,
    required Service service,
    required DateTime dateTime,
    required CustomerInfo customerInfo,
    String? customerId,
  }) async {
    _setLoading(true);
    try {
      final appointmentId = _uuid.v4();
      final appointment = Appointment(
        id: appointmentId,
        customerId: customerId ?? 'guest_${_uuid.v4()}',
        merchantId: merchantId,
        serviceId: service.id!,
        serviceName: service.name,
        dateTime: dateTime,
        status: AppointmentStatus.pending,
        customerInfo: customerInfo,
        price: service.price,
        duration: service.duration,
        createdAt: DateTime.now(),
      );

      // Store the booking
      _currentBooking = appointment;
      _error = null;
      
      // TODO: In production, send to backend API
      // await ApiService.createAppointment(...);
      
      return true;
    } catch (e) {
      _error = 'Failed to create appointment: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Generate sample time slots for demo with more realistic timing
  List<TimeSlot> _generateSampleTimeSlots(String merchantId, DateTime date, int serviceDuration) {
    final slots = <TimeSlot>[];
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // Different schedules based on merchant type
    final merchantSchedule = _getMerchantSchedule(merchantId);
    
    for (final timeSlot in merchantSchedule) {
      final startHour = timeSlot['start'] as int;
      final endHour = timeSlot['end'] as int;
      final intervalMinutes = timeSlot['interval'] as int;
      
      for (int hour = startHour; hour < endHour; hour++) {
        for (int minute = 0; minute < 60; minute += intervalMinutes) {
          final startTime = DateTime(normalizedDate.year, normalizedDate.month, normalizedDate.day, hour, minute);
          final endTime = startTime.add(Duration(minutes: intervalMinutes));
          
          // Skip if end time exceeds working hours
          if (endTime.hour >= endHour) continue;
          
          // Make some slots unavailable for realism
          final isAvailable = _isSlotAvailable(hour, minute, merchantId) &&
                             startTime.isAfter(DateTime.now().add(const Duration(hours: 1))); // Allow booking 1 hour ahead
          
          final slot = TimeSlot(
            id: _uuid.v4(),
            merchantId: merchantId,
            date: normalizedDate,
            startTime: '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
            endTime: '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
            isAvailable: isAvailable,
            createdAt: DateTime.now(),
          );
          
          if (slot.canAccommodateService(serviceDuration)) {
            slots.add(slot);
          }
        }
      }
    }
    
    return slots.where((slot) => slot.isAvailable).toList();
  }

  // Get merchant-specific schedule
  List<Map<String, dynamic>> _getMerchantSchedule(String merchantId) {
    switch (merchantId) {
      case '1': // Glamour Salon
        return [
          {'start': 9, 'end': 12, 'interval': 30}, // Morning slots
          {'start': 13, 'end': 18, 'interval': 30}, // Afternoon slots (lunch break 12-1)
        ];
      case '2': // Wellness Spa
        return [
          {'start': 8, 'end': 12, 'interval': 60}, // Longer spa sessions
          {'start': 14, 'end': 20, 'interval': 60}, // Extended hours
        ];
      case '3': // HealthCare Clinic
        return [
          {'start': 7, 'end': 12, 'interval': 15}, // Quick consultations
          {'start': 13, 'end': 17, 'interval': 15}, // Afternoon appointments
        ];
      default:
        return [
          {'start': 9, 'end': 17, 'interval': 30}, // Default schedule
        ];
    }
  }

  // Check if specific time slot is available (add some realistic unavailability)
  bool _isSlotAvailable(int hour, int minute, String merchantId) {
    // Lunch breaks
    if (hour == 12 || (hour == 13 && minute == 0)) return false;
    
    // Some random unavailable slots for realism
    final slotKey = '$hour:$minute';
    final unavailableSlots = {
      '1': ['10:30', '15:00', '16:30'], // Salon busy times
      '2': ['11:00', '16:00'], // Spa maintenance
      '3': ['09:15', '14:45'], // Doctor meetings
    };
    
    return !(unavailableSlots[merchantId]?.contains(slotKey) ?? false);
  }

  // Get appointment by ID (demo)
  Future<Appointment?> getAppointmentById(String appointmentId) async {
    // In a real app, this would fetch from backend
    return _currentBooking?.id == appointmentId ? _currentBooking : null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Calculate payment total for booking
  void calculatePaymentTotal({
    required double serviceAmount,
    required String paymentMethodId,
    double? tipAmount,
  }) {
    _paymentCalculation = PaymentService.calculateTotal(
      serviceAmount: serviceAmount,
      paymentMethodId: paymentMethodId,
      tipAmount: tipAmount,
    );
    notifyListeners();
  }

  // Process payment for booking
  Future<bool> processPayment({
    required String paymentMethodId,
    required PaymentDetails paymentDetails,
    required String appointmentId,
  }) async {
    if (_paymentCalculation == null) {
      _error = 'Payment calculation not available';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      _lastPaymentResult = await PaymentService.processPayment(
        paymentMethodId: paymentMethodId,
        amount: _paymentCalculation!.total,
        currency: 'USD',
        appointmentId: appointmentId,
        paymentDetails: paymentDetails,
      );

      if (_lastPaymentResult!.isSuccess) {
        // Update appointment with payment info
        if (_currentBooking != null) {
          _currentBooking = _currentBooking!.copyWith(
            status: AppointmentStatus.confirmed,
          );
        }
        _error = null;
        return true;
      } else {
        _error = _lastPaymentResult!.message;
        return false;
      }
    } catch (e) {
      _error = 'Payment processing failed: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get available payment methods
  List<PaymentMethod> getAvailablePaymentMethods() {
    return PaymentService.getEnabledPaymentMethods();
  }

  // Validate payment details
  PaymentValidation validatePaymentDetails({
    required String paymentMethodId,
    required PaymentDetails details,
  }) {
    return PaymentService.validatePaymentDetails(
      paymentMethodId: paymentMethodId,
      details: details,
    );
  }

  // Get recommended time slots for better user experience
  List<TimeSlot> getRecommendedSlots() {
    if (_availableSlots.isEmpty) return [];
    
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    // Recommend slots for tomorrow in preferred time ranges
    return _availableSlots.where((slot) {
      final slotDate = slot.date;
      if (slotDate.day != tomorrow.day) return false;
      
      final startTime = slot.startTime.split(':');
      final hour = int.parse(startTime[0]);
      
      // Preferred hours: 10 AM - 12 PM or 2 PM - 4 PM
      return (hour >= 10 && hour < 12) || (hour >= 14 && hour < 16);
    }).take(4).toList();
  }

  // Get popular time slots (dummy data)
  List<String> getPopularTimeSlots() {
    return [
      '10:00', '11:00', '14:00', '15:00', '16:00'
    ];
  }

  void clearCurrentBooking() {
    _currentBooking = null;
    _paymentCalculation = null;
    _lastPaymentResult = null;
    notifyListeners();
  }

  void clearPaymentData() {
    _paymentCalculation = null;
    _lastPaymentResult = null;
    notifyListeners();
  }
}
