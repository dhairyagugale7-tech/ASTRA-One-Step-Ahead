import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/guardian_model.dart';

class GuardianService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addGuardian(GuardianModel guardian) async {
    final String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('guardians')
        .add(guardian.toMap());
  }

  Future<List<GuardianModel>> getGuardians() async {
  final String uid = _auth.currentUser!.uid;

  final QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('guardians')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      return GuardianModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  Future<void> updateGuardian(GuardianModel guardian) async {
    final String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('guardians')
        .doc(guardian.id)
        .update(guardian.toMap());
  }

  Future<void> deleteGuardian(String guardianId) async {

  final String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('guardians')
        .doc(guardianId)
        .delete();
  }
}
