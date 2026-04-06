import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String type; // new_answer, vote
  final String? voteType;
  final String questionId;
  final String? answerId;
  final bool isRead;
  final DateTime createdAt;
  final String? previewText;

  NotificationModel({ 
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.type,
    this.voteType,
    required this.questionId,
    required this.answerId,
    required this.isRead,
    required this.createdAt, 
    this.previewText,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {

    final createdAtRaw = map['createdAt'];

    DateTime createdAt;

    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else {
      createdAt = DateTime.now();
    }

    return NotificationModel(
      id: id, 
      senderId: map['senderId'], 
      senderName: map['senderName'] ?? 'User',
      receiverId: map['receiverId'],
      type: map['type'], 
      voteType: map['voteType'],
      questionId: map['questionId'],
      answerId:map['answerId'],
      isRead: map['isRead'] ?? false,
      createdAt: createdAt,
      previewText: map['previewText'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'type': type,
      'voteType': voteType,
      'questionId': questionId,
      'answerId': answerId,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
      'previewText': previewText,
    };
  }
}
