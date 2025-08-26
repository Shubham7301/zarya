const express = require('express');
const { body, validationResult } = require('express-validator');
const firebaseConfig = require('../config/firebase');
const cloudinaryConfig = require('../config/cloudinary');
const logger = require('../utils/logger');
const authMiddleware = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

const router = express.Router();

// Validation schemas
const merchantValidation = [
  body('businessName').notEmpty().trim().isLength({ min: 2, max: 100 }),
  body('ownerName').notEmpty().trim().isLength({ min: 2, max: 100 }),
  body('email').isEmail().normalizeEmail(),
  body('phone').notEmpty().trim(),
  body('address').notEmpty().trim(),
  body('category').notEmpty().trim(),
  body('description').optional().trim()
];

// Get all merchants (with pagination and filtering)
router.get('/', authMiddleware.requireAuth, asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, search, category, status } = req.query;
  const offset = (page - 1) * limit;

  try {
    let merchantsRef = firebaseConfig.getFirestore().collection(firebaseConfig.collections.MERCHANTS);

    // Apply filters
    if (category) {
      merchantsRef = merchantsRef.where('category', '==', category);
    }

    if (status !== undefined) {
      merchantsRef = merchantsRef.where('isActive', '==', status === 'true');
    }

    // Get all merchants
    const snapshot = await merchantsRef.get();
    let merchants = [];

    snapshot.forEach(doc => {
      merchants.push({ id: doc.id, ...doc.data() });
    });

    // Apply search filter (client-side since Firestore doesn't support full-text search)
    if (search) {
      merchants = merchants.filter(m => 
        m.businessName?.toLowerCase().includes(search.toLowerCase()) ||
        m.ownerName?.toLowerCase().includes(search.toLowerCase()) ||
        m.email?.toLowerCase().includes(search.toLowerCase())
      );
    }

    // Get total count
    const total = merchants.length;

    // Apply pagination
    merchants = merchants
      .sort((a, b) => new Date(b.createdAt?.toDate?.() || b.createdAt) - new Date(a.createdAt?.toDate?.() || a.createdAt))
      .slice(offset, offset + parseInt(limit));

    // Remove passwords from response
    merchants = merchants.map(m => {
      const { password, ...merchantWithoutPassword } = m;
      return merchantWithoutPassword;
    });

    logger.info('Read merchants', { count: merchants.length });

    res.json({
      success: true,
      data: merchants,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    logger.logError(error, { route: '/merchants' });
    res.status(500).json({
      error: 'Failed to fetch merchants'
    });
  }
}));

// Get merchant by ID
router.get('/:id', authMiddleware.requireAuth, asyncHandler(async (req, res) => {
  const { id } = req.params;

  try {
    const merchant = await firebaseConfig.getDocument(firebaseConfig.collections.MERCHANTS, id);

    if (!merchant) {
      return res.status(404).json({
        error: 'Merchant not found'
      });
    }

    const { password, ...merchantWithoutPassword } = merchant;

    logger.info('Read merchant', { id });

    res.json({
      success: true,
      data: merchantWithoutPassword
    });

  } catch (error) {
    logger.logError(error, { route: `/merchants/${id}` });
    res.status(500).json({
      error: 'Failed to fetch merchant'
    });
  }
}));

// Create new merchant
router.post('/', merchantValidation, asyncHandler(async (req, res) => {
  // Check validation errors
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array()
    });
  }

  const merchantData = req.body;

  try {
    // Check if merchant already exists
    const existingMerchant = await firebaseConfig.getDocuments(
      firebaseConfig.collections.MERCHANTS,
      { email: merchantData.email }
    );

    if (existingMerchant.length > 0) {
      return res.status(409).json({
        error: 'Merchant with this email already exists'
      });
    }

    // Hash password if provided
    if (merchantData.password) {
      const bcrypt = require('bcryptjs');
      merchantData.password = await bcrypt.hash(merchantData.password, 10);
    }

    // Create merchant in Firebase
    const merchant = await firebaseConfig.createDocument(firebaseConfig.collections.MERCHANTS, {
      ...merchantData,
      isActive: true, // Set to true for testing
      images: [],
      workingHours: [],
      subscriptionPlan: 'freeTrial',
      subscriptionDuration: 30,
      subscriptionStartDate: new Date(),
      subscriptionEndDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    });

    const { password, ...merchantWithoutPassword } = merchant;

    logger.info('Created merchant', { id: merchant.id });
    logger.logAudit('merchant_created', req.user?.userId || 'system', 'merchants', { merchantId: merchant.id });

    res.status(201).json({
      success: true,
      message: 'Merchant created successfully',
      data: merchantWithoutPassword
    });

  } catch (error) {
    logger.logError(error, { route: '/merchants' });
    res.status(500).json({
      error: 'Failed to create merchant'
    });
  }
}));

// Update merchant
router.put('/:id', merchantValidation, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const updateData = req.body;

  // Check validation errors
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array()
    });
  }

  try {
    // Check if merchant exists
    const existingMerchant = await firebaseConfig.getDocument(firebaseConfig.collections.MERCHANTS, id);

    if (!existingMerchant) {
      return res.status(404).json({
        error: 'Merchant not found'
      });
    }

    // Hash password if provided
    if (updateData.password) {
      const bcrypt = require('bcryptjs');
      updateData.password = await bcrypt.hash(updateData.password, 10);
    }

    // Update merchant in Firebase
    const updatedMerchant = await firebaseConfig.updateDocument(
      firebaseConfig.collections.MERCHANTS,
      id,
      updateData
    );

    const { password, ...merchantWithoutPassword } = updatedMerchant;

    logger.info('Updated merchant', { id });
    logger.logAudit('merchant_updated', req.user?.userId || 'system', 'merchants', { merchantId: id });

    res.json({
      success: true,
      message: 'Merchant updated successfully',
      data: merchantWithoutPassword
    });

  } catch (error) {
    logger.logError(error, { route: `/merchants/${id}` });
    res.status(500).json({
      error: 'Failed to update merchant'
    });
  }
}));

// Delete merchant
router.delete('/:id', authMiddleware.requireAuth, asyncHandler(async (req, res) => {
  const { id } = req.params;

  try {
    // Check if merchant exists
    const existingMerchant = await firebaseConfig.getDocument(firebaseConfig.collections.MERCHANTS, id);

    if (!existingMerchant) {
      return res.status(404).json({
        error: 'Merchant not found'
      });
    }

    // Delete merchant from Firebase
    await firebaseConfig.deleteDocument(firebaseConfig.collections.MERCHANTS, id);

    logger.info('Deleted merchant', { id });
    logger.logAudit('merchant_deleted', req.user?.userId || 'system', 'merchants', { merchantId: id });

    res.json({
      success: true,
      message: 'Merchant deleted successfully'
    });

  } catch (error) {
    logger.logError(error, { route: `/merchants/${id}` });
    res.status(500).json({
      error: 'Failed to delete merchant'
    });
  }
}));

// Activate/Deactivate merchant
router.patch('/:id/status', authMiddleware.requireAuth, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { isActive } = req.body;

  try {
    // Check if merchant exists
    const existingMerchant = await firebaseConfig.getDocument(firebaseConfig.collections.MERCHANTS, id);

    if (!existingMerchant) {
      return res.status(404).json({
        error: 'Merchant not found'
      });
    }

    // Update merchant status
    const updatedMerchant = await firebaseConfig.updateDocument(
      firebaseConfig.collections.MERCHANTS,
      id,
      { isActive }
    );

    const { password, ...merchantWithoutPassword } = updatedMerchant;

    logger.info(`Merchant ${isActive ? 'activated' : 'deactivated'}`, { id });
    logger.logAudit(`merchant_${isActive ? 'activated' : 'deactivated'}`, req.user?.userId || 'system', 'merchants', { merchantId: id });

    res.json({
      success: true,
      message: `Merchant ${isActive ? 'activated' : 'deactivated'} successfully`,
      data: merchantWithoutPassword
    });

  } catch (error) {
    logger.logError(error, { route: `/merchants/${id}/status` });
    res.status(500).json({
      error: 'Failed to update merchant status'
    });
  }
}));

// Upload merchant images
router.post('/:id/images', authMiddleware.requireAuth, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { images } = req.body;

  try {
    // Check if merchant exists
    const existingMerchant = await firebaseConfig.getDocument(firebaseConfig.collections.MERCHANTS, id);

    if (!existingMerchant) {
      return res.status(404).json({
        error: 'Merchant not found'
      });
    }

    // Upload images to Cloudinary
    const uploadedImages = [];
    for (const image of images) {
      try {
        const result = await cloudinaryConfig.uploadImage(image, `merchants/${id}`);
        uploadedImages.push(result.secure_url);
      } catch (uploadError) {
        logger.error('Failed to upload image:', uploadError);
      }
    }

    // Update merchant with new images
    const updatedMerchant = await firebaseConfig.updateDocument(
      firebaseConfig.collections.MERCHANTS,
      id,
      { images: uploadedImages }
    );

    const { password, ...merchantWithoutPassword } = updatedMerchant;

    logger.info('Uploaded merchant images', { id, count: uploadedImages.length });

    res.json({
      success: true,
      message: 'Images uploaded successfully',
      data: merchantWithoutPassword
    });

  } catch (error) {
    logger.logError(error, { route: `/merchants/${id}/images` });
    res.status(500).json({
      error: 'Failed to upload images'
    });
  }
}));

module.exports = router;
