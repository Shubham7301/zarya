import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { appointmentTriggers } from './appointments';
import { notificationFunctions } from './notifications';
import { utilityFunctions } from './utilities';

// Initialize Firebase Admin SDK
admin.initializeApp();

// Export appointment-related functions
export const onAppointmentCreated = appointmentTriggers.onAppointmentCreated;
export const onAppointmentUpdated = appointmentTriggers.onAppointmentUpdated;
export const onAppointmentDeleted = appointmentTriggers.onAppointmentDeleted;

// Export notification functions
export const sendEmailNotification = notificationFunctions.sendEmailNotification;
export const sendSMSNotification = notificationFunctions.sendSMSNotification;
export const sendPushNotification = notificationFunctions.sendPushNotification;
export const scheduleAppointmentReminders = notificationFunctions.scheduleAppointmentReminders;

// Export utility functions
export const generateTimeSlots = utilityFunctions.generateTimeSlots;
export const cleanupExpiredSlots = utilityFunctions.cleanupExpiredSlots;
export const getDashboardStats = utilityFunctions.getDashboardStats;

// Health check function
export const healthCheck = functions.https.onRequest((req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});
