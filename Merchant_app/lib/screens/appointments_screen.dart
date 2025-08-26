import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
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
  String _selectedFilter = 'all';
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantId = authProvider.merchant?.id ?? '1';
      
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
      Appointment(
        id: '1',
        customerId: '1',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        customerPhone: '+1234567890',
        serviceId: '1',
        serviceName: 'Haircut & Styling',
        servicePrice: 45.0,
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
        appointmentTime: '10:00',
        status: AppointmentStatus.confirmed,
        notes: 'Customer prefers short fade',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: '2',
        customerId: '2',
        customerName: 'Jane Smith',
        customerEmail: 'jane@example.com',
        customerPhone: '+1234567891',
        serviceId: '2',
        serviceName: 'Manicure & Pedicure',
        servicePrice: 35.0,
        appointmentDate: DateTime.now().add(const Duration(days: 2)),
        appointmentTime: '14:30',
        status: AppointmentStatus.pending,
        notes: 'First time customer',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Appointment(
        id: '3',
        customerId: '3',
        customerName: 'Mike Johnson',
        customerEmail: 'mike@example.com',
        customerPhone: '+1234567892',
        serviceId: '3',
        serviceName: 'Facial Treatment',
        servicePrice: 60.0,
        appointmentDate: DateTime.now(),
        appointmentTime: '16:00',
        status: AppointmentStatus.completed,
        notes: 'Sensitive skin - use gentle products',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Appointment(
        id: '4',
        customerId: '4',
        customerName: 'Sarah Wilson',
        customerEmail: 'sarah@example.com',
        customerPhone: '+1234567893',
        serviceId: '1',
        serviceName: 'Haircut & Styling',
        servicePrice: 45.0,
        appointmentDate: DateTime.now().add(const Duration(days: 3)),
        appointmentTime: '11:00',
        status: AppointmentStatus.cancelled,
        notes: 'Customer requested cancellation',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<Appointment> get _filteredAppointments {
    switch (_selectedFilter) {
      case 'today':
        return _appointments.where((appointment) {
          final today = DateTime.now();
          final appointmentDate = appointment.appointmentDate;
          return appointmentDate.year == today.year &&
              appointmentDate.month == today.month &&
              appointmentDate.day == today.day;
        }).toList();
      case 'upcoming':
        return _appointments.where((appointment) {
          return appointment.appointmentDate.isAfter(DateTime.now()) &&
              appointment.status != AppointmentStatus.cancelled;
        }).toList();
      case 'completed':
        return _appointments.where((appointment) {
          return appointment.status == AppointmentStatus.completed;
        }).toList();
      default:
        return _appointments;
    }
  }

  Future<void> _updateAppointmentStatus(
    Appointment appointment,
    AppointmentStatus newStatus,
  ) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantId = authProvider.merchant?.id ?? '1';
      
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
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
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
          _buildAppointmentsList(_filteredAppointments),
          _buildAppointmentsList(_filteredAppointments),
          _buildAppointmentsList(_filteredAppointments),
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
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _AppointmentCard(
            appointment: appointment,
            onTap: () => _showAppointmentDetails(appointment),
            onStatusUpdate: (newStatus) => _updateAppointmentStatus(appointment, newStatus),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Appointments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All'),
              value: 'all',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Today'),
              value: 'today',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Upcoming'),
              value: 'upcoming',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Completed'),
              value: 'completed',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
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
                      color: _getStatusColor(appointment.status).withOpacity(0.1),
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
                    '\$${appointment.servicePrice.toStringAsFixed(2)}',
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
                  _DetailRow('Price', '\$${appointment.servicePrice.toStringAsFixed(2)}'),
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
