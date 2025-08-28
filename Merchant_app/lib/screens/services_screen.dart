import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/upload_service.dart';
import '../config/cloudinary_config.dart';
import '../models/service.dart';
import '../utils/app_colors.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<Service> _services = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantId = authProvider.merchant?.id ?? '1';
      
      // Load sample services for demo
      _services = _getSampleServices();
      
      // TODO: Replace with real API call
      // final services = await ApiService.getServices(merchantId, authProvider.token);
      // _services = services;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading services: $e'),
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

  List<Service> _getSampleServices() {
    return [
      Service(
        id: '1',
        merchantId: '1',
        name: 'Haircut & Styling',
        description: 'Professional haircut and styling service for all hair types. Includes consultation, wash, cut, and style.',
        price: 3750.0,
        duration: 60,
        category: 'hair',
        staffIds: ['2'],
        images: ['zarya/sample/haircut-1', 'zarya/sample/haircut-2'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Service(
        id: '2',
        merchantId: '1',
        name: 'Manicure & Pedicure',
        description: 'Complete nail care service including cuticle care, nail shaping, polish application, and hand/foot massage.',
        price: 3750.0,
        duration: 90,
        category: 'nails',
        staffIds: ['3'],
        images: ['zarya/sample/manicure-1'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Service(
        id: '3',
        merchantId: '1',
        name: 'Facial Treatment',
        description: 'Rejuvenating facial treatment with premium skincare products. Includes cleansing, exfoliation, mask, and moisturizing.',
        price: 60.0,
        duration: 75,
        category: 'facial',
        staffIds: ['3'],
        images: ['zarya/sample/facial-1', 'zarya/sample/facial-2'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Service(
        id: '4',
        merchantId: '1',
        name: 'Hair Coloring',
        description: 'Professional hair coloring service with premium products. Includes consultation, color application, and styling.',
        price: 80.0,
        duration: 120,
        category: 'hair',
        staffIds: [],
        images: ['zarya/sample/coloring-1'],
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Service(
        id: '5',
        merchantId: '1',
        name: 'Massage Therapy',
        description: 'Relaxing massage therapy session. Choose from Swedish, deep tissue, or hot stone massage.',
        price: 70.0,
        duration: 60,
        category: 'massage',
        staffIds: [],
        images: ['zarya/sample/massage-1'],
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  List<Service> get _filteredServices {
    if (_selectedCategory == 'all') {
      return _services;
    }
    return _services.where((service) => service.category == _selectedCategory).toList();
  }

  Future<void> _addService() async {
    final result = await Navigator.push<Service>(
      context,
      MaterialPageRoute(
        builder: (context) => const ServiceFormScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _services.add(result);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _editService(Service service) async {
    final result = await Navigator.push<Service>(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceFormScreen(service: service),
      ),
    );

    if (result != null) {
      setState(() {
        final index = _services.indexWhere((s) => s.id == service.id);
        if (index != -1) {
          _services[index] = result;
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _deleteService(Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final merchantId = authProvider.merchant?.id ?? '1';
        
        // TODO: Replace with real API call
        // final success = await ApiService.deleteService(
        //   service.id,
        //   merchantId,
        //   authProvider.token,
        // );
        
        // For demo, remove locally
        setState(() {
          _services.removeWhere((s) => s.id == service.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service deleted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting service: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleServiceStatus(Service service) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantId = authProvider.merchant?.id ?? '1';
      
      final updatedService = service.copyWith(isActive: !service.isActive);
      
      // TODO: Replace with real API call
      // final success = await ApiService.updateService(
      //   updatedService,
      //   merchantId,
      //   authProvider.token,
      // );
      
      // For demo, update locally
      setState(() {
        final index = _services.indexWhere((s) => s.id == service.id);
        if (index != -1) {
          _services[index] = updatedService;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Service ${updatedService.isActive ? 'activated' : 'deactivated'} successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating service: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Categories'),
              ),
              const PopupMenuItem(
                value: 'hair',
                child: Text('Hair Services'),
              ),
              const PopupMenuItem(
                value: 'nails',
                child: Text('Nail Services'),
              ),
              const PopupMenuItem(
                value: 'facial',
                child: Text('Facial Services'),
              ),
              const PopupMenuItem(
                value: 'massage',
                child: Text('Massage Services'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getCategoryDisplayName(_selectedCategory)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredServices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.spa,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No services found',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first service to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadServices,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      return _ServiceCard(
                        service: service,
                        onEdit: () => _editService(service),
                        onDelete: () => _deleteService(service),
                        onToggleStatus: () => _toggleServiceStatus(service),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addService,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return 'All Categories';
      case 'hair':
        return 'Hair Services';
      case 'nails':
        return 'Nail Services';
      case 'facial':
        return 'Facial Services';
      case 'massage':
        return 'Massage Services';
      default:
        return 'All Categories';
    }
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'hair':
        return 'Hair';
      case 'nails':
        return 'Nails';
      case 'facial':
        return 'Facial';
      case 'massage':
        return 'Massage';
      default:
        return 'Other';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'hair':
        return Colors.blue;
      case 'nails':
        return Colors.pink;
      case 'facial':
        return Colors.green;
      case 'massage':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Service Images
          if (service.images.isNotEmpty)
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: AppColors.border,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: PageView.builder(
                  itemCount: service.images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      ApiService.getCardImageUrl(service.images[index]),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.border,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          
          // Service Details
          Padding(
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
                            service.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(service.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getCategoryColor(service.category),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getCategoryDisplayName(service.category),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getCategoryColor(service.category),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\₹${service.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${service.duration} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Staff Assignment
                if (service.staffIds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Assigned Staff: ${service.staffIds.length} member(s)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: service.isActive
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: service.isActive ? AppColors.success : AppColors.error,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        service.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: service.isActive ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onToggleStatus,
                      icon: Icon(
                        service.isActive ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: service.isActive ? 'Deactivate' : 'Activate',
                    ),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete,
                        color: AppColors.error,
                      ),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceFormScreen extends StatefulWidget {
  final Service? service;

  const ServiceFormScreen({super.key, this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  
  String _selectedCategory = 'hair';
  bool _isActive = true;
  List<String> _images = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description;
      _priceController.text = widget.service!.price.toString();
      _durationController.text = widget.service!.duration.toString();
      _selectedCategory = widget.service!.category;
      _isActive = widget.service!.isActive;
      _images = List.from(widget.service!.images);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final files = await UploadService.pickMultipleImages(maxImages: 5);
      if (files.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });

        for (final file in files) {
          final publicId = await UploadService.uploadImage(
            file,
            folder: CloudinaryConfig.serviceImagesFolder,
          );
          if (publicId != null) {
            setState(() {
              _images.add(publicId);
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading images: $e'),
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

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantId = authProvider.merchant?.id ?? '1';

      final service = Service(
        id: widget.service?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        merchantId: merchantId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        duration: int.parse(_durationController.text),
        category: _selectedCategory,
        staffIds: widget.service?.staffIds ?? [],
        images: _images,
        isActive: _isActive,
        createdAt: widget.service?.createdAt ?? DateTime.now(),
      );

      if (widget.service != null) {
        // Update existing service
        // TODO: Replace with real API call
        // final success = await ApiService.updateService(
        //   service,
        //   merchantId,
        //   authProvider.token,
        // );
      } else {
        // Create new service
        // TODO: Replace with real API call
        // final newService = await ApiService.createService(
        //   service,
        //   merchantId,
        //   authProvider.token,
        // );
      }

      if (mounted) {
        Navigator.pop(context, service);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving service: $e'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service != null ? 'Edit Service' : 'Add Service'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveService,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Images
              const Text(
                'Service Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (_images.isNotEmpty)
                Container(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                ApiService.getThumbnailUrl(_images[index]),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.border,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: AppColors.textSecondary,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Images'),
              ),
              const SizedBox(height: 24),

              // Service Details
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a service name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                        suffixText: 'min',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter duration';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid duration';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'hair', child: Text('Hair Services')),
                  DropdownMenuItem(value: 'nails', child: Text('Nail Services')),
                  DropdownMenuItem(value: 'facial', child: Text('Facial Services')),
                  DropdownMenuItem(value: 'massage', child: Text('Massage Services')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Make this service available for booking'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
