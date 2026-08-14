import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'guardian_service.dart';
import 'location_service.dart';

class SOSService {
  final LocationService _locationService = LocationService();
  final GuardianService _guardianService = GuardianService();

  // PC IPv4 address
  static const String baseUrl = "http://10.84.99.101:8000";

  Future<Map<String, dynamic>> activateSOS() async {
    // 1. Get current location
    final Position position =
        await _locationService.getCurrentLocation();

    // 2. Get all guardians
    final guardians = await _guardianService.getGuardians();

    if (guardians.isEmpty) {
      throw Exception("No guardians found.");
    }

    // 3. Find primary guardian
    final primaryGuardian = guardians.firstWhere(
      (guardian) => guardian.isPrimary == true,
    );

    // 4. Convert guardians into JSON format
    final guardianData = guardians.map((guardian) {
      return {
        "name": guardian.name,
        "phone": guardian.phone,
        "is_primary": guardian.isPrimary,
      };
    }).toList();

    // 5. Send SOS to backend
    final response = await http.post(
      Uri.parse("$baseUrl/sos/activate"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "guardians": guardianData,
      }),
    );

    debugPrint("SOS Backend Status: ${response.statusCode}");
    debugPrint("SOS Backend Response: ${response.body}");

    // 6. Check backend response
    if (response.statusCode != 200) {
      throw Exception(
        "SOS activation failed: ${response.body}",
      );
    }

    // 7. Return backend result
    return jsonDecode(response.body);
  }
}