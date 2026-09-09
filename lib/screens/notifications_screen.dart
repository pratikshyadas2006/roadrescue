import 'package:flutter/material.dart';
import 'package:rr/services/api_service.dart';
import 'package:rr/services/session_manager.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {

  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {

    final user = await SessionManager.getUserDetails();

    final response = await ApiService.getNotifications(
      userId: user["user_id"],
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;

      if (response["success"] == true) {
        _notifications = response["notifications"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Notifications"),
      ),

      body: _isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : _notifications.isEmpty

              ? const Center(
                  child: Text("No notifications yet"),
                )

              : ListView.builder(
                  padding: const EdgeInsets.all(12),

                  itemCount: _notifications.length,

                  itemBuilder: (context, index) {

                    final notification =
                        _notifications[index];

                    return Card(

                      margin:
                          const EdgeInsets.only(bottom: 12),

                      child: ListTile(

                        leading: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),

                        title: Text(
                          notification["message"] ??
                              "Emergency Alert",
                        ),

                        subtitle: Text(
                          "Status: ${notification["status"]}\n"
                          "${notification["created_at"]}",
                        ),

                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}