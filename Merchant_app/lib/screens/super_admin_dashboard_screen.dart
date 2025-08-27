import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/super_admin_provider.dart';
import '../models/merchant.dart';
import '../utils/app_colors.dart';
import 'create_merchant_screen.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Consumer<SuperAdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                    Tab(icon: Icon(Icons.business), text: 'Merchants'),
                    Tab(icon: Icon(Icons.subscriptions), text: 'Subscriptions'),
                    Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
                  ],
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(provider),
                    _buildMerchantsTab(provider),
                    _buildSubscriptionsTab(provider),
                    _buildAnalyticsTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(SuperAdminProvider provider) {
    final analytics = provider.analytics;
    final dashboardData = provider.dashboardData;
    
    // Add null safety checks
    if (analytics.isEmpty || dashboardData.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Total Merchants',
                '${provider.totalMerchantsCount}',
                Icons.business,
                Colors.blue,
              ),
              _buildStatCard(
                'Active Merchants',
                '${provider.activeMerchantsCount}',
                Icons.pending,
                Colors.green,
              ),
              _buildStatCard(
                'Pending Approval',
                '${provider.pendingMerchantsCount}',
                Icons.pending,
                Colors.orange,
              ),
              _buildStatCard(
                'Total Revenue',
                '\$${analytics['totalRevenue'] ?? 0}',
                Icons.attach_money,
                Colors.purple,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...((dashboardData['recentActivity'] as List?) ?? []).map((activity) => 
                    ListTile(
                      leading: Icon(
                        _getActivityIcon(activity['type'] ?? ''),
                        color: _getActivityColor(activity['type'] ?? ''),
                      ),
                      title: Text(activity['message'] ?? ''),
                      subtitle: Text(activity['time'] ?? ''),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // System Health
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Health',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSystemHealthItem('Uptime', dashboardData['systemHealth']?['uptime'] ?? 'Unknown', Colors.green),
                  _buildSystemHealthItem('Active Users', '${dashboardData['systemHealth']?['activeUsers'] ?? 0}', Colors.blue),
                  _buildSystemHealthItem('Server Load', dashboardData['systemHealth']?['serverLoad'] ?? 'Unknown', Colors.orange),
                  _buildSystemHealthItem('Last Backup', dashboardData['systemHealth']?['lastBackup'] ?? 'Unknown', Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantsTab(SuperAdminProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Merchants Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateMerchantDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Merchant'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildMerchantStatCard(
                  'Total',
                  '${provider.totalMerchantsCount}',
                  Icons.business,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMerchantStatCard(
                  'Active',
                  '${provider.activeMerchantsCount}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMerchantStatCard(
                  'Pending',
                  '${provider.pendingMerchantsCount}',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Merchants List
          Text(
            'All Merchants',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...provider.merchants.map((merchant) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(merchant.status),
                child: Text(
                  merchant.businessName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                merchant.businessName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Owner: ${merchant.ownerName}'),
                  Text('Email: ${merchant.email}'),
                  Text('Category: ${merchant.businessType}'),
                  Text('City: ${merchant.city}'),
                  Text(
                    'Status: ${merchant.status}',
                    style: TextStyle(
                      color: _getStatusColor(merchant.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleMerchantAction(value, merchant.id ?? ''),
                itemBuilder: (context) => [
                  if (merchant.status == 'pending')
                    const PopupMenuItem(
                      value: 'approve',
                      child: Text('Approve'),
                    ),
                  if (merchant.status == 'active')
                    const PopupMenuItem(
                      value: 'suspend',
                      child: Text('Suspend'),
                    ),
                  if (merchant.status == 'suspended')
                    const PopupMenuItem(
                      value: 'activate',
                      child: Text('Activate'),
                    ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsTab(SuperAdminProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...provider.subscriptions.map((subscription) {
            final merchant = provider.merchants.firstWhere(
              (m) => m.id == subscription.merchantId,
              orElse: () => Merchant(
                id: '',
                businessName: 'Unknown',
                ownerName: '',
                email: '',
                phone: '',
                address: '',
                city: '',
                businessType: '',
                status: '',
                description: '',
                category: '',
                images: [],
                workingHours: [],
                isActive: false,
                createdAt: DateTime.now(),
              ),
            );
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(subscription.status.name),
                  child: const Icon(
                    Icons.subscriptions,
                    color: Colors.white,
                  ),
                ),
                title: Text(subscription.planName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(merchant.businessName),
                                          Text('\$${subscription.amount}/month'),
                      Text('Status: ${subscription.status.name}'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _handleSubscriptionAction(value, subscription.id),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'activate',
                      child: Text('Activate'),
                    ),
                    const PopupMenuItem(
                      value: 'suspend',
                      child: Text('Suspend'),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(SuperAdminProvider provider) {
    final analytics = provider.analytics;
    
    // Add null safety checks
    if (analytics.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Growth Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Growth',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${analytics['monthlyGrowth'] ?? 0}%',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Business Types Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Types',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...((analytics['topBusinessTypes'] as List?) ?? []).map((type) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.business, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(type.toString()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Subscription Plans
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription Plans',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...((analytics['subscriptionPlans'] as Map?) ?? {}).entries.map((entry) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key.toString()),
                          Text('${entry.value}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealthItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'new_merchant':
        return Icons.person_add;
      case 'subscription_renewal':
        return Icons.refresh;
      case 'payment_received':
        return Icons.payment;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'new_merchant':
        return Colors.green;
      case 'subscription_renewal':
        return Colors.blue;
      case 'payment_received':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleMerchantAction(String action, String merchantId) {
    final provider = Provider.of<SuperAdminProvider>(context, listen: false);
    
    switch (action) {
      case 'approve':
        provider.toggleMerchantStatus(merchantId, true);
        break;
      case 'suspend':
        provider.toggleMerchantStatus(merchantId, false);
        break;
      case 'activate':
        provider.toggleMerchantStatus(merchantId, true);
        break;
      case 'edit':
        // TODO: Implement edit merchant
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit feature coming soon!')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(merchantId);
        break;
    }
  }

  void _showDeleteConfirmation(String merchantId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Merchant'),
          content: const Text('Are you sure you want to delete this merchant account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final provider = Provider.of<SuperAdminProvider>(context, listen: false);
                provider.deleteMerchant(merchantId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Merchant deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateMerchantDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateMerchantScreen(),
      ),
    ).then((created) {
      if (created == true) {
        // Refresh the merchants list
        final provider = Provider.of<SuperAdminProvider>(context, listen: false);
        provider.initialize();
      }
    });
  }

  void _handleSubscriptionAction(String action, String subscriptionId) {
    final provider = context.read<SuperAdminProvider>();
    
    switch (action) {
      case 'activate':
        provider.updateSubscriptionStatus(subscriptionId, 'active');
        break;
      case 'suspend':
        provider.updateSubscriptionStatus(subscriptionId, 'suspended');
        break;
      case 'cancel':
        provider.updateSubscriptionStatus(subscriptionId, 'cancelled');
        break;
    }
  }

  void _handleLogout(BuildContext context) {
    context.read<SuperAdminProvider>().logout();
    Navigator.pushReplacementNamed(context, '/');
  }
}
