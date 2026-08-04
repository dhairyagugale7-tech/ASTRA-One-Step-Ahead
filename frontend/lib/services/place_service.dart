import 'dart:convert';

import 'package:http/http.dart' as http;

class PlaceService {
  static const String apiKey = "REMOVED_GOOGLE_MAPS_API_KEY";

  Future<List<dynamic>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json"
      "?input=$query"
      "&key=$apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["predictions"];
    }

    return [];
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json"
      "?place_id=$placeId"
      "&fields=geometry,name,formatted_address"
      "&key=$apiKey",
    );

    final response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      print(data);

      return data["result"];

    }

    return null;
  }
}
