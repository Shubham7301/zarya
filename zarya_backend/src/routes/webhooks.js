const express = require('express');
const firebaseConfig = require('../config/firebase');
const cloudinaryConfig = require('../config/cloudinary');
const logger = require('../utils/logger');
const { asyncHandler } = require('../middleware/errorHandler');

const router = express.Router();

// Cloudinary webhook handler
router.post('/cloudinary', asyncHandler(async (req, res) => {
  try {
    const { notification_type, public_id, resource_type, secure_url } = req.body;

    logger.info('Cloudinary webhook received', {
      notification_type,
      public_id,
      resource_type
    });

    // Handle different notification types
    switch (notification_type) {
      case 'upload':
        await handleCloudinaryUpload(public_id, resource_type, secure_url);
        break;
      case 'delete':
        await handleCloudinaryDelete(public_id, resource_type);
        break;
      case 'moderation.approved':
        await handleModerationApproved(public_id, resource_type);
        break;
      case 'moderation.rejected':
        await handleModerationRejected(public_id, resource_type);
        break;
      default:
        logger.info('Unhandled Cloudinary notification type', { notification_type });
    }

    res.status(200).json({ success: true });

  } catch (error) {
    logger.logError(error, { route: '/webhooks/cloudinary' });
    res.status(500).json({ error: 'Webhook processing failed' });
  }
}));

// Stripe webhook handler
router.post('/stripe', asyncHandler(async (req, res) => {
  try {
    const sig = req.headers['stripe-signature'];
    const event = req.body;

    logger.info('Stripe webhook received', {
      type: event.type,
      id: event.id
    });

    // Handle different event types
    switch (event.type) {
      case 'payment_intent.succeeded':
        await handlePaymentSucceeded(event.data.object);
        break;
      case 'payment_intent.payment_failed':
        await handlePaymentFailed(event.data.object);
        break;
      case 'customer.subscription.created':
        await handleSubscriptionCreated(event.data.object);
        break;
      case 'customer.subscription.updated':
        await handleSubscriptionUpdated(event.data.object);
        break;
      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object);
        break;
      default:
        logger.info('Unhandled Stripe event type', { type: event.type });
    }

    res.status(200).json({ received: true });

  } catch (error) {
    logger.logError(error, { route: '/webhooks/stripe' });
    res.status(400).json({ error: 'Webhook processing failed' });
  }
}));



// Real-time sync webhook
router.post('/realtime-sync', asyncHandler(async (req, res) => {
  try {
    const { type, data, merchantId } = req.body;

    logger.info('Real-time sync webhook received', { type, merchantId });

    // Handle different sync types
    switch (type) {
      case 'merchant_updated':
        await handleMerchantSync(data);
        break;
      case 'subscription_updated':
        await handleSubscriptionSync(data);
        break;
      case 'appointment_updated':
        await handleAppointmentSync(data);
        break;
      default:
        logger.info('Unhandled sync type', { type });
    }

    res.status(200).json({ success: true });

  } catch (error) {
    logger.logError(error, { route: '/webhooks/realtime-sync' });
    res.status(500).json({ error: 'Sync processing failed' });
  }
}));

// Helper functions for Cloudinary webhooks
async function handleCloudinaryUpload(publicId, resourceType, secureUrl) {
  try {
    // Update merchant profile if it's a profile image
    if (resourceType === 'image' && publicId.includes('merchant_profiles')) {
      const merchantId = extractMerchantIdFromPublicId(publicId);
      if (merchantId) {
        await firebaseConfig.getFirestore()
          .collection('merchants')
          .doc(merchantId)
          .update({
            profileImage: secureUrl,
            updatedAt: new Date()
          });
      }
    }

    // Update service image if it's a service image
    if (resourceType === 'image' && publicId.includes('service_images')) {
      const serviceId = extractServiceIdFromPublicId(publicId);
      if (serviceId) {
        await firebaseConfig.getFirestore()
          .collection('services')
          .doc(serviceId)
          .update({
            imageUrl: secureUrl,
            updatedAt: new Date()
          });
      }
    }

    logger.info('Cloudinary upload processed', { publicId, resourceType });
  } catch (error) {
    logger.logError(error, { context: 'handleCloudinaryUpload' });
  }
}

async function handleCloudinaryDelete(publicId, resourceType) {
  try {
    // Remove image references from database
    if (resourceType === 'image') {
      // Handle merchant profile image deletion
      if (publicId.includes('merchant_profiles')) {
        const merchantId = extractMerchantIdFromPublicId(publicId);
        if (merchantId) {
          await firebaseConfig.getFirestore()
            .collection('merchants')
            .doc(merchantId)
            .update({
              profileImage: null,
              updatedAt: new Date()
            });
        }
      }

      // Handle service image deletion
      if (publicId.includes('service_images')) {
        const serviceId = extractServiceIdFromPublicId(publicId);
        if (serviceId) {
          await firebaseConfig.getFirestore()
            .collection('services')
            .doc(serviceId)
            .update({
              imageUrl: null,
              updatedAt: new Date()
            });
        }
      }
    }

    logger.info('Cloudinary delete processed', { publicId, resourceType });
  } catch (error) {
    logger.logError(error, { context: 'handleCloudinaryDelete' });
  }
}

async function handleModerationApproved(publicId, resourceType) {
  try {
    // Update moderation status in database
    await firebaseConfig.getFirestore()
      .collection('uploads')
      .doc(publicId)
      .update({
        moderationStatus: 'approved',
        moderatedAt: new Date()
      });

    logger.info('Moderation approved processed', { publicId, resourceType });
  } catch (error) {
    logger.logError(error, { context: 'handleModerationApproved' });
  }
}

async function handleModerationRejected(publicId, resourceType) {
  try {
    // Update moderation status and delete resource
    await firebaseConfig.getFirestore()
      .collection('uploads')
      .doc(publicId)
      .update({
        moderationStatus: 'rejected',
        moderatedAt: new Date()
      });

    // Delete the rejected resource
    await cloudinaryConfig.deleteResource(publicId, resourceType);

    logger.info('Moderation rejected processed', { publicId, resourceType });
  } catch (error) {
    logger.logError(error, { context: 'handleModerationRejected' });
  }
}

// Helper functions for Stripe webhooks
async function handlePaymentSucceeded(paymentIntent) {
  try {
    const { customer, amount, metadata } = paymentIntent;
    
    // Update subscription status
    if (metadata.subscriptionId) {
      await firebaseConfig.getFirestore()
        .collection('subscriptions')
        .doc(metadata.subscriptionId)
        .update({
          status: 'active',
          lastPaymentDate: new Date(),
          nextPaymentDate: calculateNextPaymentDate(metadata.plan)
        });
    }

    logger.info('Payment succeeded processed', { customer, amount });
  } catch (error) {
    logger.logError(error, { context: 'handlePaymentSucceeded' });
  }
}

async function handlePaymentFailed(paymentIntent) {
  try {
    const { customer, metadata } = paymentIntent;
    
    // Update subscription status
    if (metadata.subscriptionId) {
      await firebaseConfig.getFirestore()
        .collection('subscriptions')
        .doc(metadata.subscriptionId)
        .update({
          status: 'payment_failed',
          lastPaymentAttempt: new Date()
        });
    }

    logger.info('Payment failed processed', { customer });
  } catch (error) {
    logger.logError(error, { context: 'handlePaymentFailed' });
  }
}

async function handleSubscriptionCreated(subscription) {
  try {
    const { id, customer, metadata } = subscription;
    
    // Create subscription record
    await firebaseConfig.getFirestore()
      .collection('subscriptions')
      .doc(id)
      .set({
        stripeSubscriptionId: id,
        merchantId: metadata.merchantId,
        plan: metadata.plan,
        status: subscription.status,
        currentPeriodStart: new Date(subscription.current_period_start * 1000),
        currentPeriodEnd: new Date(subscription.current_period_end * 1000),
        amount: subscription.items.data[0].price.unit_amount / 100,
        createdAt: new Date()
      });

    logger.info('Subscription created processed', { id, customer });
  } catch (error) {
    logger.logError(error, { context: 'handleSubscriptionCreated' });
  }
}

async function handleSubscriptionUpdated(subscription) {
  try {
    const { id, status } = subscription;
    
    // Update subscription status
    await firebaseConfig.getFirestore()
      .collection('subscriptions')
      .doc(id)
      .update({
        status: status,
        updatedAt: new Date()
      });

    logger.info('Subscription updated processed', { id, status });
  } catch (error) {
    logger.logError(error, { context: 'handleSubscriptionUpdated' });
  }
}

async function handleSubscriptionDeleted(subscription) {
  try {
    const { id } = subscription;
    
    // Update subscription status
    await firebaseConfig.getFirestore()
      .collection('subscriptions')
      .doc(id)
      .update({
        status: 'cancelled',
        cancelledAt: new Date()
      });

    logger.info('Subscription deleted processed', { id });
  } catch (error) {
    logger.logError(error, { context: 'handleSubscriptionDeleted' });
  }
}



// Helper functions for real-time sync
async function handleMerchantSync(data) {
  try {
    const { merchantId, updates } = data;
    
    await firebaseConfig.getFirestore()
      .collection('merchants')
      .doc(merchantId)
      .update({
        ...updates,
        syncedAt: new Date()
      });

    logger.info('Merchant sync processed', { merchantId });
  } catch (error) {
    logger.logError(error, { context: 'handleMerchantSync' });
  }
}

async function handleSubscriptionSync(data) {
  try {
    const { subscriptionId, updates } = data;
    
    await firebaseConfig.getFirestore()
      .collection('subscriptions')
      .doc(subscriptionId)
      .update({
        ...updates,
        syncedAt: new Date()
      });

    logger.info('Subscription sync processed', { subscriptionId });
  } catch (error) {
    logger.logError(error, { context: 'handleSubscriptionSync' });
  }
}

async function handleAppointmentSync(data) {
  try {
    const { appointmentId, updates } = data;
    
    await firebaseConfig.getFirestore()
      .collection('appointments')
      .doc(appointmentId)
      .update({
        ...updates,
        syncedAt: new Date()
      });

    logger.info('Appointment sync processed', { appointmentId });
  } catch (error) {
    logger.logError(error, { context: 'handleAppointmentSync' });
  }
}

// Utility functions
function extractMerchantIdFromPublicId(publicId) {
  const match = publicId.match(/merchant_profiles\/([^\/]+)/);
  return match ? match[1] : null;
}

function extractServiceIdFromPublicId(publicId) {
  const match = publicId.match(/service_images\/([^\/]+)/);
  return match ? match[1] : null;
}

function calculateNextPaymentDate(plan) {
  const now = new Date();
  switch (plan) {
    case 'monthly':
      return new Date(now.setMonth(now.getMonth() + 1));
    case 'quarterly':
      return new Date(now.setMonth(now.getMonth() + 3));
    case 'yearly':
      return new Date(now.setFullYear(now.getFullYear() + 1));
    default:
      return new Date(now.setMonth(now.getMonth() + 1));
  }
}

module.exports = router;
