import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Terms of Service',
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
              'Terms of Service',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Text(
              'By using Road Rescue, you agree to provide accurate vehicle and '
              'location information when requesting assistance. Misuse of the '
              'emergency SOS feature may result in account suspension.\n\n'
              'Service availability depends on your location and the availability '
              'of nearby response partners. Road Rescue is not liable for delays '
              'caused by factors outside our control, including weather, traffic, '
              'or network issues.\n\n'
              'Payment for services rendered must be completed through the app. '
              'Continued use of the app constitutes acceptance of these terms, '
              'which may be updated periodically.',
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}