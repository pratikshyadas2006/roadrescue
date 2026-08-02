import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:rr/services/session_manager.dart';
import 'package:rr/screens/edit_profile_screen.dart';

/// Same token set as home_screen.dart — kept identical so Profile reads
/// as part of the same app, not a different screen bolted on.
class _RRColors {
  static const canvasTop = Color(0xFF0A1220);
  static const canvasMid = Color(0xFF0F1B30);
  static const canvasBottom = Color(0xFF16233D);
  static const moonlight = Color(0xFF3A4C7A);
  static const mistLavender = Color(0xFF8FA6FF);
  static const beaconAmber = Color(0xFFFFB020);
  static const beaconAmberSoft = Color(0xFFFFD27A);
  static const glassFill = Color(0x14FFFFFF);
  static const glassFillHover = Color(0x1FFFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const glassHighlight = Color(0x4DFFFFFF);
  static const textOnDark = Colors.white;
  static const textMutedOnDark = Color(0xFFA9B4C4);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = "Loading...";
  String email = "Loading...";
  String phone = "Not Available";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = await SessionManager.getUserDetails();
    if (!mounted) return;
    setState(() {
      fullName = user["full_name"] ?? "Unknown";
      email = user["email"] ?? "Unknown";
      phone = user["phone"] ?? "Not Available";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // ---- BASE CANVAS ----
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
          // ---- MOONLIGHT / LIGHT-MIX GLOW ----
          Positioned(
            top: -140,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _RRColors.mistLavender.withValues(alpha: 0.18),
                    _RRColors.moonlight.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _RRColors.beaconAmber.withValues(alpha: 0.08),
                    _RRColors.beaconAmber.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // ---- AVATAR + NAME (glass hero card) ----
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_RRColors.glassFillHover, _RRColors.glassFill],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _RRColors.glassBorder),
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _RRColors.beaconAmber.withValues(alpha: 0.45),
                                    blurRadius: 22,
                                    spreadRadius: 1,
                                  ),
                                ],
                                border: Border.all(color: _RRColors.beaconAmber.withValues(alpha: 0.6), width: 2),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.jpeg',
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(color: _RRColors.textMutedOnDark, fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 13,
                        decoration: BoxDecoration(
                          color: _RRColors.beaconAmber,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ACCOUNT DETAILS',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: _RRColors.textMutedOnDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ---- INFO TILES (glass) ----
                  _InfoTile(icon: Icons.person_outline, glowColor: const Color(0xFF5B8DEF), label: 'Full Name', value: fullName),
                  const SizedBox(height: 12),
                  _InfoTile(icon: Icons.email_outlined, glowColor: const Color(0xFFB388FF), label: 'Email', value: email),
                  const SizedBox(height: 12),
                  _InfoTile(icon: Icons.phone_outlined, glowColor: const Color(0xFF4FC3F7), label: 'Phone', value: phone),
                  const SizedBox(height: 12),
                  _InfoTile(icon: Icons.location_on_outlined, glowColor: AppColors.successGreen, label: 'Location', value: 'Mumbai, India'),

                  const SizedBox(height: 30),

                  // ---- EDIT PROFILE — beacon CTA ----
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _RRColors.beaconAmber.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          );
                          if (updated == true) {
                            loadUser();
                            if (context.mounted) Navigator.pop(context, true);
                          }
                        },
                        icon: const Icon(Icons.edit, color: Color(0xFF0A1220)),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(color: Color(0xFF0A1220), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _RRColors.beaconAmber,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass info row with a colored icon glow and a top sheen line,
/// matching the _FeatureCard treatment on the home dashboard.
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color glowColor;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.glowColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [glowColor.withValues(alpha: 0.10), _RRColors.glassFill],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _RRColors.glassBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: glowColor.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: glowColor.withValues(alpha: 0.35), blurRadius: 12)],
                    ),
                    child: Icon(icon, size: 20, color: glowColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(fontSize: 11.5, color: _RRColors.textMutedOnDark, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: const TextStyle(fontSize: 14.5, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 14,
              right: 14,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, _RRColors.glassHighlight, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}