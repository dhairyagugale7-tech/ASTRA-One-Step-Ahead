import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/guardian_model.dart';

class GuardianService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future addGuardian(GuardianModel guardian) async {
    final String uid = _auth.currentUser!.uid;

    final guardiansRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('guardians');

    // If this guardian is being made primary,
    // remove primary status from the existing primary guardian.
    if (guardian.isPrimary) {
      final snapshot = await guardiansRef
          .where('isPrimary', isEqualTo: true)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({
          'isPrimary': false,
        });
      }
    }

    // Add the new guardian.
    await guardiansRef.add(guardian.toMap());
  }

  Future<void> setPrimaryGuardian(String guardianId) async {
    final String uid = _auth.currentUser!.uid;

    final guardiansRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('guardians');

    // Remove primary status from all guardians.
    final snapshot = await guardiansRef
        .where('isPrimary', isEqualTo: true)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({
        'isPrimary': false,
      });
    }

    // Make the selected guardian primary.
    await guardiansRef.doc(guardianId).update({
      'isPrimary': true,
    });
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

  Future<GuardianModel?> getGuardianByName(String name) async {
    final guardians = await getGuardians();

    for (final guardian in guardians) {
      if (guardian.name == name) {
        return guardian;
      }
    }

    return null;
  }
}
