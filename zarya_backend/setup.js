#!/usr/bin/env node

/**
 * Zarya Backend Setup Script
 * 
 * This script sets up the Zarya backend with:
 * - Environment validation
 * - Firebase initialization
 * - Default data creation
 * - Security configuration
 * - Health checks
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import Firebase configuration
const firebaseConfig = require('./src/config/firebase');
const logger = require('./src/utils/logger');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function logSuccess(message) {
  log(`✅ ${message}`, 'green');
}

function logError(message) {
  log(`❌ ${message}`, 'red');
}

function logWarning(message) {
  log(`⚠️  ${message}`, 'yellow');
}

function logInfo(message) {
  log(`ℹ️  ${message}`, 'blue');
}

// Validate environment variables
function validateEnvironment() {
  logInfo('Validating environment variables...');
  
  const requiredVars = [
    'FIREBASE_PROJECT_ID',
    'FIREBASE_PRIVATE_KEY_ID',
    'FIREBASE_PRIVATE_KEY',
    'FIREBASE_CLIENT_EMAIL',
    'FIREBASE_CLIENT_ID',
    'FIREBASE_AUTH_URI',
    'FIREBASE_TOKEN_URI',
    'FIREBASE_AUTH_PROVIDER_X509_CERT_URL',
    'FIREBASE_CLIENT_X509_CERT_URL',
    'CLOUDINARY_CLOUD_NAME',
    'CLOUDINARY_API_KEY',
    'CLOUDINARY_API_SECRET',
    'JWT_SECRET'
  ];

  const missingVars = [];
  
  for (const varName of requiredVars) {
    if (!process.env[varName]) {
      missingVars.push(varName);
    }
  }

  if (missingVars.length > 0) {
    logError(`Missing required environment variables: ${missingVars.join(', ')}`);
    logInfo('Please check your .env file and ensure all required variables are set.');
    return false;
  }

  logSuccess('Environment variables validated successfully');
  return true;
}

// Initialize Firebase
async function initializeFirebase() {
  try {
    logInfo('Initializing Firebase...');
    await firebaseConfig.initialize();
    logSuccess('Firebase initialized successfully');
    return true;
  } catch (error) {
    logError(`Failed to initialize Firebase: ${error.message}`);
    return false;
  }
}

// Create default admin user
async function createDefaultAdmin() {
  try {
    logInfo('Creating default admin user...');
    
    const adminEmail = 'admin@zarya.com';
    const adminPassword = 'Admin123!';
    
    // Check if admin already exists
    const adminsRef = firebaseConfig.getFirestore().collection(firebaseConfig.collections.ADMINS);
    const adminQuery = await adminsRef.where('email', '==', adminEmail).limit(1).get();
    
    if (!adminQuery.empty) {
      logWarning('Default admin user already exists');
      return true;
    }
    
    // Create admin user
    const hashedPassword = await bcrypt.hash(adminPassword, 12);
    const adminData = {
      email: adminEmail,
      password: hashedPassword,
      name: 'Super Admin',
      role: 'admin',
      permissions: ['all'],
      isActive: true
    };
    
    await firebaseConfig.createDocument(firebaseConfig.collections.ADMINS, adminData);
    
    logSuccess('Default admin user created successfully');
    logInfo(`Email: ${adminEmail}`);
    logInfo(`Password: ${adminPassword}`);
    logWarning('Please change the default password after first login!');
    
    return true;
  } catch (error) {
    logError(`Failed to create default admin: ${error.message}`);
    return false;
  }
}

// Create sample merchants (optional)
async function createSampleMerchants() {
  try {
    logInfo('Creating sample merchants...');
    
    const sampleMerchants = [
      {
        businessName: 'Beauty Salon Pro',
        ownerName: 'Sarah Johnson',
        email: 'sarah@beautysalonpro.com',
        phone: '+1234567890',
        address: '123 Main St, New York, NY 10001',
        category: 'Beauty & Wellness',
        description: 'Professional beauty salon offering hair, makeup, and spa services',
        password: await bcrypt.hash('password123', 12),
        isActive: true,
        subscriptionPlan: 'freeTrial',
        subscriptionDuration: 30,
        subscriptionStartDate: new Date(),
        subscriptionEndDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        images: [],
        workingHours: [
          { day: 'Monday', startTime: '09:00', endTime: '17:00', isOpen: true },
          { day: 'Tuesday', startTime: '09:00', endTime: '17:00', isOpen: true },
          { day: 'Wednesday', startTime: '09:00', endTime: '17:00', isOpen: true },
          { day: 'Thursday', startTime: '09:00', endTime: '17:00', isOpen: true },
          { day: 'Friday', startTime: '09:00', endTime: '17:00', isOpen: true },
          { day: 'Saturday', startTime: '10:00', endTime: '16:00', isOpen: true },
          { day: 'Sunday', startTime: '10:00', endTime: '16:00', isOpen: false }
        ]
      },
      {
        businessName: 'Tech Solutions Inc',
        ownerName: 'Michael Chen',
        email: 'michael@techsolutions.com',
        phone: '+1987654321',
        address: '456 Tech Ave, San Francisco, CA 94102',
        category: 'Technology',
        description: 'IT consulting and software development services',
        password: await bcrypt.hash('password123', 12),
        isActive: true,
        subscriptionPlan: 'freeTrial',
        subscriptionDuration: 30,
        subscriptionStartDate: new Date(),
        subscriptionEndDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        images: [],
        workingHours: [
          { day: 'Monday', startTime: '09:00', endTime: '18:00', isOpen: true },
          { day: 'Tuesday', startTime: '09:00', endTime: '18:00', isOpen: true },
          { day: 'Wednesday', startTime: '09:00', endTime: '18:00', isOpen: true },
          { day: 'Thursday', startTime: '09:00', endTime: '18:00', isOpen: true },
          { day: 'Friday', startTime: '09:00', endTime: '18:00', isOpen: true },
          { day: 'Saturday', startTime: '10:00', endTime: '16:00', isOpen: true },
          { day: 'Sunday', startTime: '10:00', endTime: '16:00', isOpen: false }
        ]
      },
      {
        businessName: 'Fitness First Gym',
        ownerName: 'Emma Davis',
        email: 'emma@fitnessfirst.com',
        phone: '+1555123456',
        address: '789 Fitness Blvd, Los Angeles, CA 90210',
        category: 'Health & Fitness',
        description: 'Full-service gym with personal training and group classes',
        password: await bcrypt.hash('password123', 12),
        isActive: true,
        subscriptionPlan: 'freeTrial',
        subscriptionDuration: 30,
        subscriptionStartDate: new Date(),
        subscriptionEndDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        images: [],
        workingHours: [
          { day: 'Monday', startTime: '06:00', endTime: '22:00', isOpen: true },
          { day: 'Tuesday', startTime: '06:00', endTime: '22:00', isOpen: true },
          { day: 'Wednesday', startTime: '06:00', endTime: '22:00', isOpen: true },
          { day: 'Thursday', startTime: '06:00', endTime: '22:00', isOpen: true },
          { day: 'Friday', startTime: '06:00', endTime: '22:00', isOpen: true },
          { day: 'Saturday', startTime: '08:00', endTime: '20:00', isOpen: true },
          { day: 'Sunday', startTime: '08:00', endTime: '20:00', isOpen: true }
        ]
      }
    ];
    
    for (const merchantData of sampleMerchants) {
      // Check if merchant already exists
      const merchantsRef = firebaseConfig.getFirestore().collection(firebaseConfig.collections.MERCHANTS);
      const merchantQuery = await merchantsRef.where('email', '==', merchantData.email).limit(1).get();
      
      if (merchantQuery.empty) {
        await firebaseConfig.createDocument(firebaseConfig.collections.MERCHANTS, merchantData);
        logInfo(`Created merchant: ${merchantData.businessName}`);
      } else {
        logWarning(`Merchant already exists: ${merchantData.businessName}`);
      }
    }
    
    logSuccess('Sample merchants created successfully');
    return true;
  } catch (error) {
    logError(`Failed to create sample merchants: ${error.message}`);
    return false;
  }
}

// Create logs directory
function createLogsDirectory() {
  try {
    const logsDir = path.join(__dirname, 'logs');
    if (!fs.existsSync(logsDir)) {
      fs.mkdirSync(logsDir, { recursive: true });
      logSuccess('Logs directory created');
    } else {
      logInfo('Logs directory already exists');
    }
    return true;
  } catch (error) {
    logError(`Failed to create logs directory: ${error.message}`);
    return false;
  }
}

// Test API endpoints
async function testAPIEndpoints() {
  try {
    logInfo('Testing API endpoints...');
    
    // Test health endpoint
    const healthResponse = await fetch('http://localhost:3000/health');
    if (healthResponse.ok) {
      logSuccess('Health endpoint is working');
    } else {
      logError('Health endpoint is not working');
      return false;
    }
    
    // Test admin login
    const loginResponse = await fetch('http://localhost:3000/api/v1/auth/admin/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: 'admin@zarya.com',
        password: 'Admin123!'
      })
    });
    
    if (loginResponse.ok) {
      const loginData = await loginResponse.json();
      if (loginData.token) {
        logSuccess('Admin login is working');
      } else {
        logError('Admin login failed - no token received');
        return false;
      }
    } else {
      logError('Admin login endpoint is not working');
      return false;
    }
    
    logSuccess('All API endpoints are working correctly');
    return true;
  } catch (error) {
    logError(`Failed to test API endpoints: ${error.message}`);
    logWarning('Make sure the server is running on port 3000');
    return false;
  }
}

// Main setup function
async function main() {
  log(`${colors.bright}${colors.cyan}🚀 Zarya Backend Setup${colors.reset}`);
  log(`${colors.cyan}================================${colors.reset}\n`);
  
  try {
    // Step 1: Validate environment
    if (!validateEnvironment()) {
      process.exit(1);
    }
    
    // Step 2: Initialize Firebase
    if (!await initializeFirebase()) {
      process.exit(1);
    }
    
    // Step 3: Create logs directory
    if (!createLogsDirectory()) {
      process.exit(1);
    }
    
    // Step 4: Create default admin
    if (!await createDefaultAdmin()) {
      process.exit(1);
    }
    
    // Step 5: Ask about sample data
    const answer = await new Promise((resolve) => {
      rl.question('Do you want to create sample merchants? (y/N): ', resolve);
    });
    
    if (answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes') {
      if (!await createSampleMerchants()) {
        logWarning('Failed to create sample merchants, but setup can continue');
      }
    }
    
    // Step 6: Test API endpoints (if server is running)
    const testAnswer = await new Promise((resolve) => {
      rl.question('Do you want to test API endpoints? (requires server to be running) (y/N): ', resolve);
    });
    
    if (testAnswer.toLowerCase() === 'y' || testAnswer.toLowerCase() === 'yes') {
      await testAPIEndpoints();
    }
    
    log(`\n${colors.bright}${colors.green}🎉 Setup completed successfully!${colors.reset}`);
    log(`\n${colors.cyan}Next steps:${colors.reset}`);
    log('1. Start the server: npm start');
    log('2. Test the API: curl http://localhost:3000/health');
    log('3. Login as admin: admin@zarya.com / Admin123!');
    log('4. Change the default admin password');
    log('5. Configure your Flutter app to connect to the backend');
    
    log(`\n${colors.yellow}Important:${colors.reset}`);
    log('- Change the default admin password after first login');
    log('- Update environment variables for production');
    log('- Configure SSL certificates for production');
    log('- Set up monitoring and logging');
    
  } catch (error) {
    logError(`Setup failed: ${error.message}`);
    process.exit(1);
  } finally {
    rl.close();
  }
}

// Run setup if this file is executed directly
if (require.main === module) {
  main().catch((error) => {
    logError(`Unexpected error: ${error.message}`);
    process.exit(1);
  });
}

module.exports = {
  validateEnvironment,
  initializeFirebase,
  createDefaultAdmin,
  createSampleMerchants,
  createLogsDirectory,
  testAPIEndpoints
};
