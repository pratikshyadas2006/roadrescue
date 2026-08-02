import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/screens/home_screen.dart';
import 'package:rr/screens/login_screen.dart';
import 'package:rr/services/session_manager.dart';

/// Shared dark/light hybrid theme tokens — kept in sync with home_screen.dart.
class _RRColors {
  static const canvasTop = Color(0xFF0A1220);
  static const canvasMid = Color(0xFF0F1B30);
  static const canvasBottom = Color(0xFF16233D);
  static const mistLavender = Color(0xFF8FA6FF);
  static const beaconAmber = Color(0xFFFFB020);
  static const glassFill = Color(0x1FFFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const textMutedOnDark = Color(0xFFA9B4C4);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progressValue = 0.0;
  late Timer _progressTimer;
  late Timer _loadingTimer;
  Timer? _navigationTimer;

  String _loadingText = "Loading";

  Future<void> checkLoginStatus() async {
    bool loggedIn = await SessionManager.isLoggedIn();
    print("Splash Screen Logged In:$loggedIn");

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    const int totalTicks = 50;
    const int tickDurationMs = 50;

    _progressTimer = Timer.periodic(
      const Duration(milliseconds: tickDurationMs),
      (timer) {
        if (!mounted) return;

        setState(() {
          if (_progressValue < 1.0) {
            _progressValue += 1.0 / totalTicks;
          } else {
            timer.cancel();
          }
        });
      },
    );

    _loadingTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        if (!mounted) return;

        setState(() {
          switch (_loadingText) {
            case "Loading":
              _loadingText = "Loading.";
              break;
            case "Loading.":
              _loadingText = "Loading..";
              break;
            case "Loading..":
              _loadingText = "Loading...";
              break;
            default:
              _loadingText = "Loading";
          }
        });
      },
    );

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      checkLoginStatus();
    });
  }

  @override
  void dispose() {
    _progressTimer.cancel();
    _loadingTimer.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      body: Stack(
        children: [
          // ---- BASE CANVAS ----
          // Matches the gradient used on every other screen, so the splash
          // doesn't feel like a different app in the half-second before the
          // image paints in.
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
                  colors: [
                    _RRColors.mistLavender.withValues(alpha: 0.14),
                    _RRColors.mistLavender.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/images/newsplash.jpeg',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: _RRColors.glassFill,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _RRColors.glassBorder),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _loadingText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 140,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progressValue,
                                minHeight: 5,
                                backgroundColor: _RRColors.glassBorder,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  _RRColors.beaconAmber,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}