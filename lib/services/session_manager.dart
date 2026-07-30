import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String keyIsLoggedIn = "is_logged_in";
  static const String keyUserId = "user_id";
  static const String keyFullName = "full_name";
  static const String keyEmail = "email";
  static const String keyPhone = "phone";

  // Save session when user logs in successfully
  static Future<void> saveUserSession({
    required int userId,
    required String fullName,
    required String email,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setInt(keyUserId, userId);
    await prefs.setString(keyFullName, fullName);
    await prefs.setString(keyEmail, email);
    await prefs.setString(keyPhone, phone);
  }

  // ✅ ADDED: Save updated user details from Edit Profile screen
  static Future<void> saveUserDetails({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyFullName, fullName);
    await prefs.setString(keyEmail, email);
    await prefs.setString(keyPhone, phone);
  }

  // Check if a session exists
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  // Get current user details
  static Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "user_id": prefs.getInt(keyUserId),
      "full_name": prefs.getString(keyFullName) ?? "",
      "email": prefs.getString(keyEmail) ?? "",
      "phone": prefs.getString(keyPhone) ?? "",
    };
  }

  // Clear data on logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}