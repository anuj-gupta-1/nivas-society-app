import 'package:flutter/material.dart';
import 'package:nivas/utils/constants.dart';

/// Verification pending screen
/// 
/// Final step: User waits for admin approval
class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                Icons.hourglass_empty,
                size: 100,
                color: Color(AppColors.warning),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Verification Pending',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                'Your registration has been submitted successfully!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'An admin will review your details and verify your ownership. You will be notified once approved.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color(AppColors.textSecondary),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Info Cards
              _buildInfoCard(
                context,
                icon: Icons.access_time,
                title: 'Verification Time',
                description: 'Usually takes 24-48 hours',
              ),
              
              const SizedBox(height: 16),
              
              _buildInfoCard(
                context,
                icon: Icons.notifications_active,
                title: 'Stay Updated',
                description: 'You\'ll receive a notification once verified',
              ),
              
              const SizedBox(height: 16),
              
              _buildInfoCard(
                context,
                icon: Icons.visibility,
                title: 'Read-Only Access',
                description: 'You can view discussions while waiting',
              ),
              
              const SizedBox(height: 48),
              
              // Close Button
              OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to read-only home screen
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Browse Community',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Color(AppColors.primaryBlue),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Color(AppColors.textSecondary),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
