import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String userId;
  final DateTime createdAt;
  final int voteCount;
  final int answerCount;
  final String? bestAnswerId;
  final List<String> searchKeywords;

  QuestionModel({
    required this.id, 
    required this.title, 
    required this.description, 
    required this.tags, 
    required this.userId, 
    required this.createdAt, 
    required this.voteCount, 
    required this.answerCount,
    this.bestAnswerId, 
    required this.searchKeywords,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Question document does not exist');
    }

    return QuestionModel(
      id: doc.id, 
      title: data['title'] ?? '', 
      description: data['description'] ?? '', 
      
      tags: (data['tags'] is List)
        ? List<String>.from(data['tags'])
        : [data['tags'].toString()], 

      userId: data['userId'] ?? '', 

      createdAt: data['createdAt'] == null
        ? DateTime.now()
        : data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : data['createdAt'] as DateTime,  

      voteCount: data['voteCount'] ?? 0,
      answerCount: data['answerCount'] ?? 0,
      bestAnswerId: data['bestAnswerId'],
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []), 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'tags': tags,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'voteCount': voteCount,
      'answerCount': answerCount,
      'bestAnswerId': bestAnswerId,
      'searchKeywords': searchKeywords,
    };
  }

  QuestionModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    List<String>? searchKeywords,
    String? userId,
    int? voteCount,
    int? answerCount,
    DateTime? createdAt,
  }) {
    return QuestionModel(
      id: id ?? this.id, 
      title: title ?? this.title, 
      description: description ?? this.description, 
      tags: tags ?? this.tags,  
      userId: userId ?? this.userId, 
      createdAt: createdAt ?? this.createdAt,  
      voteCount: voteCount ?? this.voteCount,  
      answerCount: answerCount ?? this.answerCount, 
      searchKeywords: searchKeywords ?? this.searchKeywords, 
    );
  }
  
}