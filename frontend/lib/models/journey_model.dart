import 'package:cloud_firestore/cloud_firestore.dart';

class JourneyModel {
  final String id;
  final String destination;

  final double destinationLatitude;
  final double destinationLongitude;

  final List<String> guardians;
  final bool shareLiveLocation;
  final bool smartCheckins;
  final bool isActive;
  final Timestamp startedAt;

  JourneyModel({
    required this.id,
    required this.destination,

    required this.destinationLatitude,
    required this.destinationLongitude,

    required this.guardians,
    required this.shareLiveLocation,
    required this.smartCheckins,
    required this.isActive,
    required this.startedAt,
  });

  factory JourneyModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return JourneyModel(
      id: documentId,
      destination: map['destination'] ?? '',

      destinationLatitude:
          (map['destinationLatitude'] ?? 0.0).toDouble(),

      destinationLongitude:
          (map['destinationLongitude'] ?? 0.0).toDouble(),

      guardians: List<String>.from(map['guardians'] ?? []),
      shareLiveLocation: map['shareLiveLocation'] ?? true,
      smartCheckins: map['smartCheckins'] ?? true,
      isActive: map['isActive'] ?? true,
      startedAt: map['startedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'destination': destination,

      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,

      'guardians': guardians,
      'shareLiveLocation': shareLiveLocation,
      'smartCheckins': smartCheckins,
      'isActive': isActive,
      'startedAt': startedAt,
    };
  }
}