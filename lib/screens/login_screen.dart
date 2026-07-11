import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        title: const Text(
          'Road Rescue',
          style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: AppColors.secondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Welcome Banner Block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello Driver,',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'How can we help you today?',
                    style: TextStyle(color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            // Dashboard Menu Items Scroll Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFeatureCard(
                      title: '🛡️ Enable Road Rescue',
                      subtitle: 'Activate live journey protection monitoring',
                      iconColor: AppColors.successGreen, // Fixed variable name
                      borderColor: AppColors.successGreen, // Fixed variable name
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureCard(
                      title: '🚗 Vehicle Breakdown',
                      subtitle: 'Flat tyre, dead battery, engine problems...',
                      iconColor: AppColors.primary,
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureCard(
                      title: '🚨 SOS Emergency',
                      subtitle: 'Immediate rescue, accidents & direct alerts',
                      iconColor: AppColors.emergencyRed, // Fixed variable name
                      borderColor: AppColors.emergencyRed, // Fixed variable name
                      bgColor: AppColors.emergencyRed.withOpacity(0.05), // Fixed variable name
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureCard(
                      title: '🤖 AI Diagnosis',
                      subtitle: 'Troubleshoot issues instantly with ChatGPT AI',
                      iconColor: Colors.purple,
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureCard(
                      title: '📍 Nearby Services',
                      subtitle: 'Find mechanics, towing services, pumps & more',
                      iconColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            
            // Dynamic Branding Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo icon + Text Side by Side
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.minor_crash_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Road Rescue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Login Button on the right hand side
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required Color iconColor,
    Color? borderColor,
    Color? bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.border, width: borderColor != null ? 1.5 : 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: iconColor, size: 14),
      ),
    );
  }
}