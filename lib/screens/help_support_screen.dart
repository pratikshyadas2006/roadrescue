import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

class _RRColors {
  static const canvasTop = Color(0xFF0A1220);
  static const canvasMid = Color(0xFF0F1B30);
  static const canvasBottom = Color(0xFF16233D);
  static const moonlight = Color(0xFF3A4C7A);
  static const mistLavender = Color(0xFF8FA6FF);
  static const beaconAmber = Color(0xFFFFB020);
  static const glassFill = Color(0x14FFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const glassHighlight = Color(0x4DFFFFFF);
  static const textMutedOnDark = Color(0xFFA9B4C4);
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_RRColors.canvasTop, _RRColors.canvasMid, _RRColors.canvasBottom],
                stops: [0.0, 0.45, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: -140,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_RRColors.mistLavender.withValues(alpha: 0.16), _RRColors.moonlight.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 13,
                      decoration: BoxDecoration(color: _RRColors.beaconAmber, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'FREQUENTLY ASKED QUESTIONS',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: _RRColors.textMutedOnDark),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _faqTile(
                  context,
                  question: 'How do I request a rescue?',
                  answer: 'Tap the SOS button on the home screen. Your live location '
                      'will be shared automatically with the nearest available responder.',
                ),
                _faqTile(
                  context,
                  question: 'How long does help usually take to arrive?',
                  answer: 'Response time depends on your location and responder '
                      'availability, but most requests are picked up within 15-20 minutes.',
                ),
                _faqTile(
                  context,
                  question: 'Can I cancel a request after sending it?',
                  answer: 'Yes, go to your active request screen and tap Cancel Request '
                      'before a responder accepts it.',
                ),
                _faqTile(
                  context,
                  question: 'How do I add emergency contacts?',
                  answer: 'Go to Settings > Manage Emergency Contacts to add or edit '
                      'people who get notified during an SOS.',
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 13,
                      decoration: BoxDecoration(color: _RRColors.beaconAmber, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'STILL NEED HELP?',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: _RRColors.textMutedOnDark),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_RRColors.beaconAmber.withValues(alpha: 0.08), _RRColors.glassFill],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _RRColors.glassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _contactRow(icon: Icons.email_outlined, text: 'support@roadrescue.com'),
                              const SizedBox(height: 14),
                              _contactRow(icon: Icons.phone_outlined, text: '+91 1800-123-456'),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 14,
                          right: 14,
                          child: Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.transparent, _RRColors.glassHighlight, Colors.transparent]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _RRColors.beaconAmber.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _RRColors.beaconAmber, size: 18),
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _faqTile(BuildContext context, {required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: _RRColors.glassFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _RRColors.glassBorder),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: _RRColors.beaconAmber,
                collapsedIconColor: _RRColors.textMutedOnDark,
                title: Text(
                  question,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    answer,
                    style: const TextStyle(fontSize: 13, color: _RRColors.textMutedOnDark, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}