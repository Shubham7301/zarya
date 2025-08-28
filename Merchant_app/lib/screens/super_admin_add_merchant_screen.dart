import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/super_admin_provider.dart';
import '../models/merchant.dart';
import '../models/merchant_subscription.dart';
import '../utils/app_colors.dart';

class SuperAdminAddMerchantScreen extends StatefulWidget {
  final Merchant? merchant; // For editing existing merchant

  const SuperAdminAddMerchantScreen({super.key, this.merchant});

  @override
  State<SuperAdminAddMerchantScreen> createState() => _SuperAdminAddMerchantScreenState();
}

class _SuperAdminAddMerchantScreenState extends State<SuperAdminAddMerchantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedCategory = 'salon';
  SubscriptionPlan _selectedPlan = SubscriptionPlan.basic;
  int _selectedDuration = 3; // months
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.merchant != null) {
      _businessNameController.text = widget.merchant!.businessName;
      _ownerNameController.text = widget.merchant!.ownerName;
      _emailController.text = widget.merchant!.email;
      _phoneController.text = widget.merchant!.phone;
      _addressController.text = widget.merchant!.address;
      _descriptionController.text = widget.merchant!.description;
      _selectedCategory = widget.merchant!.category;
      _isActive = widget.merchant!.isActive;
      _passwordController.text = '********'; // Placeholder for existing password
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveMerchant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final adminProvider = Provider.of<SuperAdminProvider>(context, listen: false);
      
             final merchantData = {
         'businessName': _businessNameController.text.trim(),
         'ownerName': _ownerNameController.text.trim(),
         'email': _emailController.text.trim(),
         'phone': _phoneController.text.trim(),
         'address': _addressController.text.trim(),
         'description': _descriptionController.text.trim(),
         'category': _selectedCategory,
         'password': widget.merchant == null ? _passwordController.text : null,
         'isActive': _isActive,
         'subscriptionPlan': _selectedPlan.name,
         'subscriptionDuration': _selectedPlan == SubscriptionPlan.freeTrial ? 1 : _selectedDuration,
       };

      bool success;
      if (widget.merchant != null) {
        success = await adminProvider.updateMerchant(widget.merchant!.id!, merchantData);
      } else {
        final merchant = await adminProvider.createMerchant(merchantData);
        success = merchant != null;
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.merchant != null 
                ? 'Merchant updated successfully!' 
                : 'Merchant created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminProvider.error ?? 'Failed to save merchant'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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

  double _getPlanPrice(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.freeTrial:
        return 0.0;
      case SubscriptionPlan.basic:
        return 2500.0;
      case SubscriptionPlan.premium:
        return 5000.0;
      case SubscriptionPlan.enterprise:
        return 8500.0;
    }
  }

  String _getPlanDescription(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.freeTrial:
        return '30-day free trial with full features';
      case SubscriptionPlan.basic:
        return 'Basic features for small businesses';
      case SubscriptionPlan.premium:
        return 'Advanced features with priority support';
      case SubscriptionPlan.enterprise:
        return 'Full features with dedicated support';
      default:
        return 'Unknown plan';
    }
  }

  String _getPlanDisplayName(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.freeTrial:
        return 'Free Trial';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.merchant != null ? 'Edit Merchant' : 'Add New Merchant'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
            )
          else
            TextButton(
              onPressed: _saveMerchant,
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
              // Business Information Section
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
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Owner Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter owner name';
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
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
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

              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
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
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'salon', child: Text('Salon')),
                  DropdownMenuItem(value: 'spa', child: Text('Spa')),
                  DropdownMenuItem(value: 'clinic', child: Text('Clinic')),
                  DropdownMenuItem(value: 'fitness', child: Text('Fitness')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Authentication Section
              const Text(
                'Authentication',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              if (widget.merchant == null)
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: AppColors.info),
                      SizedBox(width: 8),
                      Text(
                        'Password cannot be changed here. Use merchant login to change password.',
                        style: TextStyle(color: AppColors.info),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Subscription Section
              const Text(
                'Subscription Plan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Subscription Plan Cards
              ...SubscriptionPlan.values.map((plan) {
                final isSelected = _selectedPlan == plan;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPlan = plan;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Radio<SubscriptionPlan>(
                            value: plan,
                            groupValue: _selectedPlan,
                            onChanged: (value) {
                              setState(() {
                                _selectedPlan = value!;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                                                 Text(
                                   _getPlanDisplayName(plan),
                                   style: const TextStyle(
                                     fontSize: 18,
                                     fontWeight: FontWeight.bold,
                                     color: AppColors.textPrimary,
                                   ),
                                 ),
                                const SizedBox(height: 4),
                                Text(
                                  _getPlanDescription(plan),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\₹${_getPlanPrice(plan).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Text(
                                'per month',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),

                             // Duration Selection
               const Text(
                 'Subscription Duration',
                 style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.bold,
                   color: AppColors.textPrimary,
                 ),
               ),
               const SizedBox(height: 8),
               DropdownButtonFormField<int>(
                 value: _selectedDuration,
                 decoration: const InputDecoration(
                   labelText: 'Duration',
                   border: OutlineInputBorder(),
                 ),
                 items: [
                   if (_selectedPlan == SubscriptionPlan.freeTrial)
                     const DropdownMenuItem(value: 1, child: Text('30 Days (Free Trial)')),
                   const DropdownMenuItem(value: 3, child: Text('3 Months')),
                   const DropdownMenuItem(value: 6, child: Text('6 Months')),
                   const DropdownMenuItem(value: 12, child: Text('12 Months')),
                 ],
                 onChanged: (value) {
                   setState(() {
                     _selectedDuration = value!;
                   });
                 },
               ),
              const SizedBox(height: 16),

              // Total Cost Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Cost:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                                         Text(
                       _selectedPlan == SubscriptionPlan.freeTrial 
                           ? 'FREE' 
                           : '\₹${(_getPlanPrice(_selectedPlan) * _selectedDuration).toStringAsFixed(2)}',
                       style: TextStyle(
                         fontSize: 20,
                         fontWeight: FontWeight.bold,
                         color: _selectedPlan == SubscriptionPlan.freeTrial 
                             ? AppColors.primary 
                             : AppColors.success,
                       ),
                     ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Status Section
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Make this merchant active immediately'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                activeColor: AppColors.success,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMerchant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.merchant != null ? 'Update Merchant' : 'Create Merchant',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
