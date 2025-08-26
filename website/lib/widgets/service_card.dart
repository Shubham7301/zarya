import 'package:flutter/material.dart';
import '../models/service.dart';
import '../utils/app_colors.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onBookPressed;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onBookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Service Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppColors.primaryGradient,
                  ),
                  child: service.images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            service.images.first,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          ),
                        )
                      : _buildPlaceholder(),
                ),
                const SizedBox(width: 16),

                // Service Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.access_time,
                            text: service.formattedDuration,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            icon: Icons.attach_money,
                            text: service.formattedPrice,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (service.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                service.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: service.isActive ? onBookPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: service.isActive 
                      ? AppColors.primary 
                      : AppColors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  service.isActive ? 'Book Now' : 'Unavailable',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: AppColors.primaryGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.spa,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
