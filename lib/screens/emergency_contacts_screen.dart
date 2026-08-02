import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:rr/services/api_service.dart';
import 'package:rr/services/session_manager.dart';
import 'package:rr/screens/add_emergency_contact.dart';

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

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  bool _isLoading = true;
  List<dynamic> _contacts = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final user = await SessionManager.getUserDetails();

    final response = await ApiService.getEmergencyContacts(
      userId: user["user_id"],
    );

    setState(() {
      _isLoading = false;

      if (response["success"] == true) {
        _contacts = response["contacts"];
      } else {
        _errorMessage = response["message"] ?? "Something went wrong";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Emergency Contacts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEmergencyContactScreen(),
                ),
              );

              if (result == true) {
                _loadContacts();
              }
            },
          ),
        ],
      ),
      body: _RRCanvas(
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _RRColors.beaconAmber));
    }

    // Show the error message when the fetch failed, instead of a
    // generic empty-list message.
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.emergencyRed, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _RRColors.textMutedOnDark),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadContacts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _RRColors.beaconAmber,
                  foregroundColor: const Color(0xFF0A1220),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    if (_contacts.isEmpty) {
      return const Center(
        child: Text("No emergency contacts added", style: TextStyle(color: _RRColors.textMutedOnDark)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _contacts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return _ContactCard(
          name: contact["contact_name"],
          relationship: contact["relationship"],
          phone: contact["phone"],
        );
      },
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String name;
  final String relationship;
  final String phone;

  const _ContactCard({required this.name, required this.relationship, required this.phone});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_RRColors.glassFillHover, _RRColors.glassFill],
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
                  color: _RRColors.beaconAmber.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: _RRColors.beaconAmber.withValues(alpha: 0.3), blurRadius: 10),
                  ],
                ),
                child: const Icon(Icons.person, color: _RRColors.beaconAmber, size: 22),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(
                "$relationship\n$phone",
                style: const TextStyle(color: _RRColors.textMutedOnDark),
              ),
              isThreeLine: true,
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