import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/simple_booking_provider.dart';
import '../utils/app_colors.dart';

class TimeSlotPicker extends StatelessWidget {
  final DateTime selectedDate;
  final String? selectedTimeSlot;
  final Function(String) onTimeSlotSelected;

  const TimeSlotPicker({
    super.key,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.onTimeSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Times',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Consumer<BookingProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }

              if (provider.error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load time slots',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final availableSlots = provider.availableSlots;

              if (availableSlots.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 48,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No available slots',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please select a different date',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Group slots by time period
              final morningSlots = <String>[];
              final afternoonSlots = <String>[];
              final eveningSlots = <String>[];

              for (final slot in availableSlots) {
                final hour = int.parse(slot.startTime.split(':')[0]);
                if (hour < 12) {
                  morningSlots.add(slot.startTime);
                } else if (hour < 17) {
                  afternoonSlots.add(slot.startTime);
                } else {
                  eveningSlots.add(slot.startTime);
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (morningSlots.isNotEmpty) ...[
                    _buildTimeSection('Morning', morningSlots),
                    const SizedBox(height: 16),
                  ],
                  if (afternoonSlots.isNotEmpty) ...[
                    _buildTimeSection('Afternoon', afternoonSlots),
                    const SizedBox(height: 16),
                  ],
                  if (eveningSlots.isNotEmpty) ...[
                    _buildTimeSection('Evening', eveningSlots),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection(String title, List<String> timeSlots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: timeSlots.map((timeSlot) {
            final isSelected = timeSlot == selectedTimeSlot;
            return GestureDetector(
              onTap: () => onTimeSlotSelected(timeSlot),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.lightGrey,
                  ),
                ),
                child: Text(
                  _formatTime(timeSlot),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatTime(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    
    if (hour == 0) {
      return '12:${minute} AM';
    } else if (hour < 12) {
      return '${hour}:${minute} AM';
    } else if (hour == 12) {
      return '12:${minute} PM';
    } else {
      return '${hour - 12}:${minute} PM';
    }
  }
}
