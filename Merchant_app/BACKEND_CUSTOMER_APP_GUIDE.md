# Zarya Appointment Scheduling SaaS - Backend + Customer App Guide

## 🎯 Project Overview

**Zarya** is a comprehensive appointment scheduling SaaS platform with three main actors:
- **Super Admin** → Creates merchant accounts, manages overall system
- **Merchant** (Clinic/Doctor) → Manages profile, available slots, accepts/declines bookings
- **Customer** (Patient) → Searches clinics/doctors, books appointments, manages bookings

## 🏗️ Tech Stack Architecture

### Backend
- **Runtime**: Node.js with Express.js
- **Alternative**: Firebase Functions (serverless approach)
- **Authentication**: Firebase Auth
- **Database**: Firebase Firestore (NoSQL) + Redis for caching
- **Media Storage**: Cloudinary
- **Real-time**: Firebase Realtime Database or Socket.io
- **Payment**: Stripe (optional for premium features)

### Frontend Apps
- **Super Admin App**: Flutter (✅ Already implemented)
- **Merchant App**: Flutter (✅ Already implemented)
- **Customer App**: Flutter (🔄 To be implemented)
- **Web Dashboard**: React/Next.js (optional)

## 🗄️ Database Schema Design

### Firestore Collections Structure

#### 1. Users Collection
```javascript
users/{userId}
{
  uid: "string", // Firebase Auth UID
  email: "string",
  phone: "string",
  role: "super_admin" | "merchant" | "customer",
  profile: {
    firstName: "string",
    lastName: "string",
    avatar: "string", // Cloudinary URL
    dateOfBirth: "timestamp",
    gender: "string"
  },
  isActive: "boolean",
  createdAt: "timestamp",
  updatedAt: "timestamp"
}
```

#### 2. Merchants Collection
```javascript
merchants/{merchantId}
{
  userId: "string", // Reference to users collection
  businessInfo: {
    name: "string",
    description: "string",
    category: "healthcare" | "beauty" | "fitness" | "other",
    subcategory: "string", // e.g., "dentist", "dermatologist"
    address: {
      street: "string",
      city: "string",
      state: "string",
      zipCode: "string",
      country: "string",
      coordinates: {
        latitude: "number",
        longitude: "number"
      }
    },
    contactInfo: {
      phone: "string",
      email: "string",
      website: "string"
    },
    operatingHours: {
      monday: { open: "09:00", close: "17:00", isOpen: true },
      tuesday: { open: "09:00", close: "17:00", isOpen: true },
      // ... other days
    },
    services: [
      {
        id: "string",
        name: "string",
        description: "string",
        duration: "number", // minutes
        price: "number",
        currency: "string"
      }
    ]
  },
  verificationStatus: "pending" | "verified" | "rejected",
  rating: "number", // 1-5
  totalReviews: "number",
  isActive: "boolean",
  createdAt: "timestamp",
  updatedAt: "timestamp"
}
```

#### 3. Availability Slots Collection
```javascript
availability/{merchantId}/{date}
{
  merchantId: "string",
  date: "string", // YYYY-MM-DD format
  slots: [
    {
      time: "09:00",
      duration: "30", // minutes
      isAvailable: true,
      serviceId: "string", // optional, for specific service slots
      maxBookings: "number"
    }
  ],
  isCustomHours: "boolean",
  customHours: {
    open: "string",
    close: "string"
  },
  createdAt: "timestamp"
}
```

#### 4. Appointments Collection
```javascript
appointments/{appointmentId}
{
  id: "string",
  merchantId: "string",
  customerId: "string",
  serviceId: "string",
  date: "string", // YYYY-MM-DD
  time: "string", // HH:MM
  duration: "number", // minutes
  status: "pending" | "confirmed" | "cancelled" | "completed" | "no_show",
  notes: "string",
  customerNotes: "string",
  merchantNotes: "string",
  createdAt: "timestamp",
  updatedAt: "timestamp",
  cancelledAt: "timestamp",
  cancelledBy: "string", // userId who cancelled
  cancellationReason: "string"
}
```

#### 5. Reviews Collection
```javascript
reviews/{reviewId}
{
  id: "string",
  merchantId: "string",
  customerId: "string",
  appointmentId: "string",
  rating: "number", // 1-5
  comment: "string",
  isAnonymous: "boolean",
  createdAt: "timestamp"
}
```

#### 6. Notifications Collection
```javascript
notifications/{notificationId}
{
  id: "string",
  userId: "string",
  type: "appointment_reminder" | "booking_confirmation" | "cancellation" | "system",
  title: "string",
  message: "string",
  data: "object", // additional data
  isRead: "boolean",
  createdAt: "timestamp"
}
```

## 🔌 Backend API Structure

### Base URL: `https://your-api-domain.com/api/v1`

#### Authentication Endpoints
```
POST   /auth/register
POST   /auth/login
POST   /auth/logout
POST   /auth/refresh-token
POST   /auth/forgot-password
POST   /auth/reset-password
POST   /auth/verify-email
```

#### Super Admin Endpoints
```
GET    /admin/merchants
POST   /admin/merchants
GET    /admin/merchants/:id
PUT    /admin/merchants/:id
DELETE /admin/merchants/:id
POST   /admin/merchants/:id/verify
GET    /admin/dashboard
GET    /admin/analytics
```

#### Merchant Endpoints
```
GET    /merchant/profile
PUT    /merchant/profile
GET    /merchant/services
POST   /merchant/services
PUT    /merchant/services/:id
DELETE /merchant/services/:id
GET    /merchant/availability/:date
PUT    /merchant/availability/:date
GET    /merchant/appointments
PUT    /merchant/appointments/:id/status
GET    /merchant/dashboard
```

#### Customer Endpoints
```
GET    /customer/profile
PUT    /customer/profile
GET    /customer/appointments
GET    /customer/appointments/:id
POST   /customer/appointments
PUT    /customer/appointments/:id
DELETE /customer/appointments/:id
GET    /customer/search/merchants
GET    /customer/merchants/:id
GET    /customer/merchants/:id/availability
POST   /customer/reviews
```

#### Public Endpoints
```
GET    /public/merchants
GET    /public/merchants/:id
GET    /public/merchants/:id/availability
GET    /public/categories
```

## 🔐 Authentication & Authorization Flow

### 1. Role-Based Access Control (RBAC)
```javascript
// Middleware for role verification
const requireRole = (roles) => {
  return (req, res, next) => {
    const userRole = req.user.role;
    if (!roles.includes(userRole)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
};

// Usage examples
app.get('/admin/merchants', requireRole(['super_admin']), adminController.getMerchants);
app.get('/merchant/profile', requireRole(['merchant']), merchantController.getProfile);
app.get('/customer/profile', requireRole(['customer']), customerController.getProfile);
```

### 2. JWT Token Structure
```javascript
{
  "uid": "user_id",
  "email": "user@example.com",
  "role": "merchant",
  "iat": 1640995200,
  "exp": 1641081600
}
```

### 3. Authentication Flow
1. User submits credentials
2. Backend validates with Firebase Auth
3. Backend generates JWT with user info
4. Client stores JWT in secure storage
5. Client includes JWT in Authorization header
6. Backend validates JWT and extracts user info

## 🔗 Flutter App Integration

### 1. API Service Structure
```dart
// lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'https://your-api-domain.com/api/v1';
  static const String apiKey = 'your-api-key';
  
  static Future<Map<String, String>> getHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  static Future<http.Response> get(String endpoint) async {
    final headers = await getHeaders();
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }
  
  // Similar methods for POST, PUT, DELETE
}
```

### 2. Service-Specific APIs
```dart
// lib/services/merchant_api_service.dart
class MerchantApiService {
  static Future<Merchant> getProfile() async {
    final response = await ApiService.get('/merchant/profile');
    if (response.statusCode == 200) {
      return Merchant.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load profile');
  }
  
  static Future<List<Appointment>> getAppointments() async {
    final response = await ApiService.get('/merchant/appointments');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    }
    throw Exception('Failed to load appointments');
  }
}
```

### 3. State Management Integration
```dart
// lib/providers/merchant_provider.dart
class MerchantProvider extends ChangeNotifier {
  Merchant? _merchant;
  List<Appointment> _appointments = [];
  
  Future<void> loadProfile() async {
    try {
      _merchant = await MerchantApiService.getProfile();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> loadAppointments() async {
    try {
      _appointments = await MerchantApiService.getAppointments();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
```

## 📱 Customer App Features

### 1. Core Screens
- **Home**: Search clinics, featured merchants, categories
- **Search**: Filter by location, category, rating, availability
- **Merchant Details**: Profile, services, reviews, availability
- **Booking**: Select service, date, time, confirm appointment
- **Appointments**: View, cancel, reschedule appointments
- **Profile**: Personal info, booking history, preferences

### 2. Key Features
- **Location-based Search**: Find nearby clinics
- **Real-time Availability**: Live slot updates
- **Push Notifications**: Appointment reminders, confirmations
- **Offline Support**: Cache essential data
- **Multi-language**: Support for multiple languages

## 🚀 Scalability Considerations

### 1. Database Optimization
- **Indexing**: Create composite indexes for common queries
- **Pagination**: Implement cursor-based pagination for large datasets
- **Caching**: Use Redis for frequently accessed data
- **Sharding**: Consider database sharding for high traffic

### 2. API Performance
- **Rate Limiting**: Implement API rate limiting
- **Caching**: Cache responses for static data
- **CDN**: Use CDN for static assets
- **Load Balancing**: Distribute traffic across multiple servers

### 3. Business Logic Extensibility
- **Plugin Architecture**: Design for easy feature additions
- **Configuration-driven**: Make business rules configurable
- **API Versioning**: Maintain backward compatibility
- **Microservices**: Consider breaking into smaller services

## 🚀 Deployment Guide

### 1. Free/Low-Cost Options

#### Backend Deployment
- **Render**: Free tier with 750 hours/month
- **Railway**: Free tier with $5 credit/month
- **Heroku**: Free tier (limited, but good for testing)
- **Firebase Functions**: Free tier with generous limits

#### Database
- **Firebase Firestore**: Free tier with 1GB storage
- **MongoDB Atlas**: Free tier with 512MB storage
- **Supabase**: Free tier with 500MB database

#### Media Storage
- **Cloudinary**: Free tier with 25GB storage
- **Firebase Storage**: Free tier with 5GB storage

### 2. Production Deployment Steps

#### 1. Environment Setup
```bash
# Install dependencies
npm install

# Set environment variables
cp .env.example .env
# Edit .env with your production values
```

#### 2. Build and Deploy
```bash
# Build the application
npm run build

# Deploy to your chosen platform
# Example for Render:
git push origin main
```

#### 3. Environment Variables
```env
NODE_ENV=production
PORT=3000
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
JWT_SECRET=your-jwt-secret
```

### 3. Monitoring and Maintenance
- **Logging**: Implement comprehensive logging
- **Error Tracking**: Use services like Sentry
- **Performance Monitoring**: Monitor API response times
- **Backup Strategy**: Regular database backups
- **SSL Certificate**: Ensure HTTPS for security

## 🔧 Development Workflow

### 1. Local Development Setup
```bash
# Clone the repository
git clone <your-repo>
cd zarya-backend

# Install dependencies
npm install

# Set up environment
cp .env.example .env

# Start development server
npm run dev
```

### 2. Testing Strategy
- **Unit Tests**: Test individual functions
- **Integration Tests**: Test API endpoints
- **E2E Tests**: Test complete user flows
- **Load Testing**: Test performance under load

### 3. Code Quality
- **ESLint**: Code linting
- **Prettier**: Code formatting
- **Husky**: Git hooks for quality checks
- **TypeScript**: Optional type safety

## 📋 Implementation Checklist

### Phase 1: Foundation
- [ ] Set up Node.js/Express backend
- [ ] Configure Firebase project
- [ ] Set up Firestore database
- [ ] Implement authentication system
- [ ] Create basic API structure

### Phase 2: Core Features
- [ ] Implement merchant management
- [ ] Create availability system
- [ ] Build appointment booking
- [ ] Add notification system

### Phase 3: Customer App
- [ ] Design customer app UI/UX
- [ ] Implement search and filtering
- [ ] Add booking functionality
- [ ] Integrate with backend APIs

### Phase 4: Testing & Deployment
- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] Security audit
- [ ] Production deployment

## 🎯 Next Steps

1. **Choose Deployment Platform**: Decide between Firebase Functions or traditional Node.js hosting
2. **Set Up Firebase Project**: Configure Firestore, Auth, and Storage
3. **Start Backend Development**: Begin with authentication and basic CRUD operations
4. **Plan Customer App**: Design the customer app architecture and UI/UX
5. **Implement Core Features**: Build the appointment booking system step by step

This guide provides a solid foundation for building your Zarya appointment scheduling SaaS. The modular architecture will allow you to easily extend from healthcare to other industries like beauty, fitness, and professional services.
