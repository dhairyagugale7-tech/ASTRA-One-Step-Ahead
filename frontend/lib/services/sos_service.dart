import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'guardian_request_service.dart';
import 'location_service.dart';

class SOSService {
  final LocationService _locationService = LocationService();

  final GuardianRequestService _guardianRequestService =
      GuardianRequestService();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  StreamSubscription<Position>? _sosLocationSubscription;

  // ============================================================
  // ACTIVATE SOS
  // ============================================================

  Future<Map<String, dynamic>> activateSOS() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    // ------------------------------------------------------------
    // 1. GET CURRENT LOCATION
    // ------------------------------------------------------------

    final Position position =
        await _locationService.getCurrentLocation();

    debugPrint(
      'ASTRA SOS: Location = '
      '${position.latitude}, ${position.longitude}',
    );

    // ------------------------------------------------------------
    // 2. GET ALL ACTIVE GUARDIANS
    // ------------------------------------------------------------

    final relationships =
        await _guardianRequestService.getMyGuardians();

    final activeGuardians = relationships
        .where(
          (guardian) => guardian.status == 'active',
        )
        .toList();

    if (activeGuardians.isEmpty) {
      throw Exception(
        'No active guardians found.',
      );
    }

    debugPrint(
      'ASTRA SOS: Active guardians = '
      '${activeGuardians.length}',
    );

    // ------------------------------------------------------------
    // 3. CREATE SOS EVENT
    // ------------------------------------------------------------

    final sosRef = await _firestore
        .collection('sosEvents')
        .add({
      'userId': user.uid,

      // Initial location
      'latitude': position.latitude,
      'longitude': position.longitude,

      // Live location fields
      'currentLatitude': position.latitude,
      'currentLongitude': position.longitude,

      'status': 'active',
      'createdAt': Timestamp.now(),

      'guardianIds': activeGuardians
          .map(
            (guardian) => guardian.guardianId,
          )
          .toList(),
    });

    debugPrint(
      'ASTRA SOS: SOS event created: ${sosRef.id}',
    );

    // ------------------------------------------------------------
    // 4. START SOS LIVE LOCATION
    // ------------------------------------------------------------

    _startSOSLiveLocation(
      sosId: sosRef.id,
    );

    // ------------------------------------------------------------
    // 5. RETURN SOS INFORMATION
    // ------------------------------------------------------------

    return {
      'sosId': sosRef.id,

      'latitude': position.latitude,
      'longitude': position.longitude,

      'guardiansNotified':
          activeGuardians.length,

      'guardianIds': activeGuardians
          .map(
            (guardian) => guardian.guardianId,
          )
          .toList(),
    };
  }

  // ============================================================
  // START SOS LIVE LOCATION
  // ============================================================

  void _startSOSLiveLocation({
    required String sosId,
  }) {
    // Cancel any previous SOS location stream.
    _sosLocationSubscription?.cancel();

    debugPrint(
      'ASTRA SOS: Starting live location for $sosId',
    );

    _sosLocationSubscription =
        _locationService
            .getLocationStream()
            .listen(
      (Position position) async {
        try {
          await _firestore
              .collection('sosEvents')
              .doc(sosId)
              .update({
            'currentLatitude':
                position.latitude,
            'currentLongitude':
                position.longitude,
            'latitude':
                position.latitude,
            'longitude':
                position.longitude,
            'lastUpdated':
                Timestamp.now(),
          });

          debugPrint(
            'ASTRA SOS LIVE GPS: '
            '${position.latitude}, '
            '${position.longitude}',
          );
        } catch (e) {
          debugPrint(
            'ASTRA SOS: Failed to update live location: $e',
          );
        }
      },
      onError: (error) {
        debugPrint(
          'ASTRA SOS GPS stream error: $error',
        );
      },
    );
  }

  // ============================================================
  // STOP SOS LIVE LOCATION
  // ============================================================

  Future<void> stopSOSLiveLocation() async {
    await _sosLocationSubscription?.cancel();

    _sosLocationSubscription = null;

    debugPrint(
      'ASTRA SOS: Live location tracking stopped.',
    );
  }
}