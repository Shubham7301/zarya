# 🚀 Zarya - Merchant Appointment Scheduling System

A comprehensive appointment scheduling system for merchants with real-time synchronization, Super Admin management, and modern Flutter UI.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Backend Setup](#backend-setup)
- [Flutter App Setup](#flutter-app-setup)
- [Deployment](#deployment)
- [API Documentation](#api-documentation)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🎯 Overview

Zarya is a comprehensive appointment scheduling SaaS platform designed for merchants to manage their appointments, services, and customer interactions. The system includes:

- **Merchant App**: Flutter-based mobile application for merchants
- **Super Admin App**: Flutter-based mobile application for system administrators
- **Customer App**: Flutter-based mobile application for customers (planned)
- **Backend API**: Node.js/Express server with Firebase and Cloudinary integration
- **Real-time Sync**: WebSocket-based real-time data synchronization
- **Payment Integration**: Stripe payment processing (ready for integration)

## ✨ Features

### 🏪 Merchant Features
- **Dashboard**: Overview of appointments, revenue, and analytics
- **Appointment Management**: Create, edit, and manage appointments
- **Service Management**: Add and manage business services
- **Customer Management**: Track customer information and history
- **Real-time Notifications**: Instant updates for new appointments
- **Profile Management**: Update business information and settings
- **Working Hours**: Set and manage business hours
- **Image Upload**: Upload business images via Cloudinary

### 👨‍💼 Super Admin Features
- **Merchant Management**: Register, activate, and manage merchants
- **Analytics Dashboard**: System-wide analytics and insights
- **Subscription Management**: Manage merchant subscriptions
- **User Management**: Admin user management
- **System Monitoring**: Monitor system health and performance
- **Data Export**: Export merchant and system data
- **Audit Logs**: Track system activities and changes

### 🔧 Technical Features
- **Real-time Sync**: WebSocket-based real-time updates
- **Image Optimization**: Cloudinary integration for image management
- **Authentication**: JWT-based secure authentication
- **Role-based Access**: Merchant and Admin role management
- **API Security**: Rate limiting, CORS, and input validation
- **Error Handling**: Comprehensive error handling and logging
- **Database**: Firebase Firestore for scalable data storage
- **File Storage**: Cloudinary for image and file storage

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  Super Admin    │    │   Backend API   │
│   (Merchant)    │    │   (Web App)     │    │  (Node.js)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   WebSocket     │
                    │  (Real-time)    │
                    └─────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Firebase      │    │   Cloudinary    │    │   Stripe        │
│   (Database)    │    │   (Images)      │    │   (Payments)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- Flutter 3.0+
- Firebase project
- Cloudinary account
- Git

### 1. Clone the Repository

```bash
git clone <repository-url>
cd zarya
```

### 2. Backend Setup

```bash
cd zarya_backend
npm install
cp .env.example .env
# Edit .env with your credentials
npm run setup
npm start
```

### 3. Flutter App Setup

```bash
cd Merchant_app
flutter pub get
flutter run -d chrome
```

## 🔧 Backend Setup

### 1. Environment Configuration

Create a `.env` file in the `zarya_backend` directory:

```env
# Server Configuration
NODE_ENV=development
PORT=3000
APP_VERSION=1.0.0

# JWT Configuration
JWT_SECRET=your-super-secure-jwt-secret-key-here
JWT_EXPIRES_IN=7d

# Firebase Configuration
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40your-project.iam.gserviceaccount.com

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080

# Socket.IO Configuration
SOCKET_CORS_ORIGIN=http://localhost:3000
SOCKET_METHODS=GET,POST

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Security
BCRYPT_ROUNDS=12
BCRYPT_SALT_ROUNDS=12

# Logging
LOG_LEVEL=info
LOG_FILE_PATH=logs/app.log
```

### 2. Firebase Setup

1. **Create Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Firestore Database
   - Enable Authentication (Email/Password)

2. **Generate Service Account Key:**
   - Go to Project Settings > Service Accounts
   - Click "Generate new private key"
   - Download the JSON file
   - Extract values for environment variables

3. **Firestore Security Rules:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Allow authenticated users to read their own data
       match /merchants/{merchantId} {
         allow read, write: if request.auth != null && request.auth.uid == merchantId;
       }
       
       // Allow admins to read all data
       match /{document=**} {
         allow read, write: if request.auth != null && 
           get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin';
       }
     }
   }
   ```

### 3. Cloudinary Setup

1. **Create Cloudinary Account:**
   - Sign up at [Cloudinary](https://cloudinary.com/)
   - Get your cloud name, API key, and API secret

2. **Configure Upload Presets:**
   - Go to Settings > Upload
   - Create upload presets for different image types
   - Set up folder structure: `zarya/merchants/{merchantId}`

### 4. Install Dependencies

```bash
cd zarya_backend
npm install
```

### 5. Run Setup Script

```bash
npm run setup
```

This will:
- Validate environment variables
- Initialize Firebase
- Create default admin user
- Create sample data (optional)
- Test API endpoints

### 6. Start the Server

```bash
npm start
```

The server will start on `http://localhost:3000`

## 📱 Flutter App Setup

### 1. Install Flutter

Make sure you have Flutter 3.0+ installed:

```bash
flutter doctor
```

### 2. Install Dependencies

```bash
cd Merchant_app
flutter pub get
```

### 3. Configure App

Update the API configuration in `lib/config/app_config.dart`:

```dart
// For development
static const String apiBaseUrl = 'http://localhost:3000/api/v1';

// For production
static const String productionApiUrl = 'https://your-backend-domain.com/api/v1';
```

### 4. Run the App

```bash
flutter run -d chrome
```

## 🚀 Deployment

### Backend Deployment

See [DEPLOYMENT.md](zarya_backend/DEPLOYMENT.md) for detailed deployment instructions.

### Flutter App Deployment

#### Web Deployment

```bash
cd Merchant_app
flutter build web
# Deploy the build/web directory to your web server
```

#### Mobile Deployment

```bash
cd Merchant_app
flutter build apk  # For Android
flutter build ios  # For iOS
```

## 📚 API Documentation

### Authentication Endpoints

#### Merchant Login
```http
POST /api/v1/auth/merchant/login
Content-Type: application/json

{
  "email": "merchant@example.com",
  "password": "password123"
}
```

#### Admin Login
```http
POST /api/v1/auth/admin/login
Content-Type: application/json

{
  "email": "admin@zarya.com",
  "password": "Admin123!"
}
```

### Merchant Endpoints

#### Get All Merchants
```http
GET /api/v1/merchants
Authorization: Bearer <admin-token>
```

#### Create Merchant
```http
POST /api/v1/merchants
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "businessName": "New Business",
  "ownerName": "Owner Name",
  "email": "business@example.com",
  "phone": "+1234567890",
  "address": "123 Business St",
  "category": "Technology",
  "description": "Business description",
  "password": "password123"
}
```

### Health Check

```http
GET /health
```

## ⚙️ Configuration

### Environment Variables

See the `.env.example` file for all available environment variables.

### Feature Flags

Configure features in `lib/config/app_config.dart`:

```dart
// Feature Flags
static const bool enableRealTimeUpdates = true;
static const bool enablePushNotifications = true;
static const bool enableAnalytics = true;
static const bool enableCrashReporting = true;
```

### Subscription Plans

Configure subscription plans in the backend:

```javascript
const subscriptionPlans = {
  freeTrial: {
    name: 'Free Trial',
    duration: 30,
    price: 0.0,
    features: ['Basic Features', '30 Days Trial']
  },
  basic: {
    name: 'Basic Plan',
    duration: 30,
    price: 2500,
    features: ['All Basic Features', 'Email Support', 'Basic Analytics']
  }
  // ... more plans
};
```