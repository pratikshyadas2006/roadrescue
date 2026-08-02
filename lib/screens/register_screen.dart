import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:rr/services/api_service.dart';

/// Shared dark/light hybrid theme tokens — kept in sync with home_screen.dart.
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    // Trigger Form validation before submitting
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.registerUser(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration Successful"),
            backgroundColor: Colors.green,
          ),
        );

        // Return to Login screen
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Registration failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
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
            bottom: -120,
            left: -110,
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _RRColors.beaconAmber.withValues(alpha: 0.4),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Join Road Rescue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Create your account. Drive with confidence.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _RRColors.textMutedOnDark,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _RoadDivider(),
                    const SizedBox(height: 24),

                    // ---- GLASS FORM CARD ----
                    _GlassPanel(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Full name is required';
                              }
                              if (value.trim().length < 3) {
                                return 'Name must be at least 3 characters';
                              }
                              if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
                                return 'Only letters and spaces allowed';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                                return 'Enter a valid 10-digit phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            controller: passwordController,
                            label: 'Password',
                            obscureText: obscurePassword,
                            onVisibilityPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              if (!RegExp(
                                r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).+$',
                              ).hasMatch(value)) {
                                return 'Use uppercase, lowercase, number & special character';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            controller: confirmPasswordController,
                            label: 'Confirm Password',
                            obscureText: obscureConfirmPassword,
                            onVisibilityPressed: () {
                              setState(() {
                                obscureConfirmPassword = !obscureConfirmPassword;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _BeaconButton(
                      label: 'CREATE ACCOUNT',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : registerUser,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: _RRColors.textMutedOnDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: _RRColors.beaconAmber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      cursorColor: _RRColors.beaconAmber,
      decoration: _glassInputDecoration(label: label, icon: icon),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onVisibilityPressed,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      cursorColor: _RRColors.beaconAmber,
      decoration: _glassInputDecoration(
        label: label,
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: _RRColors.textMutedOnDark,
          ),
          onPressed: onVisibilityPressed,
        ),
      ),
    );
  }
}

/// Shared frosted-glass input styling for dark canvases.
InputDecoration _glassInputDecoration({
  required String label,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: _RRColors.textMutedOnDark),
    prefixIcon: Icon(icon, color: _RRColors.textMutedOnDark),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: _RRColors.glassFill,
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

/// Frosted glass card that wraps form content on a dark canvas, with a
/// thin light-catching sheen along the top edge.
class _GlassPanel extends StatelessWidget {
  final Widget child;
  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_RRColors.glassFillHover, _RRColors.glassFill],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _RRColors.glassBorder),
              ),
              child: child,
            ),
            Positioned(
              top: 0,
              left: 18,
              right: 18,
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
    );
  }
}

/// Beacon-amber primary action button, matching the home screen's hero glow.
class _BeaconButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _BeaconButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Color(0xFF0A1220),
                  strokeWidth: 2.4,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}

/// Dashed road-marking motif, matching the home screen.
class _RoadDivider extends StatelessWidget {
  const _RoadDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: Row(
        children: List.generate(16, (i) {
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i.isEven
                    ? _RRColors.beaconAmber.withValues(alpha: 0.7)
                    : Colors.transparent,
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
      ),
    );
  }
}