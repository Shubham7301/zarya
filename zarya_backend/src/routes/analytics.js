const express = require('express');
const firebaseConfig = require('../config/firebase');
const logger = require('../utils/logger');
const authMiddleware = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

const router = express.Router();

// Get overview analytics
router.get('/overview', authMiddleware.requireAuth, asyncHandler(async (req, res) => {
  try {
    const { period = '30d' } = req.query;

    // Get merchants count
    const merchantsSnapshot = await firebaseConfig.getFirestore()
      .collection('merchants')
      .get();

    // Get subscriptions count
    const subscriptionsSnapshot = await firebaseConfig.getFirestore()
      .collection('subscriptions')
      .get();

    // Get appointments count
    const appointmentsSnapshot = await firebaseConfig.getFirestore()
      .collection('appointments')
      .get();

    const merchants = merchantsSnapshot.docs.map(doc => doc.data());
    const subscriptions = subscriptionsSnapshot.docs.map(doc => doc.data());
    const appointments = appointmentsSnapshot.docs.map(doc => doc.data());

    const overview = {
      merchants: {
        total: merchants.length,
        active: merchants.filter(m => m.isActive).length,
        inactive: merchants.filter(m => !m.isActive).length
      },
      subscriptions: {
        total: subscriptions.length,
        active: subscriptions.filter(s => s.status === 'active').length,
        expired: subscriptions.filter(s => s.status === 'expired').length,
        cancelled: subscriptions.filter(s => s.status === 'cancelled').length
      },
      appointments: {
        total: appointments.length,
        completed: appointments.filter(a => a.status === 'completed').length,
        pending: appointments.filter(a => a.status === 'pending').length,
        cancelled: appointments.filter(a => a.status === 'cancelled').length
      },
      revenue: {
        total: subscriptions.reduce((sum, s) => sum + (s.amount || 0), 0),
        monthly: subscriptions
          .filter(s => s.status === 'active')
          .reduce((sum, s) => sum + (s.amount || 0), 0)
      }
    };

    res.json({
      success: true,
      data: overview
    });

  } catch (error) {
    logger.logError(error, { route: '/analytics/overview' });
    res.status(500).json({
      error: 'Failed to fetch overview analytics'
    });
  }
}));

// Get merchant analytics
router.get('/merchants', authMiddleware.requireAuth, asyncHandler(async (req, res) => {
  try {
    const merchantsSnapshot = await firebaseConfig.getFirestore()
      .collection('merchants')
      .get();

    const merchants = merchantsSnapshot.docs.map(doc => doc.data());

    const analytics = {
      total: merchants.length,
      active: merchants.filter(m => m.isActive).length,
      inactive: merchants.filter(m => !m.isActive).length,
      byCategory: merchants.reduce((acc, m) => {
        acc[m.category] = (acc[m.category] || 0) + 1;
        return acc;
      }, {}),
      recentRegistrations: merchants
        .filter(m => {
          const createdAt = m.createdAt?.toDate?.() || new Date(m.createdAt);
          const thirtyDaysAgo = new Date();
          thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
          return createdAt >= thirtyDaysAgo;
        })
        .length
    };

    res.json({
      success: true,
      data: analytics
    });

  } catch (error) {
    logger.logError(error, { route: '/analytics/merchants' });
    res.status(500).json({
      error: 'Failed to fetch merchant analytics'
    });
  }
}));

// Get revenue analytics
router.get('/revenue', authMiddleware.requireAuth, asyncHandler(async (req, res) => {
  try {
    const subscriptionsSnapshot = await firebaseConfig.getFirestore()
      .collection('subscriptions')
      .get();

    const subscriptions = subscriptionsSnapshot.docs.map(doc => doc.data());

    const analytics = {
      total: subscriptions.reduce((sum, s) => sum + (s.amount || 0), 0),
      monthly: subscriptions
        .filter(s => s.status === 'active')
        .reduce((sum, s) => sum + (s.amount || 0), 0),
      byPlan: subscriptions.reduce((acc, s) => {
        acc[s.plan] = (acc[s.plan] || 0) + (s.amount || 0);
        return acc;
      }, {}),
      byStatus: subscriptions.reduce((acc, s) => {
        acc[s.status] = (acc[s.status] || 0) + (s.amount || 0);
        return acc;
      }, {})
    };

    res.json({
      success: true,
      data: analytics
    });

  } catch (error) {
    logger.logError(error, { route: '/analytics/revenue' });
    res.status(500).json({
      error: 'Failed to fetch revenue analytics'
    });
  }
}));

// Get subscription analytics
router.get('/subscriptions', authMiddleware.requireAuth, asyncHandler(async (req, res) => {
  try {
    const subscriptionsSnapshot = await firebaseConfig.getFirestore()
      .collection('subscriptions')
      .get();

    const subscriptions = subscriptionsSnapshot.docs.map(doc => doc.data());

    const analytics = {
      total: subscriptions.length,
      active: subscriptions.filter(s => s.status === 'active').length,
      expired: subscriptions.filter(s => s.status === 'expired').length,
      cancelled: subscriptions.filter(s => s.status === 'cancelled').length,
      byPlan: subscriptions.reduce((acc, s) => {
        acc[s.plan] = (acc[s.plan] || 0) + 1;
        return acc;
      }, {}),
      averageAmount: subscriptions.length > 0 
        ? subscriptions.reduce((sum, s) => sum + (s.amount || 0), 0) / subscriptions.length 
        : 0
    };

    res.json({
      success: true,
      data: analytics
    });

  } catch (error) {
    logger.logError(error, { route: '/analytics/subscriptions' });
    res.status(500).json({
      error: 'Failed to fetch subscription analytics'
    });
  }
}));

module.exports = router;
