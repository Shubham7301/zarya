import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { notificationFunctions } from './notifications';

const db = admin.firestore();

export const appointmentTriggers = {
  // Trigger when a new appointment is created
  onAppointmentCreated: functions.firestore
    .document('appointments/{appointmentId}')
    .onCreate(async (snap, context) => {
      const appointment = snap.data();
      const appointmentId = context.params.appointmentId;

      try {
        console.log(`New appointment created: ${appointmentId}`);

        // Get merchant info
        const merchantDoc = await db
          .collection('merchants')
          .doc(appointment.merchantId)
          .get();

        if (!merchantDoc.exists) {
          console.error('Merchant not found');
          return;
        }

        const merchant = merchantDoc.data();

        // Send notification to merchant
        await notificationFunctions.sendPushNotification.call(null, {
          data: {
            userId: appointment.merchantId,
            title: 'New Appointment',
            body: `${appointment.customerInfo.name} booked ${appointment.serviceName}`,
            data: {
              type: 'new_appointment',
              appointmentId: appointmentId,
            }
          }
        });

        // Send email confirmation to customer
        await notificationFunctions.sendEmailNotification.call(null, {
          data: {
            to: appointment.customerInfo.email,
            template: 'appointment_confirmation',
            data: {
              customerName: appointment.customerInfo.name,
              serviceName: appointment.serviceName,
              merchantName: merchant?.name || 'Unknown',
              appointmentDate: appointment.dateTime.toDate().toLocaleDateString(),
              appointmentTime: appointment.dateTime.toDate().toLocaleTimeString(),
              appointmentId: appointmentId,
            }
          }
        });

        // Schedule reminder notifications
        await notificationFunctions.scheduleAppointmentReminders.call(null, {
          data: {
            appointmentId: appointmentId,
            appointment: appointment,
            merchant: merchant,
          }
        });

        console.log(`Notifications sent for appointment: ${appointmentId}`);

      } catch (error) {
        console.error('Error processing new appointment:', error);
      }
    }),

  // Trigger when an appointment is updated
  onAppointmentUpdated: functions.firestore
    .document('appointments/{appointmentId}')
    .onUpdate(async (change, context) => {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      const appointmentId = context.params.appointmentId;

      try {
        // Check what changed
        const statusChanged = beforeData.status !== afterData.status;
        const dateTimeChanged = beforeData.dateTime !== afterData.dateTime;

        if (statusChanged) {
          console.log(`Appointment status changed: ${beforeData.status} -> ${afterData.status}`);

          // Get merchant info
          const merchantDoc = await db
            .collection('merchants')
            .doc(afterData.merchantId)
            .get();

          const merchant = merchantDoc.data();

          // Send notification based on status change
          let emailTemplate = '';
          let notificationTitle = '';
          let notificationBody = '';

          switch (afterData.status) {
            case 'confirmed':
              emailTemplate = 'appointment_confirmed';
              notificationTitle = 'Appointment Confirmed';
              notificationBody = `Your appointment for ${afterData.serviceName} has been confirmed`;
              break;
            case 'cancelled':
              emailTemplate = 'appointment_cancelled';
              notificationTitle = 'Appointment Cancelled';
              notificationBody = `Your appointment for ${afterData.serviceName} has been cancelled`;
              break;
            case 'rescheduled':
              emailTemplate = 'appointment_rescheduled';
              notificationTitle = 'Appointment Rescheduled';
              notificationBody = `Your appointment for ${afterData.serviceName} has been rescheduled`;
              break;
          }

          if (emailTemplate) {
            // Send email to customer
            await notificationFunctions.sendEmailNotification.call(null, {
              data: {
                to: afterData.customerInfo.email,
                template: emailTemplate,
                data: {
                  customerName: afterData.customerInfo.name,
                  serviceName: afterData.serviceName,
                  merchantName: merchant?.name || 'Unknown',
                  appointmentDate: afterData.dateTime.toDate().toLocaleDateString(),
                  appointmentTime: afterData.dateTime.toDate().toLocaleTimeString(),
                  appointmentId: appointmentId,
                  status: afterData.status,
                }
              }
            });

            // Send SMS notification if phone number is available
            if (afterData.customerInfo.phone) {
              await notificationFunctions.sendSMSNotification.call(null, {
                data: {
                  to: afterData.customerInfo.phone,
                  message: `${notificationTitle}: ${notificationBody}. Check your email for details.`
                }
              });
            }
          }
        }

        if (dateTimeChanged) {
          console.log(`Appointment time changed for: ${appointmentId}`);
          
          // Cancel old reminders and schedule new ones
          // Note: In a real implementation, you'd need to track reminder job IDs
          await notificationFunctions.scheduleAppointmentReminders.call(null, {
            data: {
              appointmentId: appointmentId,
              appointment: afterData,
              merchant: await db.collection('merchants').doc(afterData.merchantId).get().then(doc => doc.data()),
            }
          });
        }

      } catch (error) {
        console.error('Error processing appointment update:', error);
      }
    }),

  // Trigger when an appointment is deleted
  onAppointmentDeleted: functions.firestore
    .document('appointments/{appointmentId}')
    .onDelete(async (snap, context) => {
      const appointment = snap.data();
      const appointmentId = context.params.appointmentId;

      try {
        console.log(`Appointment deleted: ${appointmentId}`);

        // Free up the time slot
        if (appointment.dateTime) {
          const date = appointment.dateTime.toDate();
          const normalizedDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());
          const startTime = `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;

          const slotsQuery = await db
            .collection('timeSlots')
            .where('merchantId', '==', appointment.merchantId)
            .where('date', '==', admin.firestore.Timestamp.fromDate(normalizedDate))
            .where('startTime', '==', startTime)
            .limit(1)
            .get();

          if (!slotsQuery.empty) {
            const slotDoc = slotsQuery.docs[0];
            await slotDoc.ref.update({
              isAvailable: true,
              appointmentId: null,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`Time slot freed up for deleted appointment: ${appointmentId}`);
          }
        }

        // Send cancellation notification to customer
        await notificationFunctions.sendEmailNotification.call(null, {
          data: {
            to: appointment.customerInfo.email,
            template: 'appointment_cancelled',
            data: {
              customerName: appointment.customerInfo.name,
              serviceName: appointment.serviceName,
              appointmentDate: appointment.dateTime.toDate().toLocaleDateString(),
              appointmentTime: appointment.dateTime.toDate().toLocaleTimeString(),
              reason: 'Appointment was cancelled',
            }
          }
        });

      } catch (error) {
        console.error('Error processing appointment deletion:', error);
      }
    }),
};
