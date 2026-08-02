import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:rr/services/api_service.dart';
import 'package:rr/services/session_manager.dart';

class _RRColors {
  static const canvasTop = Color(0xFF0A1220);
  static const canvasMid = Color(0xFF0F1B30);
  static const canvasBottom = Color(0xFF16233D);
  static const moonlight = Color(0xFF3A4C7A);
  static const mistLavender = Color(0xFF8FA6FF);
  static const beaconAmber = Color(0xFFFFB020);
  static const glassFill = Color(0x14FFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const textMutedOnDark = Color(0xFFA9B4C4);
}

class AddEmergencyContactScreen extends StatefulWidget {
  const AddEmergencyContactScreen({super.key});

  @override
  State<AddEmergencyContactScreen> createState() => _AddEmergencyContactScreenState();
}

class _AddEmergencyContactScreenState extends State<AddEmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final user = await SessionManager.getUserDetails();
    final result = await ApiService.addEmergencyContact(
      userId: user["user_id"],
      contactName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      relationship: _relationshipController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact Added Successfully"), backgroundColor: AppColors.successGreen),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"]), backgroundColor: AppColors.emergencyRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Add Emergency Contact", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
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
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_RRColors.mistLavender.withValues(alpha: 0.16), _RRColors.moonlight.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _GlassField(
                      controller: _nameController,
                      label: "Contact Name",
                      icon: Icons.person_outline,
                      validator: (value) => value!.isEmpty ? "Enter contact name" : null,
                    ),
                    const SizedBox(height: 16),
                    _GlassField(
                      controller: _phoneController,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Enter phone number";
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return "Enter a valid 10-digit phone number";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _GlassField(
                      controller: _relationshipController,
                      label: "Relationship",
                      icon: Icons.diversity_1_outlined,
                      validator: (value) => value!.isEmpty ? "Enter relationship" : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: _RRColors.beaconAmber.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveContact,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _RRColors.beaconAmber,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Color(0xFF0A1220), strokeWidth: 2.4),
                                )
                              : const Text("Save Contact", style: TextStyle(color: Color(0xFF0A1220), fontWeight: FontWeight.bold, fontSize: 15)),
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
    );
  }
}

/// Shared glass-style text field for form screens on the dark canvas.
class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _GlassField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: _RRColors.textMutedOnDark),
            prefixIcon: Icon(icon, color: _RRColors.beaconAmber, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: _RRColors.glassFill,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _RRColors.glassBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _RRColors.glassBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _RRColors.beaconAmber, width: 1.4)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.emergencyRed)),
          ),
        ),
      ),
    );
  }
}