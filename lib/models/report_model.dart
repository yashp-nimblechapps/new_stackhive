import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String contentId;
  final String contentType; // question / answer
  final String parentId;    // questionId
  final String reportedBy;  // userId
  final String reportedByName;
  final String reason;
  final DateTime createdAt;
  final String status;

  ReportModel({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.parentId,
    required this.reportedBy,
    required this.reportedByName,
    required this.reason,
    required this.createdAt,
    required this.status,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReportModel(
      id: docId,
      contentId: map['contentId'] ?? '',
      contentType: map['contentType'] ?? '',
      parentId: map['parentId'] ?? '',
      reportedBy: map['reportedBy'] ?? '',
      reportedByName: map['reportedByName'] ?? '',
      reason: map['reason'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'contentType': contentType,
      'parentId': parentId,
      'reportedBy': reportedBy,
      'reportedByName': reportedByName,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
      'status': status,
    };
  }
}