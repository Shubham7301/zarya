const express = require('express');
const { body, validationResult } = require('express-validator');
const firebaseConfig = require('../config/firebase');
const logger = require('../utils/logger');
const authMiddleware = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

const router = express.Router();

// Validation schemas
const subscriptionValidation = [
  body('merchantId').notEmpty().trim(),
  body('plan').isIn(['freeTrial', 'basic', 'premium', 'enterprise']),
  body('duration').isInt({ min: 1, max: 12 }),
  body('amount').isFloat({ min: 0 }),
  body('currency').optional().isIn(['USD', 'EUR', 'GBP']),
  body('paymentMethod').optional().trim(),
  body('notes').optional().trim()
];

// Get all subscriptions
router.get('/', authMiddleware.requireAuth, asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, merchantId, status, plan } = req.query;
  const offset = (page - 1) * limit;

  try {
    let query = firebaseConfig.getFirestore().collection('subscriptions');

    // Apply filters
    if (merchantId) {
      query = query.where('merchantId', '==', merchantId);
    }

    if (status) {
      query = query.where('status', '==', status);
    }

    if (plan) {
      query = query.where('plan', '==', plan);
    }

    // Get total count
    const totalSnapshot = await query.get();
    const total = totalSnapshot.size;

    // Apply pagination
    query = query.orderBy('createdAt', 'desc').limit(parseInt(limit)).offset(offset);

    const snapshot = await query.get();
    const subscriptions = [];

    snapshot.forEach(doc => {
      subscriptions.push({ id: doc.id, ...doc.data() });
    });

    logger.logFirebase('read', 'subscriptions', 'multiple', { count: subscriptions.length });

    res.json({
      success: true,
      data: subscriptions,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    logger.logError(error, { route: '/subscriptions' });
    res.status(500).json({
      error: 'Failed to fetch subscriptions'
    });
  }
}));

// Get subscription by ID
router.get('/:id', authMiddleware.requireAuth, asyncHandler(async (req, res) => {
  const { id } = req.params;

  try {
    const subscriptionDoc = await firebaseConfig.getFirestore()
      .collection('subscriptions')
      .doc(id)
      .get();

    if (!subscriptionDoc.exists) {
      return res.status(404).json({
        error: 'Subscription not found'
      });
    }

    const subscription = { id: subscriptionDoc.id, ...subscriptionDoc.data() };

    logger.logFirebase('read', 'subscriptions', id);

    res.json({
      success: true,
      data: subscription
    });

  } catch (error) {
    logger.logError(error, { route: `/subscriptions/${id}` });
    res.status(500).json({
      error: 'Failed to fetch subscription'
    });
  }
}));

// Create subscription
router.post('/', subscriptionValidation, authMiddleware.requireAuth, authMiddleware.requireAdmin, asyncHandler(async (req, res) => {
  // Check validation errors
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array()
    });
  }

  const subscriptionData = req.body;

  try {
    // Check if merchant exists
    const merchantDoc = await firebaseConfig.getFirestore()
      .collection('merchants')
      .doc(subscriptionData.merchantId)
      .get();

    if (!merchantDoc.exists) {
      return res.status(404).json({
        error: 'Merchant not found'
      });
    }

    // Calculate dates
    const startDate = new Date();
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + subscriptionData.duration);

    // Create subscription document
    const subscriptionRef = await firebaseConfig.getFirestore()
      .collection('subscriptions')
      .add({
        ...subscriptionData,
        status: 'active',
        startDate: new Date(),
        endDate: endDate,
        currency: subscriptionData.currency || 'USD',
        createdAt: new Date(),
        updatedAt: new Date()
      });

    const subscription = { id: subscriptionRef.id, ...subscriptionData };

    // Update merchant with subscription ID
    await firebaseConfig.getFirestore()
      .collection('merchants')
      .doc(subscriptionData.merchantId)
      .update({
        subscriptionId: subscriptionRef.id,
        updatedAt: new Date()
      });

    logger.logFirebase('create', 'subscriptions', subscriptionRef.id);
    logger.logAudit('subscription_created', req.user.userId, 'subscriptions', { 
      subscriptionId: subscriptionRef.id,
      merchantId: subscriptionData.merchantId 
    });

    res.status(201).json({
      success: true,
      message: 'Subscription created successfully',
      data: subscription
    });

  } catch (error) {
    logger.logError(error, { route: '/subscriptions' });
    res.status(500).json({
      error: 'Failed to create subscription'
    });
  }
}));

// Update subscription
router.put('/:id', subscriptionValidation, authMiddleware.requireAuth, authMiddleware.requireAdmin, asyncHandler(async (req, res) => {
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
    const subscriptionRef = firebaseConfig.getFirestore()
      .collection('subscriptions')
      .doc(id);

    const subscriptionDoc = await subscriptionRef.get();

    if (!subscriptionDoc.exists) {
      return res.status(404).json({
        error: 'Subscription not found'
      });
    }

    // Update subscription
    await subscriptionRef.update({
      ...updateData,
      updatedAt: new Date()
    });

    const updatedSubscription = { id, ...subscriptionDoc.data(), ...updateData };

    logger.logFirebase('update', 'subscriptions', id);
    logger.logAudit('subscription_updated', req.user.userId, 'subscriptions', { 
      subscriptionId: id, 
      updatedFields: Object.keys(updateData) 
    });

    res.json({
      success: true,
      message: 'Subscription updated successfully',
      data: updatedSubscription
    });

  } catch (error) {
    logger.logError(error, { route: `/subscriptions/${id}` });
    res.status(500).json({
      error: 'Failed to update subscription'
    });
  }
}));

// Cancel subscription
router.delete('/:id', authMiddleware.requireAuth, authMiddleware.requireAdmin, asyncHandler(async (req, res) => {
  const { id } = req.params;

  try {
    const subscriptionRef = firebaseConfig.getFirestore()
      .collection('subscriptions')
      .doc(id);

    const subscriptionDoc = await subscriptionRef.get();

    if (!subscriptionDoc.exists) {
      return res.status(404).json({
        error: 'Subscription not found'
      });
    }

    // Update subscription status to cancelled
    await subscriptionRef.update({
      status: 'cancelled',
      updatedAt: new Date()
    });

    logger.logFirebase('update', 'subscriptions', id);
    logger.logAudit('subscription_cancelled', req.user.userId, 'subscriptions', { subscriptionId: id });

    res.json({
      success: true,
      message: 'Subscription cancelled successfully'
    });

  } catch (error) {
    logger.logError(error, { route: `/subscriptions/${id}` });
    res.status(500).json({
      error: 'Failed to cancel subscription'
    });
  }
}));

// Renew subscription
router.post('/:id/renew', authMiddleware.requireAuth, authMiddleware.requireAdmin, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { duration, amount } = req.body;

  try {
    const subscriptionRef = firebaseConfig.getFirestore()
      .collection('subscriptions')
      .doc(id);

    const subscriptionDoc = await subscriptionRef.get();

    if (!subscriptionDoc.exists) {
      return res.status(404).json({
        error: 'Subscription not found'
      });
    }

    const subscription = subscriptionDoc.data();

    // Calculate new end date
    const currentEndDate = subscription.endDate.toDate();
    const newEndDate = new Date(currentEndDate);
    newEndDate.setMonth(newEndDate.getMonth() + (duration || 1));

    // Update subscription
    await subscriptionRef.update({
      status: 'active',
      endDate: newEndDate,
      amount: amount || subscription.amount,
      updatedAt: new Date()
    });

    logger.logFirebase('update', 'subscriptions', id);
    logger.logAudit('subscription_renewed', req.user.userId, 'subscriptions', { 
      subscriptionId: id,
      duration,
      amount 
    });

    res.json({
      success: true,
      message: 'Subscription renewed successfully',
      data: {
        endDate: newEndDate,
        amount: amount || subscription.amount
      }
    });

  } catch (error) {
    logger.logError(error, { route: `/subscriptions/${id}/renew` });
    res.status(500).json({
      error: 'Failed to renew subscription'
    });
  }
}));

// Get subscription analytics
router.get('/analytics/overview', authMiddleware.requireAuth, authMiddleware.requireAdmin, asyncHandler(async (req, res) => {
  try {
    const subscriptionsSnapshot = await firebaseConfig.getFirestore()
      .collection('subscriptions')
      .get();

    const subscriptions = subscriptionsSnapshot.docs.map(doc => doc.data());

    // Calculate analytics
    const analytics = {
      total: subscriptions.length,
      active: subscriptions.filter(s => s.status === 'active').length,
      expired: subscriptions.filter(s => s.status === 'expired').length,
      cancelled: subscriptions.filter(s => s.status === 'cancelled').length,
      plans: {
        freeTrial: subscriptions.filter(s => s.plan === 'freeTrial').length,
        basic: subscriptions.filter(s => s.plan === 'basic').length,
        premium: subscriptions.filter(s => s.plan === 'premium').length,
        enterprise: subscriptions.filter(s => s.plan === 'enterprise').length
      },
      totalRevenue: subscriptions.reduce((sum, s) => sum + (s.amount || 0), 0)
    };

    res.json({
      success: true,
      data: analytics
    });

  } catch (error) {
    logger.logError(error, { route: '/subscriptions/analytics/overview' });
    res.status(500).json({
      error: 'Failed to fetch subscription analytics'
    });
  }
}));

module.exports = router;
