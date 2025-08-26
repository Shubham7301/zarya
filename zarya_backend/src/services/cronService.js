const cron = require('node-cron');
const firebaseConfig = require('../config/firebase');
const notificationService = require('./notificationService');
const logger = require('../utils/logger');

class CronService {
  constructor() {
    this.jobs = new Map();
    this.initializeJobs();
  }

  initializeJobs() {
    try {
      // Daily subscription expiry check (runs at 9 AM daily)
      this.scheduleJob('subscription-expiry-check', '0 9 * * *', () => {
        this.checkSubscriptionExpiry();
      });

      // Appointment reminders (runs every hour)
      this.scheduleJob('appointment-reminders', '0 * * * *', () => {
        this.sendAppointmentReminders();
      });

      // Weekly analytics report (runs every Monday at 8 AM)
      this.scheduleJob('weekly-analytics', '0 8 * * 1', () => {
        this.generateWeeklyAnalytics();
      });

      // Daily backup (runs at 2 AM daily)
      this.scheduleJob('daily-backup', '0 2 * * *', () => {
        this.createDailyBackup();
      });

      // Monthly subscription renewal reminders (runs on 1st of every month at 10 AM)
      this.scheduleJob('monthly-renewal-reminders', '0 10 1 * *', () => {
        this.sendMonthlyRenewalReminders();
      });

      // Clean up old notifications (runs daily at 3 AM)
      this.scheduleJob('cleanup-notifications', '0 3 * * *', () => {
        this.cleanupOldNotifications();
      });

      // Health check (runs every 30 minutes)
      this.scheduleJob('health-check', '*/30 * * * *', () => {
        this.performHealthCheck();
      });

      logger.info('Cron jobs initialized successfully');
    } catch (error) {
      logger.logError(error, { context: 'CronService.initializeJobs' });
    }
  }

  scheduleJob(name, schedule, task) {
    try {
      const job = cron.schedule(schedule, async () => {
        try {
          logger.info(`Starting cron job: ${name}`);
          await task();
          logger.info(`Completed cron job: ${name}`);
        } catch (error) {
          logger.logError(error, { context: `CronService.${name}` });
        }
      }, {
        scheduled: true,
        timezone: process.env.TZ || 'UTC'
      });

      this.jobs.set(name, job);
      logger.info(`Scheduled cron job: ${name} with schedule: ${schedule}`);
    } catch (error) {
      logger.logError(error, { context: `CronService.scheduleJob.${name}` });
    }
  }

  async checkSubscriptionExpiry() {
    try {
      const now = new Date();
      const thirtyDaysFromNow = new Date(now.getTime() + (30 * 24 * 60 * 60 * 1000));

      // Get subscriptions expiring in the next 30 days
      const subscriptionsSnapshot = await firebaseConfig.getFirestore()
        .collection('subscriptions')
        .where('status', '==', 'active')
        .where('expiryDate', '<=', thirtyDaysFromNow)
        .get();

      const expiringSubscriptions = subscriptionsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      logger.logInfo(`Found ${expiringSubscriptions.length} subscriptions expiring soon`);

      for (const subscription of expiringSubscriptions) {
        try {
          // Get merchant details
          const merchantDoc = await firebaseConfig.getFirestore()
            .collection('merchants')
            .doc(subscription.merchantId)
            .get();

          if (!merchantDoc.exists) {
            logger.logError(`Merchant not found for subscription: ${subscription.id}`);
            continue;
          }

          const merchant = merchantDoc.data();

          // Calculate days until expiry
          const daysUntilExpiry = Math.ceil((subscription.expiryDate.toDate() - now) / (1000 * 60 * 60 * 24));

          // Send notifications based on days until expiry
          if (daysUntilExpiry <= 7) {
            // Send daily reminder for last week
            await notificationService.sendSubscriptionExpiryEmail(merchant, subscription);
          } else if (daysUntilExpiry <= 14) {
            // Send reminder every 3 days
            if (daysUntilExpiry % 3 === 0) {
              await notificationService.sendSubscriptionExpiryEmail(merchant, subscription);
            }
          } else {
            // Send weekly reminder
            if (daysUntilExpiry % 7 === 0) {
              await notificationService.sendSubscriptionExpiryEmail(merchant, subscription);
            }
          }

          // Create in-app notification
          await notificationService.createInAppNotification(
            subscription.merchantId,
            'Subscription Expiry Notice',
            `Your subscription expires in ${daysUntilExpiry} days. Please renew to avoid service interruption.`,
            'warning',
            { subscriptionId: subscription.id, daysUntilExpiry }
          );

        } catch (error) {
          logger.logError(error, { 
            context: 'checkSubscriptionExpiry',
            subscriptionId: subscription.id 
          });
        }
      }

      // Handle expired subscriptions
      const expiredSubscriptionsSnapshot = await firebaseConfig.getFirestore()
        .collection('subscriptions')
        .where('status', '==', 'active')
        .where('expiryDate', '<', now)
        .get();

      const expiredSubscriptions = expiredSubscriptionsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      for (const subscription of expiredSubscriptions) {
        try {
          // Update subscription status to expired
          await firebaseConfig.getFirestore()
            .collection('subscriptions')
            .doc(subscription.id)
            .update({
              status: 'expired',
              expiredAt: now
            });

          // Deactivate merchant
          await firebaseConfig.getFirestore()
            .collection('merchants')
            .doc(subscription.merchantId)
            .update({
              isActive: false,
              deactivatedAt: now
            });

          // Send expiry notification
          const merchantDoc = await firebaseConfig.getFirestore()
            .collection('merchants')
            .doc(subscription.merchantId)
            .get();

          if (merchantDoc.exists) {
            const merchant = merchantDoc.data();
            await notificationService.sendSubscriptionExpiryEmail(merchant, subscription);
          }

          logger.logInfo(`Subscription expired and merchant deactivated: ${subscription.id}`);
        } catch (error) {
          logger.logError(error, { 
            context: 'checkSubscriptionExpiry.expired',
            subscriptionId: subscription.id 
          });
        }
      }

    } catch (error) {
      logger.logError(error, { context: 'checkSubscriptionExpiry' });
    }
  }

  async sendAppointmentReminders() {
    try {
      const now = new Date();
      const tomorrow = new Date(now.getTime() + (24 * 60 * 60 * 1000));

      // Get appointments for tomorrow
      const appointmentsSnapshot = await firebaseConfig.getFirestore()
        .collection('appointments')
        .where('status', '==', 'confirmed')
        .where('date', '>=', now)
        .where('date', '<', tomorrow)
        .get();

      const appointments = appointmentsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      logger.logInfo(`Found ${appointments.length} appointments for tomorrow`);

      for (const appointment of appointments) {
        try {
          // Get merchant details
          const merchantDoc = await firebaseConfig.getFirestore()
            .collection('merchants')
            .doc(appointment.merchantId)
            .get();

          if (!merchantDoc.exists) {
            logger.logError(`Merchant not found for appointment: ${appointment.id}`);
            continue;
          }

          const merchant = merchantDoc.data();

          // Send reminder 24 hours before appointment
          const appointmentTime = appointment.date.toDate();
          const hoursUntilAppointment = (appointmentTime - now) / (1000 * 60 * 60);

          if (hoursUntilAppointment <= 24 && hoursUntilAppointment > 23) {
            await notificationService.sendAppointmentReminderEmail(appointment, merchant);

            // Create in-app notification for merchant
            await notificationService.createInAppNotification(
              appointment.merchantId,
              'Appointment Reminder',
              `Appointment with ${appointment.customerName} tomorrow at ${appointment.time}`,
              'info',
              { appointmentId: appointment.id }
            );
          }

        } catch (error) {
          logger.logError(error, { 
            context: 'sendAppointmentReminders',
            appointmentId: appointment.id 
          });
        }
      }

    } catch (error) {
      logger.logError(error, { context: 'sendAppointmentReminders' });
    }
  }

  async generateWeeklyAnalytics() {
    try {
      const now = new Date();
      const weekAgo = new Date(now.getTime() - (7 * 24 * 60 * 60 * 1000));

      // Get weekly data
      const merchantsSnapshot = await firebaseConfig.getFirestore()
        .collection('merchants')
        .where('createdAt', '>=', weekAgo)
        .get();

      const subscriptionsSnapshot = await firebaseConfig.getFirestore()
        .collection('subscriptions')
        .where('createdAt', '>=', weekAgo)
        .get();

      const appointmentsSnapshot = await firebaseConfig.getFirestore()
        .collection('appointments')
        .where('createdAt', '>=', weekAgo)
        .get();

      const analytics = {
        period: 'weekly',
        startDate: weekAgo,
        endDate: now,
        newMerchants: merchantsSnapshot.size,
        newSubscriptions: subscriptionsSnapshot.size,
        newAppointments: appointmentsSnapshot.size,
        revenue: subscriptionsSnapshot.docs.reduce((sum, doc) => {
          const data = doc.data();
          return sum + (data.amount || 0);
        }, 0)
      };

      // Store analytics report
      await firebaseConfig.getFirestore()
        .collection('analytics_reports')
        .add({
          ...analytics,
          createdAt: now
        });

      logger.logInfo('Weekly analytics report generated', analytics);

      // Send report to admin
      const adminUsersSnapshot = await firebaseConfig.getFirestore()
        .collection('users')
        .where('role', '==', 'admin')
        .get();

      for (const adminDoc of adminUsersSnapshot.docs) {
        const admin = adminDoc.data();
        await notificationService.createInAppNotification(
          adminDoc.id,
          'Weekly Analytics Report',
          `Weekly report: ${analytics.newMerchants} new merchants, ${analytics.newSubscriptions} new subscriptions, $${analytics.revenue} revenue`,
          'info',
          { reportId: analytics.id }
        );
      }

    } catch (error) {
      logger.logError(error, { context: 'generateWeeklyAnalytics' });
    }
  }

  async createDailyBackup() {
    try {
      const now = new Date();
      const backupData = {
        timestamp: now,
        collections: {}
      };

      // Backup merchants
      const merchantsSnapshot = await firebaseConfig.getFirestore()
        .collection('merchants')
        .get();

      backupData.collections.merchants = merchantsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      // Backup subscriptions
      const subscriptionsSnapshot = await firebaseConfig.getFirestore()
        .collection('subscriptions')
        .get();

      backupData.collections.subscriptions = subscriptionsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      // Store backup
      await firebaseConfig.getFirestore()
        .collection('backups')
        .add(backupData);

      logger.logInfo('Daily backup created', {
        merchants: backupData.collections.merchants.length,
        subscriptions: backupData.collections.subscriptions.length
      });

    } catch (error) {
      logger.logError(error, { context: 'createDailyBackup' });
    }
  }

  async sendMonthlyRenewalReminders() {
    try {
      const now = new Date();
      const nextMonth = new Date(now.getTime() + (30 * 24 * 60 * 60 * 1000));

      // Get subscriptions expiring next month
      const subscriptionsSnapshot = await firebaseConfig.getFirestore()
        .collection('subscriptions')
        .where('status', '==', 'active')
        .where('expiryDate', '>=', now)
        .where('expiryDate', '<=', nextMonth)
        .get();

      const expiringSubscriptions = subscriptionsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      logger.logInfo(`Found ${expiringSubscriptions.length} subscriptions expiring next month`);

      for (const subscription of expiringSubscriptions) {
        try {
          const merchantDoc = await firebaseConfig.getFirestore()
            .collection('merchants')
            .doc(subscription.merchantId)
            .get();

          if (merchantDoc.exists) {
            const merchant = merchantDoc.data();
            await notificationService.sendSubscriptionExpiryEmail(merchant, subscription);
          }
        } catch (error) {
          logger.logError(error, { 
            context: 'sendMonthlyRenewalReminders',
            subscriptionId: subscription.id 
          });
        }
      }

    } catch (error) {
      logger.logError(error, { context: 'sendMonthlyRenewalReminders' });
    }
  }

  async cleanupOldNotifications() {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      // Delete old read notifications
      const oldNotificationsSnapshot = await firebaseConfig.getFirestore()
        .collection('notifications')
        .where('read', '==', true)
        .where('createdAt', '<', thirtyDaysAgo)
        .get();

      const batch = firebaseConfig.getFirestore().batch();
      oldNotificationsSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      await batch.commit();

      logger.logInfo(`Cleaned up ${oldNotificationsSnapshot.size} old notifications`);

      // Clean up old SMS messages
      const oldSmsSnapshot = await firebaseConfig.getFirestore()
        .collection('sms_messages')
        .where('createdAt', '<', thirtyDaysAgo)
        .get();

      const smsBatch = firebaseConfig.getFirestore().batch();
      oldSmsSnapshot.docs.forEach(doc => {
        smsBatch.delete(doc.ref);
      });

      await smsBatch.commit();

      logger.logInfo(`Cleaned up ${oldSmsSnapshot.size} old SMS messages`);

    } catch (error) {
      logger.logError(error, { context: 'cleanupOldNotifications' });
    }
  }

  async performHealthCheck() {
    try {
      const healthStatus = {
        timestamp: new Date(),
        services: {}
      };

      // Check Firebase connection
      try {
        await firebaseConfig.getFirestore().collection('health_check').doc('test').get();
        healthStatus.services.firebase = 'healthy';
      } catch (error) {
        healthStatus.services.firebase = 'unhealthy';
        logger.logError(error, { context: 'healthCheck.firebase' });
      }

      // Check notification services
      try {
        if (notificationService.emailTransporter) {
          healthStatus.services.email = 'healthy';
        } else {
          healthStatus.services.email = 'unhealthy';
        }
      } catch (error) {
        healthStatus.services.email = 'unhealthy';
      }

      try {
        if (notificationService.twilioClient) {
          healthStatus.services.sms = 'healthy';
        } else {
          healthStatus.services.sms = 'unhealthy';
        }
      } catch (error) {
        healthStatus.services.sms = 'unhealthy';
      }

      // Store health check result
      await firebaseConfig.getFirestore()
        .collection('health_checks')
        .add(healthStatus);

      // Log if any service is unhealthy
      const unhealthyServices = Object.entries(healthStatus.services)
        .filter(([service, status]) => status === 'unhealthy')
        .map(([service]) => service);

      if (unhealthyServices.length > 0) {
        logger.logError('Health check failed', { unhealthyServices });
      } else {
        logger.logInfo('Health check passed', healthStatus);
      }

    } catch (error) {
      logger.logError(error, { context: 'performHealthCheck' });
    }
  }

  // Manual job execution
  async executeJob(jobName) {
    try {
      logger.logInfo(`Manually executing job: ${jobName}`);
      
      switch (jobName) {
        case 'subscription-expiry-check':
          await this.checkSubscriptionExpiry();
          break;
        case 'appointment-reminders':
          await this.sendAppointmentReminders();
          break;
        case 'weekly-analytics':
          await this.generateWeeklyAnalytics();
          break;
        case 'daily-backup':
          await this.createDailyBackup();
          break;
        case 'monthly-renewal-reminders':
          await this.sendMonthlyRenewalReminders();
          break;
        case 'cleanup-notifications':
          await this.cleanupOldNotifications();
          break;
        case 'health-check':
          await this.performHealthCheck();
          break;
        default:
          throw new Error(`Unknown job: ${jobName}`);
      }

      logger.logInfo(`Manually executed job completed: ${jobName}`);
    } catch (error) {
      logger.logError(error, { context: `executeJob.${jobName}` });
      throw error;
    }
  }

  // Get job status
  getJobStatus() {
    const status = {};
    for (const [name, job] of this.jobs) {
      status[name] = {
        running: job.running,
        nextDate: job.nextDate()
      };
    }
    return status;
  }

  // Stop all jobs
  stopAllJobs() {
    for (const [name, job] of this.jobs) {
      job.stop();
      logger.info(`Stopped cron job: ${name}`);
    }
  }
}

module.exports = new CronService();
