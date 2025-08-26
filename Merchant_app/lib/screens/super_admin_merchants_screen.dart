import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/super_admin_provider.dart';
import '../models/merchant.dart';
import '../utils/app_colors.dart';
import 'super_admin_add_merchant_screen.dart';
import 'super_admin_subscription_screen.dart';

class SuperAdminMerchantsScreen extends StatefulWidget {
  const SuperAdminMerchantsScreen({super.key});

  @override
  State<SuperAdminMerchantsScreen> createState() => _SuperAdminMerchantsScreenState();
}

class _SuperAdminMerchantsScreenState extends State<SuperAdminMerchantsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedStatus = 'all';
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Merchant> get _filteredMerchants {
    final adminProvider = Provider.of<SuperAdminProvider>(context, listen: false);
    List<Merchant> merchants = adminProvider.merchants;

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      merchants = merchants.where((merchant) {
        return merchant.name.toLowerCase().contains(searchTerm) ||
               merchant.ownerName.toLowerCase().contains(searchTerm) ||
               merchant.email.toLowerCase().contains(searchTerm) ||
               merchant.category.toLowerCase().contains(searchTerm);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'all') {
      merchants = merchants.where((merchant) => merchant.category == _selectedCategory).toList();
    }

    // Filter by status
    if (_selectedStatus != 'all') {
      switch (_selectedStatus) {
        case 'active':
          merchants = merchants.where((merchant) => merchant.isActive).toList();
          break;
        case 'inactive':
          merchants = merchants.where((merchant) => !merchant.isActive).toList();
          break;
      }
    }

    return merchants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search merchants...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('All Categories')),
                          const DropdownMenuItem(value: 'salon', child: Text('Salon')),
                          const DropdownMenuItem(value: 'spa', child: Text('Spa')),
                          const DropdownMenuItem(value: 'clinic', child: Text('Clinic')),
                          const DropdownMenuItem(value: 'fitness', child: Text('Fitness')),
                          const DropdownMenuItem(value: 'other', child: Text('Other')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('All Status')),
                          const DropdownMenuItem(value: 'active', child: Text('Active')),
                          const DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Merchants List
          Expanded(
            child: _filteredMerchants.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No merchants found',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredMerchants.length,
                    itemBuilder: (context, index) {
                      final merchant = _filteredMerchants[index];
                      return _MerchantCard(
                        merchant: merchant,
                        onEdit: () => _editMerchant(merchant),
                        onToggleStatus: () => _toggleMerchantStatus(merchant),
                        onViewDetails: () => _viewMerchantDetails(merchant),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMerchant,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _addNewMerchant() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SuperAdminAddMerchantScreen(),
      ),
    );

    if (result == true) {
      // Refresh the merchants list
      final adminProvider = Provider.of<SuperAdminProvider>(context, listen: false);
      // The provider will automatically update the UI
    }
  }

  void _editMerchant(Merchant merchant) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuperAdminAddMerchantScreen(merchant: merchant),
      ),
    );

    if (result == true) {
      // The provider will automatically update the UI
    }
  }

  Future<void> _toggleMerchantStatus(Merchant merchant) async {
    final adminProvider = Provider.of<SuperAdminProvider>(context, listen: false);
    final success = await adminProvider.toggleMerchantStatus(merchant.id!);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${merchant.name} ${merchant.isActive ? 'deactivated' : 'activated'} successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.error ?? 'Failed to update merchant status'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _viewMerchantDetails(Merchant merchant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MerchantDetailsSheet(merchant: merchant),
    );
  }
}

class _MerchantCard extends StatelessWidget {
  final Merchant merchant;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onViewDetails;

  const _MerchantCard({
    required this.merchant,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onViewDetails,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'salon':
        return Colors.pink;
      case 'spa':
        return Colors.green;
      case 'clinic':
        return Colors.blue;
      case 'fitness':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onViewDetails,
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
                          merchant.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Owner: ${merchant.ownerName}',
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
                      color: merchant.isActive
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: merchant.isActive ? AppColors.success : AppColors.error,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      merchant.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: merchant.isActive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(merchant.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getCategoryColor(merchant.category),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      merchant.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getCategoryColor(merchant.category),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM dd, yyyy').format(merchant.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      merchant.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    merchant.phone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onToggleStatus,
                      child: Text(merchant.isActive ? 'Deactivate' : 'Activate'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Edit'),
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
}

class _MerchantDetailsSheet extends StatelessWidget {
  final Merchant merchant;

  const _MerchantDetailsSheet({required this.merchant});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                    'Merchant Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DetailRow('Business Name', merchant.name),
                  _DetailRow('Owner Name', merchant.ownerName),
                  _DetailRow('Email', merchant.email),
                  _DetailRow('Phone', merchant.phone),
                  _DetailRow('Address', merchant.address),
                  _DetailRow('Category', merchant.category.toUpperCase()),
                  _DetailRow('Status', merchant.isActive ? 'Active' : 'Inactive'),
                  _DetailRow('Description', merchant.description),
                  _DetailRow('Created', DateFormat('EEEE, MMMM dd, yyyy').format(merchant.createdAt)),
                  if (merchant.updatedAt != null)
                    _DetailRow('Last Updated', DateFormat('EEEE, MMMM dd, yyyy').format(merchant.updatedAt!)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                                             Expanded(
                         child: ElevatedButton.icon(
                           onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => SuperAdminSubscriptionScreen(merchant: merchant),
                               ),
                             );
                           },
                           icon: const Icon(Icons.subscriptions),
                           label: const Text('View Subscription'),
                         ),
                       ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: View analytics
                          },
                          icon: const Icon(Icons.analytics),
                          label: const Text('View Analytics'),
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
            width: 100,
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
