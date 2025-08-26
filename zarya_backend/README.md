# Zarya Backend API

A comprehensive Node.js/Express backend for the Zarya Merchant App with Firebase integration, Cloudinary image management, and real-time features.

## 🚀 Features

- **Firebase Integration**: Authentication and Firestore database
- **Cloudinary**: Image upload and management
- **Real-time Communication**: Socket.IO for live updates
- **JWT Authentication**: Secure token-based authentication
- **Role-based Access Control**: Merchant and Admin roles
- **Rate Limiting**: API protection and security
- **Comprehensive Logging**: Winston logger with structured logs
- **Error Handling**: Centralized error management
- **Cron Jobs**: Automated tasks and maintenance
- **File Upload**: Multer with Cloudinary integration
- **API Documentation**: Swagger/OpenAPI documentation

## 🛠️ Technology Stack

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth + JWT
- **File Storage**: Cloudinary
- **Real-time**: Socket.IO
- **Logging**: Winston
- **Validation**: Express-validator
- **Security**: Helmet, CORS, Rate limiting
- **Documentation**: Swagger/OpenAPI

## 📋 Prerequisites

- Node.js 18.0.0 or higher
- npm 9.0.0 or higher
- Firebase project with Firestore enabled
- Cloudinary account
- Environment variables configured

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd zarya_backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp env.example .env
   # Edit .env with your actual values
   ```

4. **Configure Firebase**
   - Create a Firebase project
   - Enable Firestore database
   - Generate service account key
   - Update Firebase credentials in `.env`

5. **Configure Cloudinary**
   - Create a Cloudinary account
   - Get your cloud name, API key, and secret
   - Update Cloudinary credentials in `.env`

6. **Start the server**
   ```bash
   # Development
   npm run dev
   
   # Production
   npm start
   ```

## 🔐 Environment Variables

Copy `env.example` to `.env` and configure the following variables:

### Server Configuration
```env
NODE_ENV=development
PORT=3000
API_VERSION=v1
```

### Firebase Configuration
```env
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40your-project.iam.gserviceaccount.com
```

### Cloudinary Configuration
```env
CLOUDINARY_CLOUD_NAME=zarya-booking
CLOUDINARY_API_KEY=839433281873668
CLOUDINARY_API_SECRET=e8-kMgVFUYWwfqI54Q4SAeEMkbc
CLOUDINARY_UPLOAD_PRESET=zarya_uploads
```

### JWT Configuration
```env
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_REFRESH_EXPIRES_IN=30d
```

## 📁 Project Structure

```
zarya_backend/
├── src/
│   ├── config/           # Configuration files
│   │   ├── firebase.js   # Firebase configuration
│   │   └── cloudinary.js # Cloudinary configuration
│   ├── middleware/       # Express middleware
│   │   ├── auth.js       # Authentication middleware
│   │   ├── errorHandler.js # Error handling
│   │   └── validation.js # Input validation
│   ├── routes/           # API routes
│   │   ├── auth.js       # Authentication routes
│   │   ├── merchants.js  # Merchant management
│   │   ├── subscriptions.js # Subscription management
│   │   ├── admin.js      # Admin operations
│   │   ├── analytics.js  # Analytics and reporting
│   │   ├── webhooks.js   # Webhook handlers
│   │   └── health.js     # Health check endpoints
│   ├── services/         # Business logic services
│   │   ├── realtimeService.js # Real-time communication
│   │   ├── notificationService.js # Notification handling
│   │   └── cronService.js # Scheduled tasks
│   ├── utils/            # Utility functions
│   │   └── logger.js     # Winston logger
│   └── server.js         # Main server file
├── logs/                 # Log files
├── tests/                # Test files
├── package.json          # Dependencies and scripts
├── env.example           # Environment variables template
└── README.md            # This file
```

## 🔌 API Endpoints

### Authentication
- `POST /api/v1/auth/merchant/login` - Merchant login
- `POST /api/v1/auth/merchant/register` - Merchant registration
- `POST /api/v1/auth/admin/login` - Admin login
- `POST /api/v1/auth/refresh` - Refresh JWT token
- `POST /api/v1/auth/logout` - User logout
- `GET /api/v1/auth/profile` - Get user profile
- `PUT /api/v1/auth/profile` - Update user profile
- `PUT /api/v1/auth/change-password` - Change password

### Merchant Management
- `GET /api/v1/merchants` - Get all merchants
- `GET /api/v1/merchants/:id` - Get merchant by ID
- `POST /api/v1/merchants` - Create new merchant
- `PUT /api/v1/merchants/:id` - Update merchant
- `DELETE /api/v1/merchants/:id` - Delete merchant
- `PATCH /api/v1/merchants/:id/toggle-status` - Toggle merchant status

### Subscription Management
- `GET /api/v1/subscriptions` - Get all subscriptions
- `GET /api/v1/subscriptions/:id` - Get subscription by ID
- `POST /api/v1/subscriptions` - Create subscription
- `PUT /api/v1/subscriptions/:id` - Update subscription
- `DELETE /api/v1/subscriptions/:id` - Cancel subscription
- `POST /api/v1/subscriptions/:id/renew` - Renew subscription

### Admin Operations
- `GET /api/v1/admin/dashboard` - Admin dashboard data
- `GET /api/v1/admin/merchants` - Admin merchant management
- `POST /api/v1/admin/merchants` - Create merchant (admin)
- `PUT /api/v1/admin/merchants/:id` - Update merchant (admin)
- `DELETE /api/v1/admin/merchants/:id` - Delete merchant (admin)

### Analytics
- `GET /api/v1/analytics/overview` - Overview analytics
- `GET /api/v1/analytics/merchants` - Merchant analytics
- `GET /api/v1/analytics/revenue` - Revenue analytics
- `GET /api/v1/analytics/subscriptions` - Subscription analytics

### Webhooks
- `POST /api/v1/webhooks/cloudinary` - Cloudinary webhook
- `POST /api/v1/webhooks/stripe` - Stripe webhook
- `POST /api/v1/webhooks/twilio` - Twilio webhook

### Health Check
- `GET /health` - Server health check
- `GET /api/v1/health` - Detailed health check

## 🔄 Real-time Features

### Socket.IO Events

#### Client to Server
- `join-merchant` - Join merchant room
- `join-admin` - Join admin room
- `merchant-update` - Send merchant update
- `subscription-update` - Send subscription update
- `admin-action` - Send admin action

#### Server to Client
- `merchant-updated` - Merchant data updated
- `subscription-updated` - Subscription data updated
- `admin-action` - Admin action notification
- `notification` - General notification

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Role-based Access Control**: Merchant and Admin roles
- **Rate Limiting**: API protection against abuse
- **Input Validation**: Comprehensive request validation
- **CORS Protection**: Cross-origin resource sharing
- **Helmet Security**: Security headers
- **Password Hashing**: bcrypt for password security
- **Audit Logging**: Track all admin actions

## 📊 Logging

The application uses Winston for comprehensive logging:

- **Error Logs**: `logs/error.log`
- **Combined Logs**: `logs/combined.log`
- **Debug Logs**: `logs/debug.log`
- **Console Output**: Development environment

### Log Levels
- `error`: Application errors
- `warn`: Warning messages
- `info`: General information
- `debug`: Debug information

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch
```

## 🚀 Deployment

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

### Docker
```bash
# Build image
docker build -t zarya-backend .

# Run container
docker run -p 3000:3000 zarya-backend
```

## 📈 Monitoring

### Health Checks
- `GET /health` - Basic health check
- `GET /api/v1/health` - Detailed health check with dependencies

### Metrics
- Request/response times
- Error rates
- Database connection status
- External service status

## 🔧 Development

### Code Style
```bash
# Lint code
npm run lint

# Format code
npm run format
```

### Database Setup
1. Create Firebase project
2. Enable Firestore
3. Set up security rules
4. Create initial collections

### Environment Setup
1. Copy `env.example` to `.env`
2. Configure all required variables
3. Test connections

## 📚 API Documentation

Once the server is running, visit:
- **Swagger UI**: `http://localhost:3000/api/v1/docs`
- **Health Check**: `http://localhost:3000/health`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the logs

## 🔄 Changelog

### v1.0.0
- Initial release
- Firebase integration
- Cloudinary integration
- Real-time features
- Authentication system
- Admin dashboard
- Merchant management
- Subscription system
