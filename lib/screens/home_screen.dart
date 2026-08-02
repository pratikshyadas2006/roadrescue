import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'request_history_screen.dart';
import 'emergency_contacts_screen.dart';
import 'settings_screen.dart';
import 'vehicle_breakdown_screen.dart';
import 'sos_screen.dart';
import 'ai_diagnosis_screen.dart';
import 'nearby_services_screen.dart';
import 'package:rr/services/session_manager.dart';

/// Dark/light hybrid theme tokens.
/// The canvas stays dark (night-highway navy-black), but now carries a
/// soft "moonlight" glow bleeding down from the top and a cool lavender
/// mist behind the hero — the light half of the mix — while glass cards
/// keep their frosted, sheened look on top. Recommend promoting into
/// app_colors.dart once approved.
class _RRColors {
  static const canvasTop = Color(0xFF0A1220);
  static const canvasMid = Color(0xFF0F1B30);
  static const canvasBottom = Color(0xFF16233D);
  static const moonlight = Color(0xFF3A4C7A); // cool light-mix glow, used sparingly
  static const mistLavender = Color(0xFF8FA6FF);
  static const beaconAmber = Color(0xFFFFB020);
  static const beaconAmberSoft = Color(0xFFFFD27A);
  static const glassFill = Color(0x14FFFFFF); // white @ ~8%
  static const glassFillHover = Color(0x1FFFFFFF); // white @ ~12%
  static const glassBorder = Color(0x26FFFFFF); // white @ ~15%
  static const glassHighlight = Color(0x4DFFFFFF); // white @ ~30%, top edge sheen
  static const textOnDark = Colors.white;
  static const textMutedOnDark = Color(0xFFA9B4C4);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Login";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = await SessionManager.getUserDetails();
    if (!mounted) return;
    setState(() {
      userName = user["full_name"] ?? "Login";
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 21) return 'Good evening';
    return 'Good night';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 48,
        title: Row(
          children: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _RRColors.beaconAmber.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.jpeg',
                  width: 26,
                  height: 26,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Road Rescue',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: SizedBox(
                  height: 32,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _RRColors.beaconAmber.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                        if (updated == true) loadUser();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: _RRColors.beaconAmber,
                        foregroundColor: const Color(0xFF0A1220),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        userName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: _RRColors.canvasTop,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_RRColors.canvasTop, _RRColors.canvasBottom],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _RRColors.beaconAmber.withValues(alpha: 0.4),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.jpeg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Road Rescue',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Drive Safe. We\'re Here.',
                    style: TextStyle(color: _RRColors.textMutedOnDark, fontSize: 13),
                  ),
                ],
              ),
            ),
            _drawerTile(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () async {
                Navigator.pop(context);
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
                if (updated == true) loadUser();
              },
            ),
            const Divider(color: _RRColors.glassBorder, height: 1),
            _drawerTile(
              icon: Icons.history,
              label: 'Request History',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RequestHistoryScreen()),
                );
              },
            ),
            _drawerTile(
              icon: Icons.contact_phone_outlined,
              label: 'Emergency Contacts',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmergencyContactsScreen()),
                );
              },
            ),
            _drawerTile(
              icon: Icons.notifications_none,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            const Divider(color: _RRColors.glassBorder, height: 1),
            _drawerTile(
              icon: Icons.logout,
              label: 'Logout',
              iconColor: AppColors.emergencyRed,
              labelColor: AppColors.emergencyRed,
              onTap: () async {
                await SessionManager.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
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
          // A soft, cool wash bleeding down from the top-right — this is the
          // "light" half of the dark/light mix: a faint source of light on
          // an otherwise dark canvas, like a highway sign glowing overhead.
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- GREETING ----
                  Text(
                    '${_getGreeting()}, Driver'.toUpperCase(),
                    style: const TextStyle(
                      color: _RRColors.textMutedOnDark,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Ready for a safer journey?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.6)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.successGreen.withValues(alpha: 0.25),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, color: AppColors.successGreen, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'Ready',
                              style: TextStyle(
                                color: AppColors.successGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const _RoadDivider(),
                  const SizedBox(height: 22),

                  // ---- HERO CTA: Enable Road Rescue ----
                  _EnableRoadRescueCard(onTap: () {}),

                  const SizedBox(height: 28),

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
                        'QUICK ACTIONS',
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

                  // ---- FEATURE GRID ----
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.02,
                    children: [
                      _FeatureCard(
                        title: 'Vehicle Breakdown',
                        subtitle: 'Tyre, battery, engine & more',
                        icon: Icons.car_repair_rounded,
                        glowColor: const Color(0xFF5B8DEF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const VehicleBreakdownScreen()),
                          );
                        },
                      ),
                      _FeatureCard(
                        title: 'SOS',
                        subtitle: 'Immediate emergency alert',
                        icon: Icons.sensors_outlined,
                        glowColor: AppColors.emergencyRed,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SosScreen()),
                          );
                        },
                      ),
                      _FeatureCard(
                        title: 'AI Diagnosis',
                        subtitle: 'Describe the issue, get help',
                        icon: Icons.psychology_alt_outlined,
                        glowColor: const Color(0xFFB388FF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AiDiagnosisScreen()),
                          );
                        },
                      ),
                      _FeatureCard(
                        title: 'Nearby Services',
                        subtitle: 'Garages, fuel, hospitals & more',
                        icon: Icons.location_on_outlined,
                        glowColor: const Color(0xFF4FC3F7),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NearbyServicesScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.white70,
    Color labelColor = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(color: labelColor)),
      onTap: onTap,
    );
  }
}

/// Dashed road-marking motif — glows softly against the dark canvas,
/// the way a lane line catches headlight glow at night.
class _RoadDivider extends StatelessWidget {
  const _RoadDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(24, (i) {
        return Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i.isEven ? _RRColors.beaconAmber.withValues(alpha: 0.7) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: i.isEven
                  ? [
                      BoxShadow(
                        color: _RRColors.beaconAmber.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

/// Frosted-glass hero CTA with a glowing beacon-amber halo and a top
/// sheen line — the one unmistakably bright element on an otherwise
/// dark, quiet screen, with a light "glass catching light" edge.
class _EnableRoadRescueCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EnableRoadRescueCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _RRColors.beaconAmber.withValues(alpha: 0.35),
            blurRadius: 32,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _RRColors.glassFillHover,
                        _RRColors.glassFill,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _RRColors.beaconAmber.withValues(alpha: 0.55), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const RadialGradient(
                            colors: [_RRColors.beaconAmberSoft, _RRColors.beaconAmber, Color(0xFFD98600)],
                            stops: [0.0, 0.55, 1.0],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _RRColors.beaconAmber.withValues(alpha: 0.6),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enable Road Rescue',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.1,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Turn on live protection for this trip',
                              style: TextStyle(fontSize: 12.5, color: _RRColors.textMutedOnDark),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: _RRColors.beaconAmber, size: 26),
                    ],
                  ),
                ),
                // Glass "light catching the edge" sheen — a thin bright
                // line along the top, the light half of the dark/light mix.
                Positioned(
                  top: 0,
                  left: 18,
                  right: 18,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          _RRColors.glassHighlight,
                          Colors.transparent,
                        ],
                      ),
                    ),
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

/// Frosted-glass feature tile with a colored glow behind its icon and a
/// faint tinted wash across the card body — each module keeps its own
/// accent identity, softly lit against the dark canvas instead of
/// sitting on a flat white card.
class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color glowColor;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      glowColor.withValues(alpha: 0.10),
                      _RRColors.glassFill,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _RRColors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: glowColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: glowColor.withValues(alpha: 0.35), blurRadius: 14),
                        ],
                      ),
                      child: Icon(icon, size: 23, color: glowColor),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: _RRColors.textMutedOnDark, height: 1.25),
                    ),
                  ],
                ),
              ),
              // Thin light sheen along the top edge of every tile.
              Positioned(
                top: 0,
                left: 14,
                right: 14,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _RRColors.glassHighlight,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}