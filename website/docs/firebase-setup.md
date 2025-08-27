# Firebase Setup Guide

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `zarya-booking`
4. Enable Google Analytics (optional)
5. Create project

## 2. Enable Authentication

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Email/Password** provider
3. Save changes

## 3. Setup Firestore Database

1. Go to **Firestore Database**
2. Click "Create database"
3. Choose "Start in test mode" (we'll add security rules later)
4. Select your preferred location
5. Create database

## 4. Enable Firebase Hosting

1. Go to **Hosting** in Firebase Console
2. Click "Get started"
3. Follow the setup instructions

## 5. Enable Cloud Messaging

1. Go to **Cloud Messaging**
2. Generate FCM key for push notifications

## 6. Download Configuration Files

### For Web App (Customer)
1. Go to **Project Settings** > **General**
2. Click "Add app" > Web app
3. Register app with name: `zarya-customer-web`
4. Copy the Firebase config object
5. Save as `customer_web/web/firebase-config.js`

### For Mobile App (Merchant)
1. Click "Add app" > Android/iOS
2. Register app with package name: `com.zarya.merchant`
3. Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
4. Place in appropriate directories in `merchant_mobile/`

## 7. Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
firebase init
```

## 8. Project Configuration

Select:
- Firestore: Configure rules and indexes
- Functions: JavaScript/TypeScript Cloud Functions
- Hosting: Configure files for Firebase Hosting
- Storage: Configure security rules

## Firestore Collections Structure

```
merchants/
├── {merchantId}/
    ├── name: string
    ├── email: string
    ├── services: array
    ├── workingHours: object
    ├── createdAt: timestamp

appointments/
├── {appointmentId}/
    ├── customerId: string
    ├── merchantId: string
    ├── serviceId: string
    ├── dateTime: timestamp
    ├── status: string (pending, confirmed, completed, cancelled)
    ├── customerInfo: object
    ├── createdAt: timestamp

customers/
├── {customerId}/
    ├── name: string
    ├── email: string
    ├── phone: string
    ├── createdAt: timestamp

services/
├── {serviceId}/
    ├── merchantId: string
    ├── name: string
    ├── description: string
    ├── duration: number (minutes)
    ├── price: number
    ├── isActive: boolean
```

## Security Rules

Add these rules to Firestore:

```javascript
// See firebase/firestore.rules for complete security rules
```

## Next Steps

1. Configure each Flutter app with Firebase
2. Deploy Cloud Functions
3. Test authentication and database operations
4. Set up hosting for customer web app
