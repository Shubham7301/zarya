import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/appointment_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/recent_appointments_list.dart';
import '../widgets/quick_actions.dart';
import '../utils/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.merchant?.id != null) {
      final appointmentProvider = context.read<AppointmentProvider>();
      appointmentProvider.loadTodayAppointments(authProvider.merchant!.id!);
      appointmentProvider.loadDashboardStats(authProvider.merchant!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadDashboardData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),

                // Stats Cards
                _buildStatsSection(),

                // Quick Actions
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: QuickActions(),
                ),

                // Today's Appointments
                _buildTodayAppointments(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final merchant = authProvider.merchant;
        final isOpen = authProvider.isCurrentlyOpen();
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          merchant?.name ?? 'Merchant',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isOpen 
                          ? AppColors.success.withOpacity(0.2)
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isOpen ? AppColors.success : Colors.white,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isOpen ? AppColors.success : Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            color: isOpen ? AppColors.success : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Date
              Text(
                DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final stats = provider.dashboardStats;
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Total',
                      value: stats['total']?.toString() ?? '0',
                      icon: Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Pending',
                      value: stats['pending']?.toString() ?? '0',
                      icon: Icons.schedule,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Confirmed',
                      value: stats['confirmed']?.toString() ?? '0',
                      icon: Icons.check_circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Revenue',
                      value: '\$${stats['revenue']?.toStringAsFixed(0) ?? '0'}',
                      icon: Icons.attach_money,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayAppointments() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Today\'s Appointments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to appointments screen
                  DefaultTabController.of(context)?.animateTo(1);
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          const RecentAppointmentsList(),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
