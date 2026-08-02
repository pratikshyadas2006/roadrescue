import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:rr/services/api_service.dart';
import 'package:rr/services/session_manager.dart'; // Ensure this matches your path

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

class RequestHistoryScreen extends StatefulWidget {
  const RequestHistoryScreen({super.key});

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _requests = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserHistory();
  }

  Future<void> _loadUserHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Fetch user ID dynamically from session manager (adjust method name if needed, e.g., getUserId())
    final user = await SessionManager.getUserDetails();
final userId = user["user_id"];

    if (userId == null || userId == 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not logged in';
      });
      return;
    }

    final response = await ApiService.getBreakdownHistory(userId: userId);

    setState(() {
      _isLoading = false;
      if (response['success'] == true) {
        _requests = response['history'] ?? [];
      } else {
        _errorMessage = response['message'] ?? 'Failed to load history';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Request History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _RRCanvas(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: _RRColors.beaconAmber))
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(_errorMessage, style: const TextStyle(color: AppColors.emergencyRed, fontSize: 16)),
                      ),
                    )
                  : _requests.isEmpty
                      ? const Center(
                          child: Text(
                            "No breakdown requests found.",
                            style: TextStyle(fontSize: 16, color: _RRColors.textMutedOnDark),
                          ),
                        )
                      : RefreshIndicator(
                          color: _RRColors.beaconAmber,
                          backgroundColor: _RRColors.canvasMid,
                          onRefresh: _loadUserHistory,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: _requests.length,
                            itemBuilder: (context, index) {
                              final item = _requests[index];
                              final status = item['status'] ?? 'pending';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _HistoryCard(
                                  title: item['issue_type'] ?? 'Issue',
                                  vehicle: item['vehicle_type'] ?? 'Vehicle',
                                  status: status,
                                  date: item['created_at'] ?? '',
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String vehicle;
  final String status;
  final String date;

  const _HistoryCard({
    required this.title,
    required this.vehicle,
    required this.status,
    required this.date,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF5B8DEF);
      case 'resolved':
      case 'completed':
        return AppColors.successGreen;
      case 'cancelled':
        return AppColors.emergencyRed;
      default:
        return _RRColors.beaconAmber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.08), _RRColors.glassFill],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _RRColors.glassBorder),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10),
                  ],
                ),
                child: Icon(Icons.history, color: color, size: 20),
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Text(
                "Vehicle: $vehicle\n$date",
                style: const TextStyle(color: _RRColors.textMutedOnDark),
              ),
              isThreeLine: true,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.6)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),
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
          top: -130,
          left: -100,
          child: Container(
            width: 340,
            height: 340,
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
        Positioned(
          bottom: -130,
          right: -110,
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