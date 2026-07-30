import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:rr/services/api_service.dart';
import 'package:rr/services/session_manager.dart';

class AddEmergencyContactScreen extends StatefulWidget {
  const AddEmergencyContactScreen({super.key});

  @override
  State<AddEmergencyContactScreen> createState() =>
      _AddEmergencyContactScreenState();
}

class _AddEmergencyContactScreenState
    extends State<AddEmergencyContactScreen> {
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
        const SnackBar(
          content: Text("Contact Added Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Emergency Contact"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Contact Name",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter contact name" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter phone number";
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return "Enter a valid 10-digit phone number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _relationshipController,
                decoration: const InputDecoration(
                  labelText: "Relationship",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter relationship" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveContact,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Contact"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}