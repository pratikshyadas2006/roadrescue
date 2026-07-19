import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _faqTile(
            question: 'How do I request a rescue?',
            answer: 'Tap the SOS button on the home screen. Your live location '
                'will be shared automatically with the nearest available responder.',
          ),
          _faqTile(
            question: 'How long does help usually take to arrive?',
            answer: 'Response time depends on your location and responder '
                'availability, but most requests are picked up within 15-20 minutes.',
          ),
          _faqTile(
            question: 'Can I cancel a request after sending it?',
            answer: 'Yes, go to your active request screen and tap Cancel Request '
                'before a responder accepts it.',
          ),
          _faqTile(
            question: 'How do I add emergency contacts?',
            answer: 'Go to Settings > Manage Emergency Contacts to add or edit '
                'people who get notified during an SOS.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Still need help?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.email_outlined, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Text('support@roadrescue.com', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Text('+91 1800-123-456', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqTile({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(answer, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }
}