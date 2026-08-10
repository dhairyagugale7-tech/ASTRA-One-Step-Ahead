import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData({
    required String uid,
    required String name,
    required String phone,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {

    final document =
        await _firestore.collection('users').doc(uid).get();

    return document.data();

  }

  Future<void> updateUserData({
    required String uid,
    required String name,
    required String phone,
    required String email,
  }) async{
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
          'name': name,
          'phone': phone,
          'email': email,
        });
  }
}