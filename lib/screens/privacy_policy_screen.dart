import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

/// Shared dark/light hybrid theme tokens — kept in sync with home_screen.dart.
class _RRColors {
  static const canvasTop = Color(0xFF0A1220);
  static const canvasMid = Color(0xFF0F1B30);
  static const canvasBottom = Color(0xFF16233D);
  static const moonlight = Color(0xFF3A4C7A);
  static const mistLavender = Color(0xFF8FA6FF);
  static const beaconAmber = Color(0xFFFFB020);
  static const glassFill = Color(0x14FFFFFF);
  static const glassFillHover = Color(0x1FFFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const glassHighlight = Color(0x4DFFFFFF);
  static const textOnDark = Colors.white;
  static const textMutedOnDark = Color(0xFFA9B4C4);
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _RRCanvas(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _RRColors.beaconAmber.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: _RRColors.beaconAmber.withValues(alpha: 0.3), blurRadius: 14),
                        ],
                      ),
                      child: const Icon(Icons.privacy_tip_outlined, color: _RRColors.beaconAmber, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _GlassPanel(
                  child: const Text(
                    'Road Rescue collects location data, contact information, and vehicle '
                    'details solely to provide breakdown assistance and dispatch nearby '
                    'help. We do not sell your personal data to third parties.\n\n'
                    'Location access is used only during active requests or when the '
                    'Always-on Location setting is enabled by you. You may disable this '
                    'at any time from Settings.\n\n'
                    'We retain request history to improve service quality and for support '
                    'purposes. You can request deletion of your data at any time by '
                    'contacting our support team.',
                    style: TextStyle(fontSize: 14, height: 1.6, color: _RRColors.textMutedOnDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted glass card wrapping body content on a dark canvas.
class _GlassPanel extends StatelessWidget {
  final Widget child;
  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_RRColors.glassFillHover, _RRColors.glassFill],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _RRColors.glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Dark gradient canvas + soft moonlight glows, shared across screens.
class _RRCanvas extends StatelessWidget {
  final Widget child;
  const _RRCanvas({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
          top: -130,
          right: -100,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _RRColors.mistLavender.withValues(alpha: 0.15),
                  _RRColors.mistLavender.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -130,
          left: -110,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _RRColors.beaconAmber.withValues(alpha: 0.07),
                  _RRColors.beaconAmber.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}