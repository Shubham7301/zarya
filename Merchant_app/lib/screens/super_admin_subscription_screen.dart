import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/super_admin_provider.dart';
import '../models/merchant.dart';
import '../models/merchant_subscription.dart';
import '../utils/app_colors.dart';

class SuperAdminSubscriptionScreen extends StatefulWidget {
  final Merchant merchant;

  const SuperAdminSubscriptionScreen({super.key, required this.merchant});

  @override
  State<SuperAdminSubscriptionScreen> createState() => _SuperAdminSubscriptionScreenState();
}

class _SuperAdminSubscriptionScreenState extends State<SuperAdminSubscriptionScreen> {
  MerchantSubscription? _subscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  void _loadSubscription() {
    final adminProvider = Provider.of<SuperAdminProvider>(context, listen: false);
    _subscription = adminProvider.subscriptions
        .where((sub) => sub.merchantId == widget.merchant.id)
        .firstOrNull;
  }

  Future<void> _renewSubscription() async {
    if (_subscription == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement subscription renewal
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription renewed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to renew subscription: $e'),
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

  Future<void> _cancelSubscription() async {
    if (_subscription == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel this subscription? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Implement subscription cancellation
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription cancelled successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel subscription: $e'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription - ${widget.merchant.businessName}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subscription == null
              ? _buildNoSubscription()
              : _buildSubscriptionDetails(),
    );
  }

  Widget _buildNoSubscription() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Subscription Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This merchant does not have an active subscription.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to create subscription
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Subscription'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails() {
    final subscription = _subscription!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subscription Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(subscription.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getStatusIcon(subscription.status),
                          color: _getStatusColor(subscription.status),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.planDisplayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              subscription.statusDisplayName,
                              style: TextStyle(
                                color: _getStatusColor(subscription.status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Amount', subscription.formattedAmount),
                  _buildInfoRow('Duration', '${subscription.durationInMonths} months'),
                  _buildInfoRow('Start Date', DateFormat('MMM dd, yyyy').format(subscription.startDate)),
                  _buildInfoRow('End Date', DateFormat('MMM dd, yyyy').format(subscription.endDate)),
                  if (subscription.daysRemaining > 0)
                    _buildInfoRow('Days Remaining', '${subscription.daysRemaining} days'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Progress Bar
          if (subscription.daysRemaining > 0) ...[
            const Text(
              'Subscription Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 1 - (subscription.daysRemaining / subscription.durationInMonths / 30),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(subscription.status)),
            ),
            const SizedBox(height: 8),
            Text(
              '${((1 - (subscription.daysRemaining / subscription.durationInMonths / 30)) * 100).toStringAsFixed(1)}% used',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Actions
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          if (subscription.status == SubscriptionStatus.active) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _renewSubscription,
                icon: const Icon(Icons.refresh),
                label: const Text('Renew Subscription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _cancelSubscription,
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Subscription'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Payment Information
          if (subscription.paymentMethod != null || subscription.transactionId != null) ...[
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (subscription.paymentMethod != null)
                      _buildInfoRow('Payment Method', subscription.paymentMethod!),
                    if (subscription.transactionId != null)
                      _buildInfoRow('Transaction ID', subscription.transactionId!),
                    _buildInfoRow('Created', DateFormat('MMM dd, yyyy HH:mm').format(subscription.createdAt)),
                  ],
                ),
              ),
            ),
          ],

          // Notes
          if (subscription.notes != null && subscription.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Text(
                subscription.notes!,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.expired:
        return AppColors.warning;
      case SubscriptionStatus.suspended:
        return AppColors.error;
      case SubscriptionStatus.pending:
        return AppColors.info;
      case SubscriptionStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Icons.check_circle;
      case SubscriptionStatus.expired:
        return Icons.warning;
      case SubscriptionStatus.suspended:
        return Icons.block;
      case SubscriptionStatus.pending:
        return Icons.schedule;
      case SubscriptionStatus.cancelled:
        return Icons.cancel;
    }
  }
}
