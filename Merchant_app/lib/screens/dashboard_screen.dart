import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/web_notification_service.dart';
import '../services/cloudinary_realtime_service.dart';
import '../models/notification_data.dart';
import '../utils/app_colors.dart';
import 'profile_screen.dart';
import 'services_screen.dart';
import 'appointments_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  StreamSubscription<NotificationData>? _notificationSubscription;

  final List<Widget> _screens = [
    const DashboardHome(),
    const AppointmentsScreen(),
    const ServicesScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    CloudinaryRealtimeService.disconnect();
    super.dispose();
  }

  void _initializeNotifications() async {
    // Initialize Cloudinary real-time service
    await CloudinaryRealtimeService.initialize();
    await CloudinaryRealtimeService.connect();
    
    // Get current merchant
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final merchant = authProvider.merchant;
    
    if (merchant != null && authProvider.token != null) {
      // Subscribe to merchant-specific updates
      await CloudinaryRealtimeService.subscribe('merchant_updates', merchantId: merchant.id!);
      await CloudinaryRealtimeService.subscribe('subscription_updates', merchantId: merchant.id!);
      
      // Listen for real-time data updates
      CloudinaryRealtimeService.dataStream.listen((update) {
        if (mounted) {
          _handleRealtimeUpdate(update);
        }
      });
      
      // Listen for notifications
      _notificationSubscription = CloudinaryRealtimeService.notificationStream.listen((notification) {
        if (mounted) {
          WebNotificationService.showInAppNotification(context, notification);
        }
      });
    }
  }

  void _handleRealtimeUpdate(Map<String, dynamic> update) {
    final type = update['type'];
    
    switch (type) {
      case 'merchant_update':
        // Handle merchant profile updates
        print('Merchant profile updated: ${update['action']}');
        break;
      case 'subscription_update':
        // Handle subscription updates
        print('Subscription updated: ${update['action']}');
        break;
      case 'admin_action':
        // Handle admin actions
        print('Admin action: ${update['action']}');
        break;
      default:
        print('Unknown update type: $type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final merchant = authProvider.merchant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await authProvider.logout();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    merchant?.name ?? 'Merchant',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    merchant?.category ?? 'Business',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            const Text(
              'Today\'s Overview',
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
                _buildStatCard(
                  'Pending',
                  '5',
                  Icons.schedule,
                  AppColors.pending,
                ),
                _buildStatCard(
                  'Confirmed',
                  '12',
                  Icons.check_circle,
                  AppColors.confirmed,
                ),
                _buildStatCard(
                  'Completed',
                  '8',
                  Icons.done_all,
                  AppColors.completed,
                ),
                _buildStatCard(
                  'Revenue',
                  '\$1,250',
                  Icons.attach_money,
                  AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
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
              childAspectRatio: 1.2,
              children: [
                _buildActionCard(
                  'Add Service',
                  Icons.add_circle_outline,
                  AppColors.primary,
                  () {
                    // TODO: Navigate to add service
                  },
                ),
                _buildActionCard(
                  'View Calendar',
                  Icons.calendar_month,
                  AppColors.secondary,
                  () {
                    // TODO: Navigate to calendar
                  },
                ),
                _buildActionCard(
                  'Upload Images',
                  Icons.photo_library,
                  AppColors.info,
                  () {
                    // TODO: Navigate to image upload
                  },
                ),
                _buildActionCard(
                  'Settings',
                  Icons.settings,
                  AppColors.textSecondary,
                  () {
                    // TODO: Navigate to settings
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Appointments
            const Text(
              'Recent Appointments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentAppointments(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildRecentAppointments() {
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
        children: [
          _buildAppointmentItem(
            'John Doe',
            'Haircut',
            '10:00 AM',
            AppColors.confirmed,
          ),
          const Divider(),
          _buildAppointmentItem(
            'Jane Smith',
            'Manicure',
            '11:30 AM',
            AppColors.pending,
          ),
          const Divider(),
          _buildAppointmentItem(
            'Mike Johnson',
            'Facial',
            '2:00 PM',
            AppColors.completed,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(
    String customerName,
    String service,
    String time,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  service,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
