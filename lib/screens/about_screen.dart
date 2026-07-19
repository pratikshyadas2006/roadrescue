import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("About Road Rescue"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Icon(
              Icons.car_repair,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: 20),

            Text(
              "Road Rescue",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Version 1.0",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 25),

            Text(
              "Road Rescue is a Smart Vehicle Breakdown Assistance System developed to help users during vehicle emergencies. The application provides nearby mechanics, hospitals, police stations, fuel pumps, emergency contacts, AI vehicle issue diagnosis, and an SOS emergency feature.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),

            SizedBox(height: 25),

            Text(
              "Key Features",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text("Vehicle Breakdown Assistance"),
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text("SOS Emergency"),
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text("AI Vehicle Diagnosis"),
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text("Nearby Services"),
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text("Live Location Sharing"),
            ),

            SizedBox(height: 20),

            Center(
              child: Text(
                "Developed by Road Rescue Team",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}