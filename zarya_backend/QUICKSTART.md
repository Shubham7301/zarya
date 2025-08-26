# Zarya Backend - Quick Start Guide

Get the Zarya Backend up and running in 5 minutes!

## 🚀 Quick Setup

### 1. Prerequisites

- Node.js 18+ installed
- npm 9+ installed
- Firebase project (create one at [Firebase Console](https://console.firebase.google.com/))
- Cloudinary account (sign up at [Cloudinary](https://cloudinary.com/))

### 2. Clone and Install

```bash
# Clone the repository
git clone <repository-url>
cd zarya_backend

# Install dependencies
npm install
```

### 3. Environment Setup

```bash
# Copy environment template
cp .env.example .env

# Edit .env file with your credentials
nano .env
```

**Required Environment Variables:**
```env
# Firebase (get from Firebase Console > Project Settings > Service Accounts)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com

# Cloudinary (get from Cloudinary Dashboard)
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# JWT (generate a random string)
JWT_SECRET=your-super-secret-jwt-key
```

### 4. Initialize Database

```bash
# Run setup script to create sample data
npm run setup
```

### 5. Start the Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

### 6. Test the API

```bash
# Check if server is running
curl http://localhost:3000/health

# Or use the npm script
npm run health
```

## 📋 What's Included

### Sample Data Created
- 3 sample merchants (Beauty Salon, Tech Solutions, Fitness Gym)
- 3 sample subscriptions (monthly, quarterly, yearly)
- 1 admin user (admin@zarya.com / Admin123!)
- 4 sample services
- 2 sample appointments

### API Endpoints Available
- `GET /health` - Health check
- `POST /api/v1/auth/login` - Merchant login
- `POST /api/v1/auth/admin/login` - Admin login
- `GET /api/v1/merchants` - List merchants
- `GET /api/v1/subscriptions` - List subscriptions
- `GET /api/v1/admin/dashboard` - Admin dashboard
- `GET /api/v1/analytics/overview` - Analytics overview

### Real-time Features
- WebSocket support for real-time updates
- Socket.IO integration
- Real-time notifications

## 🔧 Development Commands

```bash
# Start development server
npm run dev

# Run tests
npm test

# Lint code
npm run lint

# Format code
npm run format

# Setup database with sample data
npm run setup

# Check health
npm run health
```

## 📱 Connect Flutter App

Update your Flutter app's API configuration:

```dart
// In your Flutter app's config
const String apiBaseUrl = 'http://localhost:3000/api/v1';
const String socketUrl = 'http://localhost:3000';
```

## 🚨 Common Issues & Solutions

### 1. Port 3000 Already in Use
```bash
# Find and kill the process
lsof -i :3000
kill -9 <PID>

# Or use a different port
PORT=3001 npm start
```

### 2. Firebase Connection Error
- Verify your Firebase credentials in `.env`
- Ensure Firestore is enabled in Firebase Console
- Check if the service account has proper permissions

### 3. Cloudinary Upload Error
- Verify your Cloudinary credentials
- Create an upload preset named 'zarya_uploads' in Cloudinary Console
- Set the preset to 'Unsigned' for client-side uploads

### 4. JWT Secret Error
- Generate a strong JWT secret: `node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"`
- Update the `JWT_SECRET` in your `.env` file

## 📊 Monitoring

### Health Check
```bash
curl http://localhost:3000/health
```

### Logs
Logs are stored in the `logs/` directory:
- `logs/error.log` - Error logs
- `logs/combined.log` - All logs
- `logs/debug.log` - Debug logs

### Real-time Monitoring
```bash
# Monitor with PM2 (if installed)
pm2 monit

# View logs
pm2 logs
```

## 🔐 Security Notes

1. **Never commit `.env` files** - They contain sensitive information
2. **Use strong JWT secrets** - Generate random strings
3. **Enable HTTPS in production** - Always use SSL/TLS
4. **Set up proper CORS** - Configure allowed origins
5. **Use rate limiting** - Prevent abuse

## 📚 Next Steps

1. **Explore the API** - Test endpoints with Postman or curl
2. **Connect your Flutter app** - Update API configuration
3. **Customize the data** - Modify sample data in `setup.js`
4. **Add more features** - Extend the API as needed
5. **Deploy to production** - Follow the deployment guide

## 🆘 Need Help?

1. Check the logs in `logs/` directory
2. Verify all environment variables are set
3. Test the health endpoint
4. Review the full documentation in `README.md`
5. Check the deployment guide in `DEPLOYMENT.md`

## 🎯 Default Credentials

**Admin User:**
- Email: `admin@zarya.com`
- Password: `Admin123!`

**Sample Merchants:**
- Beauty Salon Pro (sarah@beautysalonpro.com)
- Tech Solutions Inc (michael@techsolutions.com)
- Fitness First Gym (emma@fitnessfirst.com)

---

**Happy Coding! 🚀**

For more detailed information, check out the full documentation in `README.md` and `DEPLOYMENT.md`.
