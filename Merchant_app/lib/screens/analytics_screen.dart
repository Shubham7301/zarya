import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantId = authProvider.merchant?.id ?? '1';
      
      // Load sample analytics data for demo
      _stats = _getSampleAnalytics();
      
      // TODO: Replace with real API call
      // final stats = await ApiService.getDashboardStats(
      //   merchantId,
      //   authProvider.token,
      //   startDate: _getStartDate(),
      //   endDate: DateTime.now(),
      // );
      // _stats = stats;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: $e'),
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

  Map<String, dynamic> _getSampleAnalytics() {
    return {
      'totalRevenue': 12500.0,
      'totalAppointments': 156,
      'completedAppointments': 142,
      'cancelledAppointments': 8,
      'pendingAppointments': 6,
      'averageRating': 4.8,
      'totalCustomers': 89,
      'newCustomers': 23,
      'repeatCustomers': 66,
      'topServices': [
        {'name': 'Haircut & Styling', 'count': 45, 'revenue': 2025.0},
        {'name': 'Facial Treatment', 'count': 32, 'revenue': 1920.0},
        {'name': 'Manicure & Pedicure', 'count': 28, 'revenue': 980.0},
        {'name': 'Hair Coloring', 'count': 18, 'revenue': 1440.0},
        {'name': 'Massage Therapy', 'count': 15, 'revenue': 1050.0},
      ],
      'revenueByDay': [
        {'day': 'Mon', 'revenue': 1800.0},
        {'day': 'Tue', 'revenue': 2100.0},
        {'day': 'Wed', 'revenue': 1950.0},
        {'day': 'Thu', 'revenue': 2200.0},
        {'day': 'Fri', 'revenue': 2400.0},
        {'day': 'Sat', 'revenue': 1800.0},
        {'day': 'Sun', 'revenue': 250.0},
      ],
      'appointmentsByStatus': [
        {'status': 'Completed', 'count': 142, 'color': AppColors.completed},
        {'status': 'Pending', 'count': 6, 'color': AppColors.pending},
        {'status': 'Cancelled', 'count': 8, 'color': AppColors.cancelled},
      ],
      'customerGrowth': [
        {'month': 'Jan', 'customers': 45},
        {'month': 'Feb', 'customers': 52},
        {'month': 'Mar', 'customers': 58},
        {'month': 'Apr', 'customers': 63},
        {'month': 'May', 'customers': 71},
        {'month': 'Jun', 'customers': 78},
        {'month': 'Jul', 'customers': 89},
      ],
    };
  }

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'week':
        return now.subtract(const Duration(days: 7));
      case 'month':
        return DateTime(now.year, now.month - 1, now.day);
      case 'quarter':
        return DateTime(now.year, now.month - 3, now.day);
      case 'year':
        return DateTime(now.year - 1, now.month, now.day);
      default:
        return now.subtract(const Duration(days: 7));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Revenue'),
            Tab(text: 'Customers'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
              _loadAnalytics();
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildRevenueTab(),
                _buildCustomersTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
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
                'Total Revenue',
                '\$${_stats['totalRevenue']?.toStringAsFixed(0) ?? '0'}',
                Icons.attach_money,
                AppColors.success,
              ),
              _buildMetricCard(
                'Total Appointments',
                '${_stats['totalAppointments'] ?? 0}',
                Icons.schedule,
                AppColors.primary,
              ),
              _buildMetricCard(
                'Completed',
                '${_stats['completedAppointments'] ?? 0}',
                Icons.check_circle,
                AppColors.completed,
              ),
              _buildMetricCard(
                'Average Rating',
                '${_stats['averageRating']?.toStringAsFixed(1) ?? '0.0'}',
                Icons.star,
                AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Top Services
          const Text(
            'Top Services',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildTopServicesList(),
          const SizedBox(height: 24),

          // Appointments by Status
          const Text(
            'Appointments by Status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildAppointmentsStatusChart(),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    final revenueData = _stats['revenueByDay'] as List<dynamic>? ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Chart
          const Text(
            'Daily Revenue',
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
            child: _buildRevenueChart(revenueData),
          ),
          const SizedBox(height: 24),

          // Revenue Breakdown
          const Text(
            'Revenue Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildRevenueBreakdown(),
        ],
      ),
    );
  }

  Widget _buildCustomersTab() {
    final customerData = _stats['customerGrowth'] as List<dynamic>? ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Growth Chart
          const Text(
            'Customer Growth',
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
            child: _buildCustomerGrowthChart(customerData),
          ),
          const SizedBox(height: 24),

          // Customer Statistics
          const Text(
            'Customer Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomerStats(),
        ],
      ),
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

  Widget _buildTopServicesList() {
    final topServices = _stats['topServices'] as List<dynamic>? ?? [];
    
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
        itemCount: topServices.length,
        itemBuilder: (context, index) {
          final service = topServices[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              service['name'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              '${service['count'] ?? 0} appointments',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Text(
              '\$${service['revenue']?.toStringAsFixed(0) ?? '0'}',
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

  Widget _buildAppointmentsStatusChart() {
    final statusData = _stats['appointmentsByStatus'] as List<dynamic>? ?? [];
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
        children: statusData.map<Widget>((item) {
          final percentage = total > 0 ? (item['count'] as int) / total : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item['color'] ?? AppColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['status'] ?? '',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${item['count'] ?? 0}',
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

  Widget _buildRevenueChart(List<dynamic> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No revenue data available',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final maxRevenue = data.fold<double>(
      0.0,
      (max, item) {
        final revenue = (item['revenue'] as double?) ?? 0.0;
        return revenue > max ? revenue : max;
      },
    );

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map<Widget>((item) {
              final revenue = (item['revenue'] as double?) ?? 0.0;
              final height = maxRevenue > 0 ? revenue / maxRevenue : 0.0;
              
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
                      item['day'] ?? '',
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
          'Revenue: \$${data.fold<double>(0.0, (sum, item) => sum + ((item['revenue'] as double?) ?? 0.0)).toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueBreakdown() {
    final topServices = _stats['topServices'] as List<dynamic>? ?? [];
    final totalRevenue = _stats['totalRevenue'] as double? ?? 0.0;
    
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
        itemCount: topServices.length,
        itemBuilder: (context, index) {
          final service = topServices[index];
          final revenue = (service['revenue'] as double?) ?? 0.0;
          final percentage = totalRevenue > 0 ? revenue / totalRevenue : 0.0;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getServiceColor(index),
              child: Text(
                service['name']?.substring(0, 1) ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              service['name'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_getServiceColor(index)),
            ),
            trailing: Text(
              '\$${revenue.toStringAsFixed(0)}',
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

  Widget _buildCustomerGrowthChart(List<dynamic> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No customer data available',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final maxCustomers = data.fold<int>(
      0,
      (max, item) {
        final customers = (item['customers'] as int?) ?? 0;
        return customers > max ? customers : max;
      },
    );

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map<Widget>((item) {
              final customers = (item['customers'] as int?) ?? 0;
              final height = maxCustomers > 0 ? customers / maxCustomers : 0.0;
              
              return Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          heightFactor: height,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['month'] ?? '',
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
          'Total Customers: ${data.last['customers'] ?? 0}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Total Customers',
          '${_stats['totalCustomers'] ?? 0}',
          Icons.people,
          AppColors.primary,
        ),
        _buildMetricCard(
          'New Customers',
          '${_stats['newCustomers'] ?? 0}',
          Icons.person_add,
          AppColors.success,
        ),
        _buildMetricCard(
          'Repeat Customers',
          '${_stats['repeatCustomers'] ?? 0}',
          Icons.repeat,
          AppColors.secondary,
        ),
        _buildMetricCard(
          'Retention Rate',
          '${_stats['totalCustomers'] != null && _stats['totalCustomers'] > 0 ? ((_stats['repeatCustomers'] ?? 0) / _stats['totalCustomers'] * 100).toStringAsFixed(1) : '0.0'}%',
          Icons.trending_up,
          AppColors.warning,
        ),
      ],
    );
  }

  Color _getServiceColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
    ];
    return colors[index % colors.length];
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
        return 'Last Week';
    }
  }
}
