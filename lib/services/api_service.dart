import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
 static const String baseUrl =
    "http://10.175.184.187/roadrescue/road_rescue_api";


  // ================= REGISTER =================
  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/register.php");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "full_name": fullName,
          "email": email,
          "phone": phone,
          "password": password,
        }),
      );

      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {
          "success": false,
          "message":
              "PHP Error Output: ${response.body.replaceAll(RegExp(r'<[^>]*>'), ' ')}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e",
      };
    }
  }

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login.php");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {
          "success": false,
          "message":
              "PHP Error Output: ${response.body.replaceAll(RegExp(r'<[^>]*>'), ' ')}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e",
      };
    }
  }

  // ================= UPDATE PROFILE =================
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String fullName,
    required String phone,
  }) async {
    final url = Uri.parse("$baseUrl/update_profile.php");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
          "full_name": fullName,
          "phone": phone,
        }),
      );

      // 🔍 PRINT RAW RESPONSE TO TERMINAL/DEBUG CONSOLE
      print("--------------------------------------------------");
      print("SERVER RESPONSE STATUS: ${response.statusCode}");
      print("SERVER RAW RESPONSE: ${response.body}");
      print("--------------------------------------------------");

      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {
          "success": false,
          "message":
              "PHP Error Output: ${response.body.replaceAll(RegExp(r'<[^>]*>'), ' ')}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e",
      };
    }
  }

// ================= BREAKDOWN REQUEST =================
static Future<Map<String, dynamic>> sendBreakdownRequest({
  required int userId,
  required String vehicleType,
  required String issueType,
  required String description,
  required String latitude,
  required String longitude,
}) async {
  final url = Uri.parse("$baseUrl/breakdown/request_breakdown.php");

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "application/json",
      },
      body: {
        "user_id": userId.toString(),
        "vehicle_type": vehicleType,
        "issue_type": issueType,
        "description": description,
        "latitude": latitude,
        "longitude": longitude,
      },
    );

    // 🔍 PRINT RAW RESPONSE TO TERMINAL/DEBUG CONSOLE
    print("--------------------------------------------------");
    print("SERVER RESPONSE STATUS: ${response.statusCode}");
    print("SERVER RAW RESPONSE: ${response.body}");
    print("--------------------------------------------------");

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {
        "success": false,
        "message": "PHP Error Output: ${response.body.replaceAll(RegExp(r'<[^>]*>'), ' ')}"
      };
    }
  } catch (e) {
    return {
      "success": false,
      "message": "Connection error: $e",
    };
  }
}
// ================= GET BREAKDOWN HISTORY =================
  static Future<Map<String, dynamic>> getBreakdownHistory({
    required int userId,
  }) async {
    final url = Uri.parse("$baseUrl/history/get_request_history.php?user_id=$userId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e",
      };
    }
  }

  // ================= FORGOT PASSWORD =================
static Future<Map<String, dynamic>> forgotPassword({
  required String email,
  required String newPassword,
}) async {
  final url = Uri.parse("$baseUrl/auth/forgot_password.php");

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "email": email,
        "new_password": newPassword,
      },
    );

    return jsonDecode(response.body);
  } catch (e) {
    return {
      "success": false,
      "message": "Connection error: $e",
    };
  }
}

// ================= ADD EMERGENCY CONTACT =================
static Future<Map<String, dynamic>> addEmergencyContact({
  required int userId,
  required String contactName,
  required String phone,
  required String relationship,
}) async {
  final url = Uri.parse("$baseUrl/emergency/add_contact.php");

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "user_id": userId.toString(),
        "contact_name": contactName,
        "phone": phone,
        "relationship": relationship,
      },
    );

    return jsonDecode(response.body);
  } catch (e) {
    return {
      "success": false,
      "message": "Connection error: $e",
    };
  }
}

// ================= GET EMERGENCY CONTACTS =================
static Future<Map<String, dynamic>> getEmergencyContacts({
  required int userId,
}) async {
  final url = Uri.parse(
      "$baseUrl/emergency/get_contacts.php?user_id=$userId");

  try {
    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
      },
    );

    return jsonDecode(response.body);
  } catch (e) {
    return {
      "success": false,
      "message": "Connection error: $e",
    };
  }
}


// ================= SEND SOS =================
static Future<Map<String, dynamic>> sendSos({
  required int userId,
  required double latitude,
  required double longitude,
  String? locationAddress,
}) async {
  final url = Uri.parse("$baseUrl/sos/send_sos.php");

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "application/json",
      },
      body: {
        "user_id": userId.toString(),
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "location_address": locationAddress ?? "",
      },
    );

    print("--------------------------------------------------");
    print("SOS SERVER RESPONSE STATUS: ${response.statusCode}");
    print("SOS SERVER RAW RESPONSE: ${response.body}");
    print("--------------------------------------------------");

    return jsonDecode(response.body);
  } catch (e) {
    return {
      "success": false,
      "message": "Connection error: $e",
    };
  }
}
// ================= GET NOTIFICATIONS =================

static Future<Map<String, dynamic>> getNotifications({
  required int userId,
}) async {

  final url = Uri.parse(
    "$baseUrl/notifications/get_notifications.php?user_id=$userId",
  );

  try {
    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
      },
    );

    print("NOTIFICATIONS RESPONSE: ${response.body}");

    return jsonDecode(response.body);

  } catch (e) {
    return {
      "success": false,
      "message": "Connection error: $e",
    };
  }
}

// ================= AI DIAGNOSIS =================
static Future<Map<String, dynamic>> getAiDiagnosis({
  required int userId,
  required String userMessage,
}) async {
  final url = Uri.parse("$baseUrl/ai/ai_diagnosis.php");

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "application/json",
      },
      body: {
        "user_id": userId.toString(),
        "user_message": userMessage,
      },
    );

    print("--------------------------------------------------");
    print("AI DIAGNOSIS RESPONSE STATUS: ${response.statusCode}");
    print("AI DIAGNOSIS RAW RESPONSE: ${response.body}");
    print("--------------------------------------------------");

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {
        "success": false,
        "message": "PHP Error Output: ${response.body.replaceAll(RegExp(r'<[^>]*>'), ' ')}"
      };
    }
  } catch (e) {
    return {
      "success": false,
      "message": "Connection error: $e",
    };
  }
}

// ================= ANALYZE DASHBOARD IMAGE =================
static Future<Map<String, dynamic>> analyzeDashboardImage({
  required int userId,
  required String imagePath,
}) async {
  final url = Uri.parse("$baseUrl/ai/analyze_dashboard.php");

  try {
    final request = http.MultipartRequest("POST", url)
      ..headers["Accept"] = "application/json"
      ..fields["user_id"] = userId.toString()
      ..files.add(await http.MultipartFile.fromPath("image", imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("--------------------------------------------------");
    print("ANALYZE DASHBOARD RESPONSE STATUS: ${response.statusCode}");
    print("ANALYZE DASHBOARD RAW RESPONSE: ${response.body}");
    print("--------------------------------------------------");

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {
        "success": false,
        "message": "PHP Error Output: ${response.body.replaceAll(RegExp(r'<[^>]*>'), ' ')}"
      };
    }
  } catch (e) {
    return {
      "success": false,
      "message": "Connection error: $e",
    };
  }
}
}