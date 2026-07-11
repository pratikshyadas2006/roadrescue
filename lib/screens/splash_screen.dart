import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rr/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progressValue = 0.0;
  late Timer _progressTimer;
  late Timer _loadingTimer;

  String _loadingText = "Loading";

  @override
  void initState() {
    super.initState();

    const int totalTicks = 50;
    const int tickDurationMs = 50;

    _progressTimer = Timer.periodic(
      const Duration(milliseconds: tickDurationMs),
      (timer) {
        setState(() {
          if (_progressValue < 1.0) {
            _progressValue += 1.0 / totalTicks;
          } else {
            _progressTimer.cancel();
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

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _progressTimer.cancel();
    _loadingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F3A),
      body: Stack(
        children: [
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
                Text(
                  _loadingText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 140,
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE53935),
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