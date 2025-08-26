const express = require('express');
const firebaseConfig = require('../config/firebase');
const logger = require('../utils/logger');
const authMiddleware = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

const router = express.Router();

// Get admin dashboard data
router.get('/dashboard', authMiddleware.requireAuth, authMiddleware.requireAdmin, asyncHandler(async (req, res) => {
  try {
    // Get merchants count
    const merchantsSnapshot = await firebaseConfig.getFirestore()
      .collection('merchants')
      .get();

    // Get subscriptions count
    const subscriptionsSnapshot = await firebaseConfig.getFirestore()
      .collection('subscriptions')
      .get();

    // Get recent activities
    const auditLogsSnapshot = await firebaseConfig.getFirestore()
      .collection('audit_logs')
      .orderBy('timestamp', 'desc')
      .limit(10)
      .get();

    const merchants = merchantsSnapshot.docs.map(doc => doc.data());
    const subscriptions = subscriptionsSnapshot.docs.map(doc => doc.data());
    const auditLogs = auditLogsSnapshot.docs.map(doc => doc.data());

    const dashboardData = {
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
      revenue: {
        total: subscriptions.reduce((sum, s) => sum + (s.amount || 0), 0),
        monthly: subscriptions
          .filter(s => s.status === 'active')
          .reduce((sum, s) => sum + (s.amount || 0), 0)
      },
      recentActivity: auditLogs
    };

    res.json({
      success: true,
      data: dashboardData
    });

  } catch (error) {
    logger.logError(error, { route: '/admin/dashboard' });
    res.status(500).json({
      error: 'Failed to fetch dashboard data'
    });
  }
}));

// Get all merchants (admin view)
router.get('/merchants', authMiddleware.requireAuth, authMiddleware.requireAdmin, asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, search, category, status } = req.query;
  const offset = (page - 1) * limit;

  try {
    let query = firebaseConfig.getFirestore().collection('merchants');

    // Apply filters
    if (search) {
      query = query.where('businessName', '>=', search)
                   .where('businessName', '<=', search + '\uf8ff');
    }

    if (category) {
      query = query.where('category', '==', category);
    }

    if (status !== undefined) {
      query = query.where('isActive', '==', status === 'true');
    }

    // Get total count
    const totalSnapshot = await query.get();
    const total = totalSnapshot.size;

    // Apply pagination
    query = query.orderBy('createdAt', 'desc').limit(parseInt(limit)).offset(offset);

    const snapshot = await query.get();
    const merchants = [];

    snapshot.forEach(doc => {
      const merchant = { id: doc.id, ...doc.data() };
      delete merchant.password; // Remove password from response
      merchants.push(merchant);
    });

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
    logger.logError(error, { route: '/admin/merchants' });
    res.status(500).json({
      error: 'Failed to fetch merchants'
    });
  }
}));

// Get merchant details with subscription
router.get('/merchants/:id', authMiddleware.requireAuth, authMiddleware.requireAdmin, asyncHandler(async (req, res) => {
  const { id } = req.params;

  try {
    // Get merchant
    const merchantDoc = await firebaseConfig.getFirestore()
      .collection('merchants')
      .doc(id)
      .get();

    if (!merchantDoc.exists) {
      return res.status(404).json({
        error: 'Merchant not found'
      });
    }

    const merchant = { id: merchantDoc.id, ...merchantDoc.data() };
    delete merchant.password;

    // Get subscription if exists
    let subscription = null;
    if (merchant.subscriptionId) {
      const subscriptionDoc = await firebaseConfig.getFirestore()
        .collection('subscriptions')
        .doc(merchant.subscriptionId)
        .get();

      if (subscriptionDoc.exists) {
        subscription = { id: subscriptionDoc.id, ...subscriptionDoc.data() };
      }
    }

    res.json({
      success: true,
      data: {
        merchant,
        subscription
      }
    });

  } catch (error) {
    logger.logError(error, { route: `/admin/merchants/${id}` });
    res.status(500).json({
      error: 'Failed to fetch merchant details'
    });
  }
}));

// Update merchant (admin)
router.put('/merchants/:id', authMiddleware.requireAuth, authMiddleware.requireAdmin, asyncHandler(async (req, res) => {
  const { id } = req.params;
  const updateData = req.body;

  try {
    const merchantRef = firebaseConfig.getFirestore()
      .collection('merchants')
      .doc(id);

    const merchantDoc = await merchantRef.get();

    if (!merchantDoc.exists) {
      return res.status(404).json({
        error: 'Merchant not found'
      });
    }

    // Remove sensitive fields
    delete updateData.password;

    // Update merchant
    await merchantRef.update({
      ...updateData,
      updatedAt: new Date()
    });

    const updatedMerchant = { id, ...merchantDoc.data(), ...updateData };
    delete updatedMerchant.password;

    logger.logAudit('admin_merchant_updated', req.user.userId, 'merchants', { 
      merchantId: id, 
      updatedFields: Object.keys(updateData) 
    });

    res.json({
      success: true,
      message: 'Merchant updated successfully',
      data: updatedMerchant
    });

  } catch (error) {
    logger.logError(error, { route: `/admin/merchants/${id}` });
    res.status(500).json({
      error: 'Failed to update merchant'
    });
  }
}));

// Delete merchant (admin)
router.delete('/merchants/:id', authMiddleware.requireAuth, authMiddleware.requireAdmin, asyncHandler(async (req, res) => {
  const { id } = req.params;

  try {
    const merchantRef = firebaseConfig.getFirestore()
      .collection('merchants')
      .doc(id);

    const merchantDoc = await merchantRef.get();

    if (!merchantDoc.exists) {
      return res.status(404).json({
        error: 'Merchant not found'
      });
    }

    // Delete merchant
    await merchantRef.delete();

    // Delete associated subscription if exists
    const merchant = merchantDoc.data();
    if (merchant.subscriptionId) {
      await firebaseConfig.getFirestore()
        .collection('subscriptions')
        .doc(merchant.subscriptionId)
        .delete();
    }

    logger.logAudit('admin_merchant_deleted', req.user.userId, 'merchants', { merchantId: id });

    res.json({
      success: true,
      message: 'Merchant deleted successfully'
    });

  } catch (error) {
    logger.logError(error, { route: `/admin/merchants/${id}` });
    res.status(500).json({
      error: 'Failed to delete merchant'
    });
  }
}));

// Get audit logs
router.get('/audit-logs', authMiddleware.requireAuth, authMiddleware.requireAdmin, asyncHandler(async (req, res) => {
  const { page = 1, limit = 20, action, userId } = req.query;
  const offset = (page - 1) * limit;

  try {
    let query = firebaseConfig.getFirestore().collection('audit_logs');

    // Apply filters
    if (action) {
      query = query.where('action', '==', action);
    }

    if (userId) {
      query = query.where('userId', '==', userId);
    }

    // Get total count
    const totalSnapshot = await query.get();
    const total = totalSnapshot.size;

    // Apply pagination
    query = query.orderBy('timestamp', 'desc').limit(parseInt(limit)).offset(offset);

    const snapshot = await query.get();
    const auditLogs = [];

    snapshot.forEach(doc => {
      auditLogs.push({ id: doc.id, ...doc.data() });
    });

    res.json({
      success: true,
      data: auditLogs,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    logger.logError(error, { route: '/admin/audit-logs' });
    res.status(500).json({
      error: 'Failed to fetch audit logs'
    });
  }
}));

// Get system statistics
router.get('/statistics', authMiddleware.requireAuth, authMiddleware.requireAdmin, asyncHandler(async (req, res) => {
  try {
    // Get merchants statistics
    const merchantsSnapshot = await firebaseConfig.getFirestore()
      .collection('merchants')
      .get();

    // Get subscriptions statistics
    const subscriptionsSnapshot = await firebaseConfig.getFirestore()
      .collection('subscriptions')
      .get();

    // Get appointments statistics
    const appointmentsSnapshot = await firebaseConfig.getFirestore()
      .collection('appointments')
      .get();

    const merchants = merchantsSnapshot.docs.map(doc => doc.data());
    const subscriptions = subscriptionsSnapshot.docs.map(doc => doc.data());
    const appointments = appointmentsSnapshot.docs.map(doc => doc.data());

    const statistics = {
      merchants: {
        total: merchants.length,
        active: merchants.filter(m => m.isActive).length,
        inactive: merchants.filter(m => !m.isActive).length,
        byCategory: merchants.reduce((acc, m) => {
          acc[m.category] = (acc[m.category] || 0) + 1;
          return acc;
        }, {})
      },
      subscriptions: {
        total: subscriptions.length,
        active: subscriptions.filter(s => s.status === 'active').length,
        expired: subscriptions.filter(s => s.status === 'expired').length,
        cancelled: subscriptions.filter(s => s.status === 'cancelled').length,
        byPlan: subscriptions.reduce((acc, s) => {
          acc[s.plan] = (acc[s.plan] || 0) + 1;
          return acc;
        }, {})
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
      data: statistics
    });

  } catch (error) {
    logger.logError(error, { route: '/admin/statistics' });
    res.status(500).json({
      error: 'Failed to fetch statistics'
    });
  }
}));

module.exports = router;
