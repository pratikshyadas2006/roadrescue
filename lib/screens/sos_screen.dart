import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rr/services/api_service.dart';
import 'package:rr/services/session_manager.dart';
import 'package:android_intent_plus/android_intent.dart';


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

/// Emergency dial numbers used by the quick-action buttons below.
/// Update these if your deployment targets a different region —
/// currently set to India's ambulance (108), police (100), and
/// fuel/roadside assistance (1033) lines.
class _EmergencyNumbers {
  static const String ambulance = '108';
  static const String police = '100';
  static const String fuel = '1033';
}

/// SOS / Emergency screen.
/// Big central SOS button + quick actions for accidents:
/// call ambulance, call police, quick fuel.
class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool _sosActive = false;

  /// Opens the default SMS app pre-filled with [message], addressed to
  /// every number in [phoneNumbers].
  Future<void> sendSmsViaDefaultApp(
    List<String> phoneNumbers,
    String message,
  ) async {
    final recipients = phoneNumbers.join(',');

    final intent = AndroidIntent(
      action: 'android.intent.action.SENDTO',
      data: 'smsto:$recipients',
      arguments: <String, dynamic>{
        'sms_body': message,
      },
    );

    try {
      await intent.launch();
      print("📱 Opening SMS app for: $recipients");
    } catch (e) {
      print("❌ Could not open SMS app: $e");
    }
  }

  Future<void> _triggerSos() async {
    if (_sosActive) return;

    setState(() => _sosActive = true);

    // 📍 Check location service
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("📍 Please turn on your location."),
          ),
        );
      }
      setState(() => _sosActive = false);
      return;
    }

    // 📍 Check location permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("📍 Location permission is required."),
          ),
        );
      }
      setState(() => _sosActive = false);
      return;
    }

    try {
      // 📍 Get current location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 👤 Get logged-in user
      final user = await SessionManager.getUserDetails();
      final userId = user["user_id"];

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Unable to identify the logged-in user."),
            ),
          );
        }
        setState(() => _sosActive = false);
        return;
      }

      // 👥 Get emergency contacts
      final contactResponse = await ApiService.getEmergencyContacts(
        userId: userId,
      );

      print("👥 Emergency Contacts:");
      print(contactResponse);

      // 🚨 Save SOS to backend
      final sosResponse = await ApiService.sendSos(
        userId: userId,
        latitude: position.latitude,
        longitude: position.longitude,
        locationAddress: "${position.latitude}, ${position.longitude}",
      );

      print("🚨 SOS Response:");
      print(sosResponse);

      // ❌ Check backend result
      if (sosResponse["success"] != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(sosResponse["message"] ?? "Failed to send SOS."),
            ),
          );
        }
        setState(() => _sosActive = false);
        return;
      }

      // 🚨 Emergency message
      final String emergencyMessage = '''
🚨 EMERGENCY ALERT! 🚨

I may need immediate help.

📍 My current location:
https://www.google.com/maps?q=${position.latitude},${position.longitude}

Please contact me or send help immediately.
''';

      // Show a brief location confirmation popup before handing off to SMS
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text(
                "🚨 SOS Activated",
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 50),
                  const SizedBox(height: 15),
                  const Text(
                    "Emergency location detected",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Latitude: ${position.latitude}",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Longitude: ${position.longitude}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Preparing emergency message...",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        );

        await Future.delayed(const Duration(seconds: 4));

        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }

      // 📱 Open SMS app for emergency contacts
      if (contactResponse["success"] == true) {
        final contacts = contactResponse["contacts"];

        if (contacts != null && contacts.isNotEmpty) {
          List<String> phoneNumbers = [];

          for (final contact in contacts) {
            String phoneNumber = contact["phone"].toString().trim();

            // Remove spaces and hyphens
            phoneNumber = phoneNumber.replaceAll(RegExp(r'[\s-]'), '');

            // Add India country code
            if (!phoneNumber.startsWith("+91")) {
              if (phoneNumber.startsWith("91") && phoneNumber.length == 12) {
                phoneNumber = "+$phoneNumber";
              } else {
                phoneNumber = "+91$phoneNumber";
              }
            }

            phoneNumbers.add(phoneNumber);
          }

          // 📱 Open SMS once with ALL emergency contacts
          await sendSmsViaDefaultApp(phoneNumbers, emergencyMessage);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No emergency contacts found.")),
            );
          }
        }
      }

      if (mounted) {
        setState(() => _sosActive = false);
      }
    } catch (e) {
      print("SOS ERROR: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SOS failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _sosActive = false);
      }
    }
  }

  /// Opens the phone's dialer pre-filled with [number]. This only opens
  /// the dialer app (tel: intent) — it does not place the call
  /// automatically, so the user still confirms by tapping "Call" in
  /// their phone app.
  Future<void> _callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    final bool launched = await launchUrl(uri);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open dialer for $number'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Emergency SOS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _RRCanvas(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text(
                  'In case of an accident, tap the button below.\nYour location will be shared instantly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _RRColors.textMutedOnDark),
                ),
                const SizedBox(height: 36),
                GestureDetector(
                  onTap: _triggerSos,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFF6B5B), AppColors.emergencyRed],
                        stops: [0.0, 0.75],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emergencyRed.withValues(alpha: 0.5),
                          blurRadius: 36,
                          spreadRadius: _sosActive ? 14 : 6,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sensors_outlined, color: Colors.white, size: 44),
                        SizedBox(height: 6),
                        Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tap to alert emergency contacts,\nambulance & police',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _RRColors.textMutedOnDark),
                ),
                const SizedBox(height: 36),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.local_hospital_rounded,
                        label: 'Call\nAmbulance',
                        color: AppColors.emergencyRed,
                        onTap: () => _callNumber(_EmergencyNumbers.ambulance),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.local_police_rounded,
                        label: 'Call\nPolice',
                        color: const Color(0xFF7C93B8),
                        onTap: () => _callNumber(_EmergencyNumbers.police),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _QuickActionCard(
                  icon: Icons.local_gas_station_rounded,
                  label: 'Quick Fuel',
                  color: _RRColors.beaconAmber,
                  onTap: () => _callNumber(_EmergencyNumbers.fuel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.12), _RRColors.glassFill],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _RRColors.glassBorder),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 12),
                        ],
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 12,
                right: 12,
                child: Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, _RRColors.glassHighlight, Colors.transparent],
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

/// Retained bottom-sheet confirmation UI. Not currently wired into
/// `_triggerSos` (which now shows an AlertDialog instead), but kept
/// here in case you want to swap the confirmation UI back to this style.
class _SosSentSheet extends StatelessWidget {
  final VoidCallback onClose;
  const _SosSentSheet({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_RRColors.canvasMid, _RRColors.canvasBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(top: BorderSide(color: _RRColors.glassBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.emergencyRed.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.emergencyRed.withValues(alpha: 0.35), blurRadius: 16),
                  ],
                ),
                child: const Icon(Icons.sensors_outlined, color: AppColors.emergencyRed, size: 34),
              ),
              const SizedBox(height: 16),
              const Text(
                'SOS Alert Sent',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your live location has been shared with your\nemergency contacts. Help is on the way.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _RRColors.textMutedOnDark),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _RRColors.beaconAmber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Cancel Alert',
                    style: TextStyle(color: Color(0xFF0A1220), fontWeight: FontWeight.bold),
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
          top: -120,
          left: -100,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _RRColors.mistLavender.withValues(alpha: 0.14),
                  _RRColors.moonlight.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -140,
          right: -110,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.emergencyRed.withValues(alpha: 0.10),
                  AppColors.emergencyRed.withValues(alpha: 0.0),
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