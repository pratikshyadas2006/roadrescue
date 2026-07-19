import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'request_history_screen.dart';
import 'emergency_contacts_screen.dart';
import 'settings_screen.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
  backgroundColor: AppColors.primary,
  automaticallyImplyLeading: false,
  elevation: 0,
  title: Row(
    children: [
      Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            Icons.menu,
            color: AppColors.secondary,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      const SizedBox(width: 12),
      ClipOval(
        child: Image.asset(
          'assets/images/logo.jpeg',
          width: 32,
          height: 32,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(width: 8),
      const Text(
        'Road Rescue',
        style: TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 19,
          letterSpacing: 0.3,
        ),
      ),
    ],
  ),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Center(
        child: SizedBox(
          width: 100,
          height: 42,
          child: TextButton(
            
              onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ),
  );
},
            style: TextButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'LOGIN',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    ),
  ],
),
      drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.jpeg',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Road Rescue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Drive Safe. We\'re Here.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],

        ),
      ),

      ListTile(
  leading: const Icon(Icons.person_outline),
  title: const Text('Profile'),
  onTap: () {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  },
),

const Divider(),

ListTile(
  leading: const Icon(Icons.history),
  title: const Text('Request History'),
  onTap: () {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestHistoryScreen(),
      ),
    );
  },
),

ListTile(
  leading: const Icon(Icons.contact_phone_outlined),
  title: const Text('Emergency Contacts'),
  onTap: () {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyContactsScreen(),
      ),
    );
  },
),

ListTile(
  leading: const Icon(Icons.notifications_none),
  title: const Text('Settings'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  },
),

const Divider(),

ListTile(
  leading: const Icon(Icons.logout, color: Colors.red),
  title: const Text(
    'Logout',
    style: TextStyle(color: Colors.red),
  ),
  onTap: () {},
),
    ],
  ),
      ),
body: SafeArea(
  child: Column(
    children: [

      
            // Top Welcome Banner Block
            Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    horizontal: 22,
    vertical: 18,
  ),
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF0B1F3A),
        Color(0xFF123A63),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(24),
    ),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Driver 👋',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Ready for a safer journey?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Road Rescue is here when you need it.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: AppColors.successGreen.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.successGreen,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_outlined,
              color: AppColors.successGreen,
              size: 15,
            ),
            SizedBox(width: 5),
            Text(
              'Protection Ready',
              style: TextStyle(
                color: AppColors.successGreen,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
            
            // Grid Area presenting 5 perfectly uniform small squares
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 300,
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.68,
                          children: [
                            _buildSquareCard(
                              title: 'Vehicle Breakdown',
                              icon: Icons.car_repair_rounded,
                              accentColor: AppColors.primary,
                              onTap: () {},
                            ),
                            _buildSquareCard(
                              title: 'SOS',
                              icon: Icons.sensors_outlined,
                              accentColor: AppColors.emergencyRed,
                              isEmergency: true,
                              onTap: () {},
                            ),
                            _buildSquareCard(
                              title: 'AI Diagnosis',
                              icon: Icons.psychology_alt_outlined,
                              accentColor: Colors.purple,
                              onTap: () {},
                            ),
                            _buildSquareCard(
                              title: 'Nearby Services',
                              icon: Icons.location_on_outlined,
                              accentColor: Colors.blue,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: _buildSquareCard(
                        title: 'Enable Road Rescue',
                        icon: Icons.health_and_safety_outlined,
                        accentColor: AppColors.successGreen,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builder for rendering matching square shapes with stacked centered configurations
  Widget _buildSquareCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
    bool isEmergency = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 115,
            height: 115,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isEmergency ? accentColor.withOpacity(0.4) : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}

