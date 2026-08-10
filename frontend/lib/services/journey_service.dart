import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/journey_model.dart';

class JourneyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> startJourney(JourneyModel journey) async {
    try {
      final uid = _auth.currentUser!.uid;

      final docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('journeys')
          .add(journey.toMap());

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLiveLocation({
    required String journeyId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uid = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('journeys')
          .doc(journeyId)
          .update({
        'currentLatitude': latitude,
        'currentLongitude': longitude,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<JourneyModel>> getJourneys() async {

  final uid = _auth.currentUser!.uid;

  final QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('journeys')
        .orderBy('startedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {

      return JourneyModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

    }).toList();

  }

  Future<void> endJourney({
    required String journeyId,
  }) async {
    try {
      final uid = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('journeys')
          .doc(journeyId)
          .update({
        'isActive': false,
        'completedAt': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
