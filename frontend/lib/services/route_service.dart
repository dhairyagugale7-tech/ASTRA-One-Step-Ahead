import 'dart:convert';
import '../config/api_keys.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteService {
  

  Future<Map<String, dynamic>?> getRoute({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=$originLat,$originLng"
        "&destination=$destinationLat,$destinationLng"
        "&key=${ApiKeys.googleMapsApiKey}";

    final response = await http.get(Uri.parse(url));

    print(response.statusCode);
    print(response.body);

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);

    if (data["routes"].isEmpty) {
      return null;
    }

    final route = data["routes"][0];

    final encoded = route["overview_polyline"]["points"];

    final duration = route["legs"][0]["duration"]["text"];

    final distance = route["legs"][0]["distance"]["text"];

    PolylinePoints polylinePoints = PolylinePoints();

    final points = polylinePoints.decodePolyline(encoded);

    return {
      "points": points,
      "duration": duration,
      "distance": distance,
    };
  }
}