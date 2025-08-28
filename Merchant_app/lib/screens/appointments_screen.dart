import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../utils/app_colors.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  List<Appointment> _appointments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load sample appointments for demo
      _appointments = _getSampleAppointments();
      
      // TODO: Replace with real API call
      // final appointments = await ApiService.getAppointments(
      //   merchantId,
      //   authProvider.token,
      //   startDate: _selectedDate,
      //   endDate: _selectedDate.add(const Duration(days: 7)),
      // );
      // _appointments = appointments;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading appointments: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Appointment> _getSampleAppointments() {
    return [
      // Today's appointments
      Appointment(
        id: '1',
        merchantId: '1',
        customerId: '1',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        customerPhone: '+1234567890',
        serviceId: '1',
        serviceName: 'Haircut & Styling',
        servicePrice: 3750.0,
        staffId: '2',
        staffName: 'Mike Rodriguez',
        appointmentDate: DateTime.now(),
        appointmentTime: '09:00',
        status: AppointmentStatus.confirmed,
        bookingType: BookingType.online,
        notes: 'Customer prefers afternoon appointments',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Appointment(
        id: '2',
        merchantId: '1',
        customerId: '2',
        customerName: 'Jane Smith',
        customerEmail: 'jane@example.com',
        customerPhone: '+1234567891',
        serviceId: '2',
        serviceName: 'Manicure & Pedicure',
        servicePrice: 2500.0,
        staffId: '3',
        staffName: 'Emma Chen',
        appointmentDate: DateTime.now(),
        appointmentTime: '11:30',
        status: AppointmentStatus.pending,
        bookingType: BookingType.online,
        notes: 'First time customer',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Appointment(
        id: '3',
        merchantId: '1',
        customerId: '3',
        customerName: 'Walk-in Customer',
        customerEmail: 'walkin@example.com',
        customerPhone: '+1234567892',
        serviceId: '1',
        serviceName: 'Haircut & Styling',
        servicePrice: 3750.0,
        staffId: '2',
        staffName: 'Mike Rodriguez',
        appointmentDate: DateTime.now(),
        appointmentTime: '15:00',
        status: AppointmentStatus.confirmed,
        bookingType: BookingType.walkIn,
        notes: 'Walk-in customer, immediate service',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Appointment(
        id: '4',
        merchantId: '1',
        customerId: '4',
        customerName: 'Mike Johnson',
        customerEmail: 'mike@example.com',
        customerPhone: '+1234567892',
        serviceId: '3',
        serviceName: 'Facial Treatment',
        servicePrice: 5000.0,
        staffId: '3',
        staffName: 'Emma Chen',
        appointmentDate: DateTime.now(),
        appointmentTime: '16:00',
        status: AppointmentStatus.completed,
        bookingType: BookingType.online,
        notes: 'Sensitive skin - use gentle products',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      
      // Tomorrow's appointments
      Appointment(
        id: '5',
        merchantId: '1',
        customerId: '5',
        customerName: 'Dr. Sarah Johnson',
        customerEmail: 'sarah.johnson@clinic.com',
        customerPhone: '+1234567893',
        serviceId: '3',
        serviceName: 'General Consultation',
        servicePrice: 80.0,
        staffId: '1',
        staffName: 'Dr. Sarah Johnson',
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
        appointmentTime: '10:00',
        status: AppointmentStatus.confirmed,
        bookingType: BookingType.online,
        notes: 'Follow-up consultation',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: '6',
        merchantId: '1',
        customerId: '6',
        customerName: 'Alex Brown',
        customerEmail: 'alex@example.com',
        customerPhone: '+1234567894',
        serviceId: '1',
        serviceName: 'Haircut & Styling',
        servicePrice: 3750.0,
        staffId: '2',
        staffName: 'Mike Rodriguez',
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
        appointmentTime: '14:00',
        status: AppointmentStatus.pending,
        bookingType: BookingType.online,
        notes: 'Regular customer',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      
      // Future appointments
      Appointment(
        id: '7',
        merchantId: '1',
        customerId: '7',
        customerName: 'Lisa Davis',
        customerEmail: 'lisa@example.com',
        customerPhone: '+1234567895',
        serviceId: '2',
        serviceName: 'Manicure & Pedicure',
        servicePrice: 2500.0,
        staffId: '3',
        staffName: 'Emma Chen',
        appointmentDate: DateTime.now().add(const Duration(days: 3)),
        appointmentTime: '13:00',
        status: AppointmentStatus.confirmed,
        bookingType: BookingType.online,
        notes: 'Monthly maintenance',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Appointment(
        id: '8',
        merchantId: '1',
        customerId: '8',
        customerName: 'Sarah Wilson',
        customerEmail: 'sarah@example.com',
        customerPhone: '+1234567893',
        serviceId: '1',
        serviceName: 'Haircut & Styling',
        servicePrice: 3750.0,
        staffId: '2',
        staffName: 'Mike Rodriguez',
        appointmentDate: DateTime.now().add(const Duration(days: 5)),
        appointmentTime: '11:00',
        status: AppointmentStatus.pending,
        bookingType: BookingType.online,
        notes: 'Customer requested cancellation',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<Appointment> get _todayAppointments {
    final today = DateTime.now();
    return _appointments.where((appointment) {
      final appointmentDate = appointment.appointmentDate;
      return appointmentDate.year == today.year &&
          appointmentDate.month == today.month &&
          appointmentDate.day == today.day;
    }).toList();
  }

  List<Appointment> get _upcomingAppointments {
    return _appointments.where((appointment) {
      return appointment.appointmentDate.isAfter(DateTime.now()) &&
          appointment.status != AppointmentStatus.cancelled;
    }).toList();
  }

  List<Appointment> get _completedAppointments {
    return _appointments.where((appointment) {
      return appointment.status == AppointmentStatus.completed;
    }).toList();
  }

  Future<void> _updateAppointmentStatus(
    Appointment appointment,
    AppointmentStatus newStatus,
  ) async {
    try {
      // TODO: Replace with real API call
      // final success = await ApiService.updateAppointmentStatus(
      //   appointment.id,
      //   merchantId,
      //   newStatus,
      //   authProvider.token,
      // );
      
      // For demo, update locally
      setState(() {
        final index = _appointments.indexWhere((a) => a.id == appointment.id);
        if (index != -1) {
          _appointments[index] = appointment.copyWith(status: newStatus);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment status updated to ${newStatus.name}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating appointment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAppointmentDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentDetailsSheet(appointment: appointment),
    );
  }

  void _showCreateWalkInDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateWalkInDialog(
        onAppointmentCreated: (appointment) {
          setState(() {
            _appointments.add(appointment);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showCreateWalkInDialog,
            tooltip: 'Create Walk-in Appointment',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsList(_appointments),
          _buildAppointmentsList(_todayAppointments),
          _buildAppointmentsList(_upcomingAppointments),
          _buildAppointmentsList(_completedAppointments),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppointmentDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Group appointments by date
    final groupedAppointments = <DateTime, List<Appointment>>{};
    for (final appointment in appointments) {
      final date = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
      );
      groupedAppointments.putIfAbsent(date, () => []).add(appointment);
    }

    final sortedDates = groupedAppointments.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final dateAppointments = groupedAppointments[date]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _formatDateHeader(date),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              // Appointments for this date
              ...dateAppointments.map((appointment) => _AppointmentCard(
                appointment: appointment,
                onTap: () => _showAppointmentDetails(appointment),
                onStatusUpdate: (newStatus) => _updateAppointmentStatus(appointment, newStatus),
              )),
              if (index < sortedDates.length - 1) const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final appointmentDate = DateTime(date.year, date.month, date.day);

    if (appointmentDate == today) {
      return 'Today - ${DateFormat('EEEE, MMMM dd').format(date)}';
    } else if (appointmentDate == tomorrow) {
      return 'Tomorrow - ${DateFormat('EEEE, MMMM dd').format(date)}';
    } else {
      return DateFormat('EEEE, MMMM dd').format(date);
    }
  }



  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAppointments();
    }
  }

  void _showAddAppointmentDialog() {
    // TODO: Implement add appointment dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add appointment feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;
  final Function(AppointmentStatus) onStatusUpdate;

  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
    required this.onStatusUpdate,
  });

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return AppColors.confirmed;
      case AppointmentStatus.pending:
        return AppColors.pending;
      case AppointmentStatus.completed:
        return AppColors.completed;
      case AppointmentStatus.cancelled:
        return AppColors.cancelled;
      case AppointmentStatus.noShow:
        return AppColors.noShow;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.customerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.serviceName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(appointment.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(appointment.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(appointment.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('MMM dd, yyyy').format(appointment.appointmentDate)} at ${appointment.appointmentTime}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\₹${appointment.servicePrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (appointment.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  'Notes: ${appointment.notes}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              // Staff and booking type info
              if (appointment.staffName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Staff: ${appointment.staffName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    appointment.bookingType == BookingType.walkIn 
                        ? Icons.directions_walk 
                        : Icons.computer,
                    size: 16,
                    color: appointment.bookingType == BookingType.walkIn 
                        ? Colors.orange 
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.bookingTypeText} Booking',
                    style: TextStyle(
                      fontSize: 14,
                      color: appointment.bookingType == BookingType.walkIn 
                          ? Colors.orange 
                          : AppColors.textSecondary,
                      fontWeight: appointment.bookingType == BookingType.walkIn 
                          ? FontWeight.w500 
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showStatusUpdateDialog(context),
                      child: const Text('Update Status'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showContactDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Contact'),
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

  void _showStatusUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppointmentStatus.values.map((status) {
            return ListTile(
              title: Text(_getStatusText(status)),
              leading: Radio<AppointmentStatus>(
                value: status,
                groupValue: appointment.status,
                onChanged: (value) {
                  Navigator.pop(context);
                  onStatusUpdate(value!);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact ${appointment.customerName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(appointment.customerEmail),
              onTap: () {
                // TODO: Implement email functionality
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone'),
              subtitle: Text(appointment.customerPhone),
              onTap: () {
                // TODO: Implement phone functionality
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _AppointmentDetailsSheet extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentDetailsSheet({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DetailRow('Customer', appointment.customerName),
                  _DetailRow('Service', appointment.serviceName),
                  _DetailRow('Date', DateFormat('EEEE, MMMM dd, yyyy').format(appointment.appointmentDate)),
                  _DetailRow('Time', appointment.appointmentTime),
                  _DetailRow('Duration', '60 minutes'),
                  _DetailRow('Price', '\₹${appointment.servicePrice.toStringAsFixed(2)}'),
                  _DetailRow('Status', appointment.status.name.toUpperCase()),
                  if (appointment.notes?.isNotEmpty == true)
                    _DetailRow('Notes', appointment.notes ?? ''),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement reschedule
                          },
                          icon: const Icon(Icons.schedule),
                          label: const Text('Reschedule'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement cancel
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateWalkInDialog extends StatefulWidget {
  final Function(Appointment) onAppointmentCreated;

  const _CreateWalkInDialog({
    required this.onAppointmentCreated,
  });

  @override
  State<_CreateWalkInDialog> createState() => _CreateWalkInDialogState();
}

class _CreateWalkInDialogState extends State<_CreateWalkInDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedService = '';
  String _selectedStaff = '';
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '10:00';
  bool _isLoading = false;

  // Sample data - replace with real data from API
  final List<Map<String, String>> _services = [
    {'id': '1', 'name': 'Haircut & Styling', 'price': '3750.00'},
    {'id': '2', 'name': 'Manicure & Pedicure', 'price': '2500.00'},
    {'id': '3', 'name': 'Facial Treatment', 'price': '5000.00'},
  ];

  final List<Map<String, String>> _staff = [
    {'id': '1', 'name': 'Dr. Sarah Johnson', 'role': 'Doctor'},
    {'id': '2', 'name': 'Mike Rodriguez', 'role': 'Stylist'},
    {'id': '3', 'name': 'Emma Chen', 'role': 'Therapist'},
  ];

  final List<String> _timeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  ];

  @override
  void initState() {
    super.initState();
    if (_services.isNotEmpty) _selectedService = _services.first['id']!;
    if (_staff.isNotEmpty) _selectedStaff = _staff.first['id']!;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _createWalkInAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedService.isEmpty || _selectedStaff.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service and staff member'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedService = _services.firstWhere((s) => s['id'] == _selectedService);
      final selectedStaffMember = _staff.firstWhere((s) => s['id'] == _selectedStaff);

      final appointment = Appointment(
        merchantId: '1', // Replace with actual merchant ID
        customerId: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        customerEmail: _customerEmailController.text.trim(),
        serviceId: _selectedService,
        serviceName: selectedService['name']!,
        servicePrice: double.parse(selectedService['price']!),
        staffId: _selectedStaff,
        staffName: selectedStaffMember['name'],
        appointmentDate: _selectedDate,
        appointmentTime: _selectedTime,
        status: AppointmentStatus.confirmed,
        bookingType: BookingType.walkIn,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      // TODO: Replace with real API call
      // await ApiService.createAppointment(appointment, authProvider.token);

      widget.onAppointmentCreated(appointment);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Walk-in appointment created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating appointment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            AppBar(
              title: const Text('Create Walk-in Appointment'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _customerPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _customerEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'Appointment Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedService,
                              decoration: const InputDecoration(
                                labelText: 'Service *',
                                border: OutlineInputBorder(),
                              ),
                              items: _services.map((service) => DropdownMenuItem(
                                value: service['id'],
                                child: Text('${service['name']} (\₹${service['price']})'),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedService = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStaff,
                              decoration: const InputDecoration(
                                labelText: 'Staff Member *',
                                border: OutlineInputBorder(),
                              ),
                              items: _staff.map((staff) => DropdownMenuItem(
                                value: staff['id'],
                                child: Text('${staff['name']} (${staff['role']})'),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStaff = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 30)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date *',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedTime,
                              decoration: const InputDecoration(
                                labelText: 'Time *',
                                border: OutlineInputBorder(),
                              ),
                              items: _timeSlots.map((time) => DropdownMenuItem(
                                value: time,
                                child: Text(time),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTime = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          hintText: 'Any special requirements or notes...',
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createWalkInAppointment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Create Walk-in Appointment'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
