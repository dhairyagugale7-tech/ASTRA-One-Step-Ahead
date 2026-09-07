import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/guardian_request_model.dart';
import 'package:flutter/foundation.dart';

import '../models/guardian_relationship_model.dart';

class GuardianRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send guardian request
  Future<void> sendRequest(String receiverId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final String senderId = user.uid;

    // Prevent sending request to yourself
    if (senderId == receiverId) {
      throw Exception(
        'You cannot send a guardian request to yourself.',
      );
    }

    // Check whether a request already exists between these two users.
    // We intentionally use only senderId + receiverId here
    // to avoid requiring a composite Firestore index.
    debugPrint('ASTRA: Checking existing guardian requests...');

    final existingRequests = await _firestore
        .collection('guardianRequests')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isEqualTo: 'pending')
        .get();

    debugPrint(
      'ASTRA: Existing request query succeeded. '
      'Found ${existingRequests.docs.length} requests.',
    );

    // Check pending requests locally.
    for (final doc in existingRequests.docs) {
      final data = doc.data();

      if (data['status'] == 'pending') {
        throw Exception('Guardian request already sent.');
      }
    }

    // Create the new guardian request.
    final request = GuardianRequestModel(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      status: 'pending',
      createdAt: Timestamp.now(),
    );

    await _firestore
        .collection('guardianRequests')
        .add(request.toMap());
  }

  // Get pending guardian requests received by current user
  Future<List<GuardianRequestModel>> getReceivedRequests() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final String receiverId = user.uid;

    debugPrint(
      'ASTRA: Loading guardian requests for receiver: $receiverId',
    );

    // We intentionally do NOT use orderBy() here.
    // This avoids requiring a Firestore composite index.
    final snapshot = await _firestore
        .collection('guardianRequests')
        .where(
          'receiverId',
          isEqualTo: receiverId,
        )
        .where(
          'status',
          isEqualTo: 'pending',
        )
        .get();

    debugPrint(
      'ASTRA: Found ${snapshot.docs.length} pending guardian requests.',
    );

    final requests = snapshot.docs.map((doc) {
      return GuardianRequestModel.fromMap(
        doc.data(),
        doc.id,
      );
    }).toList();

    // Sort newest requests first locally.
    requests.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return requests;
  }

  // Accept guardian request
  Future<void> acceptRequest(String requestId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final String currentUserId = user.uid;

    // Get the guardian request first.
    final requestDoc = await _firestore
        .collection('guardianRequests')
        .doc(requestId)
        .get();

    if (!requestDoc.exists) {
      throw Exception('Guardian request not found.');
    }

    final data = requestDoc.data();

    if (data == null) {
      throw Exception('Guardian request data is missing.');
    }

    final String senderId = data['senderId'] ?? '';
    final String receiverId = data['receiverId'] ?? '';

    // Only the receiver can accept the request.
    if (receiverId != currentUserId) {
      throw Exception(
        'You are not allowed to accept this request.',
      );
    }

    // Create the guardian relationship.
    final relationship =
    GuardianRelationshipModel(
      id: '',
      userId: senderId,
      guardianId: receiverId,
      status: 'active',
      isPrimary: false,
      createdAt: Timestamp.now(),
    );

    // Save the relationship.
    await _firestore
        .collection('guardianRelationships')
        .add(
          relationship.toMap(),
        );

    // Mark the request as accepted.
    await _firestore
        .collection('guardianRequests')
        .doc(requestId)
        .update({
      'status': 'accepted',
    });
  }
  // Decline guardian request
  Future<void> declineRequest(String requestId) async {
    await _firestore
        .collection('guardianRequests')
        .doc(requestId)
        .update({
      'status': 'declined',
    });
  }

    // Delete guardian request
    Future<void> deleteRequest(String requestId) async {
      await _firestore
          .collection('guardianRequests')
          .doc(requestId)
          .delete();
    }

  // Find an ASTRA user using phone number or email
  Future<String?> findUserByPhoneOrEmail(String value) async {
    final input = value.trim();

    // First search by phone number
    final phoneSnapshot = await _firestore
        .collection('users')
        .where('phone', isEqualTo: input)
        .limit(1)
        .get();

    if (phoneSnapshot.docs.isNotEmpty) {
      return phoneSnapshot.docs.first.id;
    }

    // If not found, search by email
    final emailSnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: input)
        .limit(1)
        .get();

    if (emailSnapshot.docs.isNotEmpty) {
      return emailSnapshot.docs.first.id;
    }

    // User doesn't exist on ASTRA
    return null;
  }

  // Get guardians of the current user
  Future<List<GuardianRelationshipModel>> getMyGuardians() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final snapshot = await _firestore
        .collection('guardianRelationships')
        .where('userId',isEqualTo: user.uid)
        .where('status',isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) {
      return GuardianRelationshipModel.fromMap(
        doc.data(),
        doc.id,
      );
    }).toList();
  }

  // Get users guarded by the current user
  Future<List<GuardianRelationshipModel>> getUsersIGuard() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final snapshot = await _firestore
        .collection('guardianRelationships')
        .where(
          'guardianId',
          isEqualTo: user.uid,
        )
        .where(
          'status',
          isEqualTo: 'active',
        )
        .get();

    return snapshot.docs.map((doc) {
      return GuardianRelationshipModel.fromMap(
        doc.data(),
        doc.id,
      );
    }).toList();
  }

  // Get user details using their Firebase UID
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return doc.data();
  }

  // ------------------------------------------------------------
  // REMOVE GUARDIAN RELATIONSHIP
  // ------------------------------------------------------------

  Future<void> removeRelationship(String relationshipId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    await _firestore
        .collection('guardianRelationships')
        .doc(relationshipId)
        .delete();
  }

  // ------------------------------------------------------------
  // SET PRIMARY GUARDIAN STATUS
  // ------------------------------------------------------------

  Future<void> setPrimaryStatus(
    String relationshipId,
    bool isPrimary,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not authenticated.',
      );
    }

    final relationshipDoc = await _firestore
        .collection('guardianRelationships')
        .doc(relationshipId)
        .get();

    if (!relationshipDoc.exists) {
      throw Exception(
        'Guardian relationship not found.',
      );
    }

    final data = relationshipDoc.data();

    if (data == null) {
      throw Exception(
        'Guardian relationship data is missing.',
      );
    }

    // Only the person being guarded can decide
    // whether this guardian is primary.
    if (data['userId'] != user.uid) {
      throw Exception(
        'You are not allowed to change this guardian.',
      );
    }

    // Only active relationships can be primary.
    if (data['status'] != 'active') {
      throw Exception(
        'Only active guardians can be primary.',
      );
    }

    await _firestore
        .collection('guardianRelationships')
        .doc(relationshipId)
        .update({
      'isPrimary': isPrimary,
    });
  }
  
}