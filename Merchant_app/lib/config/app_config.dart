class AppConfig {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );
  
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://localhost:3000',
  );

  // Cloudinary Configuration
  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'your-cloud-name',
  );
  
  static const String cloudinaryApiKey = String.fromEnvironment(
    'CLOUDINARY_API_KEY',
    defaultValue: 'your-api-key',
  );
  
  static const String cloudinaryApiSecret = String.fromEnvironment(
    'CLOUDINARY_API_SECRET',
    defaultValue: 'your-api-secret',
  );

  // App Configuration
  static const String appName = 'Zarya Merchant App';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Feature Flags
  static const bool enableRealTimeUpdates = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxImagesPerMerchant = 10;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxBusinessNameLength = 100;
  static const int maxDescriptionLength = 500;

  // Subscription Plans
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'freeTrial': {
      'name': 'Free Trial',
      'duration': 30,
      'price': 0.0,
      'features': ['Basic Features', '30 Days Trial'],
    },
    'basic': {
      'name': 'Basic Plan',
      'duration': 30,
      'price': 29.99,
      'features': ['All Basic Features', 'Email Support', 'Basic Analytics'],
    },
    'premium': {
      'name': 'Premium Plan',
      'duration': 30,
      'price': 59.99,
      'features': ['All Basic Features', 'Priority Support', 'Advanced Analytics', 'Custom Branding'],
    },
    'enterprise': {
      'name': 'Enterprise Plan',
      'duration': 30,
      'price': 99.99,
      'features': ['All Premium Features', 'Dedicated Support', 'Custom Integrations', 'White Label'],
    },
  };

  // Categories
  static const List<String> businessCategories = [
    'Beauty & Wellness',
    'Health & Fitness',
    'Technology',
    'Education',
    'Food & Beverage',
    'Retail',
    'Professional Services',
    'Entertainment',
    'Automotive',
    'Real Estate',
    'Other',
  ];

  // Working Hours
  static const List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Default working hours
  static const Map<String, Map<String, String>> defaultWorkingHours = {
    'Monday': {'startTime': '09:00', 'endTime': '17:00', 'isOpen': 'true'},
    'Tuesday': {'startTime': '09:00', 'endTime': '17:00', 'isOpen': 'true'},
    'Wednesday': {'startTime': '09:00', 'endTime': '17:00', 'isOpen': 'true'},
    'Thursday': {'startTime': '09:00', 'endTime': '17:00', 'isOpen': 'true'},
    'Friday': {'startTime': '09:00', 'endTime': '17:00', 'isOpen': 'true'},
    'Saturday': {'startTime': '10:00', 'endTime': '16:00', 'isOpen': 'true'},
    'Sunday': {'startTime': '10:00', 'endTime': '16:00', 'isOpen': 'false'},
  };

  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Network error. Please check your internet connection.',
    'server_error': 'Server error. Please try again later.',
    'unauthorized': 'Unauthorized access. Please login again.',
    'validation_error': 'Please check your input and try again.',
    'unknown_error': 'An unknown error occurred. Please try again.',
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'login_success': 'Login successful!',
    'logout_success': 'Logout successful!',
    'profile_updated': 'Profile updated successfully!',
    'merchant_created': 'Merchant created successfully!',
    'merchant_updated': 'Merchant updated successfully!',
    'merchant_deleted': 'Merchant deleted successfully!',
    'subscription_updated': 'Subscription updated successfully!',
  };

  // Development Configuration
  static const bool isDevelopment = bool.fromEnvironment('dart.vm.product') == false;
  static const bool enableDebugLogs = isDevelopment;
  static const bool enableMockData = false;

  // Production URLs (update these for deployment)
  static const String productionApiUrl = 'https://your-backend-domain.com/api/v1';
  static const String productionSocketUrl = 'https://your-backend-domain.com';
  static const String productionWebUrl = 'https://your-frontend-domain.com';

  // Get current API URL based on environment
  static String get currentApiUrl {
    if (isDevelopment) {
      return apiBaseUrl;
    }
    return productionApiUrl;
  }

  // Get current socket URL based on environment
  static String get currentSocketUrl {
    if (isDevelopment) {
      return socketUrl;
    }
    return productionSocketUrl;
  }
}
