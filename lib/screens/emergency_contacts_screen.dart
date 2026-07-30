import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:rr/services/api_service.dart';
import 'package:rr/services/session_manager.dart';
import 'package:rr/screens/add_emergency_contact.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  bool _isLoading=true;
  List<dynamic> _contacts=[];
  String _errorMessage='';
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
      _errorMessage = response["message"];
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
  title: const Text("Emergency Contacts"),
  backgroundColor: AppColors.primary,
  foregroundColor: Colors.white,
  actions: [
  IconButton(
    icon: const Icon(Icons.add),
    onPressed: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddEmergencyContactScreen(),
    ),
  );

  if (result == true) {
    _loadContacts();
  }
},
  ),
],
      ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : _contacts.isEmpty
        ? const Center(
            child: Text("No emergency contacts added"),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final contact = _contacts[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(contact["contact_name"]),
                  subtitle: Text(
                    "${contact["relationship"]}\n${contact["phone"]}",
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
    );
  }
}