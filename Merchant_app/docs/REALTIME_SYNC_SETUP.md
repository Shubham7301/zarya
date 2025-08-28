# Real-Time Sync Setup Guide

## Overview

This guide explains how to set up real-time data synchronization between your backend database and the Zarya Merchant App using Cloudinary as the real-time messaging layer.

## 🚀 Architecture

```
Backend Database ←→ Cloudinary ←→ Flutter App
     (MySQL/PostgreSQL)    (Real-time Layer)    (Merchant + Super Admin)
```

### Data Flow
1. **Backend Changes** → Cloudinary WebSocket/API
2. **Cloudinary** → Real-time updates to all connected clients
3. **Flutter App** → Updates UI and sends notifications

## 📋 Prerequisites

### 1. Cloudinary Account Setup
- **Cloud Name**: `zarya-booking` (already configured)
- **API Key**: `839433281873668` (already configured)
- **API Secret**: You need to add this (see step 1 below)
- **Upload Preset**: `zarya_uploads` (already configured)

### 2. Backend API
- RESTful API endpoints for CRUD operations
- Webhook endpoint for Cloudinary notifications
- Authentication system (JWT tokens)

### 3. Flutter App
- WebSocket support enabled
- HTTP client for API calls
- Real-time notification system

## 🔧 Setup Steps

### Step 1: Configure Cloudinary API Secret

1. **Get your API Secret**:
   - Log into your Cloudinary dashboard
   - Go to Settings → Access Keys
   - Copy your API Secret

2. **Update the configuration**:
   ```dart
   // lib/config/cloudinary_config.dart
   static const String apiSecret = 'YOUR_ACTUAL_API_SECRET_HERE';
   ```

### Step 2: Backend API Configuration

1. **Update backend API URL**:
   ```dart
   // lib/services/database_sync_service.dart
   static const String _backendApiUrl = 'https://your-actual-backend-api.com/api';
   ```

2. **Add backend authentication token**:
   ```dart
   // lib/services/database_sync_service.dart
   'Authorization': 'Bearer YOUR_ACTUAL_BACKEND_TOKEN',
   ```

### Step 3: Backend Webhook Setup

Your backend needs to handle Cloudinary webhooks for real-time sync:

```javascript
// Example Node.js/Express webhook handler
app.post('/webhooks/cloudinary', (req, res) => {
  const { type, data } = req.body;
  
  switch (type) {
    case 'merchant_created':
      // Handle merchant creation
      break;
    case 'merchant_updated':
      // Handle merchant update
      break;
    case 'subscription_updated':
      // Handle subscription update
      break;
  }
  
  res.status(200).send('OK');
});
```

### Step 4: Database Schema

Ensure your backend database has the required tables:

```sql
-- Merchants table
CREATE TABLE merchants (
  id VARCHAR(255) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(50),
  address TEXT,
  description TEXT,
  category VARCHAR(100),
  is_active BOOLEAN DEFAULT true,
  subscription_id VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Subscriptions table
CREATE TABLE subscriptions (
  id VARCHAR(255) PRIMARY KEY,
  merchant_id VARCHAR(255) NOT NULL,
  plan ENUM('freeTrial', 'basic', 'premium', 'enterprise'),
  status ENUM('active', 'expired', 'suspended', 'pending', 'cancelled'),
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  amount DECIMAL(10,2),
  currency VARCHAR(10) DEFAULT 'INR',
  payment_method VARCHAR(100),
  transaction_id VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (merchant_id) REFERENCES merchants(id)
);
```

## 🔄 Real-Time Sync Features

### 1. Merchant Management
- **Create**: New merchant → Cloudinary → All clients notified
- **Update**: Merchant changes → Cloudinary → Real-time UI updates
- **Delete**: Merchant removal → Cloudinary → Immediate removal from all clients

### 2. Subscription Management
- **Plan Changes**: Subscription updates → Cloudinary → Merchant notifications
- **Status Changes**: Active/Expired → Cloudinary → Real-time status updates
- **Renewals**: Payment processing → Cloudinary → Subscription extension

### 3. Admin Actions
- **Super Admin Changes**: All actions → Cloudinary → Merchant notifications
- **Bulk Operations**: Multiple updates → Cloudinary → Batch notifications
- **System Events**: Maintenance, updates → Cloudinary → System notifications

## 📡 WebSocket Connection

### Connection Flow
1. **Initialize**: App starts → Cloudinary service initialized
2. **Connect**: WebSocket connection established
3. **Authenticate**: API key authentication
4. **Subscribe**: Subscribe to relevant data types
5. **Listen**: Real-time data stream active
6. **Heartbeat**: 30-second keep-alive messages

### Fallback Mechanism
- **WebSocket Fails** → HTTP polling every 10 seconds
- **Connection Lost** → Automatic reconnection after 5 seconds
- **Authentication Failed** → Retry with exponential backoff

## 🔐 Security Considerations

### 1. API Key Security
- **Never expose API secret in client code**
- **Use environment variables for sensitive data**
- **Rotate API keys regularly**

### 2. Data Validation
- **Validate all incoming data**
- **Sanitize user inputs**
- **Check data integrity**

### 3. Rate Limiting
- **Implement rate limiting on backend**
- **Monitor API usage**
- **Set appropriate limits**

## 🧪 Testing the Setup

### 1. Test Real-Time Updates
```bash
# Start the app
flutter run -d chrome

# Login as Super Admin
# Create a new merchant
# Check if merchant dashboard shows real-time updates
```

### 2. Test Notifications
```bash
# Login as merchant
# Make changes in Super Admin
# Verify notifications appear in merchant dashboard
```

### 3. Test Connection Stability
```bash
# Monitor console for connection logs
# Test network interruption
# Verify automatic reconnection
```

## 🐛 Troubleshooting

### Common Issues

1. **WebSocket Connection Failed**
   ```
   Error: WebSocket connection failed
   ```
   - **Solution**: Check Cloudinary API credentials
   - **Solution**: Verify network connectivity
   - **Solution**: Check firewall settings

2. **Authentication Failed**
   ```
   Error: Authentication failed
   ```
   - **Solution**: Verify API key and secret
   - **Solution**: Check Cloudinary account status
   - **Solution**: Ensure proper permissions

3. **Data Not Syncing**
   ```
   Error: No real-time updates received
   ```
   - **Solution**: Check subscription settings
   - **Solution**: Verify backend webhook setup
   - **Solution**: Monitor Cloudinary logs

4. **High Latency**
   ```
   Warning: Slow real-time updates
   ```
   - **Solution**: Check network performance
   - **Solution**: Optimize data payload size
   - **Solution**: Consider regional Cloudinary servers

### Debug Commands
```bash
# Check Flutter dependencies
flutter pub get

# Analyze code
flutter analyze

# Run with verbose logging
flutter run -d chrome --verbose

# Check Cloudinary connection
# Monitor browser console for WebSocket logs
```

## 📊 Monitoring

### 1. Connection Status
- **WebSocket Connected**: Real-time updates active
- **Polling Mode**: Fallback mechanism active
- **Disconnected**: No updates, manual refresh needed

### 2. Performance Metrics
- **Update Latency**: Time from backend to client
- **Connection Stability**: Uptime percentage
- **Data Volume**: Number of updates per minute

### 3. Error Tracking
- **Connection Errors**: Failed WebSocket connections
- **Authentication Errors**: Invalid credentials
- **Data Errors**: Malformed update payloads

## 🔄 Maintenance

### Regular Tasks
1. **Monitor Connection Logs**: Check for connection issues
2. **Update API Keys**: Rotate credentials regularly
3. **Review Performance**: Monitor update latency
4. **Backup Configuration**: Save current settings

### Updates
1. **Cloudinary SDK**: Keep updated for latest features
2. **Flutter Dependencies**: Update packages regularly
3. **Security Patches**: Apply security updates promptly

## 📞 Support

### Getting Help
1. **Check Documentation**: Review this guide first
2. **Monitor Logs**: Check console for error messages
3. **Test Connectivity**: Verify network and API access
4. **Contact Support**: Reach out with specific error details

### Useful Resources
- **Cloudinary Documentation**: https://cloudinary.com/documentation
- **Flutter WebSocket**: https://flutter.dev/docs/development/data-and-backend/networking
- **Real-Time Best Practices**: https://cloudinary.com/blog/real_time_image_processing

---

## 🎉 Success Checklist

- [ ] Cloudinary API secret configured
- [ ] Backend API URL updated
- [ ] Webhook endpoint implemented
- [ ] Database schema created
- [ ] Real-time updates working
- [ ] Notifications functioning
- [ ] Connection stability verified
- [ ] Security measures implemented
- [ ] Performance optimized
- [ ] Monitoring setup complete

Once all items are checked, your real-time sync system is ready for production! 🚀
