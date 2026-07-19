import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _passwordField(
                controller: currentPasswordController,
                label: 'Current Password',
                obscure: obscureCurrent,
                toggle: () => setState(() => obscureCurrent = !obscureCurrent),
              ),
              const SizedBox(height: 16),
              _passwordField(
                controller: newPasswordController,
                label: 'New Password',
                obscure: obscureNew,
                toggle: () => setState(() => obscureNew = !obscureNew),
              ),
              const SizedBox(height: 16),
              _passwordField(
                controller: confirmPasswordController,
                label: 'Confirm New Password',
                obscure: obscureConfirm,
                toggle: () => setState(() => obscureConfirm = !obscureConfirm),
                validateMatch: true,
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: call your password update API here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password updated successfully')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Update Password',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    bool validateMatch = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (validateMatch && value != newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}