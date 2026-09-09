import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://10.153.89.128/rr/road_rescue_api";

  // ================= PRIVATE POST HELPER =================
  static Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? jsonBody,
    Map<String, String>? formBody,
  }) async {
    final url = Uri.parse("$baseUrl$path");

    try {
      final isJson = jsonBody != null;

      final response = await http.post(
        url,
        headers: {
          "Content-Type": isJson
              ? "application/json"
              : "application/x-www-form-urlencoded",
          "Accept": "application/json",
        },
        body: isJson ? jsonEncode(jsonBody) : formBody,
      );

      return _parseResponse(response);
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e",
      };
    }
  }

  // ================= PRIVATE GET HELPER =================
  static Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$path"),
        headers: {
          "Accept": "application/json",
        },
      );

      return _parseResponse(response);
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e",
      };
    }
  }

  // ================= RESPONSE PARSER =================
  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      final cleanMsg =
          response.body.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();

      return {
        "success": false,
        "message":
            "Server Error (${response.statusCode}): $cleanMsg",
      };
    }
  }

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) =>
      _post(
        "/auth/register.php",
        jsonBody: {
          "full_name": fullName,
          "email": email,
          "phone": phone,
          "password": password,
        },
      );

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) =>
      _post(
        "/auth/login.php",
        jsonBody: {
          "email": email,
          "password": password,
        },
      );

  // ================= FORGOT PASSWORD =================
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
    required String newPassword,
  }) =>
      _post(
        "/auth/forgot_password.php",
        formBody: {
          "email": email,
          "new_password": newPassword,
        },
      );

  // ================= UPDATE PROFILE =================
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String fullName,
    required String phone,
  }) =>
      _post(
        "/update_profile.php",
        jsonBody: {
          "user_id": userId,
          "full_name": fullName,
          "phone": phone,
        },
      );

  // ================= BREAKDOWN REQUEST =================
  static Future<Map<String, dynamic>> sendBreakdownRequest({
    required int userId,
    required String vehicleType,
    required String issueType,
    required String description,
    required String latitude,
    required String longitude,
  }) =>
      _post(
        "/breakdown/request_breakdown.php",
        formBody: {
          "user_id": userId.toString(),
          "vehicle_type": vehicleType,
          "issue_type": issueType,
          "description": description,
          "latitude": latitude,
          "longitude": longitude,
        },
      );

  // ================= SEND SOS =================
  static Future<Map<String, dynamic>> sendSos({
    required int userId,
    required double latitude,
    required double longitude,
    String? locationAddress,
  }) =>
      _post(
        "/sos/send_sos.php",
        formBody: {
          "user_id": userId.toString(),
          "latitude": latitude.toString(),
          "longitude": longitude.toString(),
          "location_address": locationAddress ?? "",
        },
      );

  // ================= GET BREAKDOWN HISTORY =================
  static Future<Map<String, dynamic>> getBreakdownHistory({
    required int userId,
  }) =>
      _get(
        "/history/get_request_history.php?user_id=$userId",
      );

  // ================= ADD EMERGENCY CONTACT =================
  static Future<Map<String, dynamic>> addEmergencyContact({
    required int userId,
    required String contactName,
    required String phone,
    required String relationship,
  }) =>
      _post(
        "/emergency/add_contact.php",
        formBody: {
          "user_id": userId.toString(),
          "contact_name": contactName,
          "phone": phone,
          "relationship": relationship,
        },
      );

  // ================= GET EMERGENCY CONTACTS =================
  static Future<Map<String, dynamic>> getEmergencyContacts({
    required int userId,
  }) =>
      _get(
        "/emergency/get_contacts.php?user_id=$userId",
      );

  // ================= DELETE EMERGENCY CONTACT 🗑️ =================
  static Future<Map<String, dynamic>> deleteEmergencyContact({
    required int contactId,
  }) =>
      _post(
        "/emergency/delete_contact.php",
        formBody: {
          "contact_id": contactId.toString(),
        },
      );

  // ================= GET NOTIFICATIONS =================
  static Future<Map<String, dynamic>> getNotifications({
    required int userId,
  }) =>
      _get(
        "/notifications/get_notifications.php?user_id=$userId",
      );
}