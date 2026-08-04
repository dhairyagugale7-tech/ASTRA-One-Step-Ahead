import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteService {
  static const String apiKey = "REMOVED_GOOGLE_MAPS_API_KEY";

  Future<List<PointLatLng>> getRoute({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=$originLat,$originLng"
        "&destination=$destinationLat,$destinationLng"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    print(response.statusCode);
    print(response.body);

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body);

    if (data["routes"].isEmpty) {
      return [];
    }

    final encoded =
        data["routes"][0]["overview_polyline"]["points"];

    PolylinePoints polylinePoints = PolylinePoints();

    return polylinePoints.decodePolyline(encoded);
  }
}