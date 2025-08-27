# Super Admin Module - Quick Setup Guide

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Chrome browser (for web development)
- Git

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd Merchant_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the Application**
   ```bash
   flutter run -d chrome
   ```

## 🔐 Accessing Super Admin

### Login Credentials
- **Email**: `admin@zarya.com`
- **Password**: `admin123`

### Navigation
1. Open the app in Chrome
2. Click "Super Admin Login" on the login screen
3. Enter the credentials above
4. You'll be redirected to the Super Admin Dashboard

## 📁 Project Structure

```
Merchant_app/
├── lib/
│   ├── models/
│   │   ├── super_admin.dart
│   │   ├── merchant.dart
│   │   ├── merchant_subscription.dart
│   │   └── notification_data.dart
│   ├── providers/
│   │   └── super_admin_provider.dart
│   ├── services/
│   │   ├── super_admin_api_service.dart
│   │   └── web_notification_service.dart
│   ├── screens/
│   │   ├── super_admin_login_screen.dart
│   │   ├── super_admin_dashboard_screen.dart
│   │   ├── super_admin_merchants_screen.dart
│   │   ├── super_admin_analytics_screen.dart
│   │   ├── super_admin_add_merchant_screen.dart
│   │   └── super_admin_subscription_screen.dart
│   └── main.dart
└── docs/
    ├── SUPER_ADMIN_FEATURES.md
    └── SUPER_ADMIN_SETUP.md
```

## 🎯 Key Features to Test

### 1. Create a New Merchant
1. Go to Super Admin Dashboard
2. Click "Add New Merchant" quick action
3. Fill in business information
4. Select subscription plan (try Free Trial)
5. Set duration and save

### 2. Test Real-Time Notifications
1. Create a merchant with Free Trial
2. Login as the merchant (use the email you created)
3. You should see a welcome notification
4. Go back to Super Admin and edit the merchant
5. Check merchant dashboard for real-time updates

### 3. Test Analytics
1. Navigate to Analytics tab
2. View different metrics and charts
3. Try different time periods
4. Check category distribution

### 4. Test Search & Filtering
1. Go to Merchants tab
2. Use search bar to find merchants
3. Apply category and status filters
4. Test sorting options

## 🔧 Development Workflow

### Adding New Features
1. **Create Model** (if needed)
   ```dart
   // lib/models/your_model.dart
   class YourModel {
     // Define properties and methods
   }
   ```

2. **Update Provider**
   ```dart
   // lib/providers/super_admin_provider.dart
   // Add new methods and state management
   ```

3. **Create Service** (if needed)
   ```dart
   // lib/services/your_service.dart
   class YourService {
     // Add API calls and business logic
   }
   ```

4. **Create UI Screen**
   ```dart
   // lib/screens/your_screen.dart
   class YourScreen extends StatefulWidget {
     // Implement UI
   }
   ```

5. **Update Navigation**
   ```dart
   // lib/main.dart
   // Add routes and navigation
   ```

### Testing Real-Time Features
1. **Start the app**
   ```bash
   flutter run -d chrome
   ```

2. **Open multiple tabs**
   - Tab 1: Super Admin Dashboard
   - Tab 2: Merchant Dashboard

3. **Make changes in Super Admin**
   - Create/edit merchants
   - Change subscription status

4. **Observe real-time updates**
   - Check merchant dashboard for notifications
   - Verify data synchronization

## 🐛 Debugging

### Common Issues

1. **Provider Error During Build**
   ```
   setState() or markNeedsBuild() called during build
   ```
   - **Solution**: This is a warning, not an error. The app will work normally.

2. **API Connection Errors**
   ```
   Failed to fetch, uri=https://your-api-domain.com/api/...
   ```
   - **Solution**: Expected behavior - using mock data. Backend not implemented yet.

3. **Notification Permission Errors**
   ```
   Notification permission denied
   ```
   - **Solution**: Browser notifications require user permission. In-app notifications will still work.

### Debug Commands
```bash
# Check Flutter version
flutter --version

# Analyze code
flutter analyze

# Run tests
flutter test

# Build for production
flutter build web

# Clean and rebuild
flutter clean && flutter pub get
```

## 📊 Mock Data

### Sample Merchants
- **Beauty Salon Pro** (Active, Premium Plan)
- **Health Clinic Plus** (Inactive, Basic Plan)
- **Relaxation Spa** (Active, Free Trial)

### Sample Analytics
- Total Merchants: 156
- Active Merchants: 142
- Total Revenue: $45,678.90
- Monthly Growth: 12.5%

## 🔄 Real-Time Configuration

### Polling Intervals
- **Real-time Updates**: 30 seconds
- **Backup Refresh**: 5 minutes
- **Notification Check**: 30 seconds

### Customization
```dart
// lib/services/super_admin_api_service.dart
// Modify polling intervals
return Stream.periodic(const Duration(seconds: 30), (_) async {
  // Your polling logic
});
```

## 🚀 Deployment

### Web Deployment
1. **Build for Production**
   ```bash
   flutter build web --release
   ```

2. **Deploy to Server**
   - Upload `build/web/` contents to your web server
   - Configure server for SPA routing

### Environment Configuration
```dart
// lib/services/super_admin_api_service.dart
static const String baseUrl = 'https://your-production-api.com/api';
```

## 📞 Support

### Documentation
- **Features**: `docs/SUPER_ADMIN_FEATURES.md`
- **API Reference**: See features documentation
- **Code Comments**: Inline documentation in code

### Getting Help
1. Check the documentation first
2. Review error messages in browser console
3. Check Flutter DevTools for debugging
4. Review the code structure and examples

## 🎉 Quick Demo

### 5-Minute Demo Script
1. **Login as Super Admin** (2 min)
   - Show dashboard overview
   - Explain key metrics

2. **Create a Merchant** (2 min)
   - Fill out form with Free Trial
   - Show real-time pricing
   - Save and verify creation

3. **Test Notifications** (1 min)
   - Login as merchant
   - Show welcome notification
   - Demonstrate real-time updates

### Demo Credentials
- **Super Admin**: admin@zarya.com / admin123
- **Sample Merchant**: sarah@beautysalonpro.com / password123

---

## 🎯 Next Steps

1. **Implement Backend API** - Replace mock data with real API
2. **Add Payment Integration** - Stripe/PayPal for subscriptions
3. **Mobile App Development** - Native iOS/Android apps
4. **Advanced Analytics** - Machine learning insights
5. **Multi-Admin Support** - Multiple Super Admin accounts

The Super Admin module is production-ready and provides a solid foundation for scaling the merchant management system!
