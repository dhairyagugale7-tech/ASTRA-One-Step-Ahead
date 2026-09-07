import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_keys.dart';

class PlaceService {
  

  Future<List<dynamic>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json"
      "?input=$query"
      "&key=${ApiKeys.googleMapsApiKey}",
    );

    final response = await http.get(url);

    print("PLACE STATUS: ${response.statusCode}");
    print("PLACE RESPONSE: ${response.body}");



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
      "&key=${ApiKeys.googleMapsApiKey}",
    );

    final response = await http.get(url);

    print("PLACE STATUS: ${response.statusCode}");
    print("PLACE RESPONSE: ${response.body}");

    print(response.body);

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      print(data);

      return data["result"];

    }

    return null;
  }
}
