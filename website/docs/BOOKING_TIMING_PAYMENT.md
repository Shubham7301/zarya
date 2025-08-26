# 🕐 Booking Timing & Payment System

This document outlines the dummy timing slots and payment methods implemented in the Zarya booking platform.

## ⏰ Timing System

### **Merchant-Specific Schedules**

Each merchant type has different operating hours and time slot intervals:

#### **Glamour Salon (ID: '1')**
```dart
Schedule:
- Morning: 9:00 AM - 12:00 PM (30-minute slots)
- Afternoon: 1:00 PM - 6:00 PM (30-minute slots)
- Lunch Break: 12:00 PM - 1:00 PM

Unavailable Slots:
- 10:30 AM, 3:00 PM, 4:30 PM (busy times)

Interval: 30 minutes
```

#### **Wellness Spa (ID: '2')**
```dart
Schedule:
- Morning: 8:00 AM - 12:00 PM (60-minute slots)
- Afternoon: 2:00 PM - 8:00 PM (60-minute slots)
- Extended Hours: Yes

Unavailable Slots:
- 11:00 AM, 4:00 PM (maintenance)

Interval: 60 minutes
```

#### **HealthCare Clinic (ID: '3')**
```dart
Schedule:
- Morning: 7:00 AM - 12:00 PM (15-minute slots)
- Afternoon: 1:00 PM - 5:00 PM (15-minute slots)
- Early Start: Yes

Unavailable Slots:
- 9:15 AM, 2:45 PM (doctor meetings)

Interval: 15 minutes
```

### **Smart Slot Generation**

The system automatically generates available slots based on:
- **Merchant working hours**
- **Service duration requirements**
- **Current time + 1 hour buffer**
- **Realistic unavailability patterns**

```dart
// Example usage
await bookingProvider.fetchAvailableSlots(
  merchantId: '1',
  date: DateTime(2024, 12, 15),
  serviceDuration: 60, // 1 hour service
);
```

### **Recommended Time Slots**

The system suggests optimal booking times:
- **Tomorrow's slots** in preferred hours
- **10 AM - 12 PM** (morning preference)
- **2 PM - 4 PM** (afternoon preference)
- **Maximum 4 recommendations**

### **Popular Time Slots (Dummy Data)**
```dart
Most Popular Times:
- 10:00 AM
- 11:00 AM  
- 2:00 PM
- 3:00 PM
- 4:00 PM
```

## 💳 Payment System

### **Available Payment Methods**

#### **1. Credit/Debit Card** 💳
```dart
Processing Fee: 2.9% + $0.30
Processing Time: Instant
Validation: Card number, expiry, CVV, name
Success Rate: 90% (demo)
```

#### **2. PayPal** 🅿️
```dart
Processing Fee: 3.5% + $0.15
Processing Time: Instant
Validation: PayPal email address
Success Rate: 90% (demo)
```

#### **3. Apple Pay** 🍎
```dart
Processing Fee: 2.9% + $0.30
Processing Time: Instant (0.8-2 seconds)
Validation: Minimal (handled by Apple)
Success Rate: 90% (demo)
```

#### **4. Google Pay** 🌐
```dart
Processing Fee: 2.9% + $0.30
Processing Time: Instant (0.8-2 seconds)
Validation: Minimal (handled by Google)
Success Rate: 90% (demo)
```

#### **5. Bank Transfer** 🏦
```dart
Processing Fee: $0.50 (fixed)
Processing Time: 1-3 business days
Validation: Account number, routing number
Success Rate: 90% (demo)
```

#### **6. Pay at Location** 💵
```dart
Processing Fee: $0.00
Processing Time: At appointment
Validation: None required
Success Rate: 100%
```

### **Payment Calculation**

The system automatically calculates the total amount:

```dart
Payment Breakdown:
- Service Amount: $45.00
- Tax (8%): $3.60
- Processing Fee: $1.61 (2.9% + $0.30)
- Tip (optional): $9.00
- Total: $59.21
```

**Implementation:**
```dart
final calculation = PaymentService.calculateTotal(
  serviceAmount: 45.0,
  paymentMethodId: 'card',
  tipAmount: 9.0,
);
```

### **Payment Processing Flow**

```dart
1. Select Payment Method → validatePaymentDetails()
2. Calculate Total → calculateTotal()
3. Process Payment → processPayment()
4. Handle Result → Success/Failure
5. Update Booking Status → Confirmed/Pending
```

### **Validation Rules**

#### **Credit Card Validation:**
```dart
Required Fields:
- Card Number: Minimum 13 digits
- Expiry Month/Year: Valid future date
- CVV: Minimum 3 digits
- Cardholder Name: Not empty
```

#### **PayPal Validation:**
```dart
Required Fields:
- Email: Valid email format with '@'
```

#### **Bank Transfer Validation:**
```dart
Required Fields:
- Account Number: Not empty
- Routing Number: Not empty
```

### **Demo Payment Simulation**

The payment system includes realistic simulation:

```dart
Processing Times:
- Card: 2-4 seconds
- PayPal: 1.5-4 seconds
- Apple/Google Pay: 0.8-2 seconds
- Bank Transfer: 3-5 seconds
- Cash: 0.5 seconds

Success Rate: 90%
Error Scenarios: 10% (random)
```

**Common Error Messages:**
- "Insufficient funds"
- "Card declined" 
- "Payment method temporarily unavailable"
- "Network error - please try again"
- "Invalid payment information"

## 📱 Usage Examples

### **Booking with Timing**

```dart
class BookingScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Date picker
            DatePicker(onDateSelected: (date) {
              provider.fetchAvailableSlots(
                merchantId: widget.merchantId,
                date: date,
                serviceDuration: widget.service.duration,
              );
            }),
            
            // Available time slots
            if (provider.availableSlots.isNotEmpty)
              TimeSlotGrid(
                slots: provider.availableSlots,
                onSlotSelected: (slot) => _selectTimeSlot(slot),
              ),
            
            // Recommended slots
            RecommendedSlots(
              slots: provider.getRecommendedSlots(),
              onSlotSelected: (slot) => _selectTimeSlot(slot),
            ),
          ],
        );
      },
    );
  }
}
```

### **Payment Processing**

```dart
class PaymentScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Payment method selection
            PaymentMethodSelector(
              methods: provider.getAvailablePaymentMethods(),
              onMethodSelected: (method) {
                provider.calculatePaymentTotal(
                  serviceAmount: widget.service.price,
                  paymentMethodId: method.id,
                  tipAmount: _selectedTip,
                );
              },
            ),
            
            // Payment calculation display
            if (provider.paymentCalculation != null)
              PaymentSummary(calculation: provider.paymentCalculation!),
            
            // Payment form
            PaymentForm(
              onSubmit: (details) async {
                final success = await provider.processPayment(
                  paymentMethodId: _selectedMethod.id,
                  paymentDetails: details,
                  appointmentId: widget.appointmentId,
                );
                
                if (success) {
                  _showSuccessDialog();
                } else {
                  _showErrorDialog(provider.error);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
```

### **Tip Calculation**

```dart
class TipSelector extends StatelessWidget {
  final double serviceAmount;
  final Function(double) onTipSelected;
  
  final List<double> tipPercentages = [0.15, 0.18, 0.20, 0.25];
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: tipPercentages.map((percentage) {
        final tipAmount = serviceAmount * percentage;
        return TipButton(
          percentage: percentage,
          amount: tipAmount,
          onPressed: () => onTipSelected(tipAmount),
        );
      }).toList(),
    );
  }
}
```

## 🔧 Configuration

### **Timing Configuration**

Located in: `customer_web/lib/providers/simple_booking_provider.dart`

```dart
// Modify merchant schedules
List<Map<String, dynamic>> _getMerchantSchedule(String merchantId) {
  switch (merchantId) {
    case '1': // Salon
      return [
        {'start': 9, 'end': 12, 'interval': 30},
        {'start': 13, 'end': 18, 'interval': 30},
      ];
    // Add more cases...
  }
}

// Modify unavailable slots
bool _isSlotAvailable(int hour, int minute, String merchantId) {
  final unavailableSlots = {
    '1': ['10:30', '15:00', '16:30'],
    // Add more merchant-specific unavailable slots...
  };
}
```

### **Payment Configuration**

Located in: `customer_web/lib/services/payment_service.dart`

```dart
// Modify payment methods
static const List<PaymentMethod> availablePaymentMethods = [
  PaymentMethod(
    id: 'card',
    name: 'Credit/Debit Card',
    processingFee: 2.9, // Modify fee percentage
    isEnabled: true, // Enable/disable method
  ),
  // Add more payment methods...
];

// Modify tax rate
static PaymentCalculation calculateTotal({
  double taxRate = 0.08, // 8% tax (modify as needed)
}) {
  // Calculation logic...
}
```

## 🚨 Error Handling

### **Timing Errors**
```dart
Common Issues:
- No available slots for selected date
- Service duration too long for available slots
- Past date/time selection
- Merchant not operating on selected day

Error Messages:
- "No available time slots for this date"
- "Please select a future date and time"
- "Service duration exceeds available slots"
```

### **Payment Errors**
```dart
Common Issues:
- Invalid payment details
- Payment processing failure
- Network connectivity issues
- Insufficient funds (simulated)

Error Messages:
- "Invalid card number"
- "Payment declined"
- "Network error - please try again"
- "Payment method temporarily unavailable"
```

## 📊 Testing & Demo Data

### **Test Scenarios**

#### **Timing Tests:**
1. **Valid booking:** Select tomorrow, available slot
2. **No slots:** Select fully booked date
3. **Past time:** Try to book in the past
4. **Service duration:** Long service vs. short slots

#### **Payment Tests:**
1. **Successful payment:** Use valid card details
2. **Failed payment:** 10% chance of random failure
3. **Validation errors:** Invalid card number/CVV
4. **Network simulation:** Processing delays

### **Demo Data**
```dart
Test Cards (dummy):
- Valid: 4111 1111 1111 1111 (Visa)
- Valid: 5555 5555 5555 4444 (Mastercard)
- Expiry: Any future date
- CVV: Any 3-4 digits

Test PayPal:
- Email: any valid email format

Test Bank:
- Account: any number
- Routing: any 9-digit number
```

## 🔮 Future Enhancements

### **Timing Features**
- **Recurring appointments** (weekly, monthly)
- **Group booking** for multiple people
- **Buffer time** between appointments
- **Merchant-specific break times**
- **Holiday/vacation scheduling**

### **Payment Features**
- **Installment payments** for expensive services
- **Loyalty points** and rewards
- **Promotional codes** and discounts
- **Auto-refund** for cancellations
- **Split payments** for group bookings

---

**Last Updated**: December 2024  
**Implementation**: Demo/Dummy Data  
**Production Ready**: Requires real payment gateway integration
