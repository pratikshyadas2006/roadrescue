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

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _features = [
    'Vehicle Breakdown Assistance',
    'SOS Emergency',
    'AI Vehicle Diagnosis',
    'Nearby Services',
    'Live Location Sharing',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("About Road Rescue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _RRCanvas(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFFD27A), _RRColors.beaconAmber, Color(0xFFD98600)],
                      stops: [0.0, 0.55, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(color: _RRColors.beaconAmber.withValues(alpha: 0.5), blurRadius: 24),
                    ],
                  ),
                  child: const Icon(Icons.car_repair, size: 46, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Road Rescue",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Version 1.0",
                textAlign: TextAlign.center,
                style: TextStyle(color: _RRColors.textMutedOnDark),
              ),

              const SizedBox(height: 22),

              _GlassPanel(
                child: const Text(
                  "Road Rescue is a Smart Vehicle Breakdown Assistance System developed to help users during vehicle emergencies. The application provides nearby mechanics, hospitals, police stations, fuel pumps, emergency contacts, AI vehicle issue diagnosis, and an SOS emergency feature.",
                  style: TextStyle(fontSize: 14.5, height: 1.55, color: _RRColors.textMutedOnDark),
                  textAlign: TextAlign.justify,
                ),
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _RRColors.beaconAmber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Key Features",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ..._features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FeatureRow(label: f),
                  )),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  "Developed by Road Rescue Team",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _RRColors.beaconAmber,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  const _FeatureRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _RRColors.glassFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _RRColors.glassBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.successGreen, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ],
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