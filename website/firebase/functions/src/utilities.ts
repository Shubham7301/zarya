import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const utilityFunctions = {
  // Generate time slots for a merchant
  generateTimeSlots: functions.https.onCall(async (data, context) => {
    const { merchantId, date, startTime, endTime, slotDuration = 30 } = data;

    // Verify merchant authentication
    if (!context.auth || context.auth.uid !== merchantId) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    try {
      const targetDate = new Date(date);
      const normalizedDate = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate());
      
      // Parse start and end times
      const [startHour, startMinute] = startTime.split(':').map(Number);
      const [endHour, endMinute] = endTime.split(':').map(Number);
      
      let currentTime = new Date(normalizedDate);
      currentTime.setHours(startHour, startMinute, 0, 0);
      
      const endDateTime = new Date(normalizedDate);
      endDateTime.setHours(endHour, endMinute, 0, 0);

      const batch = db.batch();
      let batchCount = 0;
      const slots: any[] = [];

      while (currentTime < endDateTime) {
        const nextTime = new Date(currentTime.getTime() + slotDuration * 60 * 1000);
        
        const timeSlot = {
          merchantId,
          date: admin.firestore.Timestamp.fromDate(normalizedDate),
          startTime: `${currentTime.getHours().toString().padStart(2, '0')}:${currentTime.getMinutes().toString().padStart(2, '0')}`,
          endTime: `${nextTime.getHours().toString().padStart(2, '0')}:${nextTime.getMinutes().toString().padStart(2, '0')}`,
          isAvailable: true,
          appointmentId: null,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        const slotRef = db.collection('timeSlots').doc();
        batch.set(slotRef, timeSlot);
        slots.push({ id: slotRef.id, ...timeSlot });
        
        batchCount++;
        if (batchCount >= 500) {
          await batch.commit();
          batchCount = 0;
        }

        currentTime = nextTime;
      }

      if (batchCount > 0) {
        await batch.commit();
      }

      console.log(`Generated ${slots.length} time slots for merchant ${merchantId} on ${date}`);
      
      return {
        success: true,
        slotsCreated: slots.length,
        slots: slots.map(slot => ({
          startTime: slot.startTime,
          endTime: slot.endTime,
          isAvailable: slot.isAvailable,
        })),
      };
    } catch (error) {
      console.error('Error generating time slots:', error);
      throw new functions.https.HttpsError('internal', 'Failed to generate time slots');
    }
  }),

  // Clean up expired time slots
  cleanupExpiredSlots: functions.pubsub
    .schedule('0 2 * * *') // Run daily at 2 AM
    .onRun(async (context) => {
      try {
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        yesterday.setHours(23, 59, 59, 999);

        const expiredSlotsQuery = await db
          .collection('timeSlots')
          .where('date', '<', admin.firestore.Timestamp.fromDate(yesterday))
          .get();

        if (expiredSlotsQuery.empty) {
          console.log('No expired slots to clean up');
          return;
        }

        const batch = db.batch();
        let batchCount = 0;

        for (const doc of expiredSlotsQuery.docs) {
          batch.delete(doc.ref);
          batchCount++;

          if (batchCount >= 500) {
            await batch.commit();
            batchCount = 0;
          }
        }

        if (batchCount > 0) {
          await batch.commit();
        }

        console.log(`Cleaned up ${expiredSlotsQuery.size} expired time slots`);
      } catch (error) {
        console.error('Error cleaning up expired slots:', error);
      }
    }),

  // Get dashboard statistics
  getDashboardStats: functions.https.onCall(async (data, context) => {
    const { merchantId, date } = data;

    // Verify merchant authentication
    if (!context.auth || context.auth.uid !== merchantId) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    try {
      const targetDate = date ? new Date(date) : new Date();
      const startOfDay = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate());
      const endOfDay = new Date(startOfDay);
      endOfDay.setDate(endOfDay.getDate() + 1);

      // Get appointments for the specified date
      const appointmentsQuery = await db
        .collection('appointments')
        .where('merchantId', '==', merchantId)
        .where('dateTime', '>=', admin.firestore.Timestamp.fromDate(startOfDay))
        .where('dateTime', '<', admin.firestore.Timestamp.fromDate(endOfDay))
        .get();

      const stats = {
        total: 0,
        pending: 0,
        confirmed: 0,
        completed: 0,
        cancelled: 0,
        revenue: 0,
        upcomingToday: 0,
      };

      const now = new Date();

      appointmentsQuery.forEach(doc => {
        const appointment = doc.data();
        stats.total++;
        
        switch (appointment.status) {
          case 'pending':
            stats.pending++;
            break;
          case 'confirmed':
            stats.confirmed++;
            break;
          case 'completed':
            stats.completed++;
            stats.revenue += appointment.price || 0;
            break;
          case 'cancelled':
          case 'rescheduled':
            stats.cancelled++;
            break;
        }

        // Count upcoming appointments for today
        const appointmentTime = appointment.dateTime.toDate();
        if (appointmentTime > now && appointment.status !== 'cancelled') {
          stats.upcomingToday++;
        }
      });

      // Get monthly stats
      const startOfMonth = new Date(targetDate.getFullYear(), targetDate.getMonth(), 1);
      const endOfMonth = new Date(targetDate.getFullYear(), targetDate.getMonth() + 1, 1);

      const monthlyQuery = await db
        .collection('appointments')
        .where('merchantId', '==', merchantId)
        .where('dateTime', '>=', admin.firestore.Timestamp.fromDate(startOfMonth))
        .where('dateTime', '<', admin.firestore.Timestamp.fromDate(endOfMonth))
        .get();

      let monthlyRevenue = 0;
      let monthlyCompleted = 0;

      monthlyQuery.forEach(doc => {
        const appointment = doc.data();
        if (appointment.status === 'completed') {
          monthlyCompleted++;
          monthlyRevenue += appointment.price || 0;
        }
      });

      return {
        daily: stats,
        monthly: {
          completed: monthlyCompleted,
          revenue: monthlyRevenue,
        },
      };
    } catch (error) {
      console.error('Error getting dashboard stats:', error);
      throw new functions.https.HttpsError('internal', 'Failed to get dashboard stats');
    }
  }),

  // Process scheduled reminders
  processScheduledReminders: functions.pubsub
    .schedule('every 5 minutes')
    .onRun(async (context) => {
      try {
        const now = new Date();
        const fiveMinutesAgo = new Date(now.getTime() - 5 * 60 * 1000);

        const remindersQuery = await db
          .collection('scheduledReminders')
          .where('sent', '==', false)
          .where('scheduledFor', '<=', admin.firestore.Timestamp.fromDate(now))
          .where('scheduledFor', '>', admin.firestore.Timestamp.fromDate(fiveMinutesAgo))
          .get();

        if (remindersQuery.empty) {
          console.log('No reminders to process');
          return;
        }

        const batch = db.batch();

        for (const doc of remindersQuery.docs) {
          const reminder = doc.data();
          
          try {
            if (reminder.type === 'customer') {
              // Send customer reminder
              await sendCustomerReminder(reminder);
            } else {
              // Send merchant reminder
              await sendMerchantReminder(reminder);
            }

            // Mark as sent
            batch.update(doc.ref, {
              sent: true,
              sentAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          } catch (error) {
            console.error('Error sending reminder:', error);
            // Mark as failed
            batch.update(doc.ref, {
              sent: true,
              failed: true,
              error: error.message,
              sentAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          }
        }

        await batch.commit();
        console.log(`Processed ${remindersQuery.size} reminders`);
      } catch (error) {
        console.error('Error processing scheduled reminders:', error);
      }
    }),
};

async function sendCustomerReminder(reminder: any) {
  const { appointment, merchant, timeUntil } = reminder;
  
  // Send email reminder
  const emailData = {
    to: appointment.customerInfo.email,
    template: 'appointment_reminder',
    data: {
      customerName: appointment.customerInfo.name,
      serviceName: appointment.serviceName,
      merchantName: merchant?.name || 'Unknown',
      appointmentDate: appointment.dateTime.toDate().toLocaleDateString(),
      appointmentTime: appointment.dateTime.toDate().toLocaleTimeString(),
      timeUntil: `in ${timeUntil}`,
    },
  };

  // Call the email function (in production, you'd use the actual function)
  console.log('Sending customer reminder email:', emailData);
}

async function sendMerchantReminder(reminder: any) {
  const { appointment, merchant } = reminder;
  
  // Send push notification to merchant
  const notificationData = {
    userId: appointment.merchantId,
    title: 'Upcoming Appointment',
    body: `${appointment.customerInfo.name} - ${appointment.serviceName} in 15 minutes`,
    data: {
      type: 'appointment_reminder',
      appointmentId: reminder.appointmentId,
    },
  };

  console.log('Sending merchant reminder notification:', notificationData);
}
