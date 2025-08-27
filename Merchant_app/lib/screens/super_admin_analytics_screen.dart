import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/super_admin_provider.dart';
import '../utils/app_colors.dart';

class SuperAdminAnalyticsScreen extends StatefulWidget {
  const SuperAdminAnalyticsScreen({super.key});

  @override
  State<SuperAdminAnalyticsScreen> createState() => _SuperAdminAnalyticsScreenState();
}

class _SuperAdminAnalyticsScreenState extends State<SuperAdminAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Merchants'),
            Tab(text: 'Revenue'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'week', child: Text('Last Week')),
              const PopupMenuItem(value: 'month', child: Text('Last Month')),
              const PopupMenuItem(value: 'quarter', child: Text('Last Quarter')),
              const PopupMenuItem(value: 'year', child: Text('Last Year')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getPeriodDisplayName(_selectedPeriod)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildMerchantsTab(),
          _buildRevenueTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<SuperAdminProvider>(
      builder: (context, adminProvider, child) {
        final analytics = adminProvider.analytics;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Key Metrics
              const Text(
                'Key Metrics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildMetricCard(
                    'Total Merchants',
                    '${analytics['totalMerchants'] ?? 0}',
                    Icons.business,
                    AppColors.primary,
                  ),
                  _buildMetricCard(
                    'Active Merchants',
                    '${analytics['activeMerchants'] ?? 0}',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                  _buildMetricCard(
                    'Expired Merchants',
                    '${analytics['expiredMerchants'] ?? 0}',
                    Icons.warning,
                    AppColors.warning,
                  ),
                  _buildMetricCard(
                    'Total Revenue',
                    '\$${NumberFormat('#,###').format(analytics['totalRevenue'] ?? 0)}',
                    Icons.attach_money,
                    AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category Distribution
              const Text(
                'Category Distribution',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoryDistributionChart(analytics['categoryDistribution'] ?? {}),
              const SizedBox(height: 24),

              // Subscription Plans
              const Text(
                'Subscription Plans',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildSubscriptionPlansChart(analytics['subscriptionPlans'] ?? {}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMerchantsTab() {
    return Consumer<SuperAdminProvider>(
      builder: (context, adminProvider, child) {
        final merchants = adminProvider.merchants;
        final analytics = adminProvider.analytics;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Merchant Growth Chart
              const Text(
                'Merchant Growth',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildMerchantGrowthChart(),
              ),
              const SizedBox(height: 24),

              // Merchant Status Distribution
              const Text(
                'Merchant Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildMerchantStatusChart(analytics),
              const SizedBox(height: 24),

              // Top Categories
              const Text(
                'Top Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildTopCategoriesList(analytics['categoryDistribution'] ?? {}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueTab() {
    return Consumer<SuperAdminProvider>(
      builder: (context, adminProvider, child) {
        final analytics = adminProvider.analytics;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue Overview
              const Text(
                'Revenue Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildRevenueChart(),
              ),
              const SizedBox(height: 24),

              // Revenue by Category
              const Text(
                'Revenue by Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildRevenueByCategoryChart(),
              const SizedBox(height: 24),

              // Subscription Revenue
              const Text(
                'Subscription Revenue',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildSubscriptionRevenueChart(analytics['subscriptionPlans'] ?? {}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: AppColors.success,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistributionChart(Map<String, dynamic> categoryData) {
    final total = categoryData.values.fold<int>(0, (sum, value) => sum + (value as int));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: categoryData.entries.map((entry) {
          final percentage = total > 0 ? (entry.value as int) / total : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubscriptionPlansChart(Map<String, dynamic> planData) {
    final total = planData.values.fold<int>(0, (sum, value) => sum + (value as int));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: planData.entries.map((entry) {
          final percentage = total > 0 ? (entry.value as int) / total : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getPlanColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMerchantGrowthChart() {
    // Mock data for merchant growth
    final data = [
      {'month': 'Jan', 'merchants': 45},
      {'month': 'Feb', 'merchants': 52},
      {'month': 'Mar', 'merchants': 58},
      {'month': 'Apr', 'merchants': 63},
      {'month': 'May', 'merchants': 71},
      {'month': 'Jun', 'merchants': 78},
      {'month': 'Jul', 'merchants': 89},
    ];

    final maxMerchants = data.fold<int>(0, (max, item) => (item['merchants'] as int) > max ? (item['merchants'] as int) : max);

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((item) {
              final merchants = item['merchants'] as int;
              final height = maxMerchants > 0 ? merchants / maxMerchants : 0.0;
              
              return Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          heightFactor: height,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['month'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Total Merchants: ${data.last['merchants']}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMerchantStatusChart(Map<String, dynamic> analytics) {
    final statusData = [
      {'status': 'Active', 'count': analytics['activeMerchants'] ?? 0, 'color': AppColors.success},
      {'status': 'Expired', 'count': analytics['expiredMerchants'] ?? 0, 'color': AppColors.warning},
      {'status': 'Suspended', 'count': analytics['suspendedMerchants'] ?? 0, 'color': AppColors.error},
    ];

    final total = statusData.fold<int>(0, (sum, item) => sum + (item['count'] as int));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: statusData.map((item) {
          final percentage = total > 0 ? (item['count'] as int) / total : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['status'] as String,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${item['count']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopCategoriesList(Map<String, dynamic> categoryData) {
    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedCategories.length,
        itemBuilder: (context, index) {
          final entry = sortedCategories[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(entry.key).withOpacity(0.1),
              child: Text(
                entry.key.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: _getCategoryColor(entry.key),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              entry.key.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              '${entry.value} merchants',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Text(
              '${((entry.value as int) / categoryData.values.fold<int>(0, (sum, value) => sum + (value as int)) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevenueChart() {
    // Mock revenue data
    final data = [
      {'month': 'Jan', 'revenue': 15000.0},
      {'month': 'Feb', 'revenue': 18000.0},
      {'month': 'Mar', 'revenue': 22000.0},
      {'month': 'Apr', 'revenue': 25000.0},
      {'month': 'May', 'revenue': 28000.0},
      {'month': 'Jun', 'revenue': 32000.0},
      {'month': 'Jul', 'revenue': 35000.0},
    ];

    final maxRevenue = data.fold<double>(0.0, (max, item) => (item['revenue'] as double) > max ? (item['revenue'] as double) : max);

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((item) {
              final revenue = item['revenue'] as double;
              final height = maxRevenue > 0 ? revenue / maxRevenue : 0.0;
              
              return Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          heightFactor: height,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['month'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Total Revenue: \$${NumberFormat('#,###').format(data.fold<double>(0.0, (sum, item) => sum + (item['revenue'] as double)))}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueByCategoryChart() {
    // Mock revenue by category data
    final data = [
      {'category': 'Salon', 'revenue': 45000.0},
      {'category': 'Spa', 'revenue': 32000.0},
      {'category': 'Clinic', 'revenue': 28000.0},
      {'category': 'Fitness', 'revenue': 20000.0},
    ];

    final totalRevenue = data.fold<double>(0.0, (sum, item) => sum + (item['revenue'] as double));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          final percentage = totalRevenue > 0 ? (item['revenue'] as double) / totalRevenue : 0.0;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(item['category'] as String).withOpacity(0.1),
              child: Text(
                (item['category'] as String).substring(0, 1),
                style: TextStyle(
                  color: _getCategoryColor(item['category'] as String),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              item['category'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor(item['category'] as String)),
            ),
            trailing: Text(
              '\$${NumberFormat('#,###').format(item['revenue'])}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionRevenueChart(Map<String, dynamic> planData) {
    // Mock subscription revenue data
    final data = [
      {'plan': 'Basic', 'revenue': 45000.0, 'count': planData['basic'] ?? 0},
      {'plan': 'Premium', 'revenue': 60000.0, 'count': planData['premium'] ?? 0},
      {'plan': 'Enterprise', 'revenue': 20000.0, 'count': planData['enterprise'] ?? 0},
    ];

    final totalRevenue = data.fold<double>(0.0, (sum, item) => sum + (item['revenue'] as double));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          final percentage = totalRevenue > 0 ? (item['revenue'] as double) / totalRevenue : 0.0;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPlanColor(item['plan'] as String).withOpacity(0.1),
              child: Text(
                (item['plan'] as String).substring(0, 1),
                style: TextStyle(
                  color: _getPlanColor(item['plan'] as String),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${item['plan']} Plan',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              '${item['count']} subscribers',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Text(
              '\$${NumberFormat('#,###').format(item['revenue'])}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
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

  Color _getPlanColor(String plan) {
    switch (plan.toLowerCase()) {
      case 'basic':
        return AppColors.primary;
      case 'premium':
        return AppColors.secondary;
      case 'enterprise':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getPeriodDisplayName(String period) {
    switch (period) {
      case 'week':
        return 'Last Week';
      case 'month':
        return 'Last Month';
      case 'quarter':
        return 'Last Quarter';
      case 'year':
        return 'Last Year';
      default:
        return 'Last Month';
    }
  }
}
