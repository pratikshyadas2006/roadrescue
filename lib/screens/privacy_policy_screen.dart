import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Text(
              'Road Rescue collects location data, contact information, and vehicle '
              'details solely to provide breakdown assistance and dispatch nearby '
              'help. We do not sell your personal data to third parties.\n\n'
              'Location access is used only during active requests or when the '
              'Always-on Location setting is enabled by you. You may disable this '
              'at any time from Settings.\n\n'
              'We retain request history to improve service quality and for support '
              'purposes. You can request deletion of your data at any time by '
              'contacting our support team.',
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}