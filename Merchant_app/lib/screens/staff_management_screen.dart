import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/staff.dart';
import '../models/service.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/upload_service.dart';
import '../utils/app_colors.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  List<Staff> _staffList = [];
  List<Service> _services = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadStaff();
    _loadServices();
  }

  Future<void> _loadStaff() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantId = authProvider.merchant?.id ?? '1';
      
      // Load sample staff for demo
      _staffList = _getSampleStaff(merchantId);
      
      // TODO: Replace with real API call
      // final staff = await ApiService.getStaff(merchantId, authProvider.token);
      // _staffList = staff;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading staff: $e'),
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

  Future<void> _loadServices() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantId = authProvider.merchant?.id ?? '1';
      
      // Load sample services for demo
      _services = _getSampleServices(merchantId);
      
      // TODO: Replace with real API call
      // final services = await ApiService.getServices(merchantId, authProvider.token);
      // _services = services;
    } catch (e) {
      // Handle error silently for now
    }
  }

  List<Staff> _getSampleStaff(String merchantId) {
    return [
      Staff(
        id: '1',
        merchantId: merchantId,
        name: 'Dr. Sarah Johnson',
        email: 'sarah.johnson@clinic.com',
        phone: '+1234567890',
        role: 'doctor',
        specialization: 'General Practitioner',
        profileImage: 'zarya/sample/doctor-1',
        serviceIds: ['1', '3'],
        availability: [
          StaffAvailability(day: 'Monday', startTime: '09:00', endTime: '17:00', isAvailable: true),
          StaffAvailability(day: 'Tuesday', startTime: '09:00', endTime: '17:00', isAvailable: true),
          StaffAvailability(day: 'Wednesday', startTime: '09:00', endTime: '17:00', isAvailable: true),
          StaffAvailability(day: 'Thursday', startTime: '09:00', endTime: '17:00', isAvailable: true),
          StaffAvailability(day: 'Friday', startTime: '09:00', endTime: '17:00', isAvailable: true),
        ],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Staff(
        id: '2',
        merchantId: merchantId,
        name: 'Mike Rodriguez',
        email: 'mike.rodriguez@salon.com',
        phone: '+1234567891',
        role: 'stylist',
        specialization: 'Hair Styling & Coloring',
        profileImage: 'zarya/sample/stylist-1',
        serviceIds: ['1', '4'],
        availability: [
          StaffAvailability(day: 'Monday', startTime: '10:00', endTime: '18:00', isAvailable: true),
          StaffAvailability(day: 'Tuesday', startTime: '10:00', endTime: '18:00', isAvailable: true),
          StaffAvailability(day: 'Wednesday', startTime: '10:00', endTime: '18:00', isAvailable: true),
          StaffAvailability(day: 'Thursday', startTime: '10:00', endTime: '18:00', isAvailable: true),
          StaffAvailability(day: 'Friday', startTime: '10:00', endTime: '18:00', isAvailable: true),
          StaffAvailability(day: 'Saturday', startTime: '09:00', endTime: '16:00', isAvailable: true),
        ],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Staff(
        id: '3',
        merchantId: merchantId,
        name: 'Emma Chen',
        email: 'emma.chen@spa.com',
        phone: '+1234567892',
        role: 'therapist',
        specialization: 'Massage & Wellness',
        profileImage: 'zarya/sample/therapist-1',
        serviceIds: ['2', '5'],
        availability: [
          StaffAvailability(day: 'Monday', startTime: '11:00', endTime: '19:00', isAvailable: true),
          StaffAvailability(day: 'Tuesday', startTime: '11:00', endTime: '19:00', isAvailable: true),
          StaffAvailability(day: 'Wednesday', startTime: '11:00', endTime: '19:00', isAvailable: true),
          StaffAvailability(day: 'Thursday', startTime: '11:00', endTime: '19:00', isAvailable: true),
          StaffAvailability(day: 'Friday', startTime: '11:00', endTime: '19:00', isAvailable: true),
        ],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  List<Service> _getSampleServices(String merchantId) {
    return [
      Service(
        id: '1',
        merchantId: merchantId,
        name: 'Haircut & Styling',
        description: 'Professional haircut and styling service',
        price: 3750.0,
        duration: 60,
        category: 'hair',
        staffIds: ['2'],
        images: ['zarya/sample/haircut-1'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Service(
        id: '2',
        merchantId: merchantId,
        name: 'Manicure & Pedicure',
        description: 'Complete nail care service',
        price: 35.0,
        duration: 90,
        category: 'nails',
        staffIds: ['3'],
        images: ['zarya/sample/manicure-1'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Service(
        id: '3',
        merchantId: merchantId,
        name: 'General Consultation',
        description: 'Medical consultation service',
        price: 80.0,
        duration: 30,
        category: 'medical',
        staffIds: ['1'],
        images: ['zarya/sample/consultation-1'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Service(
        id: '4',
        merchantId: merchantId,
        name: 'Hair Coloring',
        description: 'Professional hair coloring service',
        price: 120.0,
        duration: 120,
        category: 'hair',
        staffIds: ['2'],
        images: ['zarya/sample/coloring-1'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Service(
        id: '5',
        merchantId: merchantId,
        name: 'Relaxing Massage',
        description: 'Therapeutic massage service',
        price: 75.0,
        duration: 60,
        category: 'wellness',
        staffIds: ['3'],
        images: ['zarya/sample/massage-1'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  void _showAddStaffDialog() {
    showDialog(
      context: context,
      builder: (context) => AddStaffDialog(
        services: _services,
        onStaffAdded: (staff) {
          setState(() {
            _staffList.add(staff);
          });
        },
      ),
    );
  }

  void _showEditStaffDialog(Staff staff) {
    showDialog(
      context: context,
      builder: (context) => AddStaffDialog(
        services: _services,
        staff: staff,
        onStaffAdded: (updatedStaff) {
          setState(() {
            final index = _staffList.indexWhere((s) => s.id == staff.id);
            if (index != -1) {
              _staffList[index] = updatedStaff;
            }
          });
        },
      ),
    );
  }

  void _toggleStaffStatus(Staff staff) {
    setState(() {
      final index = _staffList.indexWhere((s) => s.id == staff.id);
      if (index != -1) {
        _staffList[index] = staff.copyWith(isActive: !staff.isActive);
      }
    });
  }

  List<Staff> get _filteredStaff {
    if (_selectedFilter == 'all') return _staffList;
    return _staffList.where((staff) => staff.role == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddStaffDialog,
            tooltip: 'Add Staff Member',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  _buildFilterChip('doctor', 'Doctors'),
                  _buildFilterChip('stylist', 'Stylists'),
                  _buildFilterChip('therapist', 'Therapists'),
                ],
              ),
            ),
          ),
          
          // Staff list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStaff.isEmpty
                    ? const Center(
                        child: Text(
                          'No staff members found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredStaff.length,
                        itemBuilder: (context, index) {
                          final staff = _filteredStaff[index];
                          return _buildStaffCard(staff);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildStaffCard(Staff staff) {
    final assignedServices = _services
        .where((service) => staff.serviceIds.contains(service.id))
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: staff.profileImage != null
                      ? NetworkImage('https://res.cloudinary.com/your-cloud/image/upload/$staff.profileImage')
                      : null,
                  child: staff.profileImage == null
                      ? Text(
                          staff.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        staff.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        staff.specialization,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditStaffDialog(staff);
                        break;
                      case 'toggle':
                        _toggleStaffStatus(staff);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            staff.isActive ? Icons.block : Icons.check_circle,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(staff.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Contact info
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(child: Text(staff.email)),
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(staff.phone),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Assigned services
            if (assignedServices.isNotEmpty) ...[
              Text(
                'Assigned Services:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: assignedServices.map((service) => Chip(
                  label: Text(service.name),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppColors.primary),
                )).toList(),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Availability
            Text(
              'Availability:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: staff.availability.map((availability) {
                if (!availability.isAvailable) return const SizedBox.shrink();
                return Chip(
                  label: Text('${availability.day}: ${availability.startTime}-${availability.endTime}'),
                  backgroundColor: Colors.green.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.green),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 8),
            
            // Status indicator
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: staff.isActive ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  staff.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: staff.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddStaffDialog extends StatefulWidget {
  final List<Service> services;
  final Staff? staff;
  final Function(Staff) onStaffAdded;

  const AddStaffDialog({
    super.key,
    required this.services,
    this.staff,
    required this.onStaffAdded,
  });

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specializationController;
  late TextEditingController _customServiceController;
  late TextEditingController _newServiceNameController;
  late TextEditingController _newServiceDescriptionController;
  late TextEditingController _newServicePriceController;
  late TextEditingController _newServiceDurationController;
  
  String _selectedRole = 'stylist';
  List<String> _selectedServiceIds = [];
  List<StaffAvailability> _availability = [];
  bool _isLoading = false;
  String _newServiceCategory = 'hair';

  final List<String> _roles = ['doctor', 'stylist', 'therapist', 'assistant'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff?.name ?? '');
    _emailController = TextEditingController(text: widget.staff?.email ?? '');
    _phoneController = TextEditingController(text: widget.staff?.phone ?? '');
    _specializationController = TextEditingController(text: widget.staff?.specialization ?? '');
    _customServiceController = TextEditingController();
    _newServiceNameController = TextEditingController();
    _newServiceDescriptionController = TextEditingController();
    _newServicePriceController = TextEditingController();
    _newServiceDurationController = TextEditingController();
    
    if (widget.staff != null) {
      _selectedRole = widget.staff!.role;
      _selectedServiceIds = List.from(widget.staff!.serviceIds);
      _availability = List.from(widget.staff!.availability);
    } else {
      _initializeDefaultAvailability();
    }
  }

  void _initializeDefaultAvailability() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    _availability = days.map((day) => StaffAvailability(
      day: day,
      startTime: '09:00',
      endTime: '17:00',
      isAvailable: true,
    )).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _customServiceController.dispose();
    _newServiceNameController.dispose();
    _newServiceDescriptionController.dispose();
    _newServicePriceController.dispose();
    _newServiceDurationController.dispose();
    super.dispose();
  }

  Future<void> _saveStaff() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantId = authProvider.merchant?.id ?? '1';

      final staff = Staff(
        id: widget.staff?.id,
        merchantId: merchantId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole,
        specialization: _specializationController.text.trim(),
        serviceIds: _selectedServiceIds,
        availability: _availability,
        isActive: widget.staff?.isActive ?? true,
        createdAt: widget.staff?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: Replace with real API call
      // if (widget.staff != null) {
      //   await ApiService.updateStaff(staff, authProvider.token);
      // } else {
      //   await ApiService.createStaff(staff, authProvider.token);
      // }

      widget.onStaffAdded(staff);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.staff != null 
                ? 'Staff member updated successfully!' 
                : 'Staff member added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving staff: $e'),
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

  void _addCustomService(String name) {
    final newServiceId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final newService = Service(
      id: newServiceId,
      merchantId: '', // Will be set later
      name: name,
      description: '',
      price: 0.0,
      duration: 0,
      category: '',
      staffIds: [],
      images: [],
      isActive: true,
      createdAt: DateTime.now(),
    );
    setState(() {
      _selectedServiceIds.add(newServiceId);
    });
    _customServiceController.clear();
  }

  Future<void> _createNewService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantId = authProvider.merchant?.id ?? '1';

      final newService = Service(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
        merchantId: merchantId,
        name: _newServiceNameController.text.trim(),
        description: _newServiceDescriptionController.text.trim(),
        price: double.tryParse(_newServicePriceController.text.replaceAll('₹', '').trim()) ?? 0.0,
        duration: int.tryParse(_newServiceDurationController.text.trim()) ?? 0,
        category: _newServiceCategory,
        staffIds: [], // Staff IDs will be assigned later
        images: [],
        isActive: true,
        createdAt: DateTime.now(),
      );

      // TODO: Replace with real API call
      // await ApiService.createService(newService, authProvider.token);

      setState(() {
        if (newService.id != null) {
          _selectedServiceIds.add(newService.id!);
        }
        _newServiceNameController.clear();
        _newServiceDescriptionController.clear();
        _newServicePriceController.clear();
        _newServiceDurationController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Service "${newService.name}" created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating service: $e'),
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
              title: Text(widget.staff != null ? 'Edit Staff Member' : 'Add Staff Member'),
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
                      // Basic information
                      Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter staff name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
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
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Role',
                                border: OutlineInputBorder(),
                              ),
                              items: _roles.map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role.capitalize()),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _specializationController,
                              decoration: const InputDecoration(
                                labelText: 'Specialization',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter specialization';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Services assignment
                      Text(
                        'Services Assignment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: widget.services.map((service) {
                          final isSelected = _selectedServiceIds.contains(service.id);
                          return FilterChip(
                            label: Text(service.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedServiceIds.add(service.id!);
                                } else {
                                  _selectedServiceIds.remove(service.id!);
                                }
                              });
                            },
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Custom service input
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _customServiceController,
                              decoration: const InputDecoration(
                                labelText: 'Add Custom Service',
                                hintText: 'Enter service name',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.add),
                              ),
                              onFieldSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  _addCustomService(value.trim());
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_customServiceController.text.trim().isNotEmpty) {
                                _addCustomService(_customServiceController.text.trim());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Create new service section
                      ExpansionTile(
                        title: Text(
                          'Create New Service',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        children: [
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _newServiceNameController,
                            decoration: const InputDecoration(
                              labelText: 'Service Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _newServiceDescriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _newServicePriceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Price (₹)',
                                    border: OutlineInputBorder(),
                                    prefixText: '₹',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _newServiceDurationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Duration (minutes)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _newServiceCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: ['hair', 'nails', 'skincare', 'wellness', 'medical', 'other'].map((category) => 
                              DropdownMenuItem(value: category, child: Text(category.capitalize()))
                            ).toList(),
                            onChanged: (value) {
                              setState(() {
                                _newServiceCategory = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _createNewService,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Create Service & Assign'),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                      
                      // Show selected services summary
                      if (_selectedServiceIds.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Selected Services:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _selectedServiceIds.map((serviceId) {
                            // Try to find the service in existing services
                            final existingService = widget.services.firstWhere(
                              (s) => s.id == serviceId,
                              orElse: () => Service(
                                id: serviceId,
                                merchantId: '',
                                name: serviceId.startsWith('custom_') ? 'Custom Service' : serviceId,
                                description: '',
                                price: 0.0,
                                duration: 0,
                                category: '',
                                staffIds: [],
                                images: [],
                                isActive: true,
                                createdAt: DateTime.now(),
                              ),
                            );
                            
                            return Chip(
                              label: Text(existingService.name),
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _selectedServiceIds.remove(serviceId);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Availability
                      Text(
                        'Availability Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ..._availability.map((availability) => _buildAvailabilityRow(availability)),
                      
                      const SizedBox(height: 24),
                      
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveStaff,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(widget.staff != null ? 'Update Staff' : 'Add Staff'),
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

  Widget _buildAvailabilityRow(StaffAvailability availability) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              availability.day,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: availability.startTime,
                    decoration: const InputDecoration(
                      labelText: 'Start',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _getTimeSlots().map((time) => DropdownMenuItem(
                      value: time,
                      child: Text(time),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        final index = _availability.indexWhere((a) => a.day == availability.day);
                        if (index != -1) {
                          _availability[index] = availability.copyWith(startTime: value!);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text('to'),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: availability.endTime,
                    decoration: const InputDecoration(
                      labelText: 'End',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _getTimeSlots().map((time) => DropdownMenuItem(
                      value: time,
                      child: Text(time),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        final index = _availability.indexWhere((a) => a.day == availability.day);
                        if (index != -1) {
                          _availability[index] = availability.copyWith(endTime: value!);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: availability.isAvailable,
            onChanged: (value) {
              setState(() {
                final index = _availability.indexWhere((a) => a.day == availability.day);
                if (index != -1) {
                  _availability[index] = availability.copyWith(isAvailable: value);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  List<String> _getTimeSlots() {
    final slots = <String>[];
    for (int hour = 6; hour <= 22; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      if (hour < 22) {
        slots.add('${hour.toString().padLeft(2, '0')}:30');
      }
    }
    return slots;
  }
}
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

