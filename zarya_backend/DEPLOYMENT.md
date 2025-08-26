# Zarya Backend Deployment Guide

## 🚀 Production Deployment

This guide covers deploying the Zarya Backend to production environments.

## 📋 Prerequisites

- Node.js 18+ installed
- Firebase project with Firestore enabled
- Cloudinary account
- Domain name (for production)
- SSL certificate
- Environment variables configured

## 🔧 Environment Setup

### 1. Firebase Configuration

1. **Create Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Firestore Database
   - Enable Authentication (Email/Password)

2. **Generate Service Account Key:**
   - Go to Project Settings > Service Accounts
   - Click "Generate new private key"
   - Download the JSON file
   - Extract the values for environment variables

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

### 2. Cloudinary Configuration

1. **Create Cloudinary Account:**
   - Sign up at [Cloudinary](https://cloudinary.com/)
   - Get your cloud name, API key, and API secret

2. **Configure Upload Presets:**
   - Go to Settings > Upload
   - Create upload presets for different image types
   - Set up folder structure: `zarya/merchants/{merchantId}`

### 3. Environment Variables

Create a `.env` file in the `zarya_backend` directory:

```env
# Server Configuration
NODE_ENV=production
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
ALLOWED_ORIGINS=https://your-frontend-domain.com,https://www.your-frontend-domain.com

# Socket.IO Configuration
SOCKET_CORS_ORIGIN=https://your-frontend-domain.com
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

# Database
DATABASE_URL=your-database-url-if-using-external-db

# Email Configuration (for notifications)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_FROM=noreply@yourdomain.com

# Payment Integration (Stripe)
STRIPE_SECRET_KEY=sk_test_your-stripe-secret-key
STRIPE_WEBHOOK_SECRET=whsec_your-webhook-secret

# Monitoring
SENTRY_DSN=your-sentry-dsn
NEW_RELIC_LICENSE_KEY=your-new-relic-key

# Backup Configuration
BACKUP_ENABLED=true
BACKUP_SCHEDULE=0 2 * * *  # Daily at 2 AM
BACKUP_RETENTION_DAYS=30
```

## 🐳 Docker Deployment

### 1. Create Dockerfile

```dockerfile
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Create logs directory
RUN mkdir -p logs

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
```

### 2. Create docker-compose.yml

```yaml
version: '3.8'

services:
  zarya-backend:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    env_file:
      - .env
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped
    networks:
      - zarya-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - zarya-backend
    restart: unless-stopped
    networks:
      - zarya-network

networks:
  zarya-network:
    driver: bridge
```

### 3. Nginx Configuration

Create `nginx.conf`:

```nginx
events {
    worker_connections 1024;
}

http {
    upstream zarya_backend {
        server zarya-backend:3000;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

    server {
        listen 80;
        server_name your-domain.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name your-domain.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # API routes
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            
            proxy_pass http://zarya_backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }

        # Health check
        location /health {
            proxy_pass http://zarya_backend;
            access_log off;
        }

        # WebSocket support
        location /socket.io/ {
            proxy_pass http://zarya_backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

## ☁️ Cloud Deployment

### 1. Heroku Deployment

1. **Install Heroku CLI:**
   ```bash
   npm install -g heroku
   ```

2. **Create Heroku App:**
   ```bash
   heroku create your-zarya-backend
   ```

3. **Set Environment Variables:**
   ```bash
   heroku config:set NODE_ENV=production
   heroku config:set JWT_SECRET=your-jwt-secret
   # ... set all other environment variables
   ```

4. **Deploy:**
   ```bash
   git push heroku main
   ```

### 2. AWS Deployment

1. **EC2 Setup:**
   ```bash
   # Install Node.js
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs

   # Install PM2
   sudo npm install -g pm2

   # Clone repository
   git clone https://github.com/your-repo/zarya-backend.git
   cd zarya-backend

   # Install dependencies
   npm install --production

   # Start with PM2
   pm2 start src/server.js --name "zarya-backend"
   pm2 startup
   pm2 save
   ```

2. **Load Balancer Configuration:**
   - Create Application Load Balancer
   - Configure target groups
   - Set up SSL certificates
   - Configure health checks

### 3. Google Cloud Platform

1. **App Engine:**
   ```yaml
   # app.yaml
   runtime: nodejs18
   env: standard
   
   env_variables:
     NODE_ENV: production
     PORT: 8080
   
   automatic_scaling:
     target_cpu_utilization: 0.65
     min_instances: 1
     max_instances: 10
   ```

2. **Deploy:**
   ```bash
   gcloud app deploy
   ```

## 🔒 Security Configuration

### 1. SSL/TLS Setup

1. **Let's Encrypt (Free):**
   ```bash
   sudo apt-get install certbot python3-certbot-nginx
   sudo certbot --nginx -d your-domain.com
   ```

2. **Commercial SSL:**
   - Purchase SSL certificate
   - Install on your server
   - Configure nginx

### 2. Firewall Configuration

```bash
# UFW (Ubuntu)
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# iptables (CentOS/RHEL)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -j DROP
```

### 3. Database Security

1. **Firestore Security Rules:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Require authentication
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
       
       // Merchant-specific rules
       match /merchants/{merchantId} {
         allow read, write: if request.auth != null && 
           (request.auth.uid == merchantId || 
            get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'admin');
       }
     }
   }
   ```

## 📊 Monitoring & Logging

### 1. Application Monitoring

1. **PM2 Monitoring:**
   ```bash
   pm2 monit
   pm2 logs
   ```

2. **Sentry Integration:**
   ```javascript
   const Sentry = require('@sentry/node');
   
   Sentry.init({
     dsn: process.env.SENTRY_DSN,
     environment: process.env.NODE_ENV,
   });
   ```

### 2. Log Management

1. **Winston Configuration:**
   ```javascript
   const winston = require('winston');
   
   const logger = winston.createLogger({
     level: process.env.LOG_LEVEL || 'info',
     format: winston.format.combine(
       winston.format.timestamp(),
       winston.format.json()
     ),
     transports: [
       new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
       new winston.transports.File({ filename: 'logs/combined.log' }),
     ],
   });
   ```

### 3. Health Checks

```javascript
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV,
    version: process.env.APP_VERSION,
    memory: process.memoryUsage(),
  });
});
```

## 🔄 CI/CD Pipeline

### 1. GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Deploy to server
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        key: ${{ secrets.KEY }}
        script: |
          cd /path/to/zarya-backend
          git pull origin main
          npm install --production
          pm2 restart zarya-backend
```

## 📈 Performance Optimization

### 1. Caching

```javascript
const redis = require('redis');
const client = redis.createClient();

// Cache middleware
const cache = (duration) => {
  return async (req, res, next) => {
    const key = `cache:${req.originalUrl}`;
    const cached = await client.get(key);
    
    if (cached) {
      return res.json(JSON.parse(cached));
    }
    
    res.sendResponse = res.json;
    res.json = (body) => {
      client.setex(key, duration, JSON.stringify(body));
      res.sendResponse(body);
    };
    next();
  };
};
```

### 2. Database Optimization

1. **Indexes:**
   ```javascript
   // Create indexes for common queries
   db.collection('merchants').createIndex({ email: 1 });
   db.collection('merchants').createIndex({ category: 1 });
   db.collection('merchants').createIndex({ isActive: 1 });
   ```

2. **Query Optimization:**
   ```javascript
   // Use projection to limit fields
   const merchants = await db.collection('merchants')
     .find({}, { projection: { password: 0 } })
     .limit(10)
     .toArray();
   ```

## 🚨 Backup & Recovery

### 1. Database Backup

```javascript
// Automated backup script
const backupDatabase = async () => {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const backupPath = `./backups/backup-${timestamp}.json`;
  
  // Export Firestore data
  const collections = ['merchants', 'admins', 'subscriptions'];
  const backup = {};
  
  for (const collection of collections) {
    const snapshot = await db.collection(collection).get();
    backup[collection] = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  }
  
  fs.writeFileSync(backupPath, JSON.stringify(backup, null, 2));
};
```

### 2. Recovery Procedures

1. **Database Recovery:**
   ```javascript
   const restoreDatabase = async (backupFile) => {
     const backup = JSON.parse(fs.readFileSync(backupFile));
     
     for (const [collection, documents] of Object.entries(backup)) {
       for (const doc of documents) {
         await db.collection(collection).doc(doc.id).set(doc);
       }
     }
   };
   ```

## 📞 Support & Maintenance

### 1. Monitoring Alerts

```javascript
// Set up monitoring alerts
const sendAlert = async (message) => {
  // Send to Slack, email, or SMS
  console.error('ALERT:', message);
};
```

### 2. Maintenance Schedule

- **Daily:** Health checks, log rotation
- **Weekly:** Security updates, performance monitoring
- **Monthly:** Database optimization, backup verification
- **Quarterly:** Security audit, dependency updates

## 🔧 Troubleshooting

### Common Issues

1. **CORS Errors:**
   - Check `ALLOWED_ORIGINS` environment variable
   - Verify frontend domain is included

2. **Authentication Issues:**
   - Verify JWT secret is set correctly
   - Check Firebase credentials

3. **Database Connection:**
   - Verify Firebase project configuration
   - Check service account permissions

4. **Image Upload Issues:**
   - Verify Cloudinary credentials
   - Check upload limits and file types

### Debug Commands

```bash
# Check application status
pm2 status
pm2 logs zarya-backend

# Check environment variables
node -e "console.log(process.env)"

# Test database connection
node -e "require('./src/config/firebase').initialize().then(() => console.log('Connected'))"

# Monitor system resources
htop
df -h
free -h
```

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Express.js Security](https://expressjs.com/en/advanced/best-practices-security.html)
