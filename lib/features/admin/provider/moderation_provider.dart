import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/models/question_model.dart';

final allQuestionsProvider = StreamProvider<List<QuestionModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('questions')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc)).toList());
});