const express = require('express');
const { body, validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const firebaseConfig = require('../config/firebase');
const logger = require('../utils/logger');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// Validation schemas
const loginValidation = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 })
];

const registerValidation = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('businessName').notEmpty().trim(),
  body('ownerName').notEmpty().trim(),
  body('phone').notEmpty().trim(),
  body('address').notEmpty().trim(),
  body('category').notEmpty().trim()
];

const adminLoginValidation = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 })
];

// Merchant Login
router.post('/merchant/login', loginValidation, async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { email, password } = req.body;

    // Get merchant from Firebase
    const merchantsRef = firebaseConfig.getFirestore().collection(firebaseConfig.collections.MERCHANTS);
    const merchantQuery = await merchantsRef.where('email', '==', email).limit(1).get();

    if (merchantQuery.empty) {
      logger.logSecurity('Failed login attempt - merchant not found', { email });
      return res.status(401).json({
        error: 'Invalid credentials'
      });
    }

    const merchantDoc = merchantQuery.docs[0];
    const merchant = { id: merchantDoc.id, ...merchantDoc.data() };

    // Check if merchant is active
    if (!merchant.isActive) {
      logger.logSecurity('Failed login attempt - inactive merchant', { email, merchantId: merchant.id });
      return res.status(401).json({
        error: 'Account is deactivated. Please contact support.'
      });
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, merchant.password);
    if (!isValidPassword) {
      logger.logSecurity('Failed login attempt - invalid password', { email, merchantId: merchant.id });
      return res.status(401).json({
        error: 'Invalid credentials'
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        userId: merchant.id,
        email: merchant.email,
        role: 'merchant',
        businessName: merchant.businessName
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    // Update last login
    await merchantDoc.ref.update({
      lastLoginAt: new Date()
    });

    // Log successful login
    logger.logSecurity('Merchant login successful', { email, merchantId: merchant.id });

    // Remove password from response
    delete merchant.password;

    // Format merchant data for Flutter app
    const formattedMerchant = {
      id: merchant.id,
      name: merchant.businessName, // Flutter expects 'name' instead of 'businessName'
      ownerName: merchant.ownerName,
      email: merchant.email,
      phone: merchant.phone,
      address: merchant.address,
      description: merchant.description,
      category: merchant.category,
      images: merchant.images || [],
      workingHours: merchant.workingHours || [],
      isActive: merchant.isActive,
      subscriptionId: merchant.subscriptionPlan,
      createdAt: merchant.createdAt?._seconds ? new Date(merchant.createdAt._seconds * 1000).toISOString() : new Date().toISOString(),
      updatedAt: merchant.updatedAt?._seconds ? new Date(merchant.updatedAt._seconds * 1000).toISOString() : new Date().toISOString()
    };

    res.json({
      success: true,
      message: 'Login successful',
      token,
      merchant: formattedMerchant,
      expiresIn: process.env.JWT_EXPIRES_IN || '7d'
    });

  } catch (error) {
    logger.logError(error, { route: '/merchant/login' });
    res.status(500).json({
      error: 'Internal server error'
    });
  }
});

// Merchant Registration
router.post('/merchant/register', registerValidation, async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const {
      email,
      password,
      businessName,
      ownerName,
      phone,
      address,
      category,
      description = ''
    } = req.body;

    // Check if merchant already exists
    const merchantsRef = firebaseConfig.getFirestore().collection(firebaseConfig.collections.MERCHANTS);
    const existingMerchant = await merchantsRef.where('email', '==', email).limit(1).get();

    if (!existingMerchant.empty) {
      return res.status(409).json({
        error: 'Merchant with this email already exists'
      });
    }

    // Hash password
    const saltRounds = parseInt(process.env.BCRYPT_ROUNDS) || 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create merchant document
    const merchantData = {
      email,
      password: hashedPassword,
      businessName,
      ownerName,
      phone,
      address,
      category,
      description,
      isActive: false, // Requires admin approval
      images: [],
      workingHours: [],
      subscriptionPlan: 'freeTrial',
      subscriptionDuration: 30, // 30 days free trial
      subscriptionStartDate: new Date(),
      subscriptionEndDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    };

    const merchant = await firebaseConfig.createDocument(firebaseConfig.collections.MERCHANTS, merchantData);

    // Log merchant registration
    logger.logSecurity('Merchant registration', { email, merchantId: merchant.id });

    // Remove password from response
    delete merchant.password;

    // Format merchant data for Flutter app
    const formattedMerchant = {
      id: merchant.id,
      name: merchant.businessName,
      ownerName: merchant.ownerName,
      email: merchant.email,
      phone: merchant.phone,
      address: merchant.address,
      description: merchant.description,
      category: merchant.category,
      images: merchant.images || [],
      workingHours: merchant.workingHours || [],
      isActive: merchant.isActive,
      subscriptionId: merchant.subscriptionPlan,
      createdAt: merchant.createdAt?._seconds ? new Date(merchant.createdAt._seconds * 1000).toISOString() : new Date().toISOString(),
      updatedAt: merchant.updatedAt?._seconds ? new Date(merchant.updatedAt._seconds * 1000).toISOString() : new Date().toISOString()
    };

    res.status(201).json({
      success: true,
      message: 'Registration successful. Your account will be activated by an administrator.',
      merchant: formattedMerchant
    });

  } catch (error) {
    logger.logError(error, { route: '/merchant/register' });
    res.status(500).json({
      error: 'Internal server error'
    });
  }
});

// Admin Login
router.post('/admin/login', adminLoginValidation, async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { email, password } = req.body;

    // Get admin from Firebase
    const adminsRef = firebaseConfig.getFirestore().collection(firebaseConfig.collections.ADMINS);
    const adminQuery = await adminsRef.where('email', '==', email).limit(1).get();

    if (adminQuery.empty) {
      logger.logSecurity('Failed admin login attempt - admin not found', { email });
      return res.status(401).json({
        error: 'Invalid credentials'
      });
    }

    const adminDoc = adminQuery.docs[0];
    const admin = { id: adminDoc.id, ...adminDoc.data() };

    // Check if admin is active
    if (!admin.isActive) {
      logger.logSecurity('Failed admin login attempt - inactive admin', { email, adminId: admin.id });
      return res.status(401).json({
        error: 'Account is deactivated'
      });
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, admin.password);
    if (!isValidPassword) {
      logger.logSecurity('Failed admin login attempt - invalid password', { email, adminId: admin.id });
      return res.status(401).json({
        error: 'Invalid credentials'
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        userId: admin.id,
        email: admin.email,
        role: 'admin',
        permissions: admin.permissions
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    // Update last login
    await adminDoc.ref.update({
      lastLoginAt: new Date()
    });

    // Log successful login
    logger.logSecurity('Admin login successful', { email, adminId: admin.id });

    // Remove password from response
    delete admin.password;

    // Format admin data for Flutter app
    const formattedAdmin = {
      id: admin.id,
      name: admin.name,
      email: admin.email,
      role: admin.role,
      permissions: admin.permissions || [],
      isActive: admin.isActive,
      createdAt: admin.createdAt?._seconds ? new Date(admin.createdAt._seconds * 1000).toISOString() : new Date().toISOString(),
      lastLoginAt: admin.lastLoginAt?._seconds ? new Date(admin.lastLoginAt._seconds * 1000).toISOString() : null
    };

    res.json({
      success: true,
      message: 'Login successful',
      token,
      admin: formattedAdmin,
      expiresIn: process.env.JWT_EXPIRES_IN || '7d'
    });

  } catch (error) {
    logger.logError(error, { route: '/admin/login' });
    res.status(500).json({
      error: 'Internal server error'
    });
  }
});

// Admin Registration (for initial setup)
router.post('/admin/register', adminLoginValidation, async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { email, password, name, role = 'admin' } = req.body;

    // Check if admin already exists
    const adminsRef = firebaseConfig.getFirestore().collection(firebaseConfig.collections.ADMINS);
    const existingAdminQuery = await adminsRef.where('email', '==', email).limit(1).get();

    if (!existingAdminQuery.empty) {
      return res.status(409).json({
        error: 'Admin with this email already exists'
      });
    }

    // Hash password
    const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS) || 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create admin data
    const adminData = {
      email,
      password: hashedPassword,
      name: name || 'Admin',
      role: role,
      permissions: ['manage_merchants', 'view_analytics', 'manage_admins'],
      isActive: true
    };

    // Add admin to Firestore
    const admin = await firebaseConfig.createDocument(firebaseConfig.collections.ADMINS, adminData);

    // Generate JWT token
    const token = jwt.sign(
      {
        userId: admin.id,
        email: admin.email,
        role: 'admin',
        permissions: admin.permissions
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    // Log admin registration
    logger.logSecurity('Admin registration', { email, adminId: admin.id });

    // Remove password from response
    delete admin.password;

    res.status(201).json({
      success: true,
      message: 'Admin registered successfully',
      token,
      admin,
      expiresIn: process.env.JWT_EXPIRES_IN || '7d'
    });

  } catch (error) {
    logger.logError(error, { route: '/admin/register' });
    res.status(500).json({
      error: 'Internal server error'
    });
  }
});

// Refresh Token
router.post('/refresh', authMiddleware.requireAuth, async (req, res) => {
  try {
    const { userId, email, role } = req.user;

    // Generate new token
    const token = jwt.sign(
      {
        userId,
        email,
        role,
        ...(req.user.permissions && { permissions: req.user.permissions }),
        ...(req.user.businessName && { businessName: req.user.businessName })
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.json({
      success: true,
      token,
      expiresIn: process.env.JWT_EXPIRES_IN || '7d'
    });

  } catch (error) {
    logger.logError(error, { route: '/refresh' });
    res.status(500).json({
      error: 'Internal server error'
    });
  }
});

// Logout
router.post('/logout', authMiddleware.requireAuth, async (req, res) => {
  try {
    // In a more complex system, you might want to blacklist the token
    // For now, we'll just return success
    logger.logSecurity('User logout', { userId: req.user.userId, role: req.user.role });

    res.json({
      success: true,
      message: 'Logout successful'
    });

  } catch (error) {
    logger.logError(error, { route: '/logout' });
    res.status(500).json({
      error: 'Internal server error'
    });
  }
});

// Get current user profile
router.get('/profile', authMiddleware.requireAuth, async (req, res) => {
  try {
    const { userId, role } = req.user;

    let userData;

    if (role === 'merchant') {
      // Get merchant data from Firebase
      const merchant = await firebaseConfig.getDocument(firebaseConfig.collections.MERCHANTS, userId);

      if (!merchant) {
        return res.status(404).json({
          error: 'Merchant not found'
        });
      }

      userData = { ...merchant };
      delete userData.password;

    } else if (role === 'admin') {
      // Get admin data from Firebase
      const admin = await firebaseConfig.getDocument(firebaseConfig.collections.ADMINS, userId);

      if (!admin) {
        return res.status(404).json({
          error: 'Admin not found'
        });
      }

      userData = { ...admin };
      delete userData.password;
    }

    res.json({
      success: true,
      user: userData
    });

  } catch (error) {
    logger.logError(error, { route: '/profile' });
    res.status(500).json({
      error: 'Internal server error'
    });
  }
});

// Update profile
router.put('/profile', authMiddleware.requireAuth, async (req, res) => {
  try {
    const { userId, role } = req.user;
    const updateData = req.body;

    // Remove sensitive fields that shouldn't be updated via this endpoint
    delete updateData.password;
    delete updateData.email;
    delete updateData.role;
    delete updateData.permissions;

    let userData;

    if (role === 'merchant') {
      // Update merchant data in Firebase
      const updatedMerchant = await firebaseConfig.updateDocument(firebaseConfig.collections.MERCHANTS, userId, updateData);

      if (!updatedMerchant) {
        return res.status(404).json({
          error: 'Merchant not found'
        });
      }

      userData = { ...updatedMerchant };
      delete userData.password;

    } else if (role === 'admin') {
      // Update admin data in Firebase
      const updatedAdmin = await firebaseConfig.updateDocument(firebaseConfig.collections.ADMINS, userId, updateData);

      if (!updatedAdmin) {
        return res.status(404).json({
          error: 'Admin not found'
        });
      }

      userData = { ...updatedAdmin };
      delete userData.password;
    }

    // Log profile update
    logger.logAudit('profile_update', userId, role, { updatedFields: Object.keys(updateData) });

    res.json({
      success: true,
      message: 'Profile updated successfully',
      user: userData
    });

  } catch (error) {
    logger.logError(error, { route: '/profile' });
    res.status(500).json({
      error: 'Internal server error'
    });
  }
});

// Change password
router.put('/change-password', authMiddleware.requireAuth, [
  body('currentPassword').notEmpty(),
  body('newPassword').isLength({ min: 6 })
], async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { userId, role } = req.user;
    const { currentPassword, newPassword } = req.body;

    let userData;

    if (role === 'merchant') {
      userData = await firebaseConfig.getDocument(firebaseConfig.collections.MERCHANTS, userId);
    } else if (role === 'admin') {
      userData = await firebaseConfig.getDocument(firebaseConfig.collections.ADMINS, userId);
    }

    if (!userData) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    // Verify current password
    const isValidPassword = await bcrypt.compare(currentPassword, userData.password);
    if (!isValidPassword) {
      logger.logSecurity('Failed password change - invalid current password', { userId, role });
      return res.status(401).json({
        error: 'Current password is incorrect'
      });
    }

    // Hash new password
    const saltRounds = parseInt(process.env.BCRYPT_ROUNDS) || 12;
    const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

    // Update password
    const collection = role === 'merchant' ? firebaseConfig.collections.MERCHANTS : firebaseConfig.collections.ADMINS;
    await firebaseConfig.updateDocument(collection, userId, {
      password: hashedNewPassword
    });

    // Log password change
    logger.logSecurity('Password changed successfully', { userId, role });

    res.json({
      success: true,
      message: 'Password changed successfully'
    });

  } catch (error) {
    logger.logError(error, { route: '/change-password' });
    res.status(500).json({
      error: 'Internal server error'
    });
  }
});

module.exports = router;
