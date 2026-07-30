import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:rr/services/api_service.dart';
import 'package:rr/services/session_manager.dart'; // Ensure this matches your path

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Request History"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                )
              : _requests.isEmpty
                  ? const Center(
                      child: Text("No breakdown requests found.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUserHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
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

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.orange;
    if (status.toLowerCase() == 'accepted') statusColor = Colors.blue;
    if (status.toLowerCase() == 'resolved' || status.toLowerCase() == 'completed') statusColor = Colors.green;
    if (status.toLowerCase() == 'cancelled') statusColor = Colors.red;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.history,
          color: AppColors.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Vehicle: $vehicle\n$date"),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      ),
    );
  }
}