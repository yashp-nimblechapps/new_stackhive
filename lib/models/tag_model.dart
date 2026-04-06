import 'package:cloud_firestore/cloud_firestore.dart';

class TagModel {
  final String id;
  final String name;
  final int usageCount;
  final DateTime createdAt;

  TagModel({
    required this.id, 
    required this.name, 
    required this.usageCount, 
    required this.createdAt
  });

  factory TagModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TagModel(
      id: documentId, 
      name: map['name'] ?? '', 
      usageCount: map['usageCount'] ?? 0, 
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'usageCount': usageCount,
      'createdAt': createdAt,
    };
  }

}