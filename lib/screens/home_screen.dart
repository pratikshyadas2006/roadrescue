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
import 'map_screen.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:rr/screens/notifications_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rr/services/api_service.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';

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
  bool roadRescueEnabled = false;
  double acceleration = 0.0;
double rotation = 0.0;
bool accidentDetected = false;
bool isMonitoring = false;
Timer? accidentTimer;
int countdown = 15;
final AudioPlayer emergencyPlayer = AudioPlayer();

StreamSubscription<UserAccelerometerEvent>? accelerometerSubscription;
StreamSubscription<GyroscopeEvent>? gyroscopeSubscription;

bool impactDetected = false;
Timer? impactTimer;

double maxAcceleration = 0.0;
double maxRotation = 0.0;

int abnormalAccelerationCount = 0;
int abnormalRotationCount = 0;

void startSensorMonitoring() {
  // Prevent duplicate sensor listeners
  accelerometerSubscription?.cancel();
  gyroscopeSubscription?.cancel();

  accelerometerSubscription = userAccelerometerEventStream().listen((event) {
    final value = sqrt(
      event.x * event.x +
          event.y * event.y +
          event.z * event.z,
    );

    if (!mounted) return;

    setState(() {
      acceleration = value;
debugPrint("Acceleration:$value");
      if (impactDetected) {
  if (value > maxAcceleration) {
    maxAcceleration = value;
  }

  if (value >= 12.0) {
    abnormalAccelerationCount++;
  }
}

detectImpact(value);

    
    });

    // Stage 1 will be added here next
  });

  gyroscopeSubscription = gyroscopeEventStream().listen((event) {
    final value = sqrt(
      event.x * event.x +
          event.y * event.y +
          event.z * event.z,
    );

    if (!mounted) return;

   setState(() {
  rotation = value;
});

if (impactDetected) {
  if (value > maxRotation) {
    maxRotation = value;
  }

  if (value >= 4.5) {
    abnormalRotationCount++;
  }
}

debugPrint("Rotation: $value");

    // Stage 2 will use this value next
  });
}



void stopSensorMonitoring() {
  accelerometerSubscription?.cancel();
  gyroscopeSubscription?.cancel();

  accelerometerSubscription = null;
  gyroscopeSubscription = null;

  impactTimer?.cancel();
  impactTimer = null;

  impactDetected = false;

  debugPrint("🛑 Sensor monitoring stopped");
}


void detectImpact(double accelerationValue) {
  if (impactDetected || accidentDetected || !roadRescueEnabled) {
    return;
  }

  const double impactThreshold = 18.0;

  if (accelerationValue >= impactThreshold) {
    impactDetected = true;

    maxAcceleration = accelerationValue;
    maxRotation = 0.0;

    abnormalAccelerationCount = 1;
    abnormalRotationCount = 0;

    debugPrint("🚨 STAGE 1 STARTED");
    debugPrint("Initial Impact: $accelerationValue");

    impactTimer?.cancel();

    impactTimer = Timer(
      const Duration(milliseconds: 1500),
      () {
        if (!mounted) return;

        debugPrint("⏱ Confirmation Window Finished");

        debugPrint("Max Acceleration: $maxAcceleration");
        debugPrint("Max Rotation: $maxRotation");
        debugPrint(
          "Acceleration Events: $abnormalAccelerationCount",
        );
        debugPrint(
          "Rotation Events: $abnormalRotationCount",
        );

        const double rotationThreshold = 5.0;

        bool crashConfirmed =
            maxAcceleration >= 18.0 &&
            maxRotation >= rotationThreshold &&
            abnormalAccelerationCount >= 2;

        impactDetected = false;
        impactTimer = null;

        if (crashConfirmed) {
          debugPrint("✅ STAGE 2 CONFIRMED");

          detectPossibleAccident();
        } else {
          debugPrint("❌ Movement ignored");
        }
      },
    );
  }
}

void detectPossibleAccident() {
  if (accidentDetected) return;

  setState(() {
    accidentDetected = true;
    countdown = 15;
  });

  emergencyPlayer.setReleaseMode(ReleaseMode.loop);
  emergencyPlayer.play(
    AssetSource('audio/emergency_alert.mp3'),
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          if (accidentTimer == null || !accidentTimer!.isActive) {
            accidentTimer = Timer.periodic(
              const Duration(seconds: 1),
              (timer) {
                if (!mounted) {
                  timer.cancel();
                  return;
                }

                if (countdown > 1) {
                  setDialogState(() {
                    countdown--;
                  });
                } else {
                  timer.cancel();
                  accidentTimer = null;

                  emergencyPlayer.stop();

                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop();
                  }

                  setState(() {
                    accidentDetected = false;
                  });

                showEmergencyDetailsThenSend();
                }
              },
            );
          }

          return AlertDialog(
            title: const Text(
              "🚨 Possible Accident Detected",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "We detected a sudden impact or unusual movement.",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                const Text(
                  "Are you okay?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "$countdown",
                  style: const TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),

                const Text(
                  "seconds remaining",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () {
                  accidentTimer?.cancel();
                  accidentTimer = null;

                  emergencyPlayer.stop();

                  setState(() {
                    accidentDetected = false;
                    countdown = 15;
                  });

                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  "I'M OKAY",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  accidentTimer?.cancel();
                  accidentTimer = null;

                  emergencyPlayer.stop();

                  Navigator.pop(dialogContext);

                  setState(() {
                    accidentDetected = false;
                  });

                  showEmergencyDetailsThenSend();
                },
                child: const Text("SEND HELP"),
              ),
            ],
          );
        },
      );
    },
  );
}
Future<void> sendSmsViaDefaultApp(
  String phoneNumber,
  String message,
) async {
  final intent = AndroidIntent(
    action: 'android.intent.action.SENDTO',
    data: 'smsto:$phoneNumber',
    arguments: <String, dynamic>{
      'sms_body': message,
    },
  );

  try {
    await intent.launch();
    print("📱 Opening default SMS app for: $phoneNumber");
  } catch (e) {
    print("❌ Could not open SMS app: $e");
  }
}

Future<void> showEmergencyDetailsThenSend() async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const AlertDialog(
        title: Text(
          "🚨 Emergency Alert",
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 50,
            ),

            SizedBox(height: 15),

            Text(
              "Possible accident detected!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 15),

            Text(
              "📡 Sudden impact detected by sensors",
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8),

            Text(
              "📍 Location detected",
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8),

            Text(
              "Opening emergency messages...",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );

  // Wait for 4 seconds
  await Future.delayed(const Duration(seconds: 4));

  // Close this popup
  if (mounted && Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }

  // Start emergency process
  await handleEmergency();
}

Future<void> handleEmergency() async {

  print("🚨 HANDLE EMERGENCY STARTED");

  final Telephony telephony = Telephony.instance;

print("📱 Requesting SMS permission...");

final smsPermission = await Permission.sms.request();

print("📱 SMS Permission Status: $smsPermission");

if (!smsPermission.isGranted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("SMS permission is required."),
    ),
  );
  return;
}
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("📍 Please turn on your phone's location."),
      ),
    );
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("📍 Location permission is required."),
      ),
    );
    return;
  }

  Position position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );

  print("📍 Emergency Location");
  print("Latitude: ${position.latitude}");
  print("Longitude: ${position.longitude}");

  final String emergencyMessage = '''
🚨 EMERGENCY ALERT! 🚨

A possible accident has been detected.

I may need immediate help.

📍 My current location:
https://www.google.com/maps?q=${position.latitude},${position.longitude}

Please contact me or send help immediately.
''';
  // 👥 Get logged-in user's ID
final user = await SessionManager.getUserDetails();
final userId = user["user_id"];

if (userId == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Unable to identify the logged-in user."),
    ),
  );
  return;
}

// 👥 Get emergency contacts
final contactResponse = await ApiService.getEmergencyContacts(
  userId: userId,
);

print("👥 Emergency Contacts Response:");
print(contactResponse); 
if (contactResponse["success"] == true) {
  final contacts = contactResponse["contacts"];

  for (final contact in contacts) {
    String phoneNumber = contact["phone"].toString().trim();

    // Remove spaces and hyphens
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[\s-]'), '');

    // Add India country code if needed
    if (!phoneNumber.startsWith("+91")) {
      if (phoneNumber.startsWith("91") && phoneNumber.length == 12) {
        phoneNumber = "+$phoneNumber";
      } else {
        phoneNumber = "+91$phoneNumber";
      }
    }

    print("📱 Attempting SMS to: $phoneNumber");
await sendSmsViaDefaultApp(
  phoneNumber,
  emergencyMessage,
);
  }
}
// 🚨 Send emergency alert to backend

final sosResponse = await ApiService.sendSos(
  userId: userId,
  latitude: position.latitude,
  longitude: position.longitude,
  locationAddress:
      "${position.latitude}, ${position.longitude}",
);

print("🚨 SOS Response:");
print(sosResponse);

  showDialog(
  context: context,
  barrierDismissible: false,
  builder: (dialogContext) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Wrap(
  spacing: 8,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: const [
    Icon(
      Icons.check_circle,
      color: Colors.green,
    ),
    Text(
      "Emergency Alert Sent",
      style: TextStyle(
        fontWeight: FontWeight.bold,           
         ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Your emergency request has been successfully sent.",
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  "EMERGENCY LOCATION",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "${position.latitude}, ${position.longitude}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const Row(
  children: [
    const Icon(
      Icons.check_circle,
      color: Colors.green,
    ),

    const SizedBox(width: 10),

    Expanded(
      child: Text(
        "SOS request recorded successfully",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
          },
          child: const Text("OK"),
        ),
      ],
    );
  },
);
}

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
          IconButton(
    icon: const Icon(
      Icons.notifications_outlined,
      color: Colors.white,
      size: 22,
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationsScreen(),
        ),
      );
    },
  ),
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
                  _EnableRoadRescueCard(
                    enabled: roadRescueEnabled,
                    onTap: () {
  setState(() {
  roadRescueEnabled = !roadRescueEnabled;
});

if (roadRescueEnabled) {
  startSensorMonitoring();
} else {
  stopSensorMonitoring();
}

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        roadRescueEnabled
            ? "🟢 Road Rescue Enabled"
            : "⚪ Road Rescue Disabled",
      ),
    ),
  );
},
                  ),
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
                            MaterialPageRoute(builder: (context) => const MapScreen()),
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
                  : [],
            ),
          ),
        );
      }),
    );
  }
}

class _EnableRoadRescueCard extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _EnableRoadRescueCard({
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: enabled ? _RRColors.beaconAmber.withValues(alpha: 0.15) : _RRColors.glassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled ? _RRColors.beaconAmber : _RRColors.glassBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: enabled ? _RRColors.beaconAmber.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              enabled ? Icons.directions_car_rounded : Icons.shield,
              color: enabled ? _RRColors.beaconAmber : _RRColors.textMutedOnDark,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enabled ? 'Road Rescue Active' : 'Enable Road Rescue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    enabled ? 'Monitoring active for roadside assistance' : 'Tap to toggle rapid response coverage',
                    style: const TextStyle(
                      color: _RRColors.textMutedOnDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: (_) => onTap(),
              activeColor: _RRColors.beaconAmber,
            ),
          ],
        ),
      ),
    );
  }
}



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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _RRColors.glassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _RRColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: glowColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: glowColor, size: 22),
                ),
                const Icon(Icons.arrow_forward_ios, color: _RRColors.textMutedOnDark, size: 12),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _RRColors.textMutedOnDark,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
 
}