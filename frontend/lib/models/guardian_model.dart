import 'package:cloud_firestore/cloud_firestore.dart';

class GuardianModel {
  final String id;
  final String name;
  final String phone;
  final String relationship;
  final bool isPrimary;
  final Timestamp createdAt;

  GuardianModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    required this.isPrimary,
    required this.createdAt,
  });

  factory GuardianModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return GuardianModel(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relationship: map['relationship'] ?? '',
      isPrimary: map['isPrimary'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'isPrimary': isPrimary,
      'createdAt': createdAt,
    };
  }
}