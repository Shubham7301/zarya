import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../utils/app_colors.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointment = ModalRoute.of(context)!.settings.arguments as Appointment;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Animation
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Success Message
                    Text(
                      'Booking Confirmed!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Your appointment has been successfully booked. You will receive a confirmation email shortly.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Booking Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Booking Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildDetailRow(
                            icon: Icons.medical_services_outlined,
                            label: 'Service',
                            value: appointment.serviceName,
                          ),
                          const SizedBox(height: 16),

                          _buildDetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Date',
                            value: DateFormat('EEEE, MMMM d, y').format(appointment.dateTime),
                          ),
                          const SizedBox(height: 16),

                          _buildDetailRow(
                            icon: Icons.access_time_outlined,
                            label: 'Time',
                            value: DateFormat('h:mm a').format(appointment.dateTime),
                          ),
                          const SizedBox(height: 16),

                          _buildDetailRow(
                            icon: Icons.timer_outlined,
                            label: 'Duration',
                            value: '${appointment.duration} minutes',
                          ),
                          const SizedBox(height: 16),

                          _buildDetailRow(
                            icon: Icons.attach_money_outlined,
                            label: 'Price',
                            value: '\$${appointment.price.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 20),

                          const Divider(),
                          const SizedBox(height: 20),

                          _buildDetailRow(
                            icon: Icons.person_outline,
                            label: 'Name',
                            value: appointment.customerInfo.name,
                          ),
                          const SizedBox(height: 16),

                          _buildDetailRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: appointment.customerInfo.email,
                          ),
                          const SizedBox(height: 16),

                          _buildDetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: appointment.customerInfo.phone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Booking ID
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Booking Reference',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  appointment.id?.substring(0, 8).toUpperCase() ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Book Another Appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement add to calendar functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Add to calendar feature coming soon!'),
                            backgroundColor: AppColors.info,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add to Calendar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
