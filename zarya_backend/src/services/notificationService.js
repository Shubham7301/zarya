const nodemailer = require('nodemailer');
const firebaseConfig = require('../config/firebase');
const logger = require('../utils/logger');

class NotificationService {
  constructor() {
    this.emailTransporter = null;
    this.initializeServices();
  }

  async initializeServices() {
    try {
      // Initialize email transporter
      this.emailTransporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: process.env.SMTP_PORT,
        secure: process.env.SMTP_SECURE === 'true',
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS
        }
      });



      logger.info('Notification services initialized');
    } catch (error) {
      logger.logError(error, { context: 'NotificationService.initializeServices' });
    }
  }

  // Email notifications
  async sendEmail(to, subject, html, text = null) {
    try {
      if (!this.emailTransporter) {
        throw new Error('Email transporter not initialized');
      }

      const mailOptions = {
        from: process.env.SMTP_FROM,
        to: to,
        subject: subject,
        html: html,
        text: text || this.stripHtml(html)
      };

      const result = await this.emailTransporter.sendMail(mailOptions);
      
      logger.logInfo('Email sent successfully', {
        to: to,
        subject: subject,
        messageId: result.messageId
      });

      return result;
    } catch (error) {
      logger.logError(error, { context: 'NotificationService.sendEmail' });
      throw error;
    }
  }

  async sendWelcomeEmail(merchant) {
    const subject = 'Welcome to Zarya Merchant Platform';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Welcome to Zarya Merchant Platform!</h2>
        <p>Dear ${merchant.ownerName},</p>
        <p>Welcome to the Zarya Merchant Platform! Your account has been successfully created.</p>
        <div style="background-color: #f5f5f5; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <h3>Account Details:</h3>
          <p><strong>Business Name:</strong> ${merchant.businessName}</p>
          <p><strong>Email:</strong> ${merchant.email}</p>
          <p><strong>Category:</strong> ${merchant.category}</p>
        </div>
        <p>You can now log in to your dashboard and start managing your appointments and services.</p>
        <p>If you have any questions, please don't hesitate to contact our support team.</p>
        <p>Best regards,<br>The Zarya Team</p>
      </div>
    `;

    return this.sendEmail(merchant.email, subject, html);
  }

  async sendSubscriptionExpiryEmail(merchant, subscription) {
    const subject = 'Subscription Expiry Notice';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #ff6b6b;">Subscription Expiry Notice</h2>
        <p>Dear ${merchant.ownerName},</p>
        <p>Your subscription for <strong>${merchant.businessName}</strong> will expire on ${new Date(subscription.expiryDate).toLocaleDateString()}.</p>
        <div style="background-color: #fff3cd; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <h3>Subscription Details:</h3>
          <p><strong>Plan:</strong> ${subscription.plan}</p>
          <p><strong>Expiry Date:</strong> ${new Date(subscription.expiryDate).toLocaleDateString()}</p>
          <p><strong>Amount:</strong> $${subscription.amount}</p>
        </div>
        <p>To continue using our services without interruption, please renew your subscription before the expiry date.</p>
        <p>If you have any questions, please contact our support team.</p>
        <p>Best regards,<br>The Zarya Team</p>
      </div>
    `;

    return this.sendEmail(merchant.email, subject, html);
  }

  async sendPaymentFailedEmail(merchant, subscription) {
    const subject = 'Payment Failed - Action Required';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #dc3545;">Payment Failed</h2>
        <p>Dear ${merchant.ownerName},</p>
        <p>We were unable to process your payment for the subscription renewal of <strong>${merchant.businessName}</strong>.</p>
        <div style="background-color: #f8d7da; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <h3>Subscription Details:</h3>
          <p><strong>Plan:</strong> ${subscription.plan}</p>
          <p><strong>Amount:</strong> $${subscription.amount}</p>
          <p><strong>Next Payment Date:</strong> ${new Date(subscription.nextPaymentDate).toLocaleDateString()}</p>
        </div>
        <p>Please update your payment method in your dashboard to avoid service interruption.</p>
        <p>If you need assistance, please contact our support team.</p>
        <p>Best regards,<br>The Zarya Team</p>
      </div>
    `;

    return this.sendEmail(merchant.email, subject, html);
  }

  async sendAppointmentReminderEmail(appointment, merchant) {
    const subject = 'Appointment Reminder';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #28a745;">Appointment Reminder</h2>
        <p>Dear ${appointment.customerName},</p>
        <p>This is a reminder for your upcoming appointment with <strong>${merchant.businessName}</strong>.</p>
        <div style="background-color: #d4edda; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <h3>Appointment Details:</h3>
          <p><strong>Date:</strong> ${new Date(appointment.date).toLocaleDateString()}</p>
          <p><strong>Time:</strong> ${appointment.time}</p>
          <p><strong>Service:</strong> ${appointment.serviceName}</p>
          <p><strong>Duration:</strong> ${appointment.duration} minutes</p>
        </div>
        <p>Please arrive 10 minutes before your scheduled time.</p>
        <p>If you need to reschedule or cancel, please contact the business directly.</p>
        <p>Best regards,<br>${merchant.businessName}</p>
      </div>
    `;

    return this.sendEmail(appointment.customerEmail, subject, html);
  }



  // Push notifications
  async sendPushNotification(userId, title, body, data = {}) {
    try {
      // Get user's FCM token from Firestore
      const userDoc = await firebaseConfig.getFirestore()
        .collection('users')
        .doc(userId)
        .get();

      if (!userDoc.exists || !userDoc.data().fcmToken) {
        logger.logInfo('No FCM token found for user', { userId });
        return null;
      }

      const fcmToken = userDoc.data().fcmToken;

      // Send push notification using Firebase Admin SDK
      const message = {
        notification: {
          title: title,
          body: body
        },
        data: data,
        token: fcmToken
      };

      const response = await firebaseConfig.getMessaging().send(message);

      // Log push notification
      await firebaseConfig.getFirestore()
        .collection('push_notifications')
        .add({
          userId: userId,
          title: title,
          body: body,
          data: data,
          fcmToken: fcmToken,
          messageId: response,
          sentAt: new Date()
        });

      logger.logInfo('Push notification sent successfully', {
        userId: userId,
        messageId: response
      });

      return response;
    } catch (error) {
      logger.logError(error, { context: 'NotificationService.sendPushNotification' });
      throw error;
    }
  }

  // In-app notifications
  async createInAppNotification(userId, title, message, type = 'info', data = {}) {
    try {
      const notification = {
        userId: userId,
        title: title,
        message: message,
        type: type,
        data: data,
        read: false,
        createdAt: new Date()
      };

      const docRef = await firebaseConfig.getFirestore()
        .collection('notifications')
        .add(notification);

      logger.logInfo('In-app notification created', {
        userId: userId,
        notificationId: docRef.id
      });

      return docRef.id;
    } catch (error) {
      logger.logError(error, { context: 'NotificationService.createInAppNotification' });
      throw error;
    }
  }

  async markNotificationAsRead(notificationId) {
    try {
      await firebaseConfig.getFirestore()
        .collection('notifications')
        .doc(notificationId)
        .update({
          read: true,
          readAt: new Date()
        });

      logger.logInfo('Notification marked as read', { notificationId });
    } catch (error) {
      logger.logError(error, { context: 'NotificationService.markNotificationAsRead' });
      throw error;
    }
  }

  // Bulk notifications
  async sendBulkEmail(recipients, subject, html, text = null) {
    const results = [];
    const errors = [];

    for (const recipient of recipients) {
      try {
        const result = await this.sendEmail(recipient.email, subject, html, text);
        results.push({ recipient, result });
      } catch (error) {
        errors.push({ recipient, error: error.message });
      }
    }

    logger.logInfo('Bulk email completed', {
      total: recipients.length,
      successful: results.length,
      failed: errors.length
    });

    return { results, errors };
  }



  // Template helpers
  stripHtml(html) {
    return html.replace(/<[^>]*>/g, '');
  }

  // Notification preferences
  async getUserNotificationPreferences(userId) {
    try {
      const userDoc = await firebaseConfig.getFirestore()
        .collection('users')
        .doc(userId)
        .get();

      if (!userDoc.exists) {
              return {
        email: true,
        push: true,
        inApp: true
      };
      }

      return userDoc.data().notificationPreferences || {
        email: true,
        push: true,
        inApp: true
      };
    } catch (error) {
      logger.logError(error, { context: 'NotificationService.getUserNotificationPreferences' });
      return {
        email: true,
        push: true,
        inApp: true
      };
    }
  }

  async updateUserNotificationPreferences(userId, preferences) {
    try {
      await firebaseConfig.getFirestore()
        .collection('users')
        .doc(userId)
        .update({
          notificationPreferences: preferences,
          updatedAt: new Date()
        });

      logger.logInfo('Notification preferences updated', { userId, preferences });
    } catch (error) {
      logger.logError(error, { context: 'NotificationService.updateUserNotificationPreferences' });
      throw error;
    }
  }
}

module.exports = new NotificationService();
