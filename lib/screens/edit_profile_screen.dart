import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:rr/services/session_manager.dart';
import 'package:rr/services/api_service.dart';

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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    final user = await SessionManager.getUserDetails();

    if (!mounted) return;

    setState(() {
      _nameController.text = user["full_name"] ?? "";
      _emailController.text = user["email"] ?? "";
      _phoneController.text = user["phone"] ?? "";
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final user = await SessionManager.getUserDetails();
    final userId = user["user_id"];

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User ID missing from session. Please re-login."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    final result = await ApiService.updateProfile(
      userId: userId is int ? userId : int.parse(userId.toString()),
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (result["success"] == true) {
      await SessionManager.saveUserDetails(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Failed to update profile."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _RRCanvas(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: _RRColors.beaconAmber))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 6),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _RRColors.beaconAmber.withValues(alpha: 0.4),
                                  blurRadius: 22,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.jpeg',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: _RRColors.beaconAmber,
                          decoration: _glassInputDecoration(
                            label: "Full Name",
                            icon: Icons.person_outline,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? "Please enter your full name" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          style: const TextStyle(color: _RRColors.textMutedOnDark),
                          decoration: _glassInputDecoration(
                            label: "Email Address",
                            icon: Icons.email_outlined,
                            iconColor: _RRColors.textMutedOnDark,
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: _RRColors.beaconAmber,
                          decoration: _glassInputDecoration(
                            label: "Phone Number",
                            icon: Icons.phone_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter your phone number";
                            }
                            if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                              return "Enter a valid 10-digit phone number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 35),
                        _BeaconButton(
                          isSaving: _isSaving,
                          onPressed: _isSaving ? null : _saveProfile,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Shared frosted-glass input styling for dark canvases.
InputDecoration _glassInputDecoration({
  required String label,
  required IconData icon,
  Color iconColor = _RRColors.textMutedOnDark,
  bool readOnly = false,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: _RRColors.textMutedOnDark),
    prefixIcon: Icon(icon, color: iconColor),
    filled: true,
    fillColor: readOnly ? _RRColors.glassFill.withValues(alpha: 0.5) : _RRColors.glassFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _RRColors.glassBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _RRColors.glassBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _RRColors.beaconAmber, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.emergencyRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.emergencyRed, width: 1.4),
    ),
    errorStyle: const TextStyle(color: AppColors.emergencyRed),
  );
}

/// Beacon-amber primary action button, matching the home screen's hero glow.
class _BeaconButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback? onPressed;
  const _BeaconButton({required this.isSaving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _RRColors.beaconAmber.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _RRColors.beaconAmber,
          foregroundColor: const Color(0xFF0A1220),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Color(0xFF0A1220), strokeWidth: 2),
              )
            : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          top: -140,
          right: -100,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _RRColors.mistLavender.withValues(alpha: 0.16),
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