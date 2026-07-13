import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

class RequestHistoryScreen extends StatelessWidget {
  const RequestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Request History"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HistoryCard(
            title: "Flat Tyre",
            location: "Andheri, Mumbai",
            status: "Completed",
            date: "12 July 2026",
          ),
          SizedBox(height: 12),
          _HistoryCard(
            title: "Battery Issue",
            location: "Bandra, Mumbai",
            status: "Completed",
            date: "5 July 2026",
          ),
          SizedBox(height: 12),
          _HistoryCard(
            title: "Engine Overheating",
            location: "Powai, Mumbai",
            status: "Cancelled",
            date: "28 June 2026",
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String location;
  final String status;
  final String date;

  const _HistoryCard({
    required this.title,
    required this.location,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
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
        subtitle: Text("$location\n$date"),
        isThreeLine: true,
        trailing: Chip(
          label: Text(status),
        ),
      ),
    );
  }
}