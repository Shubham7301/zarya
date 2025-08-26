#!/usr/bin/env node

const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const logger = require('./src/utils/logger');

// Sample data for testing
const sampleMerchants = [
  {
    businessName: 'Beauty Salon Pro',
    ownerName: 'Sarah Johnson',
    email: 'sarah@beautysalonpro.com',
    phone: '+1234567890',
    address: '123 Main St, New York, NY 10001',
    category: 'Beauty & Wellness',
    description: 'Professional beauty salon offering hair, makeup, and spa services',
    password: 'password123',
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    businessName: 'Tech Solutions Inc',
    ownerName: 'Michael Chen',
    email: 'michael@techsolutions.com',
    phone: '+1987654321',
    address: '456 Tech Ave, San Francisco, CA 94102',
    category: 'Technology',
    description: 'IT consulting and software development services',
    password: 'password123',
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    businessName: 'Fitness First Gym',
    ownerName: 'Emma Davis',
    email: 'emma@fitnessfirst.com',
    phone: '+1555123456',
    address: '789 Fitness Blvd, Los Angeles, CA 90210',
    category: 'Health & Fitness',
    description: 'Full-service gym with personal training and group classes',
    password: 'password123',
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date()
  }
];

const sampleAdmins = [
  {
    email: 'admin@zarya.com',
    password: 'Admin123!',
    name: 'Super Admin',
    role: 'admin',
    permissions: ['all'],
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date()
  }
];

async function createSampleData() {
  try {
    logger.info('Creating sample data for testing...');
    
    // Hash passwords
    for (const merchant of sampleMerchants) {
      merchant.password = await bcrypt.hash(merchant.password, 10);
    }
    
    for (const admin of sampleAdmins) {
      admin.password = await bcrypt.hash(admin.password, 10);
    }
    
    logger.info('Sample data created successfully!');
    logger.info('');
    logger.info('Test credentials:');
    logger.info('');
    logger.info('Merchant Login:');
    logger.info('Email: sarah@beautysalonpro.com');
    logger.info('Password: password123');
    logger.info('');
    logger.info('Super Admin Login:');
    logger.info('Email: admin@zarya.com');
    logger.info('Password: Admin123!');
    logger.info('');
    logger.info('You can now test the login functionality in your Flutter app.');
    
    return { merchants: sampleMerchants, admins: sampleAdmins };
  } catch (error) {
    logger.error('Failed to create sample data:', error);
    throw error;
  }
}

// Export for use in other files
module.exports = { createSampleData };

// Run if executed directly
if (require.main === module) {
  createSampleData()
    .then(() => {
      logger.info('Setup completed successfully!');
      process.exit(0);
    })
    .catch((error) => {
      logger.error('Setup failed:', error);
      process.exit(1);
    });
}
