import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

class EmergencyContactsScreen extends StatelessWidget {
   EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Emergency Contacts"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("Mom"),
            subtitle: Text("+91 9876543210"),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("Dad"),
            subtitle: Text("+91 9876543211"),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("Friend"),
            subtitle: Text("+91 9876543212"),
          ),
        ],
      ),
    );
  }
}