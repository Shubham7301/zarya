import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../utils/app_colors.dart';

class MerchantCalendarScreen extends StatefulWidget {
  const MerchantCalendarScreen({super.key});

  @override
  State<MerchantCalendarScreen> createState() => _MerchantCalendarScreenState();
}

class _MerchantCalendarScreenState extends State<MerchantCalendarScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _currentDay = DateTime.now();
  
  // Mock appointments data - in real app, this would come from API
  final Map<DateTime, List<Appointment>> _appointments = {};
  
  // Calendar view modes
  bool _isCalendarView = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();

    _selectedDay = _focusedDay;
    _loadMockAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();

    super.dispose();
  }

  void _loadMockAppointments() {
    // Generate mock appointments for the next 30 days
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));
      final appointments = _generateMockAppointmentsForDate(date);
                  if (appointments != null && appointments.isNotEmpty) {
        _appointments[DateTime(date.year, date.month, date.day)] = appointments;
      }
    }
  }

  List<Appointment> _generateMockAppointmentsForDate(DateTime date) {
    final appointments = <Appointment>[];
    final random = date.millisecondsSinceEpoch % 5; // Vary appointments per day
    
    if (random == 0) return appointments; // Some days have no appointments
    
    final timeSlots = [
      '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
      '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM'
    ];
    
    final services = [
      'Haircut & Styling', 'Facial Treatment', 'Manicure & Pedicure',
      'Massage Therapy', 'Makeup Session', 'Hair Coloring'
    ];
    
    final customers = [
      'Sarah Johnson', 'Mike Chen', 'Emma Wilson', 'David Brown',
      'Lisa Davis', 'James Miller', 'Anna Garcia', 'Robert Taylor'
    ];
    
    final statuses = [
      AppointmentStatus.confirmed,
      AppointmentStatus.pending,
      AppointmentStatus.completed,
      AppointmentStatus.cancelled
    ];
    
    for (int i = 0; i < random; i++) {
      if (i < timeSlots.length) {
        appointments.add(Appointment(
          id: 'apt_${date.millisecondsSinceEpoch}_$i',
          customerId: 'cust_${i}',
          customerName: customers[i % customers.length],
          customerPhone: '+1-555-${(1000 + i).toString().padLeft(4, '0')}',
          customerEmail: '${customers[i % customers.length].toLowerCase().replaceAll(' ', '.')}@email.com',
          serviceId: 'service_${i}',
          serviceName: services[i % services.length],
          servicePrice: (50.0 + (i * 25.0)).toDouble(),
          appointmentDate: date,
          appointmentTime: timeSlots[i],
          status: statuses[i % statuses.length],
          notes: i % 3 == 0 ? 'Special request: ${services[i % services.length]}' : '',
          createdAt: date.subtract(Duration(days: i + 1)),
        ));
      }
    }
    
    return appointments;
  }



  List<Appointment> _getAppointmentsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _appointments[key] ?? [];
  }



  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.pending:
        return Icons.schedule;
      case AppointmentStatus.completed:
        return Icons.done_all;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      case AppointmentStatus.noShow:
        return Icons.person_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments Calendar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_month),
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
            tooltip: _isCalendarView ? 'Switch to List View' : 'Switch to Calendar View',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Calendar View'),
            Tab(text: 'Daily Schedule'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarView(),
          _buildDailyScheduleView(),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        // Calendar
        TableCalendar<Appointment>(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          onPageChanged: _onPageChanged,
          eventLoader: _getAppointmentsForDay,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: Colors.red),
            holidayTextStyle: TextStyle(color: Colors.red),
            selectedDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events != null && events.isNotEmpty) {
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${events.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
        
        // Selected Day Appointments
        Expanded(
          child: _buildSelectedDayAppointments(),
        ),
      ],
    );
  }

  Widget _buildSelectedDayAppointments() {
    if (_selectedDay == null) return const SizedBox.shrink();
    
    final appointments = _getAppointmentsForDay(_selectedDay!);
    
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments for ${DateFormat('EEEE, MMMM d').format(_selectedDay!)}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enjoy your free day!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d, y').format(_selectedDay!),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${appointments.length} appointment${appointments.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return _buildAppointmentCard(appointment);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyScheduleView() {
    return Column(
      children: [
        // Date Navigation
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentDay = _currentDay.subtract(const Duration(days: 1));
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('EEEE, MMMM d, y').format(_currentDay),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentDay = _currentDay.add(const Duration(days: 1));
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        
        // Time Slots
        Expanded(
          child: _buildTimeSlotsView(),
        ),
      ],
    );
  }

  Widget _buildTimeSlotsView() {
    final appointments = _getAppointmentsForDay(_currentDay);
    final timeSlots = _generateTimeSlots();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = timeSlots[index];
                 final slotAppointments = appointments.where((apt) => apt.appointmentTime == timeSlot).toList();
        
        return _buildTimeSlotCard(timeSlot, slotAppointments);
      },
    );
  }

  List<String> _generateTimeSlots() {
    return [
      '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
      '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM',
      '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM',
      '06:00 PM', '06:30 PM', '07:00 PM', '07:30 PM'
    ];
  }

  Widget _buildTimeSlotCard(String timeSlot, List<Appointment> appointments) {
    final isAvailable = appointments.isEmpty;
    final isPast = _isTimeSlotPast(timeSlot);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isPast ? Colors.grey[100] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Time
            Container(
              width: 80,
              child: Text(
                timeSlot,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPast ? Colors.grey[600] : AppColors.primary,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Status/Content
            Expanded(
              child: isAvailable
                  ? Text(
                      isPast ? 'Past time slot' : 'Available',
                      style: TextStyle(
                        fontSize: 16,
                        color: isPast ? Colors.grey[500] : Colors.green[600],
                        fontStyle: isPast ? FontStyle.italic : FontStyle.normal,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: appointments.map((apt) => _buildAppointmentSummary(apt)).toList(),
                    ),
            ),
            
            // Action Button
            if (!isAvailable && !isPast)
              IconButton(
                onPressed: () => _showAppointmentDetails(appointments.first),
                icon: const Icon(Icons.visibility),
                tooltip: 'View Details',
              ),
          ],
        ),
      ),
    );
  }

  bool _isTimeSlotPast(String timeSlot) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slotTime = DateFormat('hh:mm a').parse(timeSlot);
    final slotDateTime = today.add(Duration(
      hours: slotTime.hour,
      minutes: slotTime.minute,
    ));
    return slotDateTime.isBefore(now);
  }

  Widget _buildAppointmentSummary(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(appointment.status).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(appointment.status),
            color: _getStatusColor(appointment.status),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  appointment.serviceName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
                             Text(
                     appointment.status.name.toUpperCase(),
                     style: TextStyle(
                       fontSize: 10,
                       fontWeight: FontWeight.bold,
                       color: _getStatusColor(appointment.status),
                     ),
                   ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with time and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                                         Text(
                       appointment.appointmentTime,
                       style: const TextStyle(
                         fontSize: 16,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                  ],
                ),
                                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(
                       color: _getStatusColor(appointment.status),
                     ),
                   ),
                   child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Icon(
                         _getStatusIcon(appointment.status),
                         color: _getStatusColor(appointment.status),
                         size: 16,
                       ),
                       const SizedBox(width: 4),
                       Text(
                         appointment.status.name.toUpperCase(),
                         style: TextStyle(
                           fontSize: 12,
                           fontWeight: FontWeight.bold,
                           color: _getStatusColor(appointment.status),
                         ),
                       ),
                     ],
                   ),
                 ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Customer Information
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    appointment.customerName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.customerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appointment.customerEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        appointment.customerPhone,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Service Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Notes: ${appointment.notes}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAppointmentDetails(appointment),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateAppointmentStatus(appointment),
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.event,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text('Appointment Details'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Customer', appointment.customerName),
                _buildDetailRow('Email', appointment.customerEmail),
                _buildDetailRow('Phone', appointment.customerPhone),
                _buildDetailRow('Service', appointment.serviceName),
                _buildDetailRow('Date', DateFormat('EEEE, MMMM d, y').format(appointment.appointmentDate)),
                                 _buildDetailRow('Time', appointment.appointmentTime),
                 _buildDetailRow('Status', appointment.status.name.toUpperCase()),
                 _buildDetailRow('Amount', '\$${appointment.servicePrice.toStringAsFixed(2)}'),
                if (appointment.notes != null && appointment.notes!.isNotEmpty)
                  _buildDetailRow('Notes', appointment.notes!),
                _buildDetailRow('Booked On', DateFormat('MMM d, y').format(appointment.createdAt)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateAppointmentStatus(appointment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update Status'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _updateAppointmentStatus(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        AppointmentStatus selectedStatus = appointment.status;
        
        return AlertDialog(
          title: const Text('Update Appointment Status'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Update status for ${appointment.customerName}\'s appointment?'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AppointmentStatus>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'New Status',
                      border: OutlineInputBorder(),
                    ),
                    items: AppointmentStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // In real app, update the appointment status via API
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Status updated to ${selectedStatus.name.toUpperCase()}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
