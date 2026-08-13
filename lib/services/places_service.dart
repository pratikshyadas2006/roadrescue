import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  static const String apiKey = "AIzaSyBuLnq-_asQQYciX25uPWH7_vR4XRfizLY";

  Future<List<dynamic>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    required String type,
  }) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
      "?location=$latitude,$longitude"
      "&radius=5000"
      "&type=$type"
      "&key=$apiKey",
    );

    final response = await http.get(url);

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["status"] == "OK") {
        return data["results"];
      } else {
        print(data["error_message"]);
        return [];
      }
    } else {
      throw Exception("Failed to load nearby places");
    }
  }
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
  final url = Uri.parse(
    "https://maps.googleapis.com/maps/api/place/details/json"
    "?place_id=$placeId"
    "&fields=name,formatted_address,rating,formatted_phone_number,international_phone_number"
    "&key=$apiKey",
  );

  final response = await http.get(url);

  print(response.statusCode);
  print(response.body);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data["status"] == "OK") {
      return data["result"];
    } else {
      print(data["error_message"]);
      return null;
    }
  } else {
    throw Exception("Failed to load place details");
  }
}
}
