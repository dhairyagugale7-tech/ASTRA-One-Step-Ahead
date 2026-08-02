import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/journey_model.dart';

class JourneyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> startJourney(JourneyModel journey) async {

    final uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('journeys')
        .add(journey.toMap());
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
}
