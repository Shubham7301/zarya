import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../services/upload_service.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../models/merchant.dart';
import '../models/working_hours.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  
  File? _selectedImage;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    final merchant = Provider.of<AuthProvider>(context, listen: false).merchant;
    _nameController = TextEditingController(text: merchant?.name ?? '');
    _emailController = TextEditingController(text: merchant?.email ?? '');
    _phoneController = TextEditingController(text: merchant?.phone ?? '');
    _addressController = TextEditingController(text: merchant?.address ?? '');
    _descriptionController = TextEditingController(text: merchant?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await UploadService.pickImage(
      source: ImageSource.gallery,
      allowEditing: true,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final publicId = await UploadService.uploadImage(
        _selectedImage!,
        folder: 'zarya/merchant-profiles',
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (publicId != null) {
        // Update merchant profile with new image
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentMerchant = authProvider.merchant;
        if (currentMerchant != null) {
          final updatedMerchant = currentMerchant.copyWith(
            images: [publicId, ...currentMerchant.images],
          );
          await authProvider.updateProfile(updatedMerchant);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image uploaded successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentMerchant = authProvider.merchant;
    
    if (currentMerchant != null) {
      final updatedMerchant = currentMerchant.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final success = await authProvider.updateProfile(updatedMerchant);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to update profile'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final merchant = authProvider.merchant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : merchant?.images.isNotEmpty == true
                                    ? Image.network(
                                        merchant!.images.first,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: AppColors.border,
                                            child: const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: AppColors.textSecondary,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: AppColors.border,
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                          ),
                        ),
                        if (_isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: _uploadProgress / 100,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _isUploading ? null : _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_selectedImage != null && !_isUploading)
                      ElevatedButton.icon(
                        onPressed: _uploadImage,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Upload Image'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Profile Information
              const Text(
                'Business Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Business Category
              const Text(
                'Business Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      merchant?.category ?? 'Salon',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Working Hours
              const Text(
                'Working Hours',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildWorkingHoursList(merchant?.workingHours ?? []),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkingHoursList(List<WorkingHours> workingHours) {
    return Column(
      children: workingHours.map((hours) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  hours.day,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  hours.isOpen
                      ? '${hours.startTime} - ${hours.endTime}'
                      : 'Closed',
                  style: TextStyle(
                    color: hours.isOpen ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hours.isOpen ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
