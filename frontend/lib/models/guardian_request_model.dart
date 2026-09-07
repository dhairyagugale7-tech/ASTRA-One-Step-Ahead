import 'package:cloud_firestore/cloud_firestore.dart';

class GuardianRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String status;
  final Timestamp createdAt;

  GuardianRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  factory GuardianRequestModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return GuardianRequestModel(
      id: documentId,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
      'createdAt': createdAt,
    };
  }
}