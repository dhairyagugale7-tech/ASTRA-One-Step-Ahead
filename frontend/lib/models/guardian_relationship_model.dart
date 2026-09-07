import 'package:cloud_firestore/cloud_firestore.dart';

class GuardianRelationshipModel {
  final String id;

  final String userId;

  final String guardianId;

  final String status;

  final bool isPrimary;

  final Timestamp createdAt;

  GuardianRelationshipModel({
    required this.id,
    required this.userId,
    required this.guardianId,
    required this.status,
    required this.isPrimary,
    required this.createdAt,
  });

  factory GuardianRelationshipModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return GuardianRelationshipModel(
      id: documentId,
      userId: map['userId'] ?? '',
      guardianId: map['guardianId'] ?? '',
      status: map['status'] ?? 'active',
      isPrimary: map['isPrimary'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'guardianId': guardianId,
      'status': status,
      'isPrimary': isPrimary,
      'createdAt': createdAt,
    };
  }
}