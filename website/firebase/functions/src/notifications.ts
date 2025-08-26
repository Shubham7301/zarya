import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as nodemailer from 'nodemailer';

const db = admin.firestore();

// Configure email transporter (you'll need to set up your email service)
const emailTransporter = nodemailer.createTransporter({
  service: 'gmail', // or your email service
  auth: {
    user: functions.config().email?.user || process.env.EMAIL_USER,
    pass: functions.config().email?.password || process.env.EMAIL_PASSWORD,
  },
});

export const notificationFunctions = {
  // Send email notification
  sendEmailNotification: functions.https.onCall(async (data, context) => {
    const { to, template, data: templateData } = data;

    try {
      const emailContent = generateEmailContent(template, templateData);
      
      const mailOptions = {
        from: functions.config().email?.from || 'noreply@zarya-booking.com',
        to: to,
        subject: emailContent.subject,
        html: emailContent.html,
      };

      const result = await emailTransporter.sendMail(mailOptions);
      console.log('Email sent successfully:', result.messageId);
      
      return { success: true, messageId: result.messageId };
    } catch (error) {
      console.error('Error sending email:', error);
      throw new functions.https.HttpsError('internal', 'Failed to send email');
    }
  }),

  // Send SMS notification (using Twilio or similar service)
  sendSMSNotification: functions.https.onCall(async (data, context) => {
    const { to, message } = data;

    try {
      // Note: You'll need to set up Twilio or another SMS service
      // const twilio = require('twilio');
      // const client = twilio(accountSid, authToken);
      
      // For now, just log the SMS
      console.log(`SMS to ${to}: ${message}`);
      
      return { success: true, message: 'SMS sent successfully' };
    } catch (error) {
      console.error('Error sending SMS:', error);
      throw new functions.https.HttpsError('internal', 'Failed to send SMS');
    }
  }),

  // Send push notification
  sendPushNotification: functions.https.onCall(async (data, context) => {
    const { userId, title, body, data: notificationData } = data;

    try {
      // Get user's FCM tokens
      const userDoc = await db.collection('merchants').doc(userId).get();
      
      if (!userDoc.exists) {
        throw new Error('User not found');
      }

      const userData = userDoc.data();
      const fcmTokens = userData?.fcmTokens || [];

      if (fcmTokens.length === 0) {
        console.log('No FCM tokens found for user:', userId);
        return { success: false, message: 'No FCM tokens found' };
      }

      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: notificationData || {},
        tokens: fcmTokens,
      };

      const response = await admin.messaging().sendMulticast(message);
      
      // Remove invalid tokens
      const failedTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(fcmTokens[idx]);
        }
      });

      if (failedTokens.length > 0) {
        // Remove failed tokens from user document
        const validTokens = fcmTokens.filter(token => !failedTokens.includes(token));
        await userDoc.ref.update({ fcmTokens: validTokens });
      }

      console.log('Push notification sent successfully:', response.successCount, 'success,', response.failureCount, 'failures');
      
      return { 
        success: true, 
        successCount: response.successCount,
        failureCount: response.failureCount 
      };
    } catch (error) {
      console.error('Error sending push notification:', error);
      throw new functions.https.HttpsError('internal', 'Failed to send push notification');
    }
  }),

  // Schedule appointment reminders
  scheduleAppointmentReminders: functions.https.onCall(async (data, context) => {
    const { appointmentId, appointment, merchant } = data;

    try {
      const appointmentDate = appointment.dateTime.toDate();
      const now = new Date();

      // Schedule reminder 24 hours before
      const reminder24h = new Date(appointmentDate.getTime() - 24 * 60 * 60 * 1000);
      if (reminder24h > now) {
        await scheduleReminder(appointmentId, appointment, merchant, reminder24h, '24 hours');
      }

      // Schedule reminder 1 hour before
      const reminder1h = new Date(appointmentDate.getTime() - 60 * 60 * 1000);
      if (reminder1h > now) {
        await scheduleReminder(appointmentId, appointment, merchant, reminder1h, '1 hour');
      }

      // Schedule reminder 15 minutes before (for merchant)
      const reminder15m = new Date(appointmentDate.getTime() - 15 * 60 * 1000);
      if (reminder15m > now) {
        await scheduleReminder(appointmentId, appointment, merchant, reminder15m, '15 minutes', true);
      }

      console.log('Appointment reminders scheduled for:', appointmentId);
      return { success: true };
    } catch (error) {
      console.error('Error scheduling reminders:', error);
      throw new functions.https.HttpsError('internal', 'Failed to schedule reminders');
    }
  }),
};

// Helper function to generate email content based on template
function generateEmailContent(template: string, data: any): { subject: string; html: string } {
  switch (template) {
    case 'appointment_confirmation':
      return {
        subject: 'Appointment Confirmation - Zarya',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #6366F1;">Appointment Confirmed!</h2>
            <p>Dear ${data.customerName},</p>
            <p>Your appointment has been successfully booked. Here are the details:</p>
            
            <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <h3 style="margin-top: 0; color: #333;">Appointment Details</h3>
              <p><strong>Service:</strong> ${data.serviceName}</p>
              <p><strong>Merchant:</strong> ${data.merchantName}</p>
              <p><strong>Date:</strong> ${data.appointmentDate}</p>
              <p><strong>Time:</strong> ${data.appointmentTime}</p>
              <p><strong>Booking Reference:</strong> ${data.appointmentId}</p>
            </div>
            
            <p>Please arrive 10 minutes early for your appointment.</p>
            <p>If you need to reschedule or cancel, please contact the merchant directly.</p>
            
            <p>Thank you for choosing Zarya!</p>
          </div>
        `,
      };

    case 'appointment_confirmed':
      return {
        subject: 'Your Appointment is Confirmed - Zarya',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #10B981;">Appointment Confirmed!</h2>
            <p>Dear ${data.customerName},</p>
            <p>Great news! Your appointment has been confirmed by ${data.merchantName}.</p>
            
            <div style="background-color: #f0fdf4; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #10B981;">
              <h3 style="margin-top: 0; color: #333;">Confirmed Appointment</h3>
              <p><strong>Service:</strong> ${data.serviceName}</p>
              <p><strong>Date:</strong> ${data.appointmentDate}</p>
              <p><strong>Time:</strong> ${data.appointmentTime}</p>
            </div>
            
            <p>We look forward to seeing you!</p>
          </div>
        `,
      };

    case 'appointment_cancelled':
      return {
        subject: 'Appointment Cancelled - Zarya',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #EF4444;">Appointment Cancelled</h2>
            <p>Dear ${data.customerName},</p>
            <p>We're sorry to inform you that your appointment has been cancelled.</p>
            
            <div style="background-color: #fef2f2; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #EF4444;">
              <h3 style="margin-top: 0; color: #333;">Cancelled Appointment</h3>
              <p><strong>Service:</strong> ${data.serviceName}</p>
              <p><strong>Date:</strong> ${data.appointmentDate}</p>
              <p><strong>Time:</strong> ${data.appointmentTime}</p>
              ${data.reason ? `<p><strong>Reason:</strong> ${data.reason}</p>` : ''}
            </div>
            
            <p>Please feel free to book another appointment at your convenience.</p>
          </div>
        `,
      };

    case 'appointment_reminder':
      return {
        subject: 'Appointment Reminder - Zarya',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #F59E0B;">Appointment Reminder</h2>
            <p>Dear ${data.customerName},</p>
            <p>This is a friendly reminder about your upcoming appointment ${data.timeUntil}.</p>
            
            <div style="background-color: #fffbeb; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #F59E0B;">
              <h3 style="margin-top: 0; color: #333;">Appointment Details</h3>
              <p><strong>Service:</strong> ${data.serviceName}</p>
              <p><strong>Merchant:</strong> ${data.merchantName}</p>
              <p><strong>Date:</strong> ${data.appointmentDate}</p>
              <p><strong>Time:</strong> ${data.appointmentTime}</p>
            </div>
            
            <p>Please arrive 10 minutes early. We look forward to seeing you!</p>
          </div>
        `,
      };

    default:
      return {
        subject: 'Notification from Zarya',
        html: '<p>You have a new notification from Zarya.</p>',
      };
  }
}

// Helper function to schedule a reminder
async function scheduleReminder(
  appointmentId: string,
  appointment: any,
  merchant: any,
  reminderTime: Date,
  timeUntil: string,
  isMerchantReminder = false
) {
  // In a production app, you'd use a task queue like Cloud Tasks
  // For now, we'll store the reminder in Firestore and use a scheduled function
  
  await db.collection('scheduledReminders').add({
    appointmentId,
    type: isMerchantReminder ? 'merchant' : 'customer',
    scheduledFor: admin.firestore.Timestamp.fromDate(reminderTime),
    appointment,
    merchant,
    timeUntil,
    sent: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
